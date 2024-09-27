
require 'zip'

module AddressPostcodeLookup
  extend self

  GEO_DATA_SRC = Rails.root.join('db/fixtures/geo-data.json.zip')

  def run
    puts "running address postcode lookup"

    GeoEnclosure.destroy_all

    load_geo_data

    @bad_count = 0

    process_addresses_for Partner
    process_addresses_for Event

    puts "finished"
    puts "  #{GeoEnclosure.count} Geo Enclosures"
    puts "  bad_count=#{@bad_count}"
  end

  def process_addresses_for(klass)
    puts "processing #{klass.count} #{klass.name.pluralize}"

    klass.transaction do
      klass.all.each do |entity|
        next if entity.address_postcode.blank?

        postcode_text = entity.address_postcode.upcase.gsub(/\s+/, '')
        postcode_data = @postcodes[postcode_text]
        raise "postcode missing for '#{postcode_text}'" if postcode_data.blank?

        # puts postcode_data.to_json
        postcode_enclosures = postcode_data['enclosure_codes']
        entity.address_ward = find_or_create_geo_enclosure_for(postcode_enclosures)
        entity.save!
      end
    end
  end

  def load_geo_data
    data = nil
    
    puts "loading Geo Data from #{GEO_DATA_SRC}"

    Zip::File.open(GEO_DATA_SRC) do |zip|
      data = JSON.parse(zip.read('geo-data.json'))
    end

    @version = data['version']
    @enclosures = data['enclosures']
    @postcodes = data['postcodes']

    puts "  version: #{@version}"
    puts "  enclosures: #{@enclosures.count}"
    puts "  postcodes: #{@postcodes.count}"
  end

  def find_or_create_geo_enclosure_for(enclosure_list)
    return if enclosure_list.empty?

    first_ons_id = enclosure_list.first

    found = @enclosures[first_ons_id]
    # raise "could not find enclosure for ONS ID '#{first_ons_id}'" if found.blank?
    if found.blank?
      puts "bad ONS ID #{first_ons_id}, enclosure_list=#{enclosure_list.to_json}"
      @bad_count += 1
      return
    end

    @enclosures[first_ons_id]['model'] ||= GeoEnclosure.create!(
      name: found['name'],
      ons_id: first_ons_id,
      ons_version: @version,
      ons_type: found['type'],
      parent: find_or_create_geo_enclosure_for(enclosure_list[1..-1])
    )
  end
end

namespace :db do
  namespace :import do
    desc 'Loads and applies GeoEnclosures to partners and events'
    task address_postcode_lookup: :environment do
      AddressPostcodeLookup.run
    end
  end
end

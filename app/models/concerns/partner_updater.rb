require 'zip'

class PartnerUpdater

  class PostcodeLookup
    attr_reader :version
    attr_reader :enclosures
    attr_reader :postcodes

    def initialize(from_file)
      data = nil

      Zip::File.open(from_file) do |zip|
        data = JSON.parse(zip.read('geo-data.json'))
      end

      @version = data['version']
      @enclosures = data['enclosures']
      @postcodes = data['postcodes']
      # puts @postcodes.keys.to_json
    end

    def lookup_postcode(raw_text)
      raw_text = raw_text.to_s.upcase.gsub(/\s+/, '')
      return if raw_text.blank?

      postcode_data = @postcodes[raw_text]
      return if postcode_data.blank?

      postcode_enclosures = postcode_data['enclosure_codes']
      find_or_create_geo_enclosure_for postcode_enclosures
    end

    private

    def find_or_create_geo_enclosure_for(enclosure_list)
      return if enclosure_list.empty?

      first_ons_id = enclosure_list.first

      found = @enclosures[first_ons_id]
      raise "could not find enclosure for ONS ID '#{first_ons_id}'" if found.blank?

      @enclosures[first_ons_id]['model'] ||= GeoEnclosure.create!(
        name: found['name'],
        ons_id: first_ons_id,
        ons_version: @version,
        ons_type: found['type'],
        parent: find_or_create_geo_enclosure_for(enclosure_list[1..-1])
      )
    end
  end

  #
  #
  #

  attr_reader :partner
  attr_reader :postcode_db
  attr_reader :search_client

  def initialize(partner, postcode_db, search_client)
    @partner = partner
    @postcode_db = postcode_db
    @search_client = search_client
  end

  def update_and_save(new_values)
    Partner.transaction do

      update_fields new_values

      render_description_html

      scan_for_keywords

      reindex_text_fields

      lookup_postcode

      save!
    end
  end

  def update_fields(new_values)
    new_values.each do |field, value|
      partner[field] = value
    end
  end

  def save!
    partner.save!
  end


  def render_description_html
    return unless partner.description_changed?

    # TODO: maybe filter out HTML from text as well
    partner.description_html = Kramdown::Document.new(partner.description).to_html
  end

  def scan_for_keywords
    return unless partner.description_changed? || partner.summary_changed?

    partner_keyword_set = partner.partner_keywords.pluck(:keyword_id)

    # (not the fastest word scanner)
    all_partner_words = 
      [ partner.name, partner.description, partner.summary ].join(' ')
      .strip
      .downcase
      .split(/\b/)
      .delete_if { |word| word =~ /^\s+$/ }
      .uniq

    # add new/existing back again
    all_partner_words.each do |partner_word|
      found = Keyword.where(name: partner_word).first
      next if found.blank?

      # maybe add this
      partner.partner_keywords.build(keyword_id: found.id) unless partner_keyword_set.include?(found.id)

      # remove this from the delete set
      partner_keyword_set.delete found.id
    end

    partner.partner_keywords.where( keyword_id: partner_keyword_set ).destroy_all

    true
  end

  def reindex_text_fields
    return unless partner.description_changed? || partner.summary_changed? || partner.name_changed?
 
    search_client.index index: 'partners', id: partner[:id], body: partner, refresh: true
 
    # does this happen automatically?
    # what about deleting the partner, does that de-index automatically?
  end

  def lookup_postcode
    return unless partner.address_postcode_changed?

    if partner.address_postcode.blank?
      partner.address_ward = nil
      return
    end

    new_geo_enclosure = postcode_db.lookup_postcode(partner.address_postcode)
    if new_geo_enclosure.blank?
      puts "FIXME: do something here?"
      return
    end

    partner.address_ward = new_geo_enclosure
  end
end

__END__

I decided to use this pattern so I could keep the models thin, make the updater
scripts less complicated and hopefully make this logic testable in specs.

  This updates an entire model, which is used when importing partners, but we
also need to update keywords when they are added / removed and fix the postcode 
lookup code so when we have new updates to the postcode DB they will also be updated.

  so something like
- update keywords only (even if they have not changed in model)
- update postcodes (also even if they have not changed in model)

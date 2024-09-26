module PlacecalSnapshotImporter
  extend self

  def clean_db
    Partner.destroy_all
    Event.destroy_all
  end

  def import_partners
    path = Rails.root.join('db/fixtures/partners.json')
    puts "Importing partners from #{path}"

    @partners_by_placecal_id = {}

    data = JSON.parse(File.open(path).read)
    data['data']['partnersByTag'].each do |partner_data|
      partner_id = partner_data['id'].to_i
      partner_data['address'] ||= {}
      partner_data['contact'] ||= {}

      partner_name = partner_data['name']
      partner_summary = partner_data['summary']
      partner_description = partner_data['description']
      partner_logo_url = partner_data['logo']
      partner_url = partner_data['url']
      partner_address_street = partner_data['address']['streetAddress']
      partner_address_postcode = partner_data['address']['postalCode']
      partner_contact_email = partner_data['contact']['email']
      partner_contact_telephone = partner_data['contact']['telephone']

      @partners_by_placecal_id[partner_id] = 
        Partner.create!(
          placecal_id: partner_id, 
          name: partner_name, 
          description: partner_description,
          summary: partner_summary,
          contact_email: partner_contact_email,
          contact_telephone: partner_contact_telephone,
          url: partner_url,
          address_street: partner_address_street,
          address_postcode: partner_address_postcode,
          logo_url: partner_logo_url
        )
    end
  end
  
  def import_events
    path = Rails.root.join('db/fixtures/events.json')
    puts "Importing events from #{path}"

    event_table = {}

    data = JSON.parse(File.open(path).read)
    data['data']['eventsByFilter'].each do |event_data|

      organizer_id = event_data['organizer']['id'].to_i
      partner = @partners_by_placecal_id[organizer_id]
      raise "import_events: partner not found for organizer #{organizer_id}" if partner.blank?

      event_instance = {
        placecal_id: event_data['id'],
        starts_at: Time.zone.parse(event_data['startDate']),
        ends_at: Time.zone.parse(event_data['endDate'])
      }

      event_key = "#{organizer_id} #{event_data['name']}"

      if event_table.has_key?(event_key)
        event_table[event_key][:instances] << event_instance

      else
        event_data['address'] ||= {}

        event_table[event_key] = {
          event: {
            # placecal_id: event_data['id'],
            name: event_data['name'],
            summary: event_data['summary'],
            description: event_data['description'],
            organizer_placecal_id: organizer_id,
            address_street: event_data['address']['streetAddress'],
            address_postcode: event_data['address']['postalCode'],
            partner_id: partner.id
          },
          instances: [ event_instance ]
        }
      end
    end

    puts "Loaded #{event_table.count} unique events, processing..."

    event_table.values.each do |value|
      event_attributes = value[:event]
      instance_list = value[:instances]

      Event.transaction do
        event = Event.create!(event_attributes)
        instance_list.each do |instance_attributes|
          event.event_instances.create! instance_attributes
        end
      end
    end
  end

  def run
    clean_db

    import_partners

    import_events

    puts "Have created #{Partner.count} partners, #{Event.count} events and #{EventInstance.count} event instances"
  end
end

namespace :db do
  namespace :import do
    desc 'Imports partners from db fixture directory'
    task placecal_snapshot: :environment do
      PlacecalSnapshotImporter.run
    end
  end
end

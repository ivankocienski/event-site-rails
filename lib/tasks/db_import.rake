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

    data = JSON.parse(File.open(path).read)
    data['data']['eventsByFilter'].each do |event_data|
      organizer_id = event_data['organizer']['id'].to_i

      partner = @partners_by_placecal_id[organizer_id]
      raise "import_events: partner not found for organizer #{organizer_id}" if partner.blank?

      event_data['address'] ||= {}
      
      partner.events.create!(
        placecal_id: event_data['id'],
        name: event_data['name'],
        summary: event_data['summary'],
        description: event_data['description'],
        starts_at: Time.zone.parse(event_data['startDate']),
        ends_at: Time.zone.parse(event_data['endDate']),
        organizer_placecal_id: organizer_id,
        address_street: event_data['address']['streetAddress'],
        address_postcode: event_data['address']['postalCode']
      )

    end
  end

  def run
    clean_db

    import_partners

    import_events

    puts "Have created #{Partner.count} partners and #{Event.count} events"
  end
end

namespace :db do
  namespace :import do
    desc 'Imports partners from db fixture directory'
    task partners: :environment do
      PlacecalSnapshotImporter.run
    end
  end
end


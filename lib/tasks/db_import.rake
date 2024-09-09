namespace :db do
  namespace :import do
    desc 'Imports partners from db fixture directory'
    task partners: :environment do
      Partner.destroy_all

      path = Rails.root.join('db/fixtures/partners.json')
      puts "Importing partners from #{path}"

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

      puts "Have created #{Partner.count} partners"

    end
  end
end
    


module Factories
  def given_some_partners_exist
    data_path = Rails.root.join('spec/fixtures/live_data_sample.json')
    data = JSON.parse(File.open(data_path).read)

    data.each do |datum|
      Partner.create!(
        placecal_id: datum['id'], 
        name: datum['name'], 
        description: datum['description'],
        summary: datum['summary'],
        contact_email: datum['contact_email'],
        contact_telephone: datum['contact_telephone'],
        url: datum['url'],
        address_street: datum['address_street'],
        address_postcode: datum['address_postcode'],
        logo_url: datum['logo_url'] 
      )
    end
  end
end

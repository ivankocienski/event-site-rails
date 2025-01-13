
module PartnerImportUpdater
  extend self

  attr_accessor :postcode_db

  def process_from(source_file)
    if source_file.blank?
      logs "Error: missing source file"
      return
    end

    logs "Data Importer/Updater"
    logs "  using source_file #{source_file}"

    payload = JSON.parse(File.open(source_file).read)
    placecal_partners = payload['data']['partnersByTag']
    logs "  read #{placecal_partners.count} partners from placecal data dump"

    delete_partners = Set.new(Partner.pluck(:placecal_id))

    placecal_partners.each do |pc_partner|
      partner = create_or_update_partner(pc_partner)
      delete_partners.delete pc_partner['id']
    end

    Partner.where(placecal_id: delete_partners).destroy_all
  end

  def create_or_update_partner(loaded_data)
    placecal_id = loaded_data['id']
    partner = Partner.where(placecal_id:).first || Partner.new

    updater = PartnerUpdater.new(partner, postcode_db, search_client)

    fields = {
      placecal_id:       placecal_id,
      name:              loaded_data['name'],
      summary:           loaded_data['summary'],
      description:       loaded_data['description'],
      logo_url:          loaded_data['logo'],
      url:               loaded_data['url'],
      address_street:    nil,
      address_postcode:  nil,
      contact_email:     nil,
      contact_telephone: nil
    }

    if loaded_data['address'].present?
      fields[:address_street]   = loaded_data['address']['streetAddress']
      fields[:address_postcode] = loaded_data['address']['postalCode']
    end

    if loaded_data['contact'].present?
      fields[:contact_email]     = loaded_data['contact']['email']
      fields[:contact_telephone] = loaded_data['contact']['telephone']
    end

    updater.update_and_save fields

    updater.partner
  end

  def search_client
    AppSearchSystem.client
  end

  def logs(message)
    return if Rails.env.test?
    puts message
  end
end

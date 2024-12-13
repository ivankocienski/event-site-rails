
require_relative '../config/environment'

module DataImporterUpdaterTask
  extend self

  def run
    source_file = Dir.glob(
      Rails.root.join('/db/snapshots/*-snapshot.json')).sort.last
    raise "No snapshots found" if source_file.blank?

    process_from source_file
  end

  def process_from(source_file)
    logs "Data Importer/Updater"
    logs "  using source_file #{source_file}"

    payload = JSON.parse(File.open(source_file).read)
    placecal_partners = payload['data']['partnersByTag']
    logs "  read #{placecal_partners.count} partners from placecal data dump"

    delete_partners = Set.new(Partner.pluck(:placecal_id))

    placecal_partners.each do |pc_partner|
      partner = create_or_update_partner(pc_partner)
      remove_partners.delete pc_id
    end

    Partner.where(placecal_id: delete_partners).destroy_all
  end

  def create_or_update_partner(loaded_data)
    placecal_id = loaded_data['id']
    partner = Partner.where(placecal_id:).first
    partner ||= Partner.build(placecal_id:)

    partner.name = loaded_data['name']
    partner.summary = loaded_data['summary']
    partner.description = loaded_data['description']
    partner.logo_url = loaded_data['logo']
    partner.url = loaded_data['url']

    if loaded_data['address'].present?
      partner.address_street = loaded_data['address']['streetAddress']
      partner.address_postcode = loaded_data['address']['postalCode']
    else
      partner.address_street = nil
      partner.address_postcode = nil
    end

    if loaded_data['contact'].present?
      partner.contact_email = loaded_data['contact']['email']
      partner.contact_telephone = loaded_data['contact']['telephone']
    else
      partner.contact_email = nil
      partner.contact_telephone = nil
    end

    partner.save!

    partner
  end

  def load_placecal_data_partners(from_file)
  end

  def logs(message)
    return if Rails.env.test?
    puts message
  end
end

DataImporterUpdaterTask.run if $0 == __FILE__

__END__


require_relative '../config/environment'

module DataImporterUpdaterTask
  extend self

  def run
    source_file = Dir.glob(path_to('/db/snapshots/*-snapshot.json')).sort.last
    raise "No snapshots found" if source_file.blank?

    process_from source_file
  end

  def process_from(source_file)
    logs "Data Importer/Updater"
    logs "  using source_file #{source_file}"

    db_partners = load_db_partners
    logs "  loaded #{db_partners.count} existing partners"

    placecal_partners = load_placecal_data_partners source_file
    logs "  read #{placecal_partners.count} partners from placecal data dump"

    new_partners, update_partners, delete_partners = bin_partners(placecal_partners, db_partners)
    logs "  processed:"
    logs "       new #{new_partners.count}"
    logs "    update #{update_partners.count}"
    logs "    delete #{delete_partners.count}"

    # Partner.transaction do
    new_partners.each do |new_partner_id|
      Partner.create! do |partner|
        data = placecal_partners[new_partner_id]

        partner.placecal_id = new_partner_id
        partner.name = data['name']
        partner.summary = data['summary']
        partner.description = data['description']
        partner.logo_url = data['logo']
        partner.url = data['url']

        if data['address'].present?
          partner.address_street = data['address']['streetAddress']
          partner.address_postcode = data['address']['postalCode']
        end

        if data['contact'].present?
          partner.contact_email = data['contact']['email']
          partner.contact_telephone = data['contact']['telephone']
        end
      end
    end

    update_partners.each do |update_partner_id|
      db_partners[update_partner_id].tap do |partner|
        data = placecal_partners[update_partner_id]

        partner.name = data['name']
        partner.summary = data['summary']
        partner.description = data['description']
        partner.logo_url = data['logo']
        partner.url = data['url']

        if data['address'].present?
          partner.address_street = data['address']['streetAddress']
          partner.address_postcode = data['address']['postalCode']
        else
          partner.address_street = nil
          partner.address_postcode = nil
        end

        if data['contact'].present?
          partner.contact_email = data['contact']['email']
          partner.contact_telephone = data['contact']['telephone']
        else
          partner.contact_email = nil
          partner.contact_telephone = nil
        end

        partner.save!
      end
    end

    delete_partners.each do |delete_partner_id|
      partner = db_partners[delete_partner_id]
      partner.destroy
    end
  end

  def bin_partners(placecal_partners, db_partners)
    new_partners = Set.new
    update_partners = Set.new
    delete_partners = Set.new

    placecal_partners.each do |pc_id, pc_partner|
      if db_partners.has_key?(pc_id)
        update_partners << pc_id
      else
        new_partners << pc_id
      end
    end

    delete_partners = db_partners.keys - placecal_partners.keys

    [ new_partners, update_partners, delete_partners ]
  end

  def load_db_partners
    {}.tap do |db_partners|
      Partner.all.each do |partner|
        db_partners[partner.placecal_id] = partner
      end
    end
  end

  def load_placecal_data_partners(from_file)
    {}.tap do |placecal_partners|
      payload = JSON.parse(File.open(from_file).read)

      payload['data']['partnersByTag'].each do |pc|
        id = pc['id'].to_i
        placecal_partners[id] = pc
      end
    end
  end

  def path_to(file_path)
    @root_dir ||= File.expand_path(File.join(File.dirname(__FILE__), '..'))
    File.join(@root_dir, file_path)
  end

  def logs(message)
    return if Rails.env.test?
    puts message
  end
end

DataImporterUpdaterTask.run if $0 == __FILE__


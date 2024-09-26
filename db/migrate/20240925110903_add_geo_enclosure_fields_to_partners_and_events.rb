class AddGeoEnclosureFieldsToPartnersAndEvents < ActiveRecord::Migration[7.2]
  def change
    add_column :partners, :address_geo_enclosure_id, :integer
    add_column :events, :address_geo_enclosure_id, :integer

    add_index :partners, :address_geo_enclosure_id
    add_index :events, :address_geo_enclosure_id
  end
end

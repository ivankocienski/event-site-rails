class CreatePartners < ActiveRecord::Migration[7.2]
  def change
    create_table :partners do |t|
      t.integer :placecal_id, null: false
      t.string :name
      t.string :description
      t.string :summary
      t.string :contact_email
      t.string :contact_telephone
      t.string :url
      t.string :address_street
      t.string :address_postcode
      t.string :logo_url

      t.timestamps

      t.index ["placecal_id"], name: "index_partner_placecal_id", unique: true
    end
  end
end

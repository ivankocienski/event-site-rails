class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.integer :placecal_id, null: false
      t.string :name
      t.string :summary
      t.string :description
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :publisher_url
      t.integer :organizer_placecal_id
      t.string :address_street
      t.string :address_postcode

      t.integer :partner_id

      t.timestamps
    end
  end
end

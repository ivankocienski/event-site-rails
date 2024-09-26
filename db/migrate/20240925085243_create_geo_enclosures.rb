class CreateGeoEnclosures < ActiveRecord::Migration[7.2]
  def change
    create_table :geo_enclosures do |t|
      t.string :name
      t.string :ons_id, null: false
      t.integer :ons_version, null: false
      t.string :ons_type, null: false

      t.string :ancestry, null: false
      t.index  :ancestry

      # t.string :type, null: false  # STI?

      t.timestamps
    end
  end
end

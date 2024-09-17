class CreateEventInstances < ActiveRecord::Migration[7.2]
  def change
    create_table :event_instances do |t|
      t.integer :placecal_id, null: false
      t.references :event, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at

      t.timestamps
    end
  end
end

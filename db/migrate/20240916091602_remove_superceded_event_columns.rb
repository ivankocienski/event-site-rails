class RemoveSupercededEventColumns < ActiveRecord::Migration[7.2]
  def up
    remove_column :events, :placecal_id
    remove_column :events, :starts_at
    remove_column :events, :ends_at
  end

  def down
    # add_column :placecal_id, null: false
  end
end

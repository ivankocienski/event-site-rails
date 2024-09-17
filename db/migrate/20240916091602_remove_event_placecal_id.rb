class RemoveEventPlacecalId < ActiveRecord::Migration[7.2]
  def up
    remove_column :events, :placecal_id
  end

  def down
    # add_column :placecal_id, null: false
  end
end

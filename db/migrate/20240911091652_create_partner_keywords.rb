class CreatePartnerKeywords < ActiveRecord::Migration[7.2]
  def change
    create_table :partner_keywords do |t|
      t.references :partner, null: false
      t.references :keyword, null: false

      t.timestamps

      t.index ["partner_id", "keyword_id"], name: "index_partner_keywords_partner_id_keyword_id", unique: true
    end
  end
end

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_10_02_092038) do
  create_table "event_instances", force: :cascade do |t|
    t.integer "placecal_id", null: false
    t.integer "event_id", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_instances_on_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.string "summary"
    t.string "description"
    t.string "publisher_url"
    t.integer "organizer_placecal_id"
    t.string "address_street"
    t.string "address_postcode"
    t.integer "partner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "address_geo_enclosure_id"
    t.text "description_html"
    t.index ["address_geo_enclosure_id"], name: "index_events_on_address_geo_enclosure_id"
  end

  create_table "geo_enclosures", force: :cascade do |t|
    t.string "name"
    t.string "ons_id", null: false
    t.integer "ons_version", null: false
    t.string "ons_type", null: false
    t.string "ancestry", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ancestry"], name: "index_geo_enclosures_on_ancestry"
  end

  create_table "keywords", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "partner_keywords", force: :cascade do |t|
    t.integer "partner_id", null: false
    t.integer "keyword_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["keyword_id"], name: "index_partner_keywords_on_keyword_id"
    t.index ["partner_id", "keyword_id"], name: "index_partner_keywords_partner_id_keyword_id", unique: true
    t.index ["partner_id"], name: "index_partner_keywords_on_partner_id"
  end

  create_table "partners", force: :cascade do |t|
    t.integer "placecal_id", null: false
    t.string "name"
    t.string "description"
    t.string "summary"
    t.string "contact_email"
    t.string "contact_telephone"
    t.string "url"
    t.string "address_street"
    t.string "address_postcode"
    t.string "logo_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "address_geo_enclosure_id"
    t.text "description_html"
    t.index ["address_geo_enclosure_id"], name: "index_partners_on_address_geo_enclosure_id"
    t.index ["placecal_id"], name: "index_partner_placecal_id", unique: true
  end
end

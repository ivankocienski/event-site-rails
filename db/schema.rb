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

ActiveRecord::Schema[7.2].define(version: 2024_09_09_104013) do
  create_table "events", force: :cascade do |t|
    t.integer "placecal_id", null: false
    t.string "name"
    t.string "summary"
    t.string "description"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.string "publisher_url"
    t.integer "organizer_placecal_id"
    t.string "address_street"
    t.string "address_postcode"
    t.integer "partner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["placecal_id"], name: "index_partner_placecal_id", unique: true
  end
end

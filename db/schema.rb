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

ActiveRecord::Schema[8.1].define(version: 2026_07_01_020706) do
  create_table "comments", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "topic_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["topic_id"], name: "index_comments_on_topic_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "condominiums", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "service_listings", force: :cascade do |t|
    t.string "category", null: false
    t.integer "condominium_id", null: false
    t.string "contact_info"
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "upvotes_count", default: 0, null: false
    t.integer "user_id", null: false
    t.index ["condominium_id", "category"], name: "index_service_listings_on_condominium_id_and_category"
    t.index ["condominium_id"], name: "index_service_listings_on_condominium_id"
    t.index ["user_id"], name: "index_service_listings_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "topics", force: :cascade do |t|
    t.integer "condominium_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.string "topic_type", default: "discussion", null: false
    t.datetime "updated_at", null: false
    t.integer "upvotes_count", default: 0, null: false
    t.integer "user_id", null: false
    t.index ["condominium_id", "created_at"], name: "index_topics_on_condominium_id_and_created_at"
    t.index ["condominium_id"], name: "index_topics_on_condominium_id"
    t.index ["user_id"], name: "index_topics_on_user_id"
  end

  create_table "upvotes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "topic_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["topic_id"], name: "index_upvotes_on_topic_id"
    t.index ["user_id", "topic_id"], name: "index_upvotes_on_user_id_and_topic_id", unique: true
    t.index ["user_id"], name: "index_upvotes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "condominium_id", null: false
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "password_digest", null: false
    t.string "role", default: "resident", null: false
    t.datetime "updated_at", null: false
    t.index ["condominium_id"], name: "index_users_on_condominium_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "comments", "topics"
  add_foreign_key "comments", "users"
  add_foreign_key "service_listings", "condominiums"
  add_foreign_key "service_listings", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "topics", "condominiums"
  add_foreign_key "topics", "users"
  add_foreign_key "upvotes", "topics"
  add_foreign_key "upvotes", "users"
  add_foreign_key "users", "condominiums"
end

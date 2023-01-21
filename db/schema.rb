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

ActiveRecord::Schema[7.0].define(version: 2023_01_21_204521) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "campaign_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "campaign_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_campaign_memberships_on_campaign_id"
    t.index ["user_id"], name: "index_campaign_memberships_on_user_id"
  end

  create_table "campaigns", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "title", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_campaigns_on_user_id"
  end

  create_table "character_effects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "character_id"
    t.uuid "vehicle_id"
    t.uuid "fight_id", null: false
    t.string "title", null: false
    t.string "description"
    t.string "severity", default: "info", null: false
    t.string "change"
    t.string "action_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_effects_on_character_id"
    t.index ["fight_id"], name: "index_character_effects_on_fight_id"
    t.index ["vehicle_id"], name: "index_character_effects_on_vehicle_id"
  end

  create_table "characters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.integer "defense"
    t.integer "impairments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "color"
    t.uuid "user_id"
    t.jsonb "action_values"
    t.uuid "campaign_id"
    t.boolean "active", default: true, null: false
    t.index ["campaign_id"], name: "index_characters_on_campaign_id"
    t.index ["created_at"], name: "index_characters_on_created_at"
    t.index ["user_id"], name: "index_characters_on_user_id"
  end

  create_table "effects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "fight_id"
    t.uuid "user_id"
    t.integer "start_sequence"
    t.integer "end_sequence"
    t.integer "start_shot"
    t.integer "end_shot"
    t.string "severity"
    t.string "title"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fight_id"], name: "index_effects_on_fight_id"
    t.index ["user_id"], name: "index_effects_on_user_id"
  end

  create_table "fight_characters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "character_id"
    t.uuid "fight_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "shot"
    t.uuid "vehicle_id"
    t.index ["character_id"], name: "index_fight_characters_on_character_id"
    t.index ["fight_id"], name: "index_fight_characters_on_fight_id"
    t.index ["vehicle_id"], name: "index_fight_characters_on_vehicle_id"
  end

  create_table "fights", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sequence", default: 0, null: false
    t.uuid "campaign_id"
    t.boolean "active", default: true, null: false
    t.boolean "archived", default: false, null: false
    t.index ["campaign_id"], name: "index_fights_on_campaign_id"
  end

  create_table "invitations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "campaign_id", null: false
    t.uuid "user_id", null: false
    t.string "email"
    t.uuid "pending_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "maximum_count"
    t.integer "remaining_count"
    t.index ["campaign_id", "email"], name: "index_invitations_on_campaign_email", unique: true
    t.index ["campaign_id", "pending_user_id"], name: "index_invitations_on_campaign_and_pending_user", unique: true
    t.index ["campaign_id"], name: "index_invitations_on_campaign_id"
    t.index ["pending_user_id"], name: "index_invitations_on_pending_user_id"
    t.index ["user_id"], name: "index_invitations_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", null: false
    t.string "avatar_url"
    t.boolean "admin"
    t.boolean "gamemaster"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vehicles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.jsonb "action_values", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.string "color"
    t.integer "impairments"
    t.uuid "campaign_id"
    t.boolean "active", default: true, null: false
    t.index ["campaign_id"], name: "index_vehicles_on_campaign_id"
    t.index ["user_id"], name: "index_vehicles_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "campaign_memberships", "campaigns"
  add_foreign_key "campaign_memberships", "users"
  add_foreign_key "campaigns", "users"
  add_foreign_key "character_effects", "characters"
  add_foreign_key "character_effects", "fights"
  add_foreign_key "character_effects", "vehicles"
  add_foreign_key "characters", "campaigns"
  add_foreign_key "characters", "users"
  add_foreign_key "effects", "fights"
  add_foreign_key "effects", "users"
  add_foreign_key "fight_characters", "characters"
  add_foreign_key "fight_characters", "fights"
  add_foreign_key "fights", "campaigns"
  add_foreign_key "invitations", "campaigns"
  add_foreign_key "invitations", "users"
  add_foreign_key "invitations", "users", column: "pending_user_id"
  add_foreign_key "vehicles", "campaigns"
  add_foreign_key "vehicles", "users"
end

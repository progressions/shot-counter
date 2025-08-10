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

ActiveRecord::Schema[8.0].define(version: 2025_08_10_004814) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.uuid "record_id"
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
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

  create_table "advancements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "character_id", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_advancements_on_character_id"
  end

  create_table "attunements", force: :cascade do |t|
    t.uuid "character_id", null: false
    t.uuid "site_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_attunements_on_character_id"
    t.index ["site_id"], name: "index_attunements_on_site_id"
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
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index "lower((name)::text)", name: "index_campaigns_on_lower_name"
    t.index ["user_id"], name: "index_campaigns_on_user_id"
  end

  create_table "carries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "character_id", null: false
    t.uuid "weapon_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_carries_on_character_id"
    t.index ["weapon_id"], name: "index_carries_on_weapon_id"
  end

  create_table "character_effects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "character_id"
    t.uuid "vehicle_id"
    t.string "description"
    t.string "severity", default: "info", null: false
    t.string "change"
    t.string "action_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.uuid "shot_id"
    t.index ["character_id"], name: "index_character_effects_on_character_id"
    t.index ["shot_id"], name: "index_character_effects_on_shot_id"
    t.index ["vehicle_id"], name: "index_character_effects_on_vehicle_id"
  end

  create_table "character_schticks", force: :cascade do |t|
    t.uuid "character_id", null: false
    t.uuid "schtick_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id", "schtick_id"], name: "index_character_id_on_schtick_id", unique: true
    t.index ["character_id"], name: "index_character_schticks_on_character_id"
    t.index ["schtick_id"], name: "index_character_schticks_on_schtick_id"
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
    t.jsonb "description"
    t.jsonb "skills"
    t.uuid "faction_id"
    t.string "image_url"
    t.boolean "task"
    t.uuid "notion_page_id"
    t.datetime "last_synced_to_notion_at"
    t.string "summary"
    t.uuid "juncture_id"
    t.string "wealth"
    t.boolean "is_template"
    t.index "lower((name)::text)", name: "index_characters_on_lower_name"
    t.index ["action_values"], name: "index_characters_on_action_values", using: :gin
    t.index ["campaign_id"], name: "index_characters_on_campaign_id"
    t.index ["created_at"], name: "index_characters_on_created_at"
    t.index ["faction_id"], name: "index_characters_on_faction_id"
    t.index ["juncture_id"], name: "index_characters_on_juncture_id"
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
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["fight_id"], name: "index_effects_on_fight_id"
    t.index ["user_id"], name: "index_effects_on_user_id"
  end

  create_table "factions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "campaign_id", null: false
    t.boolean "active", default: true
    t.index "lower((name)::text)", name: "index_factions_on_lower_name"
    t.index ["campaign_id"], name: "index_factions_on_campaign_id"
  end

  create_table "fight_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "fight_id", null: false
    t.string "event_type"
    t.string "description"
    t.jsonb "details", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fight_id"], name: "index_fight_events_on_fight_id"
  end

  create_table "fights", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sequence", default: 0, null: false
    t.uuid "campaign_id"
    t.boolean "active", default: true, null: false
    t.boolean "archived", default: false, null: false
    t.text "description"
    t.bigint "server_id"
    t.string "fight_message_id"
    t.bigint "channel_id"
    t.datetime "started_at", precision: nil
    t.datetime "ended_at", precision: nil
    t.integer "season"
    t.integer "session"
    t.uuid "action_id"
    t.index "lower((name)::text)", name: "index_fights_on_lower_name"
    t.index ["campaign_id"], name: "index_fights_on_campaign_id"
  end

  create_table "image_positions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "positionable_type", null: false
    t.uuid "positionable_id", null: false
    t.string "context", null: false
    t.float "x_position", default: 0.0
    t.float "y_position", default: 0.0
    t.jsonb "style_overrides", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["positionable_type", "positionable_id", "context"], name: "index_image_positions_on_positionable_and_context", unique: true
    t.index ["positionable_type", "positionable_id"], name: "index_image_positions_on_positionable"
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

  create_table "junctures", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.boolean "active"
    t.uuid "faction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "notion_page_id"
    t.uuid "campaign_id"
    t.index "lower((name)::text)", name: "index_junctures_on_lower_name"
    t.index ["campaign_id"], name: "index_junctures_on_campaign_id"
    t.index ["faction_id"], name: "index_junctures_on_faction_id"
  end

  create_table "memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "party_id", null: false
    t.uuid "character_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "vehicle_id"
    t.index ["character_id"], name: "index_memberships_on_character_id"
    t.index ["party_id"], name: "index_memberships_on_party_id"
    t.index ["vehicle_id"], name: "index_memberships_on_vehicle_id"
  end

  create_table "parties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.uuid "campaign_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "faction_id"
    t.boolean "secret", default: false
    t.uuid "juncture_id"
    t.boolean "active", default: true, null: false
    t.index "lower((name)::text)", name: "index_parties_on_lower_name"
    t.index ["campaign_id"], name: "index_parties_on_campaign_id"
    t.index ["faction_id"], name: "index_parties_on_faction_id"
    t.index ["juncture_id"], name: "index_parties_on_juncture_id"
  end

  create_table "schticks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "campaign_id", null: false
    t.string "description"
    t.uuid "prerequisite_id"
    t.string "category"
    t.string "path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "color"
    t.string "image_url"
    t.boolean "bonus"
    t.jsonb "archetypes"
    t.string "name"
    t.index "lower((name)::text)", name: "index_schticks_on_lower_name"
    t.index ["campaign_id"], name: "index_schticks_on_campaign_id"
    t.index ["category", "name"], name: "index_schticks_on_category_and_name", unique: true
    t.index ["prerequisite_id"], name: "index_schticks_on_prerequisite_id"
  end

  create_table "shots", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "fight_id", null: false
    t.uuid "character_id"
    t.uuid "vehicle_id"
    t.integer "shot"
    t.string "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "count", default: 0
    t.string "color"
    t.uuid "driver_id"
    t.integer "impairments", default: 0
    t.uuid "driving_id"
    t.string "location"
    t.index ["character_id"], name: "index_shots_on_character_id"
    t.index ["driver_id"], name: "index_shots_on_driver_id"
    t.index ["driving_id"], name: "index_shots_on_driving_id"
    t.index ["fight_id"], name: "index_shots_on_fight_id"
    t.index ["vehicle_id"], name: "index_shots_on_vehicle_id"
  end

  create_table "sites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "campaign_id"
    t.string "name"
    t.uuid "faction_id"
    t.boolean "secret", default: false
    t.uuid "juncture_id"
    t.boolean "active", default: true, null: false
    t.index "lower((name)::text)", name: "index_sites_on_lower_name"
    t.index ["campaign_id", "name"], name: "index_sites_on_campaign_id_and_name", unique: true
    t.index ["campaign_id"], name: "index_sites_on_campaign_id"
    t.index ["faction_id"], name: "index_sites_on_faction_id"
    t.index ["juncture_id"], name: "index_sites_on_juncture_id"
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
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.uuid "current_campaign_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
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
    t.uuid "faction_id"
    t.string "image_url"
    t.boolean "task"
    t.uuid "notion_page_id"
    t.datetime "last_synced_to_notion_at"
    t.string "summary"
    t.uuid "juncture_id"
    t.jsonb "description"
    t.index "lower((name)::text)", name: "index_vehicles_on_lower_name"
    t.index ["campaign_id"], name: "index_vehicles_on_campaign_id"
    t.index ["faction_id"], name: "index_vehicles_on_faction_id"
    t.index ["juncture_id"], name: "index_vehicles_on_juncture_id"
    t.index ["user_id"], name: "index_vehicles_on_user_id"
  end

  create_table "weapons", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "campaign_id", null: false
    t.string "name", null: false
    t.string "description"
    t.integer "damage", null: false
    t.integer "concealment"
    t.integer "reload_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "juncture"
    t.integer "mook_bonus", default: 0, null: false
    t.string "category"
    t.boolean "kachunk"
    t.string "image_url"
    t.index "lower((name)::text)", name: "index_weapons_on_lower_name"
    t.index ["campaign_id", "name"], name: "index_weapons_on_campaign_id_and_name", unique: true
    t.index ["campaign_id"], name: "index_weapons_on_campaign_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "advancements", "characters"
  add_foreign_key "attunements", "characters"
  add_foreign_key "attunements", "sites"
  add_foreign_key "campaign_memberships", "campaigns"
  add_foreign_key "campaign_memberships", "users"
  add_foreign_key "campaigns", "users"
  add_foreign_key "carries", "characters"
  add_foreign_key "carries", "weapons"
  add_foreign_key "character_effects", "characters"
  add_foreign_key "character_effects", "shots"
  add_foreign_key "character_effects", "vehicles"
  add_foreign_key "character_schticks", "characters"
  add_foreign_key "character_schticks", "schticks"
  add_foreign_key "characters", "campaigns"
  add_foreign_key "characters", "factions"
  add_foreign_key "characters", "junctures"
  add_foreign_key "characters", "users"
  add_foreign_key "effects", "fights"
  add_foreign_key "effects", "users"
  add_foreign_key "factions", "campaigns"
  add_foreign_key "fight_events", "fights"
  add_foreign_key "fights", "campaigns"
  add_foreign_key "invitations", "campaigns"
  add_foreign_key "invitations", "users"
  add_foreign_key "invitations", "users", column: "pending_user_id"
  add_foreign_key "junctures", "campaigns"
  add_foreign_key "junctures", "factions"
  add_foreign_key "memberships", "characters"
  add_foreign_key "memberships", "parties"
  add_foreign_key "memberships", "vehicles"
  add_foreign_key "parties", "campaigns"
  add_foreign_key "parties", "factions"
  add_foreign_key "parties", "junctures"
  add_foreign_key "schticks", "campaigns"
  add_foreign_key "schticks", "schticks", column: "prerequisite_id"
  add_foreign_key "shots", "characters"
  add_foreign_key "shots", "fights"
  add_foreign_key "shots", "shots", column: "driver_id"
  add_foreign_key "shots", "shots", column: "driving_id"
  add_foreign_key "shots", "vehicles"
  add_foreign_key "sites", "campaigns"
  add_foreign_key "sites", "factions"
  add_foreign_key "sites", "junctures"
  add_foreign_key "users", "campaigns", column: "current_campaign_id"
  add_foreign_key "vehicles", "campaigns"
  add_foreign_key "vehicles", "factions"
  add_foreign_key "vehicles", "junctures"
  add_foreign_key "vehicles", "users"
  add_foreign_key "weapons", "campaigns"
end

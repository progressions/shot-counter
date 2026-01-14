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

ActiveRecord::Schema[8.0].define(version: 2026_01_14_133545) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "oban_job_state", ["available", "scheduled", "executing", "retryable", "completed", "discarded", "cancelled"]

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.uuid "record_id"
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "name", "record_id"], name: "index_active_storage_attachments_on_record_type_name_id"
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

  create_table "ai_credentials", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "provider", limit: 255, null: false
    t.binary "api_key_encrypted"
    t.binary "access_token_encrypted"
    t.binary "refresh_token_encrypted"
    t.datetime "token_expires_at", precision: 0
    t.datetime "created_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.string "status", limit: 255, default: "active", null: false
    t.string "status_message", limit: 255
    t.datetime "status_updated_at", precision: 0
    t.index ["status"], name: "ai_credentials_status_index"
    t.index ["user_id", "provider"], name: "ai_credentials_user_id_provider_index", unique: true
    t.index ["user_id"], name: "ai_credentials_user_id_index"
  end

  create_table "attunements", force: :cascade do |t|
    t.uuid "character_id", null: false
    t.uuid "site_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_attunements_on_character_id"
    t.index ["site_id"], name: "index_attunements_on_site_id"
    t.unique_constraint ["character_id", "site_id"], name: "attunements_character_id_site_id_index"
  end

  create_table "campaign_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "campaign_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "user_id"], name: "index_campaign_memberships_on_campaign_id_and_user_id"
    t.index ["campaign_id"], name: "index_campaign_memberships_on_campaign_id"
    t.index ["user_id", "created_at"], name: "index_campaign_memberships_on_user_and_created"
    t.index ["user_id"], name: "index_campaign_memberships_on_user_id"
  end

  create_table "campaigns", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.boolean "active", default: true, null: false
    t.boolean "is_master_template", default: false, null: false
    t.datetime "seeded_at"
    t.string "seeding_status", limit: 255
    t.integer "seeding_images_total", default: 0
    t.integer "seeding_images_completed", default: 0
    t.string "batch_image_status", limit: 255
    t.integer "batch_images_total", default: 0
    t.integer "batch_images_completed", default: 0
    t.boolean "ai_generation_enabled", default: true, null: false
    t.string "ai_provider", limit: 255
    t.datetime "ai_credits_exhausted_at", precision: 0
    t.string "ai_credits_exhausted_provider", limit: 255
    t.datetime "ai_credits_exhausted_notified_at", precision: 0
    t.boolean "at_a_glance", default: false, null: false
    t.binary "notion_access_token"
    t.string "notion_bot_id", limit: 255
    t.string "notion_workspace_name", limit: 255
    t.string "notion_workspace_icon", limit: 255
    t.jsonb "notion_owner"
    t.jsonb "notion_database_ids", default: {}
    t.index "lower((name)::text)", name: "index_campaigns_on_lower_name"
    t.index ["active", "created_at"], name: "index_campaigns_on_active_and_created_at"
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
    t.boolean "task"
    t.uuid "notion_page_id"
    t.datetime "last_synced_to_notion_at"
    t.string "summary"
    t.uuid "juncture_id"
    t.string "wealth"
    t.boolean "is_template"
    t.jsonb "status", default: []
    t.boolean "extending", default: false, null: false
    t.uuid "equipped_weapon_id"
    t.boolean "at_a_glance", default: false, null: false
    t.index "lower((name)::text)", name: "index_characters_on_lower_name"
    t.index ["action_values"], name: "index_characters_on_action_values", using: :gin
    t.index ["active"], name: "index_characters_on_active"
    t.index ["campaign_id", "active", "created_at"], name: "index_characters_on_campaign_active_created"
    t.index ["campaign_id", "active"], name: "index_characters_on_campaign_id_and_active"
    t.index ["campaign_id"], name: "index_characters_on_campaign_id"
    t.index ["created_at"], name: "index_characters_on_created_at"
    t.index ["equipped_weapon_id"], name: "characters_equipped_weapon_id_index"
    t.index ["faction_id"], name: "index_characters_on_faction_id"
    t.index ["juncture_id"], name: "index_characters_on_juncture_id"
    t.index ["notion_page_id"], name: "characters_notion_page_id_index", unique: true, where: "(notion_page_id IS NOT NULL)"
    t.index ["status"], name: "index_characters_on_status", using: :gin
    t.index ["user_id"], name: "index_characters_on_user_id"
  end

  create_table "chase_relationships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "pursuer_id", null: false
    t.uuid "evader_id", null: false
    t.uuid "fight_id", null: false
    t.string "position", default: "far", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["evader_id"], name: "index_chase_relationships_on_evader_id"
    t.index ["fight_id"], name: "index_chase_relationships_on_fight_id"
    t.index ["pursuer_id", "evader_id", "fight_id"], name: "unique_active_relationship", unique: true, where: "(active = true)"
    t.index ["pursuer_id"], name: "index_chase_relationships_on_pursuer_id"
    t.check_constraint "\"position\"::text = ANY (ARRAY['near'::character varying, 'far'::character varying]::text[])", name: "position_values"
    t.check_constraint "pursuer_id <> evader_id", name: "different_shots"
  end

  create_table "cli_authorization_codes", id: :uuid, default: nil, force: :cascade do |t|
    t.string "code", limit: 255, null: false
    t.boolean "approved", default: false, null: false
    t.datetime "expires_at", precision: 0, null: false
    t.uuid "user_id"
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.index ["code"], name: "cli_authorization_codes_code_index", unique: true
    t.index ["expires_at"], name: "cli_authorization_codes_expires_at_index"
    t.index ["user_id"], name: "cli_authorization_codes_user_id_index"
  end

  create_table "cli_sessions", id: :uuid, default: nil, force: :cascade do |t|
    t.string "ip_address", limit: 255
    t.string "user_agent", limit: 255
    t.datetime "last_seen_at", precision: 0
    t.uuid "user_id", null: false
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.index ["inserted_at"], name: "cli_sessions_inserted_at_index"
    t.index ["user_id"], name: "cli_sessions_user_id_index"
  end

  create_table "discord_server_settings", id: :uuid, default: nil, force: :cascade do |t|
    t.bigint "server_id", null: false
    t.uuid "current_campaign_id"
    t.uuid "current_fight_id"
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.index ["current_campaign_id"], name: "discord_server_settings_current_campaign_id_index"
    t.index ["current_fight_id"], name: "discord_server_settings_current_fight_id_index"
    t.index ["server_id"], name: "discord_server_settings_server_id_index", unique: true
  end

  create_table "ecto_migrations", primary_key: "version", id: :bigint, default: nil, force: :cascade do |t|
    t.datetime "inserted_at", precision: 0
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
    t.boolean "active", default: true, null: false
    t.string "notion_page_id", limit: 255
    t.datetime "last_synced_to_notion_at", precision: 0
    t.boolean "at_a_glance", default: false, null: false
    t.index "lower((name)::text)", name: "index_factions_on_lower_name"
    t.index ["active"], name: "index_factions_on_active"
    t.index ["campaign_id", "active"], name: "index_factions_on_campaign_id_and_active"
    t.index ["campaign_id"], name: "index_factions_on_campaign_id"
    t.index ["notion_page_id"], name: "factions_notion_page_id_index", unique: true, where: "(notion_page_id IS NOT NULL)"
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
    t.uuid "user_id"
    t.boolean "solo_mode", default: false, null: false
    t.uuid "solo_player_character_ids", array: true
    t.string "solo_behavior_type", limit: 255, default: "simple"
    t.boolean "at_a_glance", default: false, null: false
    t.index "lower((name)::text)", name: "index_fights_on_lower_name"
    t.index ["active"], name: "index_fights_on_active"
    t.index ["campaign_id", "active"], name: "index_fights_on_campaign_id_and_active"
    t.index ["campaign_id"], name: "index_fights_on_campaign_id"
    t.index ["user_id"], name: "fights_user_id_index"
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
    t.boolean "redeemed", default: false, null: false
    t.datetime "redeemed_at", precision: 0
    t.index ["campaign_id", "email"], name: "index_invitations_on_campaign_email", unique: true
    t.index ["campaign_id", "pending_user_id"], name: "index_invitations_on_campaign_and_pending_user", unique: true
    t.index ["campaign_id"], name: "index_invitations_on_campaign_id"
    t.index ["pending_user_id"], name: "index_invitations_on_pending_user_id"
    t.index ["user_id"], name: "index_invitations_on_user_id"
  end

  create_table "junctures", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.boolean "active", default: true, null: false
    t.uuid "faction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "notion_page_id"
    t.uuid "campaign_id"
    t.boolean "at_a_glance", default: false, null: false
    t.index "lower((name)::text)", name: "index_junctures_on_lower_name"
    t.index ["active"], name: "index_junctures_on_active"
    t.index ["campaign_id", "active"], name: "index_junctures_on_campaign_id_and_active"
    t.index ["campaign_id"], name: "index_junctures_on_campaign_id"
    t.index ["faction_id"], name: "index_junctures_on_faction_id"
  end

  create_table "media_images", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "campaign_id", null: false
    t.string "source", limit: 255, null: false
    t.string "entity_type", limit: 255
    t.uuid "entity_id"
    t.string "status", limit: 255, default: "orphan", null: false
    t.bigint "active_storage_blob_id"
    t.string "imagekit_file_id", limit: 255, null: false
    t.string "imagekit_url", limit: 255, null: false
    t.string "imagekit_file_path", limit: 255
    t.string "filename", limit: 255
    t.string "content_type", limit: 255, default: "image/jpeg"
    t.integer "byte_size"
    t.integer "width"
    t.integer "height"
    t.text "prompt"
    t.string "ai_provider", limit: 255
    t.uuid "generated_by_id"
    t.uuid "uploaded_by_id"
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.jsonb "ai_tags", array: true
    t.index ["active_storage_blob_id"], name: "media_images_active_storage_blob_id_index"
    t.index ["ai_tags"], name: "media_images_ai_tags_index", using: :gin
    t.index ["campaign_id"], name: "media_images_campaign_id_index"
    t.index ["entity_type", "entity_id"], name: "media_images_entity_type_entity_id_index"
    t.index ["imagekit_file_id"], name: "media_images_imagekit_file_id_index", unique: true
    t.index ["source"], name: "media_images_source_index"
    t.index ["status"], name: "media_images_status_index"
  end

  create_table "memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "party_id", null: false
    t.uuid "character_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "vehicle_id"
    t.string "role", limit: 255
    t.integer "default_mook_count"
    t.integer "position"
    t.index ["character_id"], name: "index_memberships_on_character_id"
    t.index ["party_id", "position"], name: "memberships_party_id_position_index"
    t.index ["party_id", "role"], name: "memberships_party_id_role_index"
    t.index ["party_id"], name: "index_memberships_on_party_id"
    t.index ["vehicle_id"], name: "index_memberships_on_vehicle_id"
    t.unique_constraint ["party_id", "vehicle_id"], name: "memberships_party_id_vehicle_id_index"
  end

  create_table "notifications", id: :uuid, default: nil, force: :cascade do |t|
    t.string "type", limit: 255, null: false
    t.string "title", limit: 255, null: false
    t.text "message"
    t.jsonb "payload", default: {}
    t.datetime "read_at", precision: 0
    t.datetime "dismissed_at", precision: 0
    t.uuid "user_id", null: false
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.index ["user_id", "dismissed_at"], name: "notifications_user_id_dismissed_at_index"
    t.index ["user_id"], name: "notifications_user_id_index"
  end

  create_table "notion_sync_logs", id: :uuid, default: nil, force: :cascade do |t|
    t.string "status", limit: 255, null: false
    t.jsonb "payload", default: {}
    t.jsonb "response", default: {}
    t.text "error_message"
    t.uuid "character_id"
    t.datetime "created_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.string "entity_type", limit: 255, null: false
    t.uuid "entity_id", null: false
    t.index ["character_id"], name: "notion_sync_logs_character_id_index"
    t.index ["created_at"], name: "notion_sync_logs_created_at_index"
    t.index ["entity_type", "entity_id"], name: "notion_sync_logs_entity_type_entity_id_index"
  end

  create_table "oban_jobs", comment: "12", force: :cascade do |t|
    t.enum "state", default: "available", null: false, enum_type: "oban_job_state"
    t.text "queue", default: "default", null: false
    t.text "worker", null: false
    t.jsonb "args", default: {}, null: false
    t.jsonb "errors", null: false, array: true
    t.integer "attempt", default: 0, null: false
    t.integer "max_attempts", default: 20, null: false
    t.datetime "inserted_at", precision: nil, default: -> { "timezone('UTC'::text, now())" }, null: false
    t.datetime "scheduled_at", precision: nil, default: -> { "timezone('UTC'::text, now())" }, null: false
    t.datetime "attempted_at", precision: nil
    t.datetime "completed_at", precision: nil
    t.text "attempted_by", array: true
    t.datetime "discarded_at", precision: nil
    t.integer "priority", default: 0, null: false
    t.text "tags", array: true
    t.jsonb "meta", default: {}
    t.datetime "cancelled_at", precision: nil
    t.index ["args"], name: "oban_jobs_args_index", using: :gin
    t.index ["meta"], name: "oban_jobs_meta_index", using: :gin
    t.index ["state", "queue", "priority", "scheduled_at", "id"], name: "oban_jobs_state_queue_priority_scheduled_at_id_index"
    t.check_constraint "attempt >= 0 AND attempt <= max_attempts", name: "attempt_range"
    t.check_constraint "char_length(queue) > 0 AND char_length(queue) < 128", name: "queue_length"
    t.check_constraint "char_length(worker) > 0 AND char_length(worker) < 128", name: "worker_length"
    t.check_constraint "max_attempts > 0", name: "positive_max_attempts"
  end

  add_check_constraint "oban_jobs", "priority >= 0", name: "non_negative_priority", validate: false

  create_table "oban_peers", primary_key: "name", id: :text, force: :cascade do |t|
    t.text "node", null: false
    t.datetime "started_at", precision: nil, null: false
    t.datetime "expires_at", precision: nil, null: false
  end

  create_table "onboarding_progresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.datetime "first_campaign_created_at", precision: nil
    t.datetime "first_character_created_at", precision: nil
    t.datetime "first_fight_created_at", precision: nil
    t.datetime "first_faction_created_at", precision: nil
    t.datetime "first_party_created_at", precision: nil
    t.datetime "first_site_created_at", precision: nil
    t.datetime "congratulations_dismissed_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "first_campaign_activated_at"
    t.index ["user_id"], name: "index_onboarding_progresses_on_user_id"
  end

  create_table "parties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.uuid "campaign_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "faction_id"
    t.uuid "juncture_id"
    t.boolean "active", default: true, null: false
    t.string "notion_page_id", limit: 255
    t.datetime "last_synced_to_notion_at", precision: 0
    t.boolean "at_a_glance", default: false, null: false
    t.index "lower((name)::text)", name: "index_parties_on_lower_name"
    t.index ["active"], name: "index_parties_on_active"
    t.index ["campaign_id", "active"], name: "index_parties_on_campaign_id_and_active"
    t.index ["campaign_id"], name: "index_parties_on_campaign_id"
    t.index ["faction_id"], name: "index_parties_on_faction_id"
    t.index ["juncture_id"], name: "index_parties_on_juncture_id"
    t.index ["notion_page_id"], name: "parties_notion_page_id_index", unique: true, where: "(notion_page_id IS NOT NULL)"
  end

  create_table "player_view_tokens", id: :uuid, default: nil, force: :cascade do |t|
    t.string "token", limit: 255, null: false
    t.datetime "expires_at", precision: 0, null: false
    t.boolean "used", default: false, null: false
    t.datetime "used_at", precision: 0
    t.uuid "fight_id", null: false
    t.uuid "character_id", null: false
    t.uuid "user_id", null: false
    t.datetime "created_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.index ["character_id"], name: "player_view_tokens_character_id_index"
    t.index ["expires_at"], name: "player_view_tokens_expires_at_index"
    t.index ["fight_id"], name: "player_view_tokens_fight_id_index"
    t.index ["token"], name: "player_view_tokens_token_index", unique: true
    t.index ["user_id"], name: "player_view_tokens_user_id_index"
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
    t.boolean "bonus"
    t.jsonb "archetypes"
    t.string "name"
    t.boolean "active", default: true, null: false
    t.boolean "at_a_glance", default: false, null: false
    t.index "lower((name)::text)", name: "index_schticks_on_lower_name"
    t.index ["active"], name: "index_schticks_on_active"
    t.index ["campaign_id", "active"], name: "index_schticks_on_campaign_id_and_active"
    t.index ["campaign_id"], name: "index_schticks_on_campaign_id"
    t.index ["category", "name", "campaign_id"], name: "index_schticks_on_category_name_and_campaign", unique: true
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
    t.boolean "was_rammed_or_damaged", default: false, null: false
    t.index ["character_id"], name: "index_shots_on_character_id"
    t.index ["driver_id"], name: "index_shots_on_driver_id"
    t.index ["driving_id"], name: "index_shots_on_driving_id"
    t.index ["fight_id"], name: "index_shots_on_fight_id"
    t.index ["vehicle_id"], name: "index_shots_on_vehicle_id"
    t.index ["was_rammed_or_damaged"], name: "index_shots_on_was_rammed_or_damaged"
  end

  create_table "sites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "campaign_id"
    t.string "name"
    t.uuid "faction_id"
    t.uuid "juncture_id"
    t.boolean "active", default: true, null: false
    t.string "notion_page_id", limit: 255
    t.datetime "last_synced_to_notion_at", precision: 0
    t.boolean "at_a_glance", default: false, null: false
    t.index "lower((name)::text)", name: "index_sites_on_lower_name"
    t.index ["active"], name: "index_sites_on_active"
    t.index ["campaign_id", "active"], name: "index_sites_on_campaign_id_and_active"
    t.index ["campaign_id", "name"], name: "index_sites_on_campaign_id_and_name", unique: true
    t.index ["campaign_id"], name: "index_sites_on_campaign_id"
    t.index ["faction_id"], name: "index_sites_on_faction_id"
    t.index ["juncture_id"], name: "index_sites_on_juncture_id"
    t.index ["notion_page_id"], name: "sites_notion_page_id_index", unique: true, where: "(notion_page_id IS NOT NULL)"
  end

  create_table "swerves", id: :uuid, default: nil, force: :cascade do |t|
    t.string "username", limit: 255, null: false
    t.integer "positives_sum", null: false
    t.integer "positives_rolls", null: false, array: true
    t.integer "negatives_sum", null: false
    t.integer "negatives_rolls", null: false, array: true
    t.integer "total", null: false
    t.boolean "boxcars", default: false, null: false
    t.datetime "rolled_at", precision: 0, null: false
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.index ["rolled_at"], name: "swerves_rolled_at_index"
    t.index ["username"], name: "swerves_username_index"
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
    t.string "name"
    t.boolean "active", default: true, null: false
    t.uuid "pending_invitation_id"
    t.bigint "discord_id"
    t.uuid "current_character_id"
    t.boolean "at_a_glance", default: false, null: false
    t.index "lower((name)::text)", name: "index_users_on_lower_name"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["current_character_id"], name: "users_current_character_id_index"
    t.index ["discord_id"], name: "users_discord_id_index", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["pending_invitation_id"], name: "index_users_on_pending_invitation_id"
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
    t.boolean "task"
    t.uuid "notion_page_id"
    t.datetime "last_synced_to_notion_at"
    t.string "summary"
    t.uuid "juncture_id"
    t.jsonb "description"
    t.boolean "at_a_glance", default: false, null: false
    t.index "lower((name)::text)", name: "index_vehicles_on_lower_name"
    t.index ["active"], name: "index_vehicles_on_active"
    t.index ["campaign_id", "active", "created_at"], name: "index_vehicles_on_campaign_active_created"
    t.index ["campaign_id", "active"], name: "index_vehicles_on_campaign_id_and_active"
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
    t.boolean "active", default: true, null: false
    t.boolean "at_a_glance", default: false, null: false
    t.index "lower((name)::text)", name: "index_weapons_on_lower_name"
    t.index ["active"], name: "index_weapons_on_active"
    t.index ["campaign_id", "active"], name: "index_weapons_on_campaign_id_and_active"
    t.index ["campaign_id", "name"], name: "index_weapons_on_campaign_id_and_name", unique: true
    t.index ["campaign_id"], name: "index_weapons_on_campaign_id"
  end

  create_table "webauthn_challenges", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid "user_id"
    t.binary "challenge", null: false
    t.string "challenge_type", limit: 255, null: false
    t.datetime "expires_at", precision: 0, null: false
    t.boolean "used", default: false, null: false
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.index ["expires_at"], name: "webauthn_challenges_expires_at_index"
    t.index ["user_id"], name: "webauthn_challenges_user_id_index"
  end

  create_table "webauthn_credentials", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.binary "credential_id", null: false
    t.binary "public_key", null: false
    t.bigint "sign_count", default: 0, null: false
    t.string "transports", limit: 255, array: true
    t.boolean "backed_up", default: false
    t.boolean "backup_eligible", default: false
    t.string "attestation_type", limit: 255
    t.string "name", limit: 255, null: false
    t.datetime "last_used_at", precision: 0
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.index ["credential_id"], name: "webauthn_credentials_credential_id_index", unique: true
    t.index ["user_id"], name: "webauthn_credentials_user_id_index"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "advancements", "characters"
  add_foreign_key "ai_credentials", "users", name: "ai_credentials_user_id_fkey", on_delete: :cascade
  add_foreign_key "attunements", "characters"
  add_foreign_key "attunements", "sites"
  add_foreign_key "campaign_memberships", "campaigns"
  add_foreign_key "campaign_memberships", "users"
  add_foreign_key "campaigns", "users"
  add_foreign_key "carries", "characters"
  add_foreign_key "carries", "weapons"
  add_foreign_key "character_effects", "characters"
  add_foreign_key "character_effects", "shots", name: "character_effects_shot_id_fkey", on_delete: :cascade
  add_foreign_key "character_effects", "vehicles"
  add_foreign_key "character_schticks", "characters"
  add_foreign_key "character_schticks", "schticks"
  add_foreign_key "characters", "campaigns"
  add_foreign_key "characters", "factions"
  add_foreign_key "characters", "junctures"
  add_foreign_key "characters", "users"
  add_foreign_key "characters", "weapons", column: "equipped_weapon_id", name: "characters_equipped_weapon_id_fkey", on_delete: :nullify
  add_foreign_key "chase_relationships", "fights"
  add_foreign_key "chase_relationships", "shots", column: "evader_id", name: "chase_relationships_evader_id_fkey", on_delete: :cascade
  add_foreign_key "chase_relationships", "shots", column: "pursuer_id", name: "chase_relationships_pursuer_id_fkey", on_delete: :cascade
  add_foreign_key "chase_relationships", "vehicles", column: "evader_id"
  add_foreign_key "cli_authorization_codes", "users", name: "cli_authorization_codes_user_id_fkey", on_delete: :cascade
  add_foreign_key "cli_sessions", "users", name: "cli_sessions_user_id_fkey", on_delete: :cascade
  add_foreign_key "discord_server_settings", "campaigns", column: "current_campaign_id", name: "discord_server_settings_current_campaign_id_fkey", on_delete: :nullify
  add_foreign_key "discord_server_settings", "fights", column: "current_fight_id", name: "discord_server_settings_current_fight_id_fkey", on_delete: :nullify
  add_foreign_key "effects", "fights"
  add_foreign_key "effects", "users"
  add_foreign_key "factions", "campaigns"
  add_foreign_key "fight_events", "fights"
  add_foreign_key "fights", "campaigns"
  add_foreign_key "fights", "users", name: "fights_user_id_fkey", on_delete: :nullify
  add_foreign_key "invitations", "campaigns"
  add_foreign_key "invitations", "users"
  add_foreign_key "invitations", "users", column: "pending_user_id"
  add_foreign_key "junctures", "campaigns"
  add_foreign_key "junctures", "factions"
  add_foreign_key "media_images", "campaigns", name: "media_images_campaign_id_fkey", on_delete: :cascade
  add_foreign_key "media_images", "users", column: "generated_by_id", name: "media_images_generated_by_id_fkey", on_delete: :nullify
  add_foreign_key "media_images", "users", column: "uploaded_by_id", name: "media_images_uploaded_by_id_fkey", on_delete: :nullify
  add_foreign_key "memberships", "characters"
  add_foreign_key "memberships", "parties"
  add_foreign_key "memberships", "vehicles"
  add_foreign_key "notifications", "users", name: "notifications_user_id_fkey", on_delete: :cascade
  add_foreign_key "notion_sync_logs", "characters", name: "notion_sync_logs_character_id_fkey", on_delete: :cascade
  add_foreign_key "onboarding_progresses", "users"
  add_foreign_key "parties", "campaigns"
  add_foreign_key "parties", "factions"
  add_foreign_key "parties", "junctures"
  add_foreign_key "player_view_tokens", "characters", name: "player_view_tokens_character_id_fkey", on_delete: :cascade
  add_foreign_key "player_view_tokens", "fights", name: "player_view_tokens_fight_id_fkey", on_delete: :cascade
  add_foreign_key "player_view_tokens", "users", name: "player_view_tokens_user_id_fkey", on_delete: :cascade
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
  add_foreign_key "users", "characters", column: "current_character_id", name: "users_current_character_id_fkey", on_delete: :nullify
  add_foreign_key "vehicles", "campaigns"
  add_foreign_key "vehicles", "factions"
  add_foreign_key "vehicles", "junctures"
  add_foreign_key "vehicles", "users"
  add_foreign_key "weapons", "campaigns"
  add_foreign_key "webauthn_challenges", "users", name: "webauthn_challenges_user_id_fkey", on_delete: :cascade
  add_foreign_key "webauthn_credentials", "users", name: "webauthn_credentials_user_id_fkey", on_delete: :cascade
end

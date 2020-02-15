# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_02_10_143323) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_stat_statements"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_admin_comments", id: :serial, force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_id", null: false
    t.string "resource_type", null: false
    t.string "author_type"
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

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
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.float "latitude"
    t.float "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.string "app_version"
    t.string "os_version"
    t.string "platform"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "base_leaderboards", force: :cascade do |t|
    t.bigint "challenge_id"
    t.bigint "challenge_round_id"
    t.integer "row_num"
    t.integer "previous_row_num"
    t.string "slug"
    t.string "name"
    t.integer "entries"
    t.float "score"
    t.float "score_secondary"
    t.string "media_large"
    t.string "media_thumbnail"
    t.string "media_content_type"
    t.string "description"
    t.string "description_markdown"
    t.string "leaderboard_type_cd"
    t.datetime "refreshed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "submission_id"
    t.boolean "post_challenge", default: false
    t.integer "seq"
    t.boolean "baseline"
    t.string "baseline_comment"
    t.json "meta"
    t.string "submitter_type"
    t.bigint "submitter_id"
    t.index ["challenge_id"], name: "index_base_leaderboards_on_challenge_id"
    t.index ["challenge_round_id"], name: "index_base_leaderboards_on_challenge_round_id"
    t.index ["leaderboard_type_cd"], name: "index_base_leaderboards_on_leaderboard_type_cd"
    t.index ["submitter_type", "submitter_id"], name: "index_base_leaderboards_on_submitter_type_and_submitter_id"
  end

  create_table "base_leaderboards_20180809", id: false, force: :cascade do |t|
    t.bigint "id"
    t.bigint "challenge_id"
    t.bigint "challenge_round_id"
    t.bigint "participant_id"
    t.integer "row_num"
    t.integer "previous_row_num"
    t.string "slug"
    t.string "name"
    t.integer "entries"
    t.float "score"
    t.float "score_secondary"
    t.string "media_large"
    t.string "media_thumbnail"
    t.string "media_content_type"
    t.string "description"
    t.string "description_markdown"
    t.string "leaderboard_type_cd"
    t.datetime "refreshed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "submission_id"
    t.boolean "post_challenge"
  end

  create_table "blazer_audits", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "query_id"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.bigint "creator_id"
    t.bigint "query_id"
    t.string "state"
    t.string "schedule"
    t.text "emails"
    t.text "slack_channels"
    t.string "check_type"
    t.text "message"
    t.datetime "last_run_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.bigint "dashboard_id"
    t.bigint "query_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.bigint "creator_id"
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.text "description"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "blogs", force: :cascade do |t|
    t.bigint "participant_id"
    t.string "title"
    t.text "body"
    t.boolean "published"
    t.integer "vote_count"
    t.integer "view_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "body_markdown"
    t.integer "seq"
    t.datetime "posted_at"
    t.string "slug"
    t.index ["participant_id"], name: "index_blogs_on_participant_id"
  end

  create_table "challenge_call_responses", force: :cascade do |t|
    t.bigint "challenge_call_id"
    t.string "email"
    t.string "phone"
    t.string "organization"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "challenge_description"
    t.string "contact_name"
    t.string "challenge_title"
    t.text "motivation"
    t.text "timeline"
    t.text "evaluation_criteria"
    t.text "organizers_bio"
    t.text "other"
    t.index ["challenge_call_id"], name: "index_challenge_call_responses_on_challenge_call_id"
  end

  create_table "challenge_calls", force: :cascade do |t|
    t.string "title"
    t.string "website"
    t.datetime "closing_date"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.bigint "organizer_id"
    t.string "headline"
    t.text "description_markdown"
    t.index ["organizer_id"], name: "index_challenge_calls_on_organizer_id"
  end

  create_table "challenge_participants", force: :cascade do |t|
    t.bigint "challenge_id"
    t.bigint "participant_id"
    t.string "email"
    t.string "name"
    t.boolean "registered", default: false
    t.boolean "accepted_dataset_toc", default: false
    t.integer "clef_task_id"
    t.string "clef_eua_file"
    t.boolean "clef_approved", default: false
    t.string "clef_status_cd"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "challenge_rules_accepted_date"
    t.integer "challenge_rules_accepted_version"
    t.boolean "challenge_rules_additional_checkbox", default: false
    t.index ["challenge_id"], name: "index_challenge_participants_on_challenge_id"
    t.index ["participant_id"], name: "index_challenge_participants_on_participant_id"
  end

  create_table "challenge_partners", force: :cascade do |t|
    t.bigint "challenge_id"
    t.string "image_file"
    t.string "partner_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["challenge_id"], name: "index_challenge_partners_on_challenge_id"
  end

  create_table "challenge_rounds", force: :cascade do |t|
    t.bigint "challenge_id"
    t.string "challenge_round"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "submission_limit"
    t.string "submission_limit_period_cd"
    t.datetime "start_dttm"
    t.datetime "end_dttm"
    t.float "minimum_score"
    t.float "minimum_score_secondary"
    t.integer "ranking_window"
    t.integer "ranking_highlight"
    t.integer "score_precision"
    t.integer "score_secondary_precision"
    t.text "leaderboard_note_markdown"
    t.text "leaderboard_note"
    t.integer "failed_submissions", default: 0
    t.integer "parallel_submissions", default: 0, null: false
    t.string "score_title", default: "", null: false
    t.string "score_secondary_title", default: "", null: false
    t.string "primary_sort_order_cd", default: "ascending", null: false
    t.string "secondary_sort_order_cd", default: "not_used", null: false
    t.index ["challenge_id"], name: "index_challenge_rounds_on_challenge_id"
  end

  create_table "challenge_rules", force: :cascade do |t|
    t.bigint "challenge_id"
    t.text "terms"
    t.text "terms_markdown"
    t.text "instructions"
    t.text "instructions_markdown"
    t.boolean "has_additional_checkbox", default: false
    t.string "additional_checkbox_text"
    t.integer "version", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "additional_checkbox_text_markdown"
    t.index ["challenge_id"], name: "index_challenge_rules_on_challenge_id"
  end

  create_table "challenges", id: :serial, force: :cascade do |t|
    t.integer "organizer_id"
    t.string "challenge"
    t.string "status_cd", default: "draft"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tagline"
    t.string "primary_sort_order_cd", default: "ascending"
    t.string "secondary_sort_order_cd", default: "not_used"
    t.boolean "perpetual_challenge", default: false
    t.string "answer_file_s3_key"
    t.integer "page_views", default: 0
    t.integer "participant_count", default: 0
    t.integer "submissions_count", default: 0
    t.string "score_title"
    t.string "score_secondary_title"
    t.string "slug"
    t.string "submission_license"
    t.boolean "api_required", default: false
    t.boolean "media_on_leaderboard", default: false
    t.string "challenge_client_name"
    t.boolean "online_grading", default: true
    t.integer "vote_count", default: 0
    t.text "description_markdown"
    t.text "description"
    t.text "evaluation_markdown"
    t.text "evaluation"
    t.text "rules_markdown"
    t.text "rules"
    t.text "prizes_markdown"
    t.text "prizes"
    t.text "resources_markdown"
    t.text "resources"
    t.text "submission_instructions_markdown"
    t.text "submission_instructions"
    t.text "license_markdown"
    t.text "license"
    t.text "dataset_description_markdown"
    t.text "dataset_description"
    t.string "image_file"
    t.integer "featured_sequence", default: 0
    t.boolean "dynamic_content_flag", default: false
    t.text "dynamic_content"
    t.string "dynamic_content_tab"
    t.text "winner_description_markdown"
    t.text "winner_description"
    t.boolean "winners_tab_active", default: false
    t.bigint "clef_task_id"
    t.boolean "clef_challenge", default: false
    t.boolean "submissions_page"
    t.boolean "private_challenge", default: false
    t.boolean "show_leaderboard", default: true
    t.string "grader_identifier"
    t.boolean "online_submissions", default: false
    t.boolean "grader_logs", default: false
    t.boolean "require_registration", default: false
    t.boolean "grading_history", default: false
    t.boolean "post_challenge_submissions", default: false
    t.boolean "submissions_downloadable", default: false
    t.text "dataset_note_markdown"
    t.text "dataset_note"
    t.boolean "discussions_visible", default: true
    t.boolean "require_toc_acceptance", default: false
    t.string "toc_acceptance_text"
    t.text "toc_acceptance_instructions"
    t.text "toc_acceptance_instructions_markdown"
    t.boolean "toc_accordion", default: false
    t.string "dynamic_content_url"
    t.string "prize_cash"
    t.integer "prize_travel"
    t.integer "prize_academic"
    t.string "prize_misc"
    t.integer "discourse_category_id"
    t.boolean "latest_submission", default: false
    t.string "other_scores_fieldnames"
    t.boolean "teams_allowed", default: true, null: false
    t.integer "max_team_participants", default: 5
    t.integer "team_freeze_seconds_before_end", default: 604800
    t.boolean "hidden_challenge", default: false, null: false
    t.datetime "team_freeze_time"
    t.index ["clef_task_id"], name: "index_challenges_on_clef_task_id"
    t.index ["organizer_id"], name: "index_challenges_on_organizer_id"
    t.index ["slug"], name: "index_challenges_on_slug", unique: true
  end

  create_table "clef_tasks", force: :cascade do |t|
    t.bigint "organizer_id"
    t.string "task"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "eua_file"
    t.index ["organizer_id"], name: "index_clef_tasks_on_organizer_id"
  end

  create_table "dataset_file_downloads", id: :serial, force: :cascade do |t|
    t.integer "participant_id"
    t.integer "dataset_file_id"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dataset_file_id"], name: "index_dataset_file_downloads_on_dataset_file_id"
    t.index ["participant_id"], name: "index_dataset_file_downloads_on_participant_id"
  end

  create_table "dataset_files", id: :serial, force: :cascade do |t|
    t.integer "seq"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.integer "challenge_id"
    t.string "dataset_file_s3_key"
    t.boolean "evaluation", default: false
    t.string "title"
    t.string "hosting_location"
    t.string "external_url"
    t.boolean "visible", default: true
    t.string "external_file_size"
    t.index ["challenge_id"], name: "index_dataset_files_on_challenge_id"
  end

  create_table "disentanglement_leaderboards", force: :cascade do |t|
    t.bigint "challenge_id"
    t.bigint "challenge_round_id"
    t.bigint "participant_id"
    t.integer "row_num"
    t.integer "previous_row_num"
    t.string "slug"
    t.string "name"
    t.integer "entries"
    t.float "score"
    t.float "score_secondary"
    t.string "media_large"
    t.string "media_thumbnail"
    t.string "media_content_type"
    t.string "description"
    t.string "description_markdown"
    t.string "leaderboard_type_cd"
    t.datetime "refreshed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "submission_id"
    t.boolean "post_challenge", default: false
    t.integer "seq"
    t.boolean "baseline"
    t.string "baseline_comment"
    t.json "meta"
    t.float "extra_score1"
    t.float "extra_score2"
    t.float "extra_score3"
    t.float "extra_score4"
    t.float "extra_score5"
    t.float "avg_rank"
    t.index ["challenge_id"], name: "index_disentanglement_leaderboards_on_challenge_id"
    t.index ["challenge_round_id"], name: "index_disentanglement_leaderboards_on_challenge_round_id"
    t.index ["leaderboard_type_cd"], name: "index_disentanglement_leaderboards_on_leaderboard_type_cd"
    t.index ["participant_id"], name: "index_disentanglement_leaderboards_on_participant_id"
  end

  create_table "email_invitations", force: :cascade do |t|
    t.bigint "invitor_id", null: false
    t.citext "email", null: false
    t.citext "token", null: false
    t.bigint "claimant_id"
    t.datetime "claimed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["claimant_id"], name: "index_email_invitations_on_claimant_id"
    t.index ["email"], name: "index_email_invitations_on_email"
    t.index ["invitor_id"], name: "index_email_invitations_on_invitor_id"
    t.index ["token"], name: "index_email_invitations_on_token", unique: true
  end

  create_table "email_preferences", id: :serial, force: :cascade do |t|
    t.integer "participant_id"
    t.boolean "newsletter", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "challenges_followed", default: true
    t.boolean "mentions", default: true
    t.string "email_frequency_cd", default: "daily"
    t.index ["participant_id"], name: "index_email_preferences_on_participant_id"
  end

  create_table "email_preferences_tokens", force: :cascade do |t|
    t.bigint "participant_id"
    t.string "email_preferences_token"
    t.datetime "token_expiration_dttm"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["participant_id"], name: "index_email_preferences_tokens_on_participant_id"
  end

  create_table "follows", id: :serial, force: :cascade do |t|
    t.integer "followable_id", null: false
    t.string "followable_type", null: false
    t.integer "participant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followable_id", "followable_type"], name: "index_follows_on_followable_id_and_followable_type"
    t.index ["participant_id"], name: "index_follows_on_participant_id"
  end

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "invitations", force: :cascade do |t|
    t.bigint "challenge_id"
    t.bigint "participant_id"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitee_name"
    t.index ["challenge_id"], name: "index_invitations_on_challenge_id"
    t.index ["participant_id"], name: "index_invitations_on_participant_id"
  end

  create_table "job_postings", force: :cascade do |t|
    t.string "title"
    t.string "organisation"
    t.string "contact_name"
    t.string "contact_email"
    t.string "contact_phone"
    t.date "posting_date"
    t.date "closing_date"
    t.string "status_cd"
    t.text "description"
    t.boolean "remote", default: true
    t.string "location"
    t.string "country"
    t.integer "page_views"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "job_url"
    t.string "slug"
    t.text "description_markdown"
  end

  create_table "mandrill_messages", force: :cascade do |t|
    t.jsonb "res"
    t.jsonb "message"
    t.jsonb "meta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "participant_id"
  end

  create_table "migration_mappings", force: :cascade do |t|
    t.string "source_type"
    t.integer "source_id"
    t.integer "crowdai_participant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "participant_id"
    t.string "notification_type"
    t.string "notifiable_type"
    t.bigint "notifiable_id"
    t.datetime "read_at"
    t.boolean "is_new", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "message"
    t.string "thumbnail_url"
    t.string "notification_url"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["participant_id"], name: "index_notifications_on_participant_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer "resource_owner_id"
    t.bigint "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "organizer_applications", id: :serial, force: :cascade do |t|
    t.string "contact_name"
    t.string "email"
    t.string "phone"
    t.string "organization"
    t.string "organization_description"
    t.string "challenge_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organizers", id: :serial, force: :cascade do |t|
    t.string "organizer"
    t.text "address"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "approved", default: false
    t.string "slug"
    t.string "image_file"
    t.string "tagline"
    t.string "challenge_proposal"
    t.string "api_key"
    t.boolean "clef_organizer", default: false
    t.index ["slug"], name: "index_organizers_on_slug", unique: true
  end

  create_table "participant_clef_tasks", force: :cascade do |t|
    t.bigint "participant_id"
    t.bigint "clef_task_id"
    t.boolean "approved", default: false
    t.string "eua_file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status_cd"
    t.index ["clef_task_id"], name: "index_participant_clef_tasks_on_clef_task_id"
    t.index ["participant_id"], name: "index_participant_clef_tasks_on_participant_id"
  end

  create_table "participants", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.boolean "admin", default: false
    t.boolean "verified", default: false
    t.date "verification_date"
    t.string "timezone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "unconfirmed_email"
    t.integer "organizer_id"
    t.string "name"
    t.boolean "email_public", default: false
    t.text "bio"
    t.string "website"
    t.string "github"
    t.string "linkedin"
    t.string "twitter"
    t.boolean "account_disabled", default: false
    t.text "account_disabled_reason"
    t.datetime "account_disabled_dttm"
    t.string "slug"
    t.string "api_key"
    t.string "image_file"
    t.string "affiliation"
    t.string "country_cd"
    t.text "address"
    t.string "city"
    t.string "first_name"
    t.string "last_name"
    t.boolean "clef_email", default: false
    t.string "provider"
    t.string "uid"
    t.datetime "participation_terms_accepted_date"
    t.integer "participation_terms_accepted_version"
    t.boolean "agreed_to_terms_of_use_and_privacy", default: true
    t.boolean "agreed_to_marketing", default: true
    t.index ["confirmation_token"], name: "index_participants_on_confirmation_token", unique: true
    t.index ["email"], name: "index_participants_on_email", unique: true
    t.index ["organizer_id"], name: "index_participants_on_organizer_id"
    t.index ["reset_password_token"], name: "index_participants_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_participants_on_slug", unique: true
    t.index ["unlock_token"], name: "index_participants_on_unlock_token", unique: true
  end

  create_table "participation_terms", force: :cascade do |t|
    t.text "terms"
    t.text "terms_markdown"
    t.text "instructions"
    t.text "instructions_markdown"
    t.integer "version", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "partners", force: :cascade do |t|
    t.bigint "organizer_id"
    t.string "image_file"
    t.boolean "visible", default: false
    t.integer "seq", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["organizer_id"], name: "index_partners_on_organizer_id"
  end

  create_table "reserved_userhandles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_reserved_userhandles_on_name", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.boolean "jobs_visible", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "submission_file_definitions", id: :serial, force: :cascade do |t|
    t.integer "challenge_id"
    t.integer "seq"
    t.string "submission_file_description"
    t.string "filetype_cd"
    t.boolean "file_required", default: false
    t.text "submission_file_help_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["challenge_id"], name: "index_submission_file_definitions_on_challenge_id"
  end

  create_table "submission_files", id: :serial, force: :cascade do |t|
    t.integer "submission_id"
    t.integer "seq"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "submission_file_s3_key"
    t.boolean "leaderboard_video", default: false
    t.index ["submission_id"], name: "index_submission_files_on_submission_id"
  end

  create_table "submission_grades", id: :serial, force: :cascade do |t|
    t.integer "submission_id"
    t.string "grading_status_cd"
    t.string "grading_message"
    t.float "grading_factor"
    t.float "score"
    t.float "score_secondary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_submission_grades_on_slug", unique: true
    t.index ["submission_id"], name: "index_submission_grades_on_submission_id"
  end

  create_table "submissions", id: :serial, force: :cascade do |t|
    t.integer "challenge_id"
    t.integer "participant_id"
    t.float "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.float "score_secondary"
    t.string "grading_message"
    t.string "grading_status_cd", default: "ready"
    t.text "description_markdown"
    t.integer "vote_count", default: 0
    t.boolean "post_challenge", default: false
    t.string "api"
    t.string "media_large"
    t.string "media_thumbnail"
    t.string "media_content_type"
    t.integer "challenge_round_id"
    t.json "meta", default: {}
    t.string "short_url"
    t.text "clef_method_description"
    t.string "clef_retrieval_type"
    t.string "clef_run_type"
    t.boolean "clef_primary_run", default: false
    t.text "clef_other_info"
    t.text "clef_additional"
    t.boolean "online_submission", default: false
    t.float "score_display"
    t.float "score_secondary_display"
    t.boolean "baseline", default: false
    t.string "baseline_comment"
    t.index ["challenge_id"], name: "index_submissions_on_challenge_id"
    t.index ["challenge_round_id"], name: "index_submissions_on_challenge_round_id"
    t.index ["participant_id"], name: "index_submissions_on_participant_id"
  end

  create_table "success_stories", force: :cascade do |t|
    t.string "title"
    t.text "byline"
    t.text "html_content"
    t.boolean "published"
    t.datetime "posted_at"
    t.integer "seq"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "image_file"
  end

  create_table "task_dataset_file_downloads", force: :cascade do |t|
    t.bigint "participant_id"
    t.bigint "task_dataset_file_id"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["participant_id"], name: "index_task_dataset_file_downloads_on_participant_id"
    t.index ["task_dataset_file_id"], name: "index_task_dataset_file_downloads_on_task_dataset_file_id"
  end

  create_table "task_dataset_files", force: :cascade do |t|
    t.bigint "clef_task_id"
    t.integer "seq", default: 0
    t.string "description"
    t.boolean "evaluation", default: false
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dataset_file_s3_key"
    t.index ["clef_task_id"], name: "index_task_dataset_files_on_clef_task_id"
  end

  create_table "team_invitations", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "invitor_id", null: false
    t.string "status", default: "pending", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitee_type", null: false
    t.bigint "invitee_id", null: false
    t.index ["invitee_type", "invitee_id"], name: "index_team_invitations_on_invitee_type_and_invitee_id", unique: true, where: "((invitee_type)::text = 'EmailInvitation'::text)"
    t.index ["invitor_id"], name: "index_team_invitations_on_invitor_id"
    t.index ["team_id"], name: "index_team_invitations_on_team_id"
    t.index ["uuid"], name: "index_team_invitations_on_uuid", unique: true
  end

  create_table "team_members", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.string "section"
    t.string "description"
    t.integer "seq"
    t.bigint "participant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_team_members_on_name"
    t.index ["participant_id"], name: "index_team_members_on_participant_id"
  end

  create_table "team_participants", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "participant_id", null: false
    t.string "role", default: "member", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["participant_id", "team_id"], name: "index_team_participants_on_participant_id_and_team_id", unique: true
    t.index ["participant_id"], name: "index_team_participants_on_participant_id"
    t.index ["team_id"], name: "index_team_participants_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.bigint "challenge_id", null: false
    t.citext "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["challenge_id"], name: "index_teams_on_challenge_id"
    t.index ["name", "challenge_id"], name: "index_teams_on_name_and_challenge_id", unique: true
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "votes", id: :serial, force: :cascade do |t|
    t.integer "votable_id", null: false
    t.string "votable_type", null: false
    t.integer "participant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["participant_id"], name: "index_votes_on_participant_id"
    t.index ["votable_id", "votable_type"], name: "index_votes_on_votable_id_and_votable_type"
  end

  add_foreign_key "base_leaderboards", "challenge_rounds"
  add_foreign_key "base_leaderboards", "challenges"
  add_foreign_key "blogs", "participants"
  add_foreign_key "challenge_call_responses", "challenge_calls"
  add_foreign_key "challenge_participants", "challenges"
  add_foreign_key "challenge_participants", "participants"
  add_foreign_key "challenge_partners", "challenges"
  add_foreign_key "challenge_rounds", "challenges"
  add_foreign_key "challenge_rules", "challenges"
  add_foreign_key "challenges", "organizers"
  add_foreign_key "clef_tasks", "organizers"
  add_foreign_key "dataset_file_downloads", "dataset_files"
  add_foreign_key "dataset_file_downloads", "participants"
  add_foreign_key "email_invitations", "participants", column: "claimant_id"
  add_foreign_key "email_invitations", "participants", column: "invitor_id"
  add_foreign_key "email_preferences", "participants"
  add_foreign_key "follows", "participants"
  add_foreign_key "invitations", "challenges"
  add_foreign_key "invitations", "participants"
  add_foreign_key "notifications", "participants"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "participant_clef_tasks", "clef_tasks"
  add_foreign_key "participant_clef_tasks", "participants"
  add_foreign_key "participants", "organizers"
  add_foreign_key "partners", "organizers"
  add_foreign_key "submission_file_definitions", "challenges"
  add_foreign_key "submission_files", "submissions"
  add_foreign_key "submission_grades", "submissions"
  add_foreign_key "submissions", "challenges"
  add_foreign_key "submissions", "participants"
  add_foreign_key "task_dataset_files", "clef_tasks"
  add_foreign_key "team_invitations", "participants", column: "invitor_id"
  add_foreign_key "team_invitations", "teams"
  add_foreign_key "team_members", "participants"
  add_foreign_key "team_participants", "participants"
  add_foreign_key "team_participants", "teams"
  add_foreign_key "teams", "challenges"
  add_foreign_key "votes", "participants"

  create_view "challenge_organizer_participants", materialized: true,  sql_definition: <<-SQL
      SELECT DISTINCT cop.id,
      cop.participant_id,
      cop.clef_task_id,
      cop.organizer_id,
      cop.name,
      cop.challenge
     FROM ( SELECT c.id,
              p.id AS participant_id,
              c.clef_task_id,
              c.organizer_id,
              p.name,
              c.challenge
             FROM participants p,
              challenges c,
              organizers o
            WHERE ((p.organizer_id = o.id) AND (c.organizer_id = o.id))
          UNION
           SELECT c.id,
              p.id AS participant_id,
              c.clef_task_id,
              c.organizer_id,
              p.name,
              c.challenge
             FROM participants p,
              challenges c
            WHERE ((c.clef_challenge IS TRUE) AND (c.clef_task_id IN ( SELECT c1.clef_task_id
                     FROM challenges c1,
                      organizers o1,
                      participants p1
                    WHERE ((c1.clef_challenge IS TRUE) AND (o1.id = c1.organizer_id) AND (o1.id = p1.organizer_id) AND (p1.id = p.id)))))) cop;
  SQL

  create_view "participant_sign_ups",  sql_definition: <<-SQL
      SELECT row_number() OVER () AS id,
      count(participants.id) AS count,
      (date_part('month'::text, participants.created_at))::integer AS mnth,
      (date_part('year'::text, participants.created_at))::integer AS yr
     FROM participants
    GROUP BY ((date_part('month'::text, participants.created_at))::integer), ((date_part('year'::text, participants.created_at))::integer)
    ORDER BY ((date_part('year'::text, participants.created_at))::integer), ((date_part('month'::text, participants.created_at))::integer);
  SQL

  create_view "participant_submissions",  sql_definition: <<-SQL
      SELECT s.id,
      s.challenge_id,
      s.participant_id,
      p.name,
      s.grading_status_cd,
      s.post_challenge,
      s.score,
      s.score_secondary,
      count(f.*) AS files,
      s.created_at
     FROM participants p,
      (submissions s
       LEFT JOIN submission_files f ON ((f.submission_id = s.id)))
    WHERE (s.participant_id = p.id)
    GROUP BY s.id, s.challenge_id, s.participant_id, p.name, s.grading_status_cd, s.post_challenge, s.score, s.score_secondary, s.created_at
    ORDER BY s.created_at DESC;
  SQL

  create_view "challenge_round_views",  sql_definition: <<-SQL
      SELECT cr.id,
      cr.challenge_round,
      cr.row_num,
      cr.active,
      cr.challenge_id,
      cr.start_dttm,
      cr.end_dttm,
      cr.submission_limit,
      cr.submission_limit_period_cd,
      cr.failed_submissions,
      cr.minimum_score,
      cr.minimum_score_secondary
     FROM ( SELECT r1.id,
              r1.challenge_id,
              r1.challenge_round,
              r1.active,
              r1.created_at,
              r1.updated_at,
              r1.submission_limit,
              r1.submission_limit_period_cd,
              r1.start_dttm,
              r1.end_dttm,
              r1.minimum_score,
              r1.minimum_score_secondary,
              r1.ranking_window,
              r1.ranking_highlight,
              r1.score_precision,
              r1.score_secondary_precision,
              r1.leaderboard_note_markdown,
              r1.leaderboard_note,
              r1.failed_submissions,
              row_number() OVER (PARTITION BY r1.challenge_id ORDER BY r1.challenge_id, r1.start_dttm) AS row_num
             FROM challenge_rounds r1) cr;
  SQL

  create_view "challenge_round_summaries",  sql_definition: <<-SQL
      SELECT cr.id,
      cr.challenge_round,
      cr.row_num,
      acr.row_num AS active_row_num,
          CASE
              WHEN (cr.row_num < acr.row_num) THEN 'history'::text
              WHEN (cr.row_num = acr.row_num) THEN 'current'::text
              WHEN (cr.row_num > acr.row_num) THEN 'future'::text
              ELSE NULL::text
          END AS round_status_cd,
      cr.active,
      cr.challenge_id,
      cr.start_dttm,
      cr.end_dttm,
      cr.submission_limit,
      cr.submission_limit_period_cd,
      cr.failed_submissions,
      cr.minimum_score,
      cr.minimum_score_secondary,
      c.status_cd
     FROM challenge_round_views cr,
      challenge_round_views acr,
      challenges c
    WHERE ((c.id = cr.challenge_id) AND (c.id = acr.challenge_id) AND (acr.active IS TRUE));
  SQL

  create_view "leaderboards",  sql_definition: <<-SQL
      SELECT base_leaderboards.id,
      base_leaderboards.challenge_id,
      base_leaderboards.challenge_round_id,
      base_leaderboards.submitter_type,
      base_leaderboards.submitter_id,
      base_leaderboards.row_num,
      base_leaderboards.previous_row_num,
      base_leaderboards.slug,
      base_leaderboards.name,
      base_leaderboards.entries,
      base_leaderboards.score,
      base_leaderboards.score_secondary,
      base_leaderboards.meta,
      base_leaderboards.media_large,
      base_leaderboards.media_thumbnail,
      base_leaderboards.media_content_type,
      base_leaderboards.description,
      base_leaderboards.description_markdown,
      base_leaderboards.leaderboard_type_cd,
      base_leaderboards.refreshed_at,
      base_leaderboards.created_at,
      base_leaderboards.updated_at,
      base_leaderboards.submission_id,
      base_leaderboards.post_challenge,
      base_leaderboards.seq,
      base_leaderboards.baseline,
      base_leaderboards.baseline_comment
     FROM base_leaderboards
    WHERE ((base_leaderboards.leaderboard_type_cd)::text = 'leaderboard'::text);
  SQL

  create_view "ongoing_leaderboards",  sql_definition: <<-SQL
      SELECT base_leaderboards.id,
      base_leaderboards.challenge_id,
      base_leaderboards.challenge_round_id,
      base_leaderboards.submitter_type,
      base_leaderboards.submitter_id,
      base_leaderboards.row_num,
      base_leaderboards.previous_row_num,
      base_leaderboards.slug,
      base_leaderboards.name,
      base_leaderboards.entries,
      base_leaderboards.score,
      base_leaderboards.score_secondary,
      base_leaderboards.meta,
      base_leaderboards.media_large,
      base_leaderboards.media_thumbnail,
      base_leaderboards.media_content_type,
      base_leaderboards.description,
      base_leaderboards.description_markdown,
      base_leaderboards.leaderboard_type_cd,
      base_leaderboards.refreshed_at,
      base_leaderboards.created_at,
      base_leaderboards.updated_at,
      base_leaderboards.submission_id,
      base_leaderboards.post_challenge,
      base_leaderboards.seq,
      base_leaderboards.baseline,
      base_leaderboards.baseline_comment
     FROM base_leaderboards
    WHERE ((base_leaderboards.leaderboard_type_cd)::text = 'ongoing'::text);
  SQL

  create_view "previous_leaderboards",  sql_definition: <<-SQL
      SELECT base_leaderboards.id,
      base_leaderboards.challenge_id,
      base_leaderboards.challenge_round_id,
      base_leaderboards.submitter_type,
      base_leaderboards.submitter_id,
      base_leaderboards.row_num,
      base_leaderboards.previous_row_num,
      base_leaderboards.slug,
      base_leaderboards.name,
      base_leaderboards.entries,
      base_leaderboards.score,
      base_leaderboards.score_secondary,
      base_leaderboards.media_large,
      base_leaderboards.media_thumbnail,
      base_leaderboards.media_content_type,
      base_leaderboards.description,
      base_leaderboards.description_markdown,
      base_leaderboards.leaderboard_type_cd,
      base_leaderboards.refreshed_at,
      base_leaderboards.created_at,
      base_leaderboards.updated_at,
      base_leaderboards.submission_id,
      base_leaderboards.post_challenge,
      base_leaderboards.seq,
      base_leaderboards.baseline,
      base_leaderboards.baseline_comment
     FROM base_leaderboards
    WHERE ((base_leaderboards.leaderboard_type_cd)::text = 'previous'::text);
  SQL

  create_view "previous_ongoing_leaderboards",  sql_definition: <<-SQL
      SELECT base_leaderboards.id,
      base_leaderboards.challenge_id,
      base_leaderboards.challenge_round_id,
      base_leaderboards.submitter_type,
      base_leaderboards.submitter_id,
      base_leaderboards.row_num,
      base_leaderboards.previous_row_num,
      base_leaderboards.slug,
      base_leaderboards.name,
      base_leaderboards.entries,
      base_leaderboards.score,
      base_leaderboards.score_secondary,
      base_leaderboards.media_large,
      base_leaderboards.media_thumbnail,
      base_leaderboards.media_content_type,
      base_leaderboards.description,
      base_leaderboards.description_markdown,
      base_leaderboards.leaderboard_type_cd,
      base_leaderboards.refreshed_at,
      base_leaderboards.created_at,
      base_leaderboards.updated_at,
      base_leaderboards.submission_id,
      base_leaderboards.post_challenge,
      base_leaderboards.seq,
      base_leaderboards.baseline,
      base_leaderboards.baseline_comment
     FROM base_leaderboards
    WHERE ((base_leaderboards.leaderboard_type_cd)::text = 'previous_ongoing'::text);
  SQL

  create_view "challenge_registrations",  sql_definition: <<-SQL
      SELECT row_number() OVER () AS id,
      x.challenge_id,
      x.participant_id,
      x.registration_type,
      x.clef_task_id
     FROM ( SELECT s.challenge_id,
              s.participant_id,
              'submission'::text AS registration_type,
              NULL::integer AS clef_task_id
             FROM submissions s
          UNION
           SELECT s.votable_id,
              s.participant_id,
              'heart'::text AS registration_type,
              NULL::integer AS clef_task_id
             FROM votes s
            WHERE ((s.votable_type)::text = 'Challenge'::text)
          UNION
           SELECT df.challenge_id,
              dfd.participant_id,
              'dataset_download'::text,
              NULL::integer AS clef_task_id
             FROM dataset_file_downloads dfd,
              dataset_files df
            WHERE (dfd.dataset_file_id = df.id)
          UNION
           SELECT c.id,
              pc.participant_id,
              'clef_task'::text AS registration_type,
              pc.clef_task_id
             FROM participant_clef_tasks pc,
              challenges c
            WHERE (c.clef_task_id = pc.clef_task_id)) x;
  SQL

  create_view "participant_challenges",  sql_definition: <<-SQL
      SELECT DISTINCT p.id,
      cr.challenge_id,
      cr.participant_id,
      c.organizer_id,
      c.status_cd,
      c.challenge,
      c.private_challenge,
      c.description,
      c.rules,
      c.prizes,
      c.resources,
      c.tagline,
      c.image_file,
      c.submissions_count,
      c.participant_count,
      c.page_views,
      p.name,
      p.email,
      p.bio,
      p.github,
      p.linkedin,
      p.twitter
     FROM participants p,
      challenges c,
      challenge_registrations cr
    WHERE ((cr.participant_id = p.id) AND (cr.challenge_id = c.id));
  SQL

  create_view "participant_challenge_counts",  sql_definition: <<-SQL
      SELECT row_number() OVER () AS row_number,
      y.challenge_id,
      y.participant_id,
      y.registration_type
     FROM ( SELECT DISTINCT x.challenge_id,
              x.participant_id,
              x.registration_type
             FROM ( SELECT s.challenge_id,
                      s.participant_id,
                      'submission'::text AS registration_type
                     FROM submissions s
                  UNION
                   SELECT s.votable_id,
                      s.participant_id,
                      'heart'::text AS registration_type
                     FROM votes s
                    WHERE ((s.votable_type)::text = 'Challenge'::text)
                  UNION
                   SELECT df.challenge_id,
                      dfd.participant_id,
                      'dataset_download'::text
                     FROM dataset_file_downloads dfd,
                      dataset_files df
                    WHERE (dfd.dataset_file_id = df.id)) x
            ORDER BY x.challenge_id, x.participant_id) y;
  SQL

  create_view "challenge_stats",  sql_definition: <<-SQL
      SELECT row_number() OVER () AS id,
      c.id AS challenge_id,
      c.challenge,
      r.id AS challenge_round_id,
      r.challenge_round,
      r.start_dttm,
      r.end_dttm,
      (r.end_dttm - r.start_dttm) AS duration,
      ( SELECT count(s.id) AS count
             FROM submissions s
            WHERE (s.challenge_id = c.id)) AS submissions,
      ( SELECT count(p.id) AS count
             FROM participants p
            WHERE (p.id IN ( SELECT s1.participant_id
                     FROM submissions s1
                    WHERE (s1.challenge_id = c.id)))) AS participants
     FROM challenges c,
      challenge_rounds r
    WHERE (r.challenge_id = c.id)
    ORDER BY (row_number() OVER ()), c.challenge;
  SQL

end

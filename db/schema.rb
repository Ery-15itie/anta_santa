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

ActiveRecord::Schema[7.2].define(version: 2025_12_11_072236) do
  # These are extensions that must be enabled in order to support this database
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

  create_table "emotion_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "body"
    t.integer "intensity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "emotion", default: 8, null: false
    t.integer "magic_powder", default: 0, null: false
    t.index ["user_id", "created_at"], name: "index_emotion_logs_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_emotion_logs_on_user_id"
  end

  create_table "evaluation_scores", force: :cascade do |t|
    t.bigint "evaluation_id", null: false
    t.bigint "template_item_id", null: false
    t.integer "score"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_checked", default: false, null: false
    t.index ["evaluation_id"], name: "index_evaluation_scores_on_evaluation_id"
    t.index ["template_item_id"], name: "index_evaluation_scores_on_template_item_id"
  end

  create_table "evaluations", force: :cascade do |t|
    t.bigint "evaluator_id", null: false
    t.bigint "evaluated_user_id", null: false
    t.bigint "template_id", null: false
    t.integer "status", default: 0
    t.integer "total_score", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "message"
    t.string "from_name"
    t.index ["evaluated_user_id"], name: "index_evaluations_on_evaluated_user_id"
    t.index ["evaluator_id"], name: "index_evaluations_on_evaluator_id"
    t.index ["template_id"], name: "index_evaluations_on_template_id"
  end

  create_table "github_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "access_token", null: false
    t.string "refresh_token"
    t.datetime "expires_at"
    t.integer "followers_count", default: 0
    t.integer "public_repos_count", default: 0
    t.integer "total_private_repos_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_github_profiles_on_user_id", unique: true
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "ogp_images", force: :cascade do |t|
    t.string "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uuid"], name: "index_ogp_images_on_uuid"
  end

  create_table "reflection_questions", force: :cascade do |t|
    t.text "body"
    t.string "category"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "relationships", force: :cascade do |t|
    t.bigint "follower_id", null: false
    t.bigint "followed_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_id"], name: "index_relationships_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_relationships_on_follower_id"
  end

  create_table "template_items", force: :cascade do |t|
    t.bigint "template_id", null: false
    t.string "title"
    t.text "description"
    t.string "item_type"
    t.integer "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
    t.string "sub_category"
    t.integer "position", default: 0, null: false
    t.index ["template_id"], name: "index_template_items_on_template_id"
  end

  create_table "templates", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "description"
    t.boolean "is_public"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_templates_on_user_id"
  end

  create_table "user_card_selections", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "value_card_id", null: false
    t.integer "timeframe", default: 1, null: false
    t.integer "satisfaction"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "value_card_id", "timeframe"], name: "index_unique_user_card_selection", unique: true
    t.index ["user_id"], name: "index_user_card_selections_on_user_id"
    t.index ["value_card_id"], name: "index_user_card_selections_on_value_card_id"
  end

  create_table "user_reflections", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "reflection_question_id", null: false
    t.text "answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reflection_question_id"], name: "index_user_reflections_on_reflection_question_id"
    t.index ["user_id"], name: "index_user_reflections_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "image_url"
    t.string "github_username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "rescue_code"
    t.datetime "rescue_code_expires_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["rescue_code"], name: "index_users_on_rescue_code", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "value_cards", force: :cascade do |t|
    t.bigint "value_category_id", null: false
    t.string "name", null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["value_category_id", "name"], name: "index_value_cards_on_value_category_id_and_name", unique: true
    t.index ["value_category_id"], name: "index_value_cards_on_value_category_id"
  end

  create_table "value_categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "theme_color", null: false
    t.string "icon_key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_value_categories_on_name", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "emotion_logs", "users"
  add_foreign_key "evaluation_scores", "evaluations"
  add_foreign_key "evaluation_scores", "template_items"
  add_foreign_key "evaluations", "templates"
  add_foreign_key "evaluations", "users", column: "evaluated_user_id"
  add_foreign_key "evaluations", "users", column: "evaluator_id"
  add_foreign_key "github_profiles", "users"
  add_foreign_key "relationships", "users", column: "followed_id"
  add_foreign_key "relationships", "users", column: "follower_id"
  add_foreign_key "template_items", "templates"
  add_foreign_key "templates", "users"
  add_foreign_key "user_card_selections", "users"
  add_foreign_key "user_card_selections", "value_cards"
  add_foreign_key "user_reflections", "reflection_questions"
  add_foreign_key "user_reflections", "users"
  add_foreign_key "value_cards", "value_categories"
end

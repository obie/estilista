# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_03_07_035528) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "authentications", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "email", null: false
    t.boolean "used", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "authors", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.string "name", default: "", null: false
    t.string "email", null: false
    t.string "editor", default: "Text Field", null: false
    t.string "twitter_handle", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "channels", force: :cascade do |t|
    t.text "name", null: false
    t.text "twitter_hashtag", null: false
    t.text "ad", default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.bigint "channel_id", null: false
    t.string "title", null: false
    t.string "slug", null: false
    t.text "body", null: false
    t.boolean "published", default: false, null: false
    t.datetime "published_at", null: false
    t.boolean "tweeted", default: false, null: false
    t.integer "likes", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_id"], name: "index_posts_on_author_id"
    t.index ["channel_id"], name: "index_posts_on_channel_id"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
  end

end

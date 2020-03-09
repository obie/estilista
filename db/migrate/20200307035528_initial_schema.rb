class InitialSchema < ActiveRecord::Migration[6.0]
  def change
    enable_extension "plpgsql"
    enable_extension "uuid-ossp"

    create_table :authentications, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.string :email, null: false
      t.boolean :used, null: false, default: false
      t.timestamps
    end

    create_table :authors do |t|
      t.boolean :admin, null: false, default: false
      t.string :name, null: false, default: ""
      t.string :email, null: false
      t.string :editor, null: false, default: 'Text Field'
      t.string :twitter_handle, null: false
      t.timestamps
    end

    create_table :posts do |t|
      t.belongs_to :author, index: true, null: false
      t.belongs_to :channel, index: true, null: false
      t.string :title, null: false
      t.string :slug, null: false
      t.text :body, null: false
      t.boolean :published, null: false, default: false
      t.timestamp :published_at, null: false
      t.boolean :tweeted, null: false, default: false
      t.integer :likes, default: 0, null: false
      t.timestamps
    end

    create_table :channels do |t|
      t.text :name, null: false
      t.text :twitter_hashtag, null: false
      t.text :ad, null: false, default: ""
      t.timestamps
    end

    add_index :posts, :slug, unique: true
  end
end

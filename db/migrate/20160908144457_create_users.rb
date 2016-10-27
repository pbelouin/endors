class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string  :name
      t.string  :slug
      t.string  :tagline
      t.string  :provider
      t.string  :uid
      t.string  :image
      t.string  :linkedin_token
      t.string  :github_token
      t.string  :github_nickname
      t.string  :github_url
      t.integer :github_balance, unsigned: true, default: 0

      t.string  :stackexchange_token
      t.string  :stackexchange_nickname
      t.string  :stackexchange_url
      t.integer  :stackexchange_id
      t.integer :stackexchange_balance, unsigned: true, default: 0

      t.integer :balance, unsigned: true, default: 0
      t.timestamps
      t.index :slug, unique: true
    end
  end
end

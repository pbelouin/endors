class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string  :name
      t.string  :slug
      t.string  :provider
      t.string  :uid
      t.string  :image
      t.string  :linkedin_token
      t.string  :github_token
      t.string  :github_nickname
      t.string  :github_url
      t.integer :balance, unsigned: true, default: 0
      t.timestamps
      t.index :slug, unique: true
    end
  end
end

class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string  :name
      t.string  :provider
      t.string  :uid
      t.string  :image
      t.string  :linkedin_token
      t.string  :github_token
      t.integer :balance, unsigned: true, default: 0
      t.timestamps
    end
  end
end

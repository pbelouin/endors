class CreateUserSkills < ActiveRecord::Migration[5.0]
  def change
    create_table :user_skills do |t|
      t.belongs_to :user
      t.belongs_to :skill
      t.integer    :balance, unsigned: true, default: 0
      t.timestamps
    end
  end
end

class CreateSkillCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :skill_categories do |t|
      t.belongs_to :skill
      t.belongs_to :category
      t.timestamps
    end
  end
end

# == Schema Information
#
# Table name: languages
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Skill < ApplicationRecord
  has_many :user_skills
  has_many :users, through: :user_skills
  has_many :skill_categories
  has_many :categories, through: :skill_categories
end

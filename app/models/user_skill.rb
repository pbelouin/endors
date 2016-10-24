# == Schema Information
#
# Table name: user_languages
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  language_id :integer
#  balance     :integer          default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class UserSkill < ApplicationRecord
	belongs_to :user
	belongs_to :skill

	delegate :name, to: :skill
end

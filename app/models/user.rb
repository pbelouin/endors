# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string
#  provider               :string
#  uid                    :string
#  image                  :string
#  linkedin_token         :string
#  github_token           :string
#  balance                :integer          default(0)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:linkedin, :github]
  
  has_many :user_skills
  has_many :skills, through: :user_skills
  
  before_save :find_skills

  attr_accessor :github_user
  
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name   # assuming the user model has a name
      user.image = auth.info.image # assuming the user model has an image
      user.github_token = auth.credentials.token
    end
  end

  def github_user
  	Octokit::Client.new(:access_token => github_token)
  end
  
  def find_skills
    github_user_repos = github_user.repos
    star_total = 0
    github_user_repos.each do |repo|
      skill = Skill.find_or_create_by(name: repo.language)
      user_skill         =  UserSkill.find_or_create_by(user_id: self.id, skill_id: skill.id)
      user_skill.balance += repo.stargazers_count
      star_total         += repo.stargazers_count
      user_skill.save
    end
    self.balance += star_total
  end
end

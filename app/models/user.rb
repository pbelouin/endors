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

  has_many :sent_connection_requests,     foreign_key: "sender_id", class_name: "ConnectionRequest"
  has_many :received_connection_requests, foreign_key: "receiver_id", class_name: "ConnectionRequest"

  before_save :find_skills, if: :has_github?

  attr_accessor :github_user

  scope :skip, ->(user) { where.not(id: user) }
  
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name   # assuming the user model has a name
      user.image = auth.info.image # assuming the user model has an image
      user.github_token = auth.credentials.token
      user.github_nickname = auth.info.nickname
      user.github_url      = auth.info.urls.GitHub
    end
  end

  def requested_connection_status_for(user)
    connection_request = ConnectionRequest.find_by(sender_id: self.id, receiver_id: user.id)
    return :none if connection_request.nil?
    connection_request.status.to_sym
  end

  def has_github?
    self.github_token.present?
  end

  def github_user
  	Octokit::Client.new(:access_token => github_token)
  end
  
  def find_skills
    github_user_repos = github_user.repos
    star_total = 0
    github_user_repos.each do |repo|
      skill = Skill.find_or_create_by(name: repo.language.downcase)
      user_skill         =  UserSkill.find_or_create_by(user_id: self.id, skill_id: skill.id)
      user_skill.balance += repo.stargazers_count
      star_total         += repo.stargazers_count
      user_skill.save
    end
    self.balance += star_total
  end
end

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

  extend FriendlyId
  friendly_id :name, use: :slugged

  def self.create_from_omniauth(params)
    attributes = {
      email: params['info']['email'],
      password: Devise.friendly_token
    }

    create(attributes)
  end

  attr_accessor :github_client

  has_many :authentications, class_name: 'UserAuthentication', dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:linkedin, :github, :stackexchange]
  
  has_many :user_skills, dependent: :destroy
  has_many :skills, through: :user_skills

  has_many :sent_connection_requests,     foreign_key: "sender_id", class_name: "ConnectionRequest"
  has_many :received_connection_requests, foreign_key: "receiver_id", class_name: "ConnectionRequest"

  accepts_nested_attributes_for :skills, allow_destroy: true
  accepts_nested_attributes_for :user_skills, allow_destroy: true

  #after_create :setup_profile_from_github_data, if: :has_github?

  scope :skip, ->(user) { where.not(id: user) }
  default_scope {order('balance DESC')}
  
  #def self.from_omniauth(auth)
  #  where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
  #    user.email = auth.info.email
  #    user.password = Devise.friendly_token[0,20]
  #    user.name = auth.info.name   # assuming the user model has a name
  #    user.image = auth.info.image # assuming the user model has an image
  #    user.github_token = auth.credentials.token
  #    user.github_nickname = auth.info.nickname
  #    user.github_url      = auth.info.urls.GitHub
  #  end
  #end

  def requested_connection_status_for(user)
    connection_request = ConnectionRequest.find_by(sender_id: self.id, receiver_id: user.id)
    return :none if connection_request.nil?
    connection_request.status.to_sym
  end

  def has_superior_balance_than? user_skill
    user_skill_for_self = self.user_skills.where(skill_id: user_skill.skill_id).first
    return false if user_skill_for_self.nil?
    balance_for_skill = user_skill_for_self.balance
    return balance_for_skill > user_skill.balance
  end

  def has_github?
    self.github_token.present?
  end

  def available_skills
    available_skills = []
    Skill.all.where.not(id: self.skills.map(&:id)).each do |skill|
      available_skills << skill.name.capitalize
    end
    available_skills
  end

  def has_stackexchange?
    self.stackexchange_token.present?
  end

  def github_client
    @github_client = Octokit::Client.new(access_token: github_token)
    @github_client
  end

  def set_stackexchange_data!
    stackexchange_params       = self.authentications
                               .joins(:authentication_provider)
                               .where(authentication_providers: { name: 'stackexchange' })
                               .first.params
    
    self.stackexchange_token      = stackexchange_params.credentials.token
    self.stackexchange_nickname   = stackexchange_params.info.nickname
    self.stackexchange_url        = stackexchange_params.info.urls.stackoverflow 
    self.stackexchange_id         = stackexchange_params.extra.raw_info.user_id
    self.set_stackexchange_balance_per_skill!
    self.save
  end

  def stackexchange_answers
    answers = []
    RubyStackoverflow.users_with_answers([self.stackexchange_id]).data[0].answers.each do |answer|
      answers << {answer_id: answer.answer_id, question_id: answer.question_id, score: answer.score}
    end
    answers
  end

  def set_stackexchange_balance_per_skill!
    qids = []
    @stackexchange_answers = self.stackexchange_answers
    self.stackexchange_answers.each do |answer|
       qids << answer[:question_id]
    end
    RubyStackoverflow.questions_by_ids(qids).data.each do |question|
      question_skills = []  
        question.tags.each do |tag|
          if tag.downcase.include? 'rails'
            skill = Skill.find_or_create_by(name: 'Ruby on Rails')
          else
            skill = Skill.where('lower(name) = ?', tag.downcase).first_or_create(:name=>tag)
          end
          question_skills << skill
        end      
      question_skills.each do |qskill|
        self.skills << qskill unless self.skills.include? qskill
      end
      @stackexchange_answers.each do |answer|
        if answer[:question_id] == question.question_id
          user_skills_for_question = self.user_skills.where(skill_id: question_skills.uniq.map(&:id))
          user_skills_for_question.update_all(balance: answer[:score])
          self.balance += user_skills_for_question.pluck(:balance).sum
        end
      end

    end
  end

  def set_github_data!
    github_params          = self.authentications
                               .joins(:authentication_provider)
                               .where(authentication_providers: { name: 'github' })
                               .first.params
    self.name              = github_params.info.name   
    self.image             = github_params.info.image
    self.github_token      = github_params.credentials.token
    self.github_nickname   = github_params.info.nickname
    self.github_url        = github_params.info.urls.GitHub 
    github_user_repos      = github_client.repos
    star_total = 0
    github_user_repos.each do |repo|
      skill = Skill.where('lower(name) = ?', repo.language.downcase).first_or_create(:name=>repo.language)
      user_skill         =  UserSkill.find_or_create_by(user_id: self.id, skill_id: skill.id)
      user_skill.balance += 1
      user_skill.balance += repo.stargazers_count
      user_skill.save
      self.balance += 1
      puts self.balance
    end
    self.save
  end
end

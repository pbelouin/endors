class UserSkillsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_skill, only: [:add_credit]

  # PUT /add_credit
  def add_credit
    ActiveRecord::Base.transaction do
      session[:return_to] ||= request.referer
      current_user.balance -=1
      @user_skill.balance += 1
      @user_skill.save
      @user = User.find(@user_skill.user_id)
      @user.balance += 1
      current_user.save
      @user.save
    end
    flash[:notice] = "you endorsed #{@user.name} for #{Skill.find(@user_skill.skill_id).name.capitalize}. Your new balance is #{current_user.balance}"
    redirect_to session.delete(:return_to)
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_skill
      @user_skill = UserSkill.find(params[:user_skill_id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_skill_params
      params.fetch(:user_skill, {}).permit()
    end
end

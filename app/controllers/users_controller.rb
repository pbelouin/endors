class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy, :request_connection, :add_skill, :remove_skill]

  # GET /users
  def index
    @users = User.all.skip(current_user)
  end

  # GET /users/1
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  def add_skill
    skill_name = params[:skill_name]
    skill = Skill.where('lower(name) = ?', skill_name.downcase).first_or_create(:name=>skill_name)
    @user.skills << skill unless @user.skills.pluck(:id).include? skill.id
    redirect_to [:edit, @user], notice: 'Skill was successfully added'
  end

  def remove_skill
    @user.user_skills.where(id: params[:user_skill_id]).first.destroy
    redirect_to [:edit, @user], notice: 'Skill was successfully removed'
  end

  def request_connection
    ConnectionRequest.find_or_create_by(sender_id: current_user.id, receiver_id: @user.id)
    flash[:notice] = "Your request has been sent. #{@user.name} will accept you if he wishes to do so."
    render :edit
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.friendly.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.fetch(:user, {}).permit(:name, :tagline, user_skills_attributes: [:id, :_destroy, :skill_id, skill_attributes: [:id, :_destroy, :name]])
    end
end

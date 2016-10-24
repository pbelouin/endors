class SkillsController < ApplicationController
  before_action :set_skill, only: [:show, :edit, :update, :destroy]

  # GET /skills
  def index
    @skills = Language.all
  end

  # GET /skills/1
  def show
  end

  # GET /skills/new
  def new
    @skill = Language.new
  end

  # GET /skills/1/edit
  def edit
  end

  # POST /skills
  def create
    @skill = Language.new(skill_params)

    if @skill.save
      redirect_to @skill, notice: 'Language was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /skills/1
  def update
    if @skill.update(skill_params)
      redirect_to @skill, notice: 'Language was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /skills/1
  def destroy
    @skill.destroy
    redirect_to skills_url, notice: 'Language was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_skill
      @skill = Language.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def skill_params
      params.fetch(:skill, {})
    end
end

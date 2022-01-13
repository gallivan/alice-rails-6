class UserDutiesController < ApplicationController
  before_action :set_user_duty, only: [:show, :edit, :update, :destroy]

  # GET /user_duties
  # GET /user_duties.json
  def index
    @user_duties = UserDuty.all
  end

  # GET /user_duties/1
  # GET /user_duties/1.json
  def show
  end

  # GET /user_duties/new
  def new
    @user_duty = UserDuty.new
  end

  # GET /user_duties/1/edit
  def edit
  end

  # POST /user_duties
  # POST /user_duties.json
  def create
    @user_duty = UserDuty.new(user_duty_params)

    respond_to do |format|
      if @user_duty.save
        format.html { redirect_to @user_duty, notice: 'User duty was successfully created.' }
        format.json { render :show, status: :created, location: @user_duty }
      else
        format.html { render :new }
        format.json { render json: @user_duty.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_duties/1
  # PATCH/PUT /user_duties/1.json
  def update
    respond_to do |format|
      if @user_duty.update(user_duty_params)
        format.html { redirect_to @user_duty, notice: 'User duty was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_duty }
      else
        format.html { render :edit }
        format.json { render json: @user_duty.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_duties/1
  # DELETE /user_duties/1.json
  def destroy
    @user_duty.destroy
    respond_to do |format|
      format.html { redirect_to user_duties_url, notice: 'User duty was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_duty
      @user_duty = UserDuty.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_duty_params
      params.require(:user_duty).permit(:user_id, :duty_id)
    end
end

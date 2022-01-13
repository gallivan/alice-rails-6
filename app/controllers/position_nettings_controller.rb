class PositionNettingsController < ApplicationController
  before_action :set_position_netting, only: [:show, :edit, :update, :destroy]

  # GET /position_nettings
  # GET /position_nettings.json
  def index
    if params[:q].blank? and current_user.accounts.count > 0
      params[:q] = {}
      params[:q][:account_id_eq] = current_user.accounts.order(:code).first.id
    end
    @q = PositionNetting.ransack(params[:q])
    @position_nettings = @q.result.page(params[:page]).per(20)
  end

  # GET /position_nettings/1
  # GET /position_nettings/1.json
  def show
  end

  # GET /position_nettings/new
  def new
    @position_netting = PositionNetting.new
  end

  # GET /position_nettings/1/edit
  def edit
  end

  # POST /position_nettings
  # POST /position_nettings.json
  def create
    @position_netting = PositionNetting.new(position_netting_params)

    respond_to do |format|
      if @position_netting.save
        format.html { redirect_to @position_netting, notice: 'Position netting was successfully created.' }
        format.json { render :show, status: :created, location: @position_netting }
      else
        format.html { render :new }
        format.json { render json: @position_netting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /position_nettings/1
  # PATCH/PUT /position_nettings/1.json
  def update
    respond_to do |format|
      if @position_netting.update(position_netting_params)
        format.html { redirect_to @position_netting, notice: 'Position netting was successfully updated.' }
        format.json { render :show, status: :ok, location: @position_netting }
      else
        format.html { render :edit }
        format.json { render json: @position_netting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /position_nettings/1
  # DELETE /position_nettings/1.json
  def destroy
    @position_netting.destroy
    respond_to do |format|
      format.html { redirect_to position_nettings_url, notice: 'Position netting was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_position_netting
      @position_netting = PositionNetting.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def position_netting_params
      params.require(:position_netting).permit(:account_id, :currency_id, :claim_id, :position_netting_type_id, :bot_position_id, :sld_position_id, :posted_on, :done, :bot_price, :sld_price, :bot_price_traded, :sld_price_traded, :pnl)
    end
end

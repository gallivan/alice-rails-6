class StatementPositionNettingsController < ApplicationController
  before_action :set_statement_position_netting, only: [:show]
  before_action :trap_request, only: [:edit, :update, :destroy]

  # GET /statement_position_nettings
  # GET /statement_position_nettings.json
  def index
    if params[:q].blank? and current_user.accounts.count > 0
      params[:q] = {}
      params[:q][:account_id_eq] = current_user.accounts.order(:code).first.id
    end
    @q = StatementPositionNetting.order("id desc").ransack(params[:q])
    @statement_position_nettings = @q.result.page(params[:page]).per(20)
  end

  # GET /statement_position_nettings/1
  # GET /statement_position_nettings/1.json
  def show
  end

  # GET /statement_position_nettings/new
  def new
    @statement_position_netting = StatementPositionNetting.new
  end

  # GET /statement_position_nettings/1/edit
  def edit
  end

  # POST /statement_position_nettings
  # POST /statement_position_nettings.json
  def create
    @statement_position_netting = StatementPositionNetting.new(statement_position_netting_params)

    respond_to do |format|
      if @statement_position_netting.save
        format.html {redirect_to @statement_position_netting, notice: 'Statement position netting was successfully created.'}
        format.json {render :show, status: :created, location: @statement_position_netting}
      else
        format.html {render :new}
        format.json {render json: @statement_position_netting.errors, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /statement_position_nettings/1
  # PATCH/PUT /statement_position_nettings/1.json
  def update
    respond_to do |format|
      if @statement_position_netting.update(statement_position_netting_params)
        format.html {redirect_to @statement_position_netting, notice: 'Statement position netting was successfully updated.'}
        format.json {render :show, status: :ok, location: @statement_position_netting}
      else
        format.html {render :edit}
        format.json {render json: @statement_position_netting.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /statement_position_nettings/1
  # DELETE /statement_position_nettings/1.json
  def destroy
    @statement_position_netting.destroy
    respond_to do |format|
      format.html {redirect_to statement_position_nettings_url, notice: 'Statement position netting was successfully destroyed.'}
      format.json {head :no_content}
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_statement_position_netting
    @statement_position_netting = StatementPositionNetting.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def statement_position_netting_params
    params.require(:statement_position_netting).permit(:stated_on, :posted_on, :account_id, :account_code, :claim_code, :netting_code, :bot_price_traded, :sld_price_traded, :done, :pnl, :currency_code)
  end

  def trap_request
    flash[:danger] = "Changes are not allowed"
    redirect_to statement_position_nettings_path
  end

end

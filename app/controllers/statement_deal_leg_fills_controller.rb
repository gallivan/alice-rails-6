class StatementDealLegFillsController < ApplicationController
  before_action :set_statement_deal_leg_fill, only: [:show]
  before_action :trap_request, only: [:edit, :update, :destroy]

  # GET /statement_deal_leg_fills
  # GET /statement_deal_leg_fills.json
  def index
    if params[:q].blank? and current_user.accounts.count > 0
      params[:q] = {}
      params[:q][:account_id_eq] = current_user.accounts.order(:code).first.id
    end
    @q = StatementDealLegFill.order("id desc").ransack(params[:q])
    @statement_deal_leg_fills = @q.result.page(params[:page]).per(20)
  end

  # GET /statement_deal_leg_fills/1
  # GET /statement_deal_leg_fills/1.json
  def show
  end

  # GET /statement_deal_leg_fills/new
  def new
    @statement_deal_leg_fill = StatementDealLegFill.new
  end

  # GET /statement_deal_leg_fills/1/edit
  def edit
  end

  # POST /statement_deal_leg_fills
  # POST /statement_deal_leg_fills.json
  def create
    @statement_deal_leg_fill = StatementDealLegFill.new(statement_deal_leg_fill_params)

    respond_to do |format|
      if @statement_deal_leg_fill.save
        format.html {redirect_to @statement_deal_leg_fill, notice: 'Statement deal leg fill was successfully created.'}
        format.json {render :show, status: :created, location: @statement_deal_leg_fill}
      else
        format.html {render :new}
        format.json {render json: @statement_deal_leg_fill.errors, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /statement_deal_leg_fills/1
  # PATCH/PUT /statement_deal_leg_fills/1.json
  def update
    respond_to do |format|
      if @statement_deal_leg_fill.update(statement_deal_leg_fill_params)
        format.html {redirect_to @statement_deal_leg_fill, notice: 'Statement deal leg fill was successfully updated.'}
        format.json {render :show, status: :ok, location: @statement_deal_leg_fill}
      else
        format.html {render :edit}
        format.json {render json: @statement_deal_leg_fill.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /statement_deal_leg_fills/1
  # DELETE /statement_deal_leg_fills/1.json
  def destroy
    @statement_deal_leg_fill.destroy
    respond_to do |format|
      format.html {redirect_to statement_deal_leg_fills_url, notice: 'Statement deal leg fill was successfully destroyed.'}
      format.json {head :no_content}
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_statement_deal_leg_fill
    @statement_deal_leg_fill = StatementDealLegFill.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def statement_deal_leg_fill_params
    params.require(:statement_deal_leg_fill).permit(:account_id, :account_code, :claim_code, :stated_on, :posted_on, :traded_on, :bot, :sld, :net, :price, :price_traded)
  end

  def trap_request
    flash[:danger] = "Changes are not allowed"
    redirect_to positions_path
  end

end

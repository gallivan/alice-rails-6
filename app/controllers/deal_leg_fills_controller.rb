class DealLegFillsController < ApplicationController
  before_action :set_deal_leg_fill, only: [:show, :edit, :update, :destroy]
  before_action :trap_request, only: [:edit, :update, :destroy]

  # GET /deal_leg_fills
  # GET /deal_leg_fills.json
  def index
    if params[:q].blank? and current_user.accounts.count > 0
      params[:q] = {}
      params[:q][:account_id_eq] = current_user.accounts.order(:code).first.id
    end
    @q = DealLegFill.order(:traded_at).ransack(params[:q])
    @deal_leg_fills = @q.result.page(params[:page]).per(20)
  end

  # GET /deal_leg_fills/1
  # GET /deal_leg_fills/1.json
  def show
  end

  # GET /deal_leg_fills/new
  def new
    @deal_leg_fill = DealLegFill.new
  end

  # GET /deal_leg_fills/1/edit
  def edit
  end

  # POST /deal_leg_fills
  # POST /deal_leg_fills.json
  def create
    # @deal_leg_fill = DealLegFill.new(deal_leg_fill_params)
    params = {}
    deal_leg_fill_params.keys.each do |key|
      params[key.to_sym] = deal_leg_fill_params[key]
    end
    account = Account.find(params[:account_id])
    @deal_leg_fill = account.handle_fill(deal_leg_fill_params)

    respond_to do |format|
      # if @deal_leg_fill.save
      if @deal_leg_fill
        format.html {redirect_to @deal_leg_fill, notice: "Deal leg fill #{@deal_leg_fill.id} was successfully created."}
        format.json {render :show, status: :created, location: @deal_leg_fill}
      else
        format.html {render :new}
        format.json {render json: @deal_leg_fill.errors, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /deal_leg_fills/1
  # PATCH/PUT /deal_leg_fills/1.json
  def update
    respond_to do |format|
      if @deal_leg_fill.update(deal_leg_fill_params)
        format.html {redirect_to @deal_leg_fill, notice: "Deal leg fill #{@deal_leg_fill.id} was successfully updated."}
        format.json {render :show, status: :ok, location: @deal_leg_fill}
      else
        format.html {render :edit}
        format.json {render json: @deal_leg_fill.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /deal_leg_fills/1
  # DELETE /deal_leg_fills/1.json
  def destroy
    @deal_leg_fill.destroy
    respond_to do |format|
      format.html {redirect_to deal_leg_fills_url, notice: "Deal leg fill #{@deal_leg_fill.id} was successfully was successfully destroyed."}
      format.json {head :no_content}
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_deal_leg_fill
    @deal_leg_fill = DealLegFill.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def deal_leg_fill_params
    params.require(:deal_leg_fill).permit(:deal_leg_id, :system_id, :dealing_venue_id, :dealing_venue_done_id, :account_id, :claim_id, :done, :price, :price_traded, :posted_on, :traded_on, :traded_at, :position_id, :booker_report_id, :kind)
  end

  # Confirms a logged-in user.
  def trap_request
    flash[:danger] = "Changes are not allowed"
    redirect_to deal_leg_fills_path
  end

end

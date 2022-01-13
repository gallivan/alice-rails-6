class ViewPointsController < ApplicationController
  before_action :set_view_point, only: [:show, :edit, :update, :destroy]

  def positions_by_claim
    @data = params[:format] ? ViewPoint.positions_by_claim_data(params[:account_id]) : []

    respond_to do |format|
      format.html
      format.xml {render :xml => @data}
      format.json {render :json => @data}
    end
  end

  def statement_positions_by_claim_on
    date = StatementPosition.maximum(:stated_on)
    account_id = params[:account_id]
    @data = params[:format] ? ViewPoint.statement_positions_by_claim_on(account_id, date) : []

    respond_to do |format|
      format.html
      format.xml {render :xml => @data}
      format.json {render :json => @data}
    end
  end

  def firm_positions_by_claim
    @data = params[:format] ? ViewPoint.firm_positions_by_claim_data : []

    respond_to do |format|
      format.html
      format.xml {render :xml => @data}
      format.json {render :json => @data}
    end
  end

  def firm_statement_positions_by_claim_on
    date = StatementPosition.maximum(:stated_on)
    @data = params[:format] ? ViewPoint.firm_statement_positions_by_claim_on(date) : []

    respond_to do |format|
      format.html
      format.xml {render :xml => @data}
      format.json {render :json => @data}
    end
  end

  def positions_by_claim_set
    @data = Position.open.joins(:claim).select('claims.code as claim_code, sum(bot) as bot, sum(sld) as sld, sum(net) as net').group('claims.code').order('claims.code')

    respond_to do |format|
      format.html
      format.xml {render :xml => @data}
      format.json {render :json => @data}
    end
  end

  # def who_what_when
  #   @data = params[:format] ? ViewPoint.who_what_when(current_user) : []
  #
  #   respond_to do |format|
  #     format.html
  #     format.xml {render :xml => @data}
  #     format.json {render :json => @data}
  #   end
  # end

  def who_what_when_range
    start_date = params[:startDate]
    end_date = params[:endDate]
    @data = params[:format] ? ViewPoint.who_what_when(current_user, start_date, end_date) : []

    respond_to do |format|
      format.json {render :json => @data}
    end
  end

  # def firm_what_when
  #   @data = params[:format] ? ViewPoint.firm_what_when : []
  #
  #   respond_to do |format|
  #     format.html
  #     format.xml {render :xml => @data}
  #     format.json {render :json => @data}
  #   end
  # end

  def firm_what_when_range
    start_date = params[:startDate]
    end_date = params[:endDate]
    @data = params[:format] ? ViewPoint.firm_what_when(start_date, end_date) : []

    respond_to do |format|
      format.html
      format.xml {render :xml => @data}
      format.json {render :json => @data}
    end
  end

  def firm_dashboard
    @data = []
    respond_to do |format|
      format.html
    end
  end

  def account_dashboard
    if params[:account] and params[:account][:id]
      @account = Account.find(params[:account][:id])
    elsif current_user.is_trader?
      @account = current_user.accounts.order(:code).first
    else
      @account = Account.order(:code).first
    end

    session[:account_id] = @account.id

    respond_to do |format|
      format.html
    end
  end

  def statement_money_lines_ytd
    @data = params[:format] ? ViewPoint.statement_money_lines_ytd(params[:account_id]) : []

    respond_to do |format|
      format.html
      format.xml {render :xml => @data}
      format.json {render :json => @data}
    end
  end

  def statement_money_lines_since
    date = StatementMoneyLine.maximum(:posted_on) - 30.days
    @data = params[:format] ? ViewPoint.statement_money_lines_since(params[:account_id], date) : []

    respond_to do |format|
      format.html
      format.xml {render :xml => @data}
      format.json {render :json => @data}
    end
  end

  def firm_statement_money_lines_since
    date = StatementMoneyLine.maximum(:posted_on) - 30.days
    @data = params[:format] ? ViewPoint.firm_statement_money_lines_since(date) : []

    respond_to do |format|
      format.html
      format.xml {render :xml => @data}
      format.json {render :json => @data}
    end
  end

  def income_to_expense_ratio_by_claim_set
    @data = params[:format] ? ViewPoint.income_to_expense_ratio_by_claim_set(params[:account_id]) : []

    respond_to do |format|
      format.html
      format.xml {render :xml => @data}
      format.json {render :json => @data}
    end
  end

  def income_to_expense_ratio_by_claim_set_for_firm
    @data = params[:format] ? ViewPoint.income_to_expense_ratio_by_claim_set_for_firm : []

    respond_to do |format|
      format.html
      format.xml {render :xml => @data}
      format.json {render :json => @data}
    end
  end

  def positions
    @data = params[:format] ? ViewPoint.positions : []

    respond_to do |format|
      format.html
      format.xml {render :xml => @data}
      format.json {render :json => @data}
    end
  end

  def seasonal_spread_sets
    if params[:claim_set] and params[:claim_set][:id]
      @claim_set = ClaimSet.find(params[:claim_set][:id])
    else
      @claim_set = ClaimSet.spreads.first
    end
    respond_to do |format|
      format.html
    end
  end

  def seasonal_spread_sets_data
    @data = params[:format] ? ViewPoint.claim_set_marks_by_date(params[:claim_set_id]) : []

    respond_to do |format|
      format.html
      format.xml {render :xml => @data}
      format.json {render :json => @data}
    end
  end

  def seasonal_spreads
    if params[:claim] and params[:claim][:id]
      @claim = Claim.find(params[:claim][:id])
    elsif params[:claim_set_code]
      @claim = Claim.find_by_code(params[:claim_set_code])
    else
      @claim = Claim.spreads.order(:code).first
    end
    respond_to do |format|
      format.html
    end
  end

  def seasonal_spreads_data
    @data = params[:format] ? ViewPoint.seasonal_spreads_data(params[:claim_id]) : []

    respond_to do |format|
      format.html
      format.xml {render :xml => @data}
      format.json {render :json => @data}
    end
  end

  # GET /view_points
  # GET /view_points.json
  def index
    @view_points = ViewPoint.all
  end

  # GET /view_points/1
  # GET /view_points/1.json
  def show
  end

  # GET /view_points/new
  def new
    @view_point = ViewPoint.new
  end

  # GET /view_points/1/edit
  def edit
  end

  # POST /view_points
  # POST /view_points.json
  def create
    @view_point = ViewPoint.new(view_point_params)

    respond_to do |format|
      if @view_point.save
        format.html {redirect_to @view_point, notice: 'View point was successfully created.'}
        format.json {render :show, status: :created, location: @view_point}
      else
        format.html {render :new}
        format.json {render json: @view_point.errors, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /view_points/1
  # PATCH/PUT /view_points/1.json
  def update
    respond_to do |format|
      if @view_point.update(view_point_params)
        format.html {redirect_to @view_point, notice: 'View point was successfully updated.'}
        format.json {render :show, status: :ok, location: @view_point}
      else
        format.html {render :edit}
        format.json {render json: @view_point.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /view_points/1
  # DELETE /view_points/1.json
  def destroy
    @view_point.destroy
    respond_to do |format|
      format.html {redirect_to view_points_url, notice: 'View point was successfully destroyed.'}
      format.json {head :no_content}
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_view_point
    @view_point = ViewPoint.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def view_point_params
    print params
    params.require(:view_point).permit(:name, :note, :code)
  end

  protect_from_forgery unless: -> {request.format.json?}

end

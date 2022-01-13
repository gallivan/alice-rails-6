class StatementMoneyLinesController < ApplicationController
  before_action :set_statement_money_line, only: [:show]
  before_action :trap_request, only: [:edit, :update, :destroy]

  # GET /statement_money_lines
  # GET /statement_money_lines.json
  def index
    if params[:q].blank? and current_user.accounts.count > 0
      params[:q] = {}
      params[:q][:account_id_eq] = current_user.accounts.order(:code).first.id
    end
    @q = StatementMoneyLine.order("id desc").ransack(params[:q])
    @statement_money_lines = @q.result.page(params[:page]).per(20)
  end

  # GET /statement_money_lines/1
  # GET /statement_money_lines/1.json
  def show
  end

  # GET /statement_money_lines/new
  def new
    @statement_money_line = StatementMoneyLine.new
  end

  # GET /statement_money_lines/1/edit
  def edit
  end

  # POST /statement_money_lines
  # POST /statement_money_lines.json
  def create
    @statement_money_line = StatementMoneyLine.new(statement_money_line_params)

    respond_to do |format|
      if @statement_money_line.save
        format.html {redirect_to @statement_money_line, notice: 'Statement money line was successfully created.'}
        format.json {render :show, status: :created, location: @statement_money_line}
      else
        format.html {render :new}
        format.json {render json: @statement_money_line.errors, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /statement_money_lines/1
  # PATCH/PUT /statement_money_lines/1.json
  def update
    respond_to do |format|
      if @statement_money_line.update(statement_money_line_params)
        format.html {redirect_to @statement_money_line, notice: 'Statement money line was successfully updated.'}
        format.json {render :show, status: :ok, location: @statement_money_line}
      else
        format.html {render :edit}
        format.json {render json: @statement_money_line.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /statement_money_lines/1
  # DELETE /statement_money_lines/1.json
  def destroy
    @statement_money_line.destroy
    respond_to do |format|
      format.html {redirect_to statement_money_lines_url, notice: 'Statement money line was successfully destroyed.'}
      format.json {head :no_content}
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_statement_money_line
    @statement_money_line = StatementMoneyLine.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def statement_money_line_params
    params.require(:statement_money_line).permit(:stated_on, :posted_on, :account_id, :account_code, :held_currency_code, :base_currency_code, :beginning_balance, :pnl_futures, :ledger_balance, :open_trade_equity, :cash_account_balance, :net_liquidating_balance)
  end

  def trap_request
    flash[:danger] = "Changes are not allowed"
    redirect_to statement_money_lines_path
  end

end

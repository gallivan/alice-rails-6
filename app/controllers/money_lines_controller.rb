class MoneyLinesController < ApplicationController
  before_action :set_money_line, only: [:show, :edit, :update, :destroy]

  # GET /money_lines
  # GET /money_lines.json
  def index
    @q = MoneyLine.ransack(params[:q])
    @money_lines = @q.result.order(:id).page(params[:page]).per(20)
  end

  # GET /money_lines/1
  # GET /money_lines/1.json
  def show
  end

  # GET /money_lines/new
  def new
    @money_line = MoneyLine.new
  end

  # GET /money_lines/1/edit
  def edit
  end

  # POST /money_lines
  # POST /money_lines.json
  def create
    @money_line = MoneyLine.new(money_line_params)

    respond_to do |format|
      if @money_line.save
        format.html { redirect_to @money_line, notice: 'Money line was successfully created.' }
        format.json { render :show, status: :created, location: @money_line }
      else
        format.html { render :new }
        format.json { render json: @money_line.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /money_lines/1
  # PATCH/PUT /money_lines/1.json
  def update
    respond_to do |format|
      if @money_line.update(money_line_params)
        format.html { redirect_to @money_line, notice: 'Money line was successfully updated.' }
        format.json { render :show, status: :ok, location: @money_line }
      else
        format.html { render :edit }
        format.json { render json: @money_line.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /money_lines/1
  # DELETE /money_lines/1.json
  def destroy
    @money_line.destroy
    respond_to do |format|
      format.html { redirect_to money_lines_url, notice: 'Money line was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_money_line
      @money_line = MoneyLine.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def money_line_params
      params.require(:money_line).permit(:account_id, :currency_held_id, :currency_base_id, :currency_mark_id, :posted_on, :beginning_balance, :cash, :pnl_futures, :pnl_options, :adjustments, :rebates, :charges, :ledger_balance, :open_trade_equity, :cash_account_balance, :margin, :long_option_value, :short_option_value, :net_option_value, :net_liquidating_balance)
    end
end

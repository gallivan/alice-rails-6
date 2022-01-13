class StatementAdjustmentsController < ApplicationController
  before_action :set_statement_adjustment, only: [:show]
  before_action :trap_request, only: [:edit, :update, :destroy]

  # GET /statement_adjustments
  # GET /statement_adjustments.json
  def index
    if params[:q].blank? and current_user.accounts.count > 0
      params[:q] = {}
      params[:q][:account_id_eq] = current_user.accounts.order(:code).first.id
    end
    @q = StatementAdjustment.order("id desc").ransack(params[:q])
    @statement_adjustments = @q.result.page(params[:page]).per(20)
  end

  # GET /statement_adjustments/1
  # GET /statement_adjustments/1.json
  def show
  end

  # GET /statement_adjustments/new
  def new
    @statement_adjustment = StatementAdjustment.new
  end

  # GET /statement_adjustments/1/edit
  def edit
  end

  # POST /statement_adjustments
  # POST /statement_adjustments.json
  def create
    @statement_adjustment = StatementAdjustment.new(statement_adjustment_params)

    respond_to do |format|
      if @statement_adjustment.save
        format.html {redirect_to @statement_adjustment, notice: 'Statement adjustment was successfully created.'}
        format.json {render :show, status: :created, location: @statement_adjustment}
      else
        format.html {render :new}
        format.json {render json: @statement_adjustment.errors, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /statement_adjustments/1
  # PATCH/PUT /statement_adjustments/1.json
  def update
    respond_to do |format|
      if @statement_adjustment.update(statement_adjustment_params)
        format.html {redirect_to @statement_adjustment, notice: 'Statement adjustment was successfully updated.'}
        format.json {render :show, status: :ok, location: @statement_adjustment}
      else
        format.html {render :edit}
        format.json {render json: @statement_adjustment.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /statement_adjustments/1
  # DELETE /statement_adjustments/1.json
  def destroy
    @statement_adjustment.destroy
    respond_to do |format|
      format.html {redirect_to statement_adjustments_url, notice: 'Statement adjustment was successfully destroyed.'}
      format.json {head :no_content}
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_statement_adjustment
    @statement_adjustment = StatementAdjustment.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def statement_adjustment_params
    params.require(:statement_adjustment).permit(:posted_on, :stated_on, :account_id, :account_code, :commission_code, :journal_code, :currency_code, :amount, :memo)
  end

  def trap_request
    flash[:danger] = "Changes are not allowed"
    redirect_to statement_adjustments_path
  end

end

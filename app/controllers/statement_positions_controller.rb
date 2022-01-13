class StatementPositionsController < ApplicationController
  before_action :set_statement_position, only: [:show]
  before_action :trap_request, only: [:edit, :update, :destroy]

  # GET /statement_positions
  # GET /statement_positions.json
  def index
    if params[:q].blank? and current_user.accounts.count > 0
      params[:q] = {}
      params[:q][:account_id_eq] = current_user.accounts.order(:code).first.id
    end
    @q = StatementPosition.order("id desc").ransack(params[:q])
    @q.sorts = ['stated_on', 'claim_code', 'traded_on', 'posted_on', 'price'] # if @q.sorts.empty?
    @statement_positions = @q.result.page(params[:page]).per(30)
  end

  # GET /statement_positions/1
  # GET /statement_positions/1.json
  def show
  end

  # GET /statement_positions/new
  def new
    @statement_position = StatementPosition.new
  end

  # GET /statement_positions/1/edit
  def edit
  end

  # POST /statement_positions
  # POST /statement_positions.json
  def create
    @statement_position = StatementPosition.new(statement_position_params)

    respond_to do |format|
      if @statement_position.save
        format.html {redirect_to @statement_position, notice: 'Statement position was successfully created.'}
        format.json {render :show, status: :created, location: @statement_position}
      else
        format.html {render :new}
        format.json {render json: @statement_position.errors, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /statement_positions/1
  # PATCH/PUT /statement_positions/1.json
  def update
    respond_to do |format|
      if @statement_position.update(statement_position_params)
        format.html {redirect_to @statement_position, notice: 'Statement position was successfully updated.'}
        format.json {render :show, status: :ok, location: @statement_position}
      else
        format.html {render :edit}
        format.json {render json: @statement_position.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /statement_positions/1
  # DELETE /statement_positions/1.json
  def destroy
    @statement_position.destroy
    respond_to do |format|
      format.html {redirect_to statement_positions_url, notice: 'Statement position was successfully destroyed.'}
      format.json {head :no_content}
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_statement_position
    @statement_position = StatementPosition.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def statement_position_params
    params.require(:statement_position).permit(:account_id, :account_code, :claim_code, :stated_on, :posted_on, :traded_on, :bot, :sld, :net, :price, :mark, :ote, :currency_code, :position_status_code)
  end

  def trap_request
    flash[:danger] = "Changes are not allowed"
    redirect_to statement_positions_path
  end

end

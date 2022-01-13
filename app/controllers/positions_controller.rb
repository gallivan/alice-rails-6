class PositionsController < ApplicationController
  before_action :set_position, only: [:show]
  before_action :trap_request, only: [:edit, :update, :destroy]

  # GET /positions
  # GET /positions.json
  def index
    if params[:q].blank? and current_user.accounts.count > 0
      params[:q] = {}
      params[:q][:account_id_eq] = current_user.accounts.order(:code).first.id
    end
    @q = Position.joins(:claim).ransack(params[:q])
    @q.sorts = ['claims.code', 'posted_on', 'price'] #if @q.sorts.empty?
    @positions = @q.result.page(params[:page]).per(30)
  end

  # GET /positions/1
  # GET /positions/1.json
  def show
  end

  # GET /positions/new
  def new
    @position = Position.new
  end

  # GET /positions/1/edit
  def edit
  end

  # POST /positions
  # POST /positions.json
  def create
    @position = Position.new(position_params)

    respond_to do |format|
      if @position.save
        format.html {redirect_to @position, notice: 'Position was successfully created.'}
        format.json {render :show, status: :created, location: @position}
      else
        format.html {render :new}
        format.json {render json: @position.errors, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /positions/1
  # PATCH/PUT /positions/1.json
  def update
    respond_to do |format|
      if @position.update(position_params)
        format.html {redirect_to @position, notice: 'Position was successfully updated.'}
        format.json {render :show, status: :ok, location: @position}
      else
        format.html {render :edit}
        format.json {render json: @position.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /positions/1
  # DELETE /positions/1.json
  def destroy
    @position.destroy
    respond_to do |format|
      format.html {redirect_to positions_url, notice: 'Position was successfully destroyed.'}
      format.json {head :no_content}
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_position
    @position = Position.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def position_params
    params.require(:position).permit(:account_id, :claim_id, :currency_id, :position_status_id, :posted_on, :traded_on, :price, :price_traded, :bot, :sld, :bot_off, :sld_off, :net, :mark, :ote)
  end

  def trap_request
    flash[:danger] = "Changes are not allowed"
    redirect_to positions_path
  end

end

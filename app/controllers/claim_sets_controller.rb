class ClaimSetsController < ApplicationController
  before_action :set_claim_set, only: [:show, :edit, :update, :destroy]

  # GET /claim_sets
  # GET /claim_sets.json
  def index
    @q = ClaimSet.ransack(params[:q])
    @claim_sets = @q.result.page(params[:page]).per(20)
  end

  # GET /claim_sets/1
  # GET /claim_sets/1.json
  def show
  end

  # GET /claim_sets/new
  def new
    @claim_set = ClaimSet.new
  end

  # GET /claim_sets/1/edit
  def edit
  end

  # POST /claim_sets
  # POST /claim_sets.json
  def create
    @claim_set = ClaimSet.new(claim_set_params)

    respond_to do |format|
      if @claim_set.save
        format.html { redirect_to @claim_set, notice: 'Claim set was successfully created.' }
        format.json { render :show, status: :created, location: @claim_set }
      else
        format.html { render :new }
        format.json { render json: @claim_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /claim_sets/1
  # PATCH/PUT /claim_sets/1.json
  def update
    respond_to do |format|
      if @claim_set.update(claim_set_params)
        format.html { redirect_to @claim_set, notice: 'Claim set was successfully updated.' }
        format.json { render :show, status: :ok, location: @claim_set }
      else
        format.html { render :edit }
        format.json { render json: @claim_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /claim_sets/1
  # DELETE /claim_sets/1.json
  def destroy
    @claim_set.destroy
    respond_to do |format|
      format.html { redirect_to claim_sets_url, notice: 'Claim set was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_claim_set
      @claim_set = ClaimSet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def claim_set_params
      params.require(:claim_set).permit(:code, :name)
    end
end

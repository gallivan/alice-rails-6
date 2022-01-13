class ClaimSubTypesController < ApplicationController
  before_action :set_claim_sub_type, only: [:show, :edit, :update, :destroy]

  # GET /claim_sub_types
  # GET /claim_sub_types.json
  def index
    @claim_sub_types = ClaimSubType.all
  end

  # GET /claim_sub_types/1
  # GET /claim_sub_types/1.json
  def show
  end

  # GET /claim_sub_types/new
  def new
    @claim_sub_type = ClaimSubType.new
  end

  # GET /claim_sub_types/1/edit
  def edit
  end

  # POST /claim_sub_types
  # POST /claim_sub_types.json
  def create
    @claim_sub_type = ClaimSubType.new(claim_sub_type_params)

    respond_to do |format|
      if @claim_sub_type.save
        format.html { redirect_to @claim_sub_type, notice: 'Claim sub type was successfully created.' }
        format.json { render :show, status: :created, location: @claim_sub_type }
      else
        format.html { render :new }
        format.json { render json: @claim_sub_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /claim_sub_types/1
  # PATCH/PUT /claim_sub_types/1.json
  def update
    respond_to do |format|
      if @claim_sub_type.update(claim_sub_type_params)
        format.html { redirect_to @claim_sub_type, notice: 'Claim sub type was successfully updated.' }
        format.json { render :show, status: :ok, location: @claim_sub_type }
      else
        format.html { render :edit }
        format.json { render json: @claim_sub_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /claim_sub_types/1
  # DELETE /claim_sub_types/1.json
  def destroy
    @claim_sub_type.destroy
    respond_to do |format|
      format.html { redirect_to claim_sub_types_url, notice: 'Claim sub type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_claim_sub_type
      @claim_sub_type = ClaimSubType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def claim_sub_type_params
      params.require(:claim_sub_type).permit(:code, :name)
    end
end

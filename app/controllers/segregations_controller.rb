class SegregationsController < ApplicationController
  before_action :set_segregation, only: [:show, :edit, :update, :destroy]

  # GET /segregations
  # GET /segregations.json
  def index
    @segregations = Segregation.all
  end

  # GET /segregations/1
  # GET /segregations/1.json
  def show
  end

  # GET /segregations/new
  def new
    @segregation = Segregation.new
  end

  # GET /segregations/1/edit
  def edit
  end

  # POST /segregations
  # POST /segregations.json
  def create
    @segregation = Segregation.new(segregation_params)

    respond_to do |format|
      if @segregation.save
        format.html { redirect_to @segregation, notice: 'Segregation was successfully created.' }
        format.json { render :show, status: :created, location: @segregation }
      else
        format.html { render :new }
        format.json { render json: @segregation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /segregations/1
  # PATCH/PUT /segregations/1.json
  def update
    respond_to do |format|
      if @segregation.update(segregation_params)
        format.html { redirect_to @segregation, notice: 'Segregation was successfully updated.' }
        format.json { render :show, status: :ok, location: @segregation }
      else
        format.html { render :edit }
        format.json { render json: @segregation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /segregations/1
  # DELETE /segregations/1.json
  def destroy
    @segregation.destroy
    respond_to do |format|
      format.html { redirect_to segregations_url, notice: 'Segregation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_segregation
      @segregation = Segregation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def segregation_params
      params.require(:segregation).permit(:code, :name, :note)
    end
end

class DealingVenuesController < ApplicationController
  before_action :set_dealing_venue, only: [:show, :edit, :update, :destroy]

  # GET /dealing_venues
  # GET /dealing_venues.json
  def index
    @dealing_venues = DealingVenue.all
  end

  # GET /dealing_venues/1
  # GET /dealing_venues/1.json
  def show
  end

  # GET /dealing_venues/new
  def new
    @dealing_venue = DealingVenue.new
  end

  # GET /dealing_venues/1/edit
  def edit
  end

  # POST /dealing_venues
  # POST /dealing_venues.json
  def create
    @dealing_venue = DealingVenue.new(dealing_venue_params)

    respond_to do |format|
      if @dealing_venue.save
        format.html { redirect_to @dealing_venue, notice: 'Dealing venue was successfully created.' }
        format.json { render :show, status: :created, location: @dealing_venue }
      else
        format.html { render :new }
        format.json { render json: @dealing_venue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dealing_venues/1
  # PATCH/PUT /dealing_venues/1.json
  def update
    respond_to do |format|
      if @dealing_venue.update(dealing_venue_params)
        format.html { redirect_to @dealing_venue, notice: 'Dealing venue was successfully updated.' }
        format.json { render :show, status: :ok, location: @dealing_venue }
      else
        format.html { render :edit }
        format.json { render json: @dealing_venue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dealing_venues/1
  # DELETE /dealing_venues/1.json
  def destroy
    @dealing_venue.destroy
    respond_to do |format|
      format.html { redirect_to dealing_venues_url, notice: 'Dealing venue was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dealing_venue
      @dealing_venue = DealingVenue.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dealing_venue_params
      params.require(:dealing_venue).permit(:entity_id, :dealing_venue_type_id, :code, :name)
    end
end

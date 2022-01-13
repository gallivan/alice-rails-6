class SystemTypesController < ApplicationController
  before_action :set_system_type, only: [:show, :edit, :update, :destroy]

  # GET /system_types
  # GET /system_types.json
  def index
    @system_types = SystemType.all
  end

  # GET /system_types/1
  # GET /system_types/1.json
  def show
  end

  # GET /system_types/new
  def new
    @system_type = SystemType.new
  end

  # GET /system_types/1/edit
  def edit
  end

  # POST /system_types
  # POST /system_types.json
  def create
    @system_type = SystemType.new(system_type_params)

    respond_to do |format|
      if @system_type.save
        format.html { redirect_to @system_type, notice: 'System type was successfully created.' }
        format.json { render :show, status: :created, location: @system_type }
      else
        format.html { render :new }
        format.json { render json: @system_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /system_types/1
  # PATCH/PUT /system_types/1.json
  def update
    respond_to do |format|
      if @system_type.update(system_type_params)
        format.html { redirect_to @system_type, notice: 'System type was successfully updated.' }
        format.json { render :show, status: :ok, location: @system_type }
      else
        format.html { render :edit }
        format.json { render json: @system_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /system_types/1
  # DELETE /system_types/1.json
  def destroy
    @system_type.destroy
    respond_to do |format|
      format.html { redirect_to system_types_url, notice: 'System type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_system_type
      @system_type = SystemType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def system_type_params
      params.require(:system_type).permit(:code, :name)
    end
end

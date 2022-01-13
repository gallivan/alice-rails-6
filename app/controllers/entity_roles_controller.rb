class EntityRolesController < ApplicationController
  before_action :set_entity_role, only: [:show, :edit, :update, :destroy]

  # GET /entity_roles
  # GET /entity_roles.json
  def index
    @entity_roles = EntityRole.all
  end

  # GET /entity_roles/1
  # GET /entity_roles/1.json
  def show
  end

  # GET /entity_roles/new
  def new
    @entity_role = EntityRole.new
  end

  # GET /entity_roles/1/edit
  def edit
  end

  # POST /entity_roles
  # POST /entity_roles.json
  def create
    @entity_role = EntityRole.new(entity_role_params)

    respond_to do |format|
      if @entity_role.save
        format.html { redirect_to @entity_role, notice: 'Entity role was successfully created.' }
        format.json { render :show, status: :created, location: @entity_role }
      else
        format.html { render :new }
        format.json { render json: @entity_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /entity_roles/1
  # PATCH/PUT /entity_roles/1.json
  def update
    respond_to do |format|
      if @entity_role.update(entity_role_params)
        format.html { redirect_to @entity_role, notice: 'Entity role was successfully updated.' }
        format.json { render :show, status: :ok, location: @entity_role }
      else
        format.html { render :edit }
        format.json { render json: @entity_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /entity_roles/1
  # DELETE /entity_roles/1.json
  def destroy
    @entity_role.destroy
    respond_to do |format|
      format.html { redirect_to entity_roles_url, notice: 'Entity role was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_entity_role
      @entity_role = EntityRole.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def entity_role_params
      params.require(:entity_role).permit(:entity_id, :role_id)
    end
end

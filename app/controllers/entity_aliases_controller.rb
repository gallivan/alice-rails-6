class EntityAliasesController < ApplicationController
  before_action :set_entity_alias, only: [:show, :edit, :update, :destroy]

  # GET /entity_aliases
  # GET /entity_aliases.json
  def index
    @entity_aliases = EntityAlias.all
  end

  # GET /entity_aliases/1
  # GET /entity_aliases/1.json
  def show
  end

  # GET /entity_aliases/new
  def new
    @entity_alias = EntityAlias.new
  end

  # GET /entity_aliases/1/edit
  def edit
  end

  # POST /entity_aliases
  # POST /entity_aliases.json
  def create
    @entity_alias = EntityAlias.new(entity_alias_params)

    respond_to do |format|
      if @entity_alias.save
        format.html { redirect_to @entity_alias, notice: 'Entity alias was successfully created.' }
        format.json { render :show, status: :created, location: @entity_alias }
      else
        format.html { render :new }
        format.json { render json: @entity_alias.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /entity_aliases/1
  # PATCH/PUT /entity_aliases/1.json
  def update
    respond_to do |format|
      if @entity_alias.update(entity_alias_params)
        format.html { redirect_to @entity_alias, notice: 'Entity alias was successfully updated.' }
        format.json { render :show, status: :ok, location: @entity_alias }
      else
        format.html { render :edit }
        format.json { render json: @entity_alias.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /entity_aliases/1
  # DELETE /entity_aliases/1.json
  def destroy
    @entity_alias.destroy
    respond_to do |format|
      format.html { redirect_to entity_aliases_url, notice: 'Entity alias was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_entity_alias
      @entity_alias = EntityAlias.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def entity_alias_params
      params.require(:entity_alias).permit(:system_id, :entity_id, :code)
    end
end

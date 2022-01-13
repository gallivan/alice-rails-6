class LedgerEntryTypesController < ApplicationController
  before_action :set_ledger_entry_type, only: [:show, :edit, :update, :destroy]

  # GET /ledger_entry_types
  # GET /ledger_entry_types.json
  def index
    @ledger_entry_types = LedgerEntryType.all
  end

  # GET /ledger_entry_types/1
  # GET /ledger_entry_types/1.json
  def show
  end

  # GET /ledger_entry_types/new
  def new
    @ledger_entry_type = LedgerEntryType.new
  end

  # GET /ledger_entry_types/1/edit
  def edit
  end

  # POST /ledger_entry_types
  # POST /ledger_entry_types.json
  def create
    @ledger_entry_type = LedgerEntryType.new(ledger_entry_type_params)

    respond_to do |format|
      if @ledger_entry_type.save
        format.html { redirect_to @ledger_entry_type, notice: 'Ledger entry type was successfully created.' }
        format.json { render :show, status: :created, location: @ledger_entry_type }
      else
        format.html { render :new }
        format.json { render json: @ledger_entry_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ledger_entry_types/1
  # PATCH/PUT /ledger_entry_types/1.json
  def update
    respond_to do |format|
      if @ledger_entry_type.update(ledger_entry_type_params)
        format.html { redirect_to @ledger_entry_type, notice: 'Ledger entry type was successfully updated.' }
        format.json { render :show, status: :ok, location: @ledger_entry_type }
      else
        format.html { render :edit }
        format.json { render json: @ledger_entry_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ledger_entry_types/1
  # DELETE /ledger_entry_types/1.json
  def destroy
    @ledger_entry_type.destroy
    respond_to do |format|
      format.html { redirect_to ledger_entry_types_url, notice: 'Ledger entry type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ledger_entry_type
      @ledger_entry_type = LedgerEntryType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ledger_entry_type_params
      params.require(:ledger_entry_type).permit(:code, :name)
    end
end

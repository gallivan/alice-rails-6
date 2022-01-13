class LedgerEntriesController < ApplicationController
  before_action :set_ledger_entry, only: [:show, :edit, :update, :destroy]

  # GET /ledger_entries
  # GET /ledger_entries.json
  def index
    @q = LedgerEntry.ransack(params[:q])
    @ledger_entries = @q.result.page(params[:page]).per(20)
  end

  # GET /ledger_entries/1
  # GET /ledger_entries/1.json
  def show
  end

  # GET /ledger_entries/new
  def new
    @ledger_entry = LedgerEntry.new
  end

  # GET /ledger_entries/1/edit
  def edit
  end

  # POST /ledger_entries
  # POST /ledger_entries.json
  def create
    @ledger_entry = LedgerEntry.new(ledger_entry_params)

    respond_to do |format|
      if @ledger_entry.save
        format.html { redirect_to @ledger_entry, notice: 'Ledger entry was successfully created.' }
        format.json { render :show, status: :created, location: @ledger_entry }
      else
        format.html { render :new }
        format.json { render json: @ledger_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ledger_entries/1
  # PATCH/PUT /ledger_entries/1.json
  def update
    respond_to do |format|
      if @ledger_entry.update(ledger_entry_params)
        format.html { redirect_to @ledger_entry, notice: 'Ledger entry was successfully updated.' }
        format.json { render :show, status: :ok, location: @ledger_entry }
      else
        format.html { render :edit }
        format.json { render json: @ledger_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ledger_entries/1
  # DELETE /ledger_entries/1.json
  def destroy
    @ledger_entry.destroy
    respond_to do |format|
      format.html { redirect_to ledger_entries_url, notice: 'Ledger entry was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ledger_entry
      @ledger_entry = LedgerEntry.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ledger_entry_params
      params.require(:ledger_entry).permit(:ledger_id, :ledger_entry_type_id, :account_id, :currency_id, :posted_on, :as_of_on, :amount, :memo)
    end
end

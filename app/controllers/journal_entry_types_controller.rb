class JournalEntryTypesController < ApplicationController
  before_action :set_journal_entry_type, only: [:show, :edit, :update, :destroy]

  # GET /journal_entry_types
  # GET /journal_entry_types.json
  def index
    @journal_entry_types = JournalEntryType.all
  end

  # GET /journal_entry_types/1
  # GET /journal_entry_types/1.json
  def show
  end

  # GET /journal_entry_types/new
  def new
    @journal_entry_type = JournalEntryType.new
  end

  # GET /journal_entry_types/1/edit
  def edit
  end

  # POST /journal_entry_types
  # POST /journal_entry_types.json
  def create
    @journal_entry_type = JournalEntryType.new(journal_entry_type_params)

    respond_to do |format|
      if @journal_entry_type.save
        format.html { redirect_to @journal_entry_type, notice: 'Journal entry type was successfully created.' }
        format.json { render :show, status: :created, location: @journal_entry_type }
      else
        format.html { render :new }
        format.json { render json: @journal_entry_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /journal_entry_types/1
  # PATCH/PUT /journal_entry_types/1.json
  def update
    respond_to do |format|
      if @journal_entry_type.update(journal_entry_type_params)
        format.html { redirect_to @journal_entry_type, notice: 'Journal entry type was successfully updated.' }
        format.json { render :show, status: :ok, location: @journal_entry_type }
      else
        format.html { render :edit }
        format.json { render json: @journal_entry_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /journal_entry_types/1
  # DELETE /journal_entry_types/1.json
  def destroy
    @journal_entry_type.destroy
    respond_to do |format|
      format.html { redirect_to journal_entry_types_url, notice: 'Journal entry type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_journal_entry_type
      @journal_entry_type = JournalEntryType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def journal_entry_type_params
      params.require(:journal_entry_type).permit(:code, :name)
    end
end

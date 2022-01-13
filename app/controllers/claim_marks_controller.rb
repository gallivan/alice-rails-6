class ClaimMarksController < ApplicationController
  before_action :set_claim_mark, only: [:show, :edit, :update, :destroy]

  # GET /claim_marks
  # GET /claim_marks.json
  def index
    @q = ClaimMark.order(:posted_on).ransack(params[:q])
    @claim_marks = @q.result.page(params[:page]).per(20)
  end

  # GET /claim_marks/1
  # GET /claim_marks/1.json
  def show
  end

  # GET /claim_marks/new
  def new
    @claim_mark = ClaimMark.new
  end

  # GET /claim_marks/1/edit
  def edit
  end

  # POST /claim_marks
  # POST /claim_marks.json
  def create
    @claim_mark = ClaimMark.new(claim_mark_params)

    respond_to do |format|
      if @claim_mark.save
        format.html { redirect_to @claim_mark, notice: 'Claim mark was successfully created.' }
        format.json { render :show, status: :created, location: @claim_mark }
      else
        format.html { render :new }
        format.json { render json: @claim_mark.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /claim_marks/1
  # PATCH/PUT /claim_marks/1.json
  def update
    respond_to do |format|
      if @claim_mark.update(claim_mark_params)
        format.html { redirect_to @claim_mark, notice: 'Claim mark was successfully updated.' }
        format.json { render :show, status: :ok, location: @claim_mark }
      else
        format.html { render :edit }
        format.json { render json: @claim_mark.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /claim_marks/1
  # DELETE /claim_marks/1.json
  def destroy
    @claim_mark.destroy
    respond_to do |format|
      format.html { redirect_to claim_marks_url, notice: 'Claim mark was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_claim_mark
      @claim_mark = ClaimMark.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def claim_mark_params
      params.require(:claim_mark).permit(:system_id, :claim_id, :posted_on, :mark)
    end
end

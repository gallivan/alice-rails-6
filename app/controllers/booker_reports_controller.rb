class BookerReportsController < ApplicationController
  before_action :set_booker_report, only: [:show, :edit, :update, :destroy]

  # GET /booker_reports
  # GET /booker_reports.json
  def index
    @q = BookerReport.order(:id).ransack(params[:q])
    @booker_reports = @q.result.page(params[:page]).per(20)
  end

  # GET /booker_reports/1
  # GET /booker_reports/1.json
  def show
  end

  # GET /booker_reports/new
  def new
    @booker_report = BookerReport.new
  end

  # GET /booker_reports/1/edit
  def edit
  end

  # POST /booker_reports
  # POST /booker_reports.json
  def create
    @booker_report = BookerReport.new(booker_report_params)

    respond_to do |format|
      if @booker_report.save
        format.html { redirect_to @booker_report, notice: 'Booker report was successfully created.' }
        format.json { render :show, status: :created, location: @booker_report }
      else
        format.html { render :new }
        format.json { render json: @booker_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /booker_reports/1
  # PATCH/PUT /booker_reports/1.json
  def update
    respond_to do |format|
      if @booker_report.update(booker_report_params)
        format.html { redirect_to @booker_report, notice: 'Booker report was successfully updated.' }
        format.json { render :show, status: :ok, location: @booker_report }
      else
        format.html { render :edit }
        format.json { render json: @booker_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /booker_reports/1
  # DELETE /booker_reports/1.json
  def destroy
    @booker_report.destroy
    respond_to do |format|
      format.html { redirect_to booker_reports_url, notice: 'Booker report was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /booker_reports/1/redo/
  def redo
    report = BookerReport.find(params[:id])

    BookerReport.do_redo(report)

    respond_to do |format|
      @booker_report = report
      format.html { redirect_to @booker_report, notice: 'BookerReport was successfully redone.' }
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booker_report
      @booker_report = BookerReport.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def booker_report_params
      params.require(:booker_report).permit(:posted_on, :kind, :fate, :data, :goof_error, :goof_trace)
    end
end

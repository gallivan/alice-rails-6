class PickerReportsController < ApplicationController
  before_action :set_picker_report, only: [:show, :edit, :update, :destroy]

  # GET /picker_reports
  # GET /picker_reports.json
  def index
    @q = PickerReport.order(:id).ransack(params[:q])
    @picker_reports = @q.result.page(params[:page]).per(20)
  end

  # GET /picker_reports/1
  # GET /picker_reports/1.json
  def show
  end

  # GET /picker_reports/new
  def new
    @picker_report = PickerReport.new
  end

  # GET /picker_reports/1/edit
  def edit
  end

  # POST /picker_reports
  # POST /picker_reports.json
  def create
    @picker_report = PickerReport.new(picker_report_params)

    respond_to do |format|
      if @picker_report.save
        format.html { redirect_to @picker_report, notice: 'Picker report was successfully created.' }
        format.json { render :show, status: :created, location: @picker_report }
      else
        format.html { render :new }
        format.json { render json: @picker_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /picker_reports/1
  # PATCH/PUT /picker_reports/1.json
  def update
    respond_to do |format|
      if @picker_report.update(picker_report_params)
        format.html { redirect_to @picker_report, notice: 'Picker report was successfully updated.' }
        format.json { render :show, status: :ok, location: @picker_report }
      else
        format.html { render :edit }
        format.json { render json: @picker_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /picker_reports/1
  # DELETE /picker_reports/1.json
  def destroy
    @picker_report.destroy
    respond_to do |format|
      format.html { redirect_to picker_reports_url, notice: 'Picker report was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_picker_report
      @picker_report = PickerReport.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def picker_report_params
      params.require(:picker_report).permit(:posted_on, :kind, :fate, :data, :goof_error, :goof_trace)
    end
end

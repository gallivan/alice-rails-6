class PackerReportsController < ApplicationController
  before_action :set_packer_report, only: [:show, :edit, :update, :destroy]

  # GET /packer_reports
  # GET /packer_reports.json
  def index
    @q = PackerReport.order(:id).ransack(params[:q])
    @packer_reports = @q.result.page(params[:page]).per(20)
  end

  # GET /packer_reports/1
  # GET /packer_reports/1.json
  def show
  end

  # GET /packer_reports/new
  def new
    @packer_report = PackerReport.new
  end

  # GET /packer_reports/1/edit
  def edit
  end

  # POST /packer_reports
  # POST /packer_reports.json
  def create
    @packer_report = PackerReport.new(packer_report_params)

    respond_to do |format|
      if @packer_report.save
        format.html { redirect_to @packer_report, notice: 'Packer report was successfully created.' }
        format.json { render :show, status: :created, location: @packer_report }
      else
        format.html { render :new }
        format.json { render json: @packer_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /packer_reports/1
  # PATCH/PUT /packer_reports/1.json
  def update
    respond_to do |format|
      if @packer_report.update(packer_report_params)
        format.html { redirect_to @packer_report, notice: 'Packer report was successfully updated.' }
        format.json { render :show, status: :ok, location: @packer_report }
      else
        format.html { render :edit }
        format.json { render json: @packer_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /packer_reports/1
  # DELETE /packer_reports/1.json
  def destroy
    @packer_report.destroy
    respond_to do |format|
      format.html { redirect_to packer_reports_url, notice: 'Packer report was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /packer_reports/1/redo/
  def redo
    report = PackerReport.find(params[:id])

    PackerReport.do_redo(report)

    respond_to do |format|
      @packer_report = report
      format.html { redirect_to @packer_report, notice: 'Packer report was successfully updated.' }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_packer_report
    @packer_report = PackerReport.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def packer_report_params
    params.require(:packer_report).permit(:posted_on, :kind, :fate, :data, :goof_error, :goof_trace)
  end

end

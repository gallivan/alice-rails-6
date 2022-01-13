ActiveAdmin.register Report do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  menu parent: 'Reports'

  actions :index, :show

  filter :report_type
  filter :format_type
  filter :memo
  filter :posted_on

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :posted_on
    column :memo
    column :access do |obj|
      if obj.format_type.code =~ /PDF/
        link_to obj.format_type.code, download_pdf_admin_reports_path(id: obj.id, format: :pdf)
      elsif obj.format_type.code =~ /TXT/
        link_to obj.format_type.code, download_txt_admin_reports_path(id: obj.id, format: :txt)
      else
        "Format #{obj.format_type.code} unknown."
      end
    end
    column :redistribute do |obj|
      if obj.report_type.code.match(/LTR-CFTC|LTR-CME/)
        link_to 'redistribute', redistribute_admin_reports_path(id: obj.id)
      end
    end
  end

  # https://codedump.io/share/edtvfUFKUvRO/1/download-a-pdf-from-within-active-admin

  collection_action :download_pdf, method: :get do
    report = Report.find(params[:id])
    send_file report.location
  end

  collection_action :download_txt, method: :get do
    report = Report.find(params[:id])
    send_file report.location
  end

  collection_action :redistribute, method: :get do
    report = Report.find(params[:id])
    Rails.logger.info("Redistributing report #{report.id} with location #{report.location}")
    if Rails.env.production?
      begin
        if report.report_type.code == 'LTR-CFTC'
          (Workers::LargeTraderReportCftc.new).distribute(report.location)
        elsif report.report_type.code == 'LTR-CME'
          (Workers::LargeTraderReportCme.new).distribute(report.location)
        else
          redirect_to admin_report_path(id: report.id), notice: 'Report not sent. No known Worker.'
        end
        redirect_to admin_report_path(id: report.id), notice: "Report sent."
      rescue Exception => e
        redirect_to admin_report_path(id: report.id), notice: "Report not sent. Exception: #{e.message}"
      end
    else
      redirect_to admin_report_path(id: report.id), notice: 'Report not sent. Not the production environment.'
    end
  end

end

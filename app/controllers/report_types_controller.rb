class ReportTypesController < InheritedResources::Base

  private

    def report_type_params
      params.require(:report_type).permit(:code, :name)
    end
end


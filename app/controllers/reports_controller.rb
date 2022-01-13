class ReportsController < InheritedResources::Base

  private

    def report_params
      params.require(:report).permit(:report_type_id, :format_type_id, :memo, :location)
    end
end


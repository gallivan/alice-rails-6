class FormatTypesController < InheritedResources::Base

  private

    def format_type_params
      params.require(:format_type).permit(:code, :name)
    end
end


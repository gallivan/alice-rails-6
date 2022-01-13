class ChargeableTypesController < InheritedResources::Base

  private

    def chargeable_type_params
      params.require(:chargeable_type).permit(:code, :name)
    end
end


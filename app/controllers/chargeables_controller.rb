class ChargeablesController < InheritedResources::Base

  private

    def chargeable_params
      params.require(:chargeable).permit(:chargeable_type_id, :claim_set_id, :currency_id, :amount, :begun_on, :ended_on)
    end
end


class ChargesController < InheritedResources::Base

  private

    def charge_params
      params.require(:charge).permit(:account_id, :chargeable_id, :currency_id, :segregation_id, :amount, :memo, :posted_on, :as_of_on)
    end
end


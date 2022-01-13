ActiveAdmin.register ChargesByExchangeAndPostedOnProxy do

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

  menu parent: 'Helpers', label: 'Charges by Exchange'

  actions :index

  filter :posted_on
  filter :entity
  filter :currency
  filter :chargeable_type

  index title: 'Charges by Exchange' do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :posted_on
    column :entity do |obj|
      obj.entity.code
    end
    column :chargeable_type do |obj|
      obj.chargeable_type.code
    end
    column :amount, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.amount, precision: 2), delimiter: ",")
    end
    column :currency do |obj|
      obj.currency.code
    end
  end

end

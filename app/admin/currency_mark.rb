ActiveAdmin.register CurrencyMark do

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

  permit_params :currency_id, :posted_on, :mark

  menu parent: 'Reference'

  filter :currency
  filter :posted_on

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :currency do |obj|
      obj.currency.code
    end
    column :posted_on
    column :mark, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.mark, precision: 6), delimiter: ",")
    end
    column :created_at
    column :updated_at
    actions
  end
  
end

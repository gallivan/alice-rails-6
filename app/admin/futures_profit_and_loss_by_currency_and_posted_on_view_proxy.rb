ActiveAdmin.register FuturesProfitAndLossByCurrencyAndPostedOnViewProxy do

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

  menu parent: 'Helpers', label: 'Futures Profit & Loss by Currency'

  actions :index

  filter :currency
  filter :posted_on

  index title: 'Futures Profit & Loss by Currency' do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :posted_on
    column :futures_profit_and_loss, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.pnl_futures, precision: 2), delimiter: ",")
    end
    column :currency do |obj|
      obj.currency.code
    end
    column :kind
  end

  csv do
    column :posted_on
    column :futures_profit_and_loss, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.pnl_futures, precision: 2), delimiter: ",")
    end
    column :currency do |obj|
      obj.currency.code
    end
    column :kind
  end

end

ActiveAdmin.register LedgerBalanceByCurrencyAndPostedOnViewProxy do

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

  menu parent: 'Helpers', label: 'Ledger Balance by Currency'

  actions :index

  filter :currency
  filter :posted_on

  ActiveAdmin.register LedgerBalanceByCurrencyAndPostedOnViewProxy do
    config.sort_order = 'posted_on_desc'
  end

  index title: 'Ledger Balance by Currency' do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :posted_on
    column :ledger_balance, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.ledger_balance, precision: 2), delimiter: ",")
    end
    column :currency do |obj|
      obj.currency.code
    end
    column :kind
  end

  csv do
    column :posted_on
    column :ledger_balance, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.ledger_balance, precision: 2), delimiter: ",")
    end
    column :currency do |obj|
      obj.currency.code
    end
    column :kind
  end

end

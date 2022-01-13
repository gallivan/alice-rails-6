ActiveAdmin.register Margin do
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

  menu parent: 'Margin'

  actions :index, :show

  filter :portfolio_account_code, collection: proc { Account.pluck(:code).sort }, as: :select, label: 'Account'
  filter :margin_status, label: 'Status'
  filter :posted_on

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :portfolio do |obj|
      obj.portfolio.account.code
    end
    column :portfolio
    column :margin_calculator
    column :margin_status
    column :initial, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.initial, precision: 2), delimiter: ",")
    end
    column :maintenance, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.maintenance, precision: 2), delimiter: ",")
    end
    column :currency do |obj|
      obj.currency.code
    end
    column :posted_on
    column :created_at
    column :updated_at
    actions
  end

end

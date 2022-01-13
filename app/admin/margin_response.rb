ActiveAdmin.register MarginResponse do
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

  filter :margin_request_margin_portfolio_account_code, collection: proc { Account.pluck(:code).sort }, as: :select, label: 'Account'
  filter :margin_response_status, label: 'Status'
  filter :posted_on

  actions :index, :show

end

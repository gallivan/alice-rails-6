ActiveAdmin.register StatementPositionNetting do

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

  menu parent: 'Statement'

  actions :index, :show

  filter :account_code, collection: proc { Account.pluck(:code).sort }, as: :select
  filter :claim_name, collection: proc { Claim.pluck(:name).sort }, as: :select
  filter :netting_code, collection: proc { PositionNettingType.pluck(:code).sort }, as: :select
  filter :stated_on
  filter :posted_on

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :stated_on
    column :posted_on
    column :account do |obj|
      obj.account.code
    end
    column :claim_name
    column :netting_code
    column :bot_price_traded, class: :number
    column :sld_price_traded, class: :number
    column :done, class: :number
    column :price_traded, class: :number
    column :pnl, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.pnl, precision: 2), delimiter: ",")
    end
    column :currency_code
    actions
  end

end

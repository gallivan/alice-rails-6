ActiveAdmin.register StatementMoneyLine do

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

  menu parent: "Statement"

  actions :index, :show

  filter :account_code, collection: proc { Account.pluck(:code).sort }, as: :select
  filter :kind, collection: proc { ['HELD', 'BASE'] }, as: :select
  filter :currency_code, collection: proc { Currency.pluck(:code).sort }, as: :select
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
    column :kind
    column :seg_code do |obj|
          obj.segregation_code
    end
    column :beg_bal, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.beginning_balance, precision: 2), delimiter: ",")
    end
    column :charges, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.charges, precision: 2), delimiter: ",")
    end
    column :adjs, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.adjustments, precision: 2), delimiter: ",")
    end
    column :pnl, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.pnl_futures, precision: 2), delimiter: ",")
    end
    column :legr_bal, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.ledger_balance, precision: 2), delimiter: ",")
    end
    column :OTE, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.open_trade_equity, precision: 2), delimiter: ",")
    end
    column :cash_bal, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.cash_account_balance, precision: 2), delimiter: ",")
    end
    column :net_liq, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.net_liquidating_balance, precision: 2), delimiter: ",")
    end
    column :currency_code
    column :currency_mark, class: :number
    actions
  end
end

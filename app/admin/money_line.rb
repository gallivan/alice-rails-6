ActiveAdmin.register MoneyLine do

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

  menu parent: 'Bookkeeping'

  actions :index, :show

  filter :account_code, collection: proc { Account.pluck(:code).sort }, as: :select
  filter :kind, collection: proc { ['HELD', 'BASE'] }, as: :select
  filter :currency_name, collection: proc { Currency.pluck(:name).sort }, as: :select
  filter :net_liquidating_balance
  filter :posted_on

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :posted_on
    column :account do |obj|
      obj.account.code
    end
    column :kind
    column :seg do |obj|
      obj.segregation.code
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
    column :currency do |obj|
      obj.currency.code
    end
    column :fx_rate, class: :number do |obj|
      obj.currency.currency_marks.posted_on(obj.posted_on).first.mark
    end
    actions
  end

  index as: ActiveAdmin::Views::IndexAsTable do
    column :posted_on
    column :account do |obj|
      obj.account.code
    end
  end

  csv do
    column :posted_on
    column :account do |obj|
      obj.account.code
    end
    column :kind do |obj|
      obj.kind
    end
    column :seg do |obj|
      obj.segregation.code
    end
    column :beg_bal do |obj|
      obj.beginning_balance
    end
    column :charges do |obj|
      obj.charges
    end
    column :adj do |obj|
      obj.adjustments
    end
    column :pnl do |obj|
      obj.pnl_futures
    end
    column :ledger do |obj|
      obj.ledger_balance
    end
    column :ote do |obj|
      obj.open_trade_equity
    end
    column :net_liq do |obj|
      obj.net_liquidating_balance
    end
    column :currency do |obj|
      obj.currency.code
    end
    column :fx_rate, class: :number do |obj|
      obj.currency.currency_marks.posted_on(obj.posted_on).first.mark
    end
  end

end

ActiveAdmin.register MoneyLine, :as => 'Balancer' do

  menu parent: 'Helpers'

  actions :index

  filter :account_code, collection: proc { Account.pluck(:code).sort }, as: :select
  filter :kind, collection: proc { ['HELD', 'BASE'] }, as: :select
  filter :posted_on
  filter :currency

  index do
    column :posted_on
    column :account do |obj|
      obj.account.code
    end
    column :pnl, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.pnl_futures, precision: 2), delimiter: ",")
    end
    column :ote, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.open_trade_equity, precision: 2), delimiter: ",")
    end
    column :charges, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.charges, precision: 3), delimiter: ",")
    end
    column :currency do |obj|
      obj.currency.code
    end
  end

  csv do
    column :posted_on
    column :account do |obj|
      obj.account.code
    end
    column :pnl do |obj|
      obj.pnl_futures
    end
    column :ote do |obj|
      obj.open_trade_equity
    end
    column :charges do |obj|
      obj.charges
    end
    column :currency do |obj|
      obj.currency.code
    end
  end
end

ActiveAdmin.register LedgerEntry do

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


  filter :account_code, collection: proc { Account.pluck(:code).sort }, as: :select
  filter :ledger_entry_type_name, collection: proc { LedgerEntryType.pluck(:name).sort }, as: :select
  filter :currency_name, collection: proc { Currency.pluck(:name).sort }, as: :select
  filter :memo
  filter :posted_on

  actions :index, :show

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :account do |obj|
      obj.account.code
    end
    column :posted_on
    column :as_of_on
    column :ledger do |obj|
      obj.ledger.code
    end
    column :ledger_entry_type do |obj|
      obj.ledger_entry_type.name
    end
    column :amount, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.amount, precision: 3), delimiter: ",")
    end
    column :currency do |obj|
      obj.currency.code
    end
    column :segregation do |obj|
      obj.segregation.code
    end
    column :memo
    actions
  end

end

ActiveAdmin.register StatementAdjustment do

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
  filter :adjustment_code, collection: proc { AdjustmentType.pluck(:code).sort }, as: :select
  # filter :journal_code, collection: proc { Journal.pluck(:code).sort}, as: :select
  filter :stated_on
  filter :posted_on
  filter :memo

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :account do |obj|
      obj.account.code
    end
    column :stated_on
    column :posted_on
    column :amount, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.amount, precision: 2), delimiter: ",")
    end
    column :currency_code
    column :memo
    actions
  end

end

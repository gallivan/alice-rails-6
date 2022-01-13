ActiveAdmin.register Charge do

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
  filter :posted_on
  filter :memo_includes, as: :string, label: 'MEMO INCLUDES'

  index do
    column :posted_on
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :account do |obj|
      obj.account.code
    end
    column :type do |obj|
      obj.chargeable.chargeable_type.code
    end
    column :amount, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.amount, precision: 2), delimiter: ",")
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

  csv do
    column :posted_on
    column :account do |obj|
      obj.account.code
    end
    column :memo
    column :type do |obj|
      obj.chargeable.chargeable_type.code
    end
    column :amount, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.amount, precision: 2), delimiter: ",")
    end
    column :currency do |obj|
      obj.currency.code
    end
    column :seg do |obj|
      obj.segregation.code
    end
  end


end

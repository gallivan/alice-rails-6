ActiveAdmin.register Adjustment do

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

  permit_params :account_id, :currency_id, :adjustment_type_id, :amount, :posted_on, :as_of_on, :segregation_id, :memo

  menu parent: 'Bookkeeping'

  filter :account_code, collection: proc { Account.pluck(:code).sort }, as: :select
  filter :posted_on
  filter :as_of_on
  filter :memo
  filter :memo_includes, as: :string, label: 'MEMO INCLUDES'

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :account do |obj|
      obj.account.code
    end
    column :posted_on
    column :as_of_on
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

  form do |f|
    f.semantic_errors
    inputs 'Details' do
      f.input :adjustment_type
      f.input :account
      f.input :currency
      f.input :segregation_id, :as => :select, :collection => Segregation.where("code not like 'SEGB'").order(:code).map {|u| [u.code, u.id]}, include_blank: true
      f.input :amount
      f.input :posted_on, as: :datepicker #, datepicker_options: { min_date: "2013-10-08",        max_date: "+3D" }
      f.input :as_of_on, as: :datepicker #, datepicker_options: { min_date: "2013-10-08",        max_date: "+3D" }
      f.input :memo
    end
    f.actions
  end

  controller do
    def create
      @adjustment = Builders::AdjustmentBuilder.build(params[:adjustment])
      super
    end

    def update
      params[:adjustment][:id] = params[:id]
      @adjustment = Builders::AdjustmentBuilder.update(params[:adjustment])
      super
    end

    def destroy
      @adjustment = Builders::AdjustmentBuilder.destroy(params)
      super
    end
  end

  csv do
    column :posted_on
    column :as_of_on
    column :account do |obj|
      obj.account.code
    end
    column :memo
    column :adjustment_type do |obj|
      obj.adjustment_type.code
    end
    column :seg do |obj|
      obj.segregation.code
    end
    column :amount
    column :currency do |obj|
      obj.currency.code
    end
  end

end

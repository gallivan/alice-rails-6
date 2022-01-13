ActiveAdmin.register Chargeable do

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

  permit_params :chargeable_type_id, :claim_set_id, :currency_id, :amount, :begun_on, :ended_on

  menu parent: 'Reference'

  filter :claim_set_id, collection: proc { ClaimSet.order(:name).all }, as: :select
  filter :chargeable_type
  filter :amount

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :chargeable_type
    column :claim_set
    column :amount, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.amount, precision: 3), delimiter: ",")
    end
    column :currency do |obj|
      obj.currency.code
    end
    column :begun_on
    column :ended_on
    actions
  end

  form do |f|
    f.semantic_errors
    inputs 'Details' do
      input :chargeable_type_id, as: :select, collection: ChargeableType.order(:name).all.map { |t| [t.name, t.id] }, :include_blank => false
      input :claim_set_id, as: :select, collection: ClaimSet.order(:name).all.map { |s| [s.name, s.id] }, :include_blank => false
      input :currency_id, as: :select, collection: Currency.order(:name).all.map { |c| [c.name, c.id] }, :include_blank => false
      input :amount
      #input :begun_on, as: :datepicker #, datepicker_options: { min_date: "2013-10-08",        max_date: "+3D" }
      #input :ended_on, as: :datepicker #, datepicker_options: { min_date: "2013-10-08",        max_date: "+3D" }

      input :begun_on, as: :datepicker, datepicker_options: { min_date: Date.today,        max_date: "+3D" }
      input :ended_on, as: :datepicker, datepicker_options: { min_date: 5.years.from_now,  max_date: "+10Y" }
    end
    actions
  end

  csv do
    column :claim_set do |obj|
      obj.claim_set.name
    end
    column :chargeable_type do |obj|
      obj.chargeable_type.code
    end
    column :amount, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.amount, precision: 3), delimiter: ",")
    end
    column :currency do |obj|
      obj.currency.code
    end
    column :begun_on
    column :ended_on
  end

end

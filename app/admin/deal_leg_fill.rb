ActiveAdmin.register DealLegFill do

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

  menu parent: "Dealing"

  permit_params :system_id, :dealing_venue_id, :account_id, :claim_id, :done, :price, :price_traded, :posted_on, :traded_on

  filter :account_code, collection: proc { Account.pluck(:code).sort }, as: :select
  filter :claim_name, collection: proc { Claim.pluck(:name).sort }, as: :select
  filter :posted_on
  filter :done
  filter :price

  actions :all, :except => [:edit]

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end

    column :account
    column :posted_on
    column :traded_on
    column :claim
    column :done, class: :number do |obj|
      number_with_delimiter(obj.done.to_i, delimiter: ",")
    end
    column :price, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.price, precision: 8), delimiter: ",")
    end
    column :price_traded, class: :number do |obj|
      obj.price_traded
    end
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys

    inputs 'Details' do
      para "Decimal: CBT:S|C|W|KW 3.25"
      para "Fractional: CBT:S|C|W|KW 3.60-1/4"
      para "Decimal: CBT:21|25|26 108.1484375"
      para "Fractional: CBT:21|25|26 108-047"
      para "Decimal: CBT:21|25|26 108.0"
      para "Fractional: CBT:21|25|26 108-000"
      input :system_id, :as => :select, :collection => System.all.order(:name).map {|u| [u.name, u.id]}, :include_blank => false
      input :dealing_venue_id, :as => :select, :collection => DealingVenue.all.order(:name).map {|u| [u.name, u.id]}, :include_blank => false
      input :account_id, :as => :select, :collection => Account.all.order(:code).map {|u| [u.code, u.id]}, :include_blank => false
      input :claim_id, :as => :select, :collection => Claim.all.order(:name).map {|u| [u.name, u.id]}, :include_blank => false
      input :done, input_html: {value: params[:done]}
      input :price, input_html: {value: params[:price]}
      input :price_traded, input_html: {value: params[:price_traded]}
      input :posted_on, as: :datepicker #, datepicker_options: { min_date: "2013-10-08",        max_date: "+3D" }
      input :traded_on, as: :datepicker #, datepicker_options: { min_date: "2013-10-08",        max_date: "+3D" }
    end
    actions
  end

  # .field
  #   = f.input :posted_on, as: :date, html5: true, :input_html => { :value => @deal_leg_fill.posted_on || Date.today}
  # .field
  #   = f.input :traded_on, as: :date, html5: true, :input_html => { :value => @deal_leg_fill.traded_on || Date.today}

  controller do
    def create

      puts '*' * 50
      puts params
      puts '*' * 50

      dlf_params = params['deal_leg_fill']

      dlf_params.keys.each do |key|
        dlf_params[(key.to_sym rescue key) || key] = dlf_params.delete(key)
      end

      puts '*' * 50
      puts dlf_params
      puts '*' * 50

      Rails.cache.clear
      account = Account.find(dlf_params[:account_id])
      @deal_leg_fill = account.handle_fill(dlf_params)

      super
    end
  end

end

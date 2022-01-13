ActiveAdmin.register ClaimMark do

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

  permit_params :system_id, :claim_id, :posted_on, :mark, :mark_traded, :approved

  menu parent: 'Reference'

  filter :claim_name, collection: proc { Claim.pluck(:name).sort }, as: :select
  filter :posted_on

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :claim do |obj|
      obj.claim.name
    end
    column :posted_on
    column :mark, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.mark, precision: 6), delimiter: ",")
    end
    column :mark_traded
    column :approved
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.semantic_errors
    inputs 'Details' do
      input :system_id, as: :select, collection: System.order(:name).all.map { |u| [u.name, u.id] }, :include_blank => false
      input :claim_id, as: :select, collection: Claim.order(:name).all.map { |u| [u.name, u.id] }, :include_blank => false
      input :mark
      input :mark_traded
      input :posted_on, as: :datepicker #, datepicker_options: { min_date: "2013-10-08",        max_date: "+3D" }
      input :approved
      input :open
      input :high
      input :low
      input :last
      input :change
      input :volume
      input :interest
    end
    actions
  end

end

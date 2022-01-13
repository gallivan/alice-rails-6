ActiveAdmin.register Claim do

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

  permit_params :code, :name

  menu parent: 'Reference'

  filter :claim_set_id, collection: proc {ClaimSet.order(:name).all.map {|u| [u.name, u.id]}}, as: :select
  filter :claimable_type
  filter :code
  filter :name

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :claimable_type
    column :code
    column :name
    column :size, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.size, precision: 0), delimiter: ",")
    end
    column :point_value, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.point_value, precision: 2), delimiter: ",")
    end
    actions
  end

end

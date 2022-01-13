ActiveAdmin.register AccountType do
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

  menu parent: 'Types'

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :code
    column :name
    actions
  end

end

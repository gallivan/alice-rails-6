ActiveAdmin.register User do

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

  permit_params :name, :email, :password, :password_confirmation

  menu parent: 'Users'

  filter :duties
  filter :name
  filter :email

  form do |f|
    f.semantic_errors
    inputs 'Details' do
      f.inputs :name, :email, :password, :password_confirmation
    end
    f.actions
  end

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :name
    column :email
    column :sign_in_count
    column :current_sign_in_at
    column :last_sign_in_at
    column :current_sign_in_ip
    column :last_sign_in_ip
    actions
  end

end

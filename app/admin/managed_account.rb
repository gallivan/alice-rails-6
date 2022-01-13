ActiveAdmin.register ManagedAccount do

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

  permit_params :user_id, :account_id

  menu parent: 'Users'

  filter :user_name, collection: proc {User.where('name is not null').pluck(:name).sort}, as: :select
  filter :account_code, collection: proc {Account.pluck(:code).sort}, as: :select

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :user
    column :account
    actions
  end

end

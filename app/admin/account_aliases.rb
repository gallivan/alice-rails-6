ActiveAdmin.register AccountAlias do
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
#
#
#
permit_params :system_id, :account_id, :code

menu parent: "Aliases"

filter :system_name, collection: proc { System.pluck(:name).sort }, as: :select
filter :account_code, collection: proc { account.pluck(:code).sort }, as: :select
filter :code

index do
  div class: 'top_pagination' do
    paginated_collection(collection, download_links: false)
  end
  column :system
  column :account
  column :code
  actions
end

end

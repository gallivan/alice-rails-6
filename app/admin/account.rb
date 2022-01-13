ActiveAdmin.register Account do

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

  permit_params :code, :name, :entity_id, :account_type_id, :active

  menu parent: 'Bookkeeping'

  filter :users, collection: proc {Account.joins(:users).where("users.name is not null").order('users.name').pluck("users.name, users.id ")}, as: :select
  filter :account_type
  filter :code
  filter :name
  filter :active, as: :check_boxes

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :code
    column :name
    column :entity
    column :account_type
    column :active
    actions
  end

  form do |f|
    f.semantic_errors
    inputs 'Details' do
      f.input :entity
      f.input :account_type
      f.input :code
      f.input :name
      f.input :active, as: :boolean
    end
    f.actions
  end

  show :title => :name do
    # https://code.tutsplus.com/tutorials/create-beautiful-administration-interfaces-with-active-admin--net-21729
    panel "Details" do
      table_for account do |a|
        a.column("Code") {account.code}
        a.column("Name") {account.name}
        a.column("Entity") {account.entity}
        a.column("Type") {account.account_type}
        a.column("Active") {account.active}
      end
    end
    if account.grp?
      panel "Group Account Members" do
        table_for account.group_members.order(:code) do |m|
          m.column("Code") {|account| account.code}
          m.column("Name") {|account| account.name}
          m.column("Active") {|account| account.active}
        end
      end
    end
  end

end

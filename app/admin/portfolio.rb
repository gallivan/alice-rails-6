ActiveAdmin.register Portfolio do
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

  menu parent: 'Margin'

  actions :index, :show

  filter :account_code, collection: proc { Account.pluck(:code).sort }, as: :select, label: 'Account'
  filter :posted_on

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :account do |obj|
      obj.account.code
    end
    column :code
    column :name
    column :note
    column :posted_on
    column :created_at
    column :updated_at
    actions
  end

  show :title => :name do
    # https://code.tutsplus.com/tutorials/create-beautiful-administration-interfaces-with-active-admin--net-21729
    panel "Positions" do
      table_for portfolio.positions  do |p|
        p.column("account") { |position| position.account.code }
        p.column("Posted On") { |position| position.posted_on }
        p.column("Traded On") { |position| position.traded_on }
        p.column("Claim") { |position| position.claim.name }
        p.column :bot, class: :number do |position|
          position.bot > 0 ? number_with_delimiter(position.bot.to_i, delimiter: ",") : ''
        end
        p.column :sld, class: :number do |position|
          position.sld > 0 ? number_with_delimiter(position.sld.to_i, delimiter: ",") : ''
        end
        p.column :net, class: :number do |position|
          number_with_delimiter(position.net.to_i, delimiter: ",")
        end
        p.column :price, class: :number do |position|
          number_with_delimiter(number_with_precision(position.price, precision: 6), delimiter: ",")
        end
        p.column :price_traded, class: :number do |position|
          position.price_traded
        end
        p.column :position_status do |position|
          position.position_status.code
        end

        # t.column("Status") { |task| status_tag (task.is_done ? "Done" : "Pending"), (task.is_done ? :ok : :error) }
        # t.column("Title") { |task| link_to task.title, admin_task_path(task) }
        # t.column("Assigned To") { |task| task.admin_user.email }
      end
    end
  end

end

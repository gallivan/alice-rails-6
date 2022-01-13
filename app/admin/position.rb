ActiveAdmin.register Position do

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

  actions :index, :show

  member_action :transfer, method: :put do
    # resource.lock!
    redirect_to new_admin_position_transfer
  end

  menu parent: "Dealing"

  filter :account_code, collection: proc { Account.pluck(:code).sort }, as: :select
  filter :claim_id, collection: proc { Claim.order(:name).all }, as: :select
  filter :position_status
  filter :posted_on
  filter :traded_on
  filter :price

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :account
    column :posted_on
    column :traded_on
    column :claim
    column :bot, class: :number do |position|
      position.bot > 0 ? number_with_delimiter(position.bot.to_i, delimiter: ",") : ''
    end
    column :sld, class: :number do |position|
      position.sld > 0 ? number_with_delimiter(position.sld.to_i, delimiter: ",") : ''
    end
    column :net, class: :number do |position|
      number_with_delimiter(position.net.to_i, delimiter: ",")
    end
    column :price, class: :number do |position|
      number_with_delimiter(number_with_precision(position.price, precision: 8), delimiter: ",")
    end
    column :price_traded, class: :number do |position|
      position.price_traded
    end
    column :position_status do |position|
      position.position_status.code
    end
    actions
    column :Transfer do |position|
      # link_to 'Transfer', new_position_transfer_path(fm_position_id: position.id) if position.open?
      # link_to 'Transfer', new_admin_position_transfer_path(id: position.id) if position.open?
      link_to 'Transfer', new_admin_position_transfer_path(fm_position_id: position.id, bot_transfered: position.bot.to_i, sld_transfered: position.sld.to_i) if position.open?
    end
  end

end

ActiveAdmin.register PositionNetting do

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

  actions :index, :show

  filter :account_code, collection: proc { Account.pluck(:code).sort }, as: :select
  filter :claim_name, collection: proc { Claim.pluck(:name).sort }, as: :select
  filter :position_netting_type
  filter :posted_on

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :posted_on
    column :account do |position_netting|
      position_netting.account
    end
    column :entity do |position_netting|
      position_netting.claim.entity.code
    end
    column :claim do |position_netting|
      position_netting.claim
    end
    column :done, class: :number do |position_netting|
      position_netting.done.to_i
      number_with_delimiter(position_netting.done.to_i, delimiter: ",")
    end
    column :bot_at, class: :number do |position_netting|
      number_with_delimiter(number_with_precision(position_netting.bot_price, precision: 6), delimiter: ",")
    end
    column :sld_at, class: :number do |position_netting|
      number_with_delimiter(number_with_precision(position_netting.sld_price, precision: 6), delimiter: ",")
    end
    column :pnl, class: :number do |position_netting|
      number_with_delimiter(number_with_precision(position_netting.pnl, precision: 2), delimiter: ",")
    end
    column :type do |obj|
      obj.position_netting_type
    end
    actions
  end

  csv do
    column :posted_on
    column :account do |position_netting|
      position_netting.account.code
    end
    column :entity do |position_netting|
      position_netting.claim.entity.code
    end
    column :claim do |position_netting|
      position_netting.claim.code
    end
    column :done do |position_netting|
      position_netting.done.to_i
    end
    column :bot_at do |position_netting|
      position_netting.bot_price
    end
    column :sld_at do |position_netting|
      position_netting.sld_price
    end
    column :pnl do |position_netting|
      position_netting.pnl
    end
    column :type do |obj|
      obj.position_netting_type.code
    end
  end
end

ActiveAdmin.register PositionTransfer do

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

  permit_params :to_account_id, :id, :fm_position_id

  menu parent: "Dealing"

  actions :index, :show, :new

  filter :user
  filter :fm_position_claim_id, collection: proc { Claim.order(:name).all }, as: :select
  filter :fm_position_account_id, collection: proc { Account.order(:code).all }, as: :select
  filter :to_position_account_id, collection: proc { Account.order(:code).all }, as: :select

  index do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :fm_account do |position_transfer|
      position_transfer.fm_position.account
    end
    column :to_account do |position_transfer|
      position_transfer.to_position.account
    end
    column :claim do |position_transfer|
      position_transfer.fm_position.claim
    end
    column :bot_transfered, class: :number do |position_transfer|
      number_with_delimiter(position_transfer.bot_transfered.to_i, delimiter: ",")
    end
    column :sld_transfered, class: :number do |position_transfer|
      number_with_delimiter(position_transfer.sld_transfered.to_i, delimiter: ",")
    end
    column :fm_position do |position_transfer|
      position_transfer.fm_position
    end
    column :to_position do |position_transfer|
      position_transfer.to_position
    end
    actions
  end

  # https://spin.atomicobject.com/2016/05/20/customize-activeadmin-forms/
  # https://github.com/activeadmin/activeadmin/tree/master/docs

  form do |f|
    position = Position.find(params[:fm_position_id] || params[:position_transfer][:fm_position_id])
    div "Transfering #{position.claim.name} at #{position.price_traded} from account #{position.account.code}"

    f.semantic_errors *f.object.errors.keys
    # puts '+' * 100
    # puts 'form'
    # puts params
    # puts '+' * 100
    inputs 'Details' do
      input :fm_position_id, as: 'hidden', :input_html => {:value => params[:fm_position_id] || params[:position_transfer][:fm_position_id]}
      input :to_account_id, :as => :select, :collection => Account.all.map { |u| [u.code, u.id] }, :include_blank => false
      input :bot_transfered, input_html: {value: params[:bot_transfered] || params[:position_transfer][:bot_transfered]}
      input :sld_transfered, input_html: {value: params[:sld_transfered] || params[:position_transfer][:sld_transfered]}
    end
    actions
  end

  controller do
    def create
      # puts 'x' * 100
      # puts 'create'
      # puts params
      # puts 'x' * 100

      #
      # TODO needs something more idiomatic
      #

      fm_position = Position.find(params[:position_transfer][:fm_position_id])
      to_account = Account.find(params[:position_transfer][:to_account_id])
      bot_transfered = params[:position_transfer][:bot_transfered].to_i
      sld_transfered = params[:position_transfer][:sld_transfered].to_i

      @position_transfer = Builders::PositionTransferBuilder.build(current_user, fm_position, to_account, bot_transfered, sld_transfered, 'by controller')

      super
    end
  end

end

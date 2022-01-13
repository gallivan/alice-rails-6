ActiveAdmin.register StatementPositionByClaimAndAccountViewProxy do

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

  menu parent: "Statement", label: 'Statement Positions by Claim & Account'

  actions :index

  filter :account
  filter :claim
  filter :stated_on, :start_year => Date.today.year, :end_year => Date.today.year + 20
  filter :currency

  # https://lorefnon.me/2014/07/13/presenting-sql-views-through-active-admin.html

  index title: 'Statement Positions by Claim & Account' do
    div class: 'top_pagination' do
      paginated_collection(collection, download_links: false)
    end
    column :stated_on
    column :account do |obj|
      obj.account.code
    end
    column :claim do |obj|
      obj.claim.name
    end
    column :bot, class: :number do |position|
      position.bot > 0 ? number_with_delimiter(position.bot.to_i, delimiter: ",") : ''
    end
    column :sld, class: :number do |position|
      position.sld > 0 ? number_with_delimiter(position.sld.to_i, delimiter: ",") : ''
    end
    column :net, class: :number do |position|
      number_with_delimiter(position.net.to_i, delimiter: ",")
    end
    column :avg_price, class: :number do |position|
      number_with_delimiter(number_with_precision(position.price, precision: 6), delimiter: ",")
    end
    column :mark, class: :number do |position|
      number_with_delimiter(number_with_precision(position.mark, precision: 6), delimiter: ",")
    end
    column :ote, class: :number do |position|
      number_with_delimiter(number_with_precision(position.ote, precision: 2), delimiter: ",")
    end
    column :currency do |obj|
      obj.currency.code
    end
  end

  csv do
    column :stated_on
    column :account do |obj|
      obj.account.code
    end
    column :claim do |obj|
      obj.claim.name
    end
    column :bot do |obj|
      number_with_delimiter(number_with_precision(obj.bot, precision: 0), delimiter: ",")
    end
    column :sld do |obj|
      number_with_delimiter(number_with_precision(obj.sld, precision: 0), delimiter: ",")
    end
    column :net do |obj|
      number_with_delimiter(number_with_precision(obj.net, precision: 0), delimiter: ",")
    end
    column :avg_price, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.price, precision: 6), delimiter: ",")
    end
    column :mark, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.mark, precision: 6), delimiter: ",")
    end
    column :ote, class: :number do |obj|
      number_with_delimiter(number_with_precision(obj.ote, precision: 2), delimiter: ",")
    end
    column :currency do |obj|
      obj.currency.code
    end
  end

end

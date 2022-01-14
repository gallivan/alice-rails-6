module Builders

  class PositionBuilder

    # def self.reverse(fill)
    #   puts "Position reverse..."
    #
    #   key = "#{fill.account.id}:#{fill.claim.id}:#{fill.posted_on}:#{fill.traded_on}:#{fill.price}"
    #   position = Rails.cache.fetch(key)
    #
    #   if position.blank?
    #     puts "Position CACHE MISS...SELECT"
    #     position = fill.position
    #   else
    #     puts "Position CACHE HIT...UPDATE"
    #   end
    #
    #   if fill.done > 0
    #     position.update(:bot, position.bot - fill.done)
    #   else
    #     position.update(:sld, position.sld - fill.done.abs)
    #   end
    #
    #   position.update(:net, position.bot - position.sld)
    #
    #   # puts '+' * 40
    #   # puts position.inspect
    #   # puts '-' * 40
    #
    #   Rails.cache.write(key, position)
    #
    #   position
    # end

    def self.build_or_update(fill)
      # puts "Position build or update..."

      key = "#{fill.account.id}:#{fill.claim.id}:#{fill.posted_on}:#{fill.traded_on}:#{fill.price}"

      position = Rails.cache.fetch(key)

      position = Position.where(posted_on: fill.posted_on, traded_on: fill.traded_on, account_id: fill.account.id, claim_id: fill.claim.id, price: fill.price).first unless position

      if position.blank?
        # puts "Position CACHE MISS...CREATE"

        position_status = Rails.cache.fetch("position_status:OPN") {
          PositionStatus.find_by_code('OPN')
        }

        position = Position.new do |p|
          p.posted_on = fill.posted_on
          p.traded_on = fill.traded_on
          p.account_id = fill.account.id
          p.claim_id = fill.claim.id
          p.price = fill.price
          p.price_traded = fill.price_traded
          p.currency_id = fill.claim.point_currency_id
          p.bot = (fill.done < 0) ? 0 : fill.done
          p.sld = (fill.done > 0) ? 0 : fill.done.abs
          p.bot_off = 0.00
          p.sld_off = 0.00
          p.net = p.bot - p.sld
          p.position_status = position_status
          p.mark = fill.price
        end
        position.save!
      else
        # puts "Position CACHE HIT...UPDATE"

        if fill.done > 0
          position.update(bot: position.bot + fill.done)
        else
          position.update(sld: position.sld + fill.done.abs)
        end

        position.update(net: position.bot - position.sld)
      end

      # puts '+' * 40
      # puts position.inspect
      # puts '-' * 40

      Rails.cache.write(key, position)

      position
    end
  end
end
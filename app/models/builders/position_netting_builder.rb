module Builders

  class PositionNettingBuilder

    def self.build(posted_on, bot, sld)
      build_nettings(posted_on, bot, sld)
    end

    private

    def self.build_nettings(posted_on, bot, sld)
      # bot = []
      # sld = []
      net = []
      # puts positions.count
      # positions.each { |p| bot << p if p.bot > 0 }
      # positions.each { |p| sld << p if p.sld > 0 }
      bot.each do |b|
        # puts "con: #{b.claim.code} bot: #{b.id}"
        sld.each do |s|
          # puts "con: #{s.claim.code} sld: #{s.id}"
          # reload is expensive but it works
          b.reload
          s.reload
          next if s.sld == 0
          break if b.bot == 0
          net << build_netting(posted_on, b, s)
        end
        next if b.bot == 0
      end
      net
    end

    def self.build_netting(posted_on, bot_position, sld_position)
      account = bot_position.account
      claim = bot_position.claim

      netting = PositionNetting.create! do |pn|
        pn.claim_id = bot_position.claim_id
        pn.account_id = account.id
        pn.currency_id = bot_position.currency_id
        pn.posted_on = posted_on
        pn.bot_position_id = bot_position.id
        pn.sld_position_id = sld_position.id
        pn.bot_price = bot_position.price
        pn.sld_price = sld_position.price
        pn.bot_price_traded = bot_position.price_traded
        pn.sld_price_traded = sld_position.price_traded
        pn.done = determine_done(bot_position, sld_position)
        pn.position_netting_type = determine_type(pn, bot_position, sld_position)

        mul = claim.point_value

        pay = (BigDecimal(pn.bot_price.to_s, 16) * BigDecimal(mul.to_s, 16)).round(2)
        rec = (BigDecimal(pn.sld_price.to_s, 16) * BigDecimal(mul.to_s, 16)).round(2)

        pn.pnl = (pn.done * (rec - pay)).round(2)
      end

      update_positions(bot_position, sld_position, netting)

      # show(bot_position, sld_position, netting)

      journal_pnl(netting)

      netting
    end

    def self.update_positions(bot_position, sld_position, netting)
      status = PositionStatus.find_by_code('CLO')

      if bot_position.id == sld_position.id
        position = bot_position

        position.update_attribute(:bot, position.bot - netting.done)
        position.update_attribute(:sld, position.sld - netting.done)

        position.update_attribute(:bot_off, position.bot_off + netting.done)
        position.update_attribute(:sld_off, position.sld_off + netting.done)

        position.update_attribute(:net, position.bot - position.sld)

        position.update_attribute(:position_status_id, status.id) if position.bot == 0 and position.sld == 0
      else
        bot_position.update_attribute(:bot, bot_position.bot - netting.done)
        sld_position.update_attribute(:sld, sld_position.sld - netting.done)

        bot_position.update_attribute(:bot_off, bot_position.bot_off + netting.done)
        sld_position.update_attribute(:sld_off, sld_position.sld_off + netting.done)

        bot_position.update_attribute(:net, bot_position.bot - bot_position.sld)
        sld_position.update_attribute(:net, sld_position.bot - sld_position.sld)

        bot_position.update_attribute(:position_status_id, status.id) if bot_position.bot == 0 and bot_position.sld == 0
        sld_position.update_attribute(:position_status_id, status.id) if sld_position.bot == 0 and sld_position.sld == 0
      end
    end

    def self.break_nettings(account, date)
      nettings = account.position_nettings.posted_on(date).order('id desc')
      nettings.each do |netting|
        break_netting(netting)
      end
    end

    def self.break_netting(netting)
      journal_pnl_reverse(netting)
      update_positions_reverse(netting)
    end

    def self.update_positions_reverse(netting)
      bot_position = netting.bot_position
      sld_position = netting.sld_position

      status = PositionStatus.find_by_code('OPN')

      if bot_position.id == sld_position.id
        position = bot_position

        position.update_attribute(:bot, bot_position.bot + netting.done)
        position.update_attribute(:sld, sld_position.sld + netting.done)

        position.update_attribute(:bot_off, position.bot_off - netting.done)
        position.update_attribute(:sld_off, position.sld_off - netting.done)

        position.update_attribute(:net, position.bot - position.sld)

        position.update_attribute(:position_status_id, status.id)
      else
        bot_position.update_attribute(:bot, bot_position.bot + netting.done)
        sld_position.update_attribute(:sld, sld_position.sld + netting.done)

        bot_position.update_attribute(:bot_off, bot_position.bot_off - netting.done)
        sld_position.update_attribute(:sld_off, sld_position.sld_off - netting.done)

        bot_position.update_attribute(:net, bot_position.bot - bot_position.sld)
        sld_position.update_attribute(:net, sld_position.bot - sld_position.sld)

        bot_position.update_attribute(:position_status_id, status.id)
        sld_position.update_attribute(:position_status_id, status.id)
      end

      netting.delete
    end

    def self.show(b, s, o)
      puts "con: #{b.claim.code} bid: #{b.id} sid: #{s.id} bot: #{b.bot} sld: #{s.sld} bpx: #{b.price} spx: #{s.price} off: #{o.done} pnl: #{o.pnl}"
      # puts b.inspect
      # puts s.inspect
      # puts o.inspect
    end

    def self.determine_done(bot_position, sld_position)

      if bot_position.bot == sld_position.sld
        done = bot_position.bot
      else
        done = [bot_position.bot, sld_position.sld].min
      end
      # puts "bot/sld/done: #{bot_position.bot} #{sld_position.sld} #{done}"
      done
    end

    def self.determine_type(po, b, s)
      if b.posted_on != s.posted_on
        PositionNettingType.find_by_code('OVR')
      elsif po.bot_price == po.sld_price
        PositionNettingType.find_by_code('SCH')
      else
        PositionNettingType.find_by_code('DAY')
      end
    end

    def self.journal_pnl(netting)
      pnl = {}
      pnl['account_id'] = netting.account.id
      pnl['netting_id'] = netting.id
      pnl['claim_id'] = netting.claim_id
      pnl['amount'] = netting.pnl
      pnl['currency_id'] = netting.bot_position.claim.point_currency_id
      pnl['posted_on'] = netting.posted_on
      JournalEntryBuilder.build_for_pnl(pnl)
    end

    def self.journal_pnl_reverse(netting)
      date = netting.posted_on
      type = JournalEntryType.find_by_code('PNL')
      JournalEntry.where(posted_on: date, journal_entry_type_id: type.id).delete_all
    end

  end
end

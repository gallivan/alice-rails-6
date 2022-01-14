module Builders
  class PositionTransferBuilder

    #
    # TODO manage the race condition
    #
    # The fm_position instance may be subject to change elsewhere, e.g., Booker.
    # Use of this method might be best done through a Booker instances with a
    # handle on the fm_position via queue. The difficulty: user expectations re
    # "seeing" the effect of the change. That might be managed by returning a
    # messaging saying something like "transfer queued for processing" and a
    # subsequent email/message saying "transfer complete".
    #

    def self.build(user, fm_position, to_account, bot_to_transfer, sld_to_transfer, note)
      params = {
          account_id: to_account.id,
          bot: bot_to_transfer,
          sld: sld_to_transfer,
          net: bot_to_transfer - sld_to_transfer,
          bot_off: 0,
          sld_off: 0,
          ote: 0,

          claim_id: fm_position.claim.id,
          posted_on: fm_position.posted_on,
          traded_on: fm_position.traded_on,
          price: fm_position.price,
          price_traded: fm_position.price_traded,
          currency_id: fm_position.currency_id,
          position_status_id: fm_position.position_status_id
      }
      to_position = Position.create! params

      # reset fm_position bot, sld and net per transfer quantities
      params = {
          bot: fm_position.bot - bot_to_transfer,
          sld: fm_position.sld - sld_to_transfer,
          ote: 0
      }
      fm_position.update(params)
      fm_position.net!
      fm_position.close! if fm_position.bot == 0 and fm_position.sld == 0

      # build position_transfer instance
      params = {
          fm_position: fm_position,
          to_position: to_position,
          bot_transfered: bot_to_transfer,
          sld_transfered: sld_to_transfer,
          user: user
      }
      PositionTransfer.create! params
    end

  end
end
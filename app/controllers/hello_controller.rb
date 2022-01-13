class HelloController < ApplicationController

  # GET /positions
  # GET /positions.json
  def index
    @data = {}
    # @data[:volumes] = volumes_by_claim
    @data[:volumes] = volumes_by_claim_set
    # @data[:positions] = positions_by_claim
    @data[:picker_report_tracks] = get_picker_report_tracks
    @data[:packer_report_tracks] = get_packer_report_tracks
    @data[:booker_report_tracks] = get_booker_report_tracks
    @data[:expiring_positions] = get_expiring_positions
  end

  private

  def get_expiring_positions
    date = Date.today
    # futures = Future.expired_or_expiring(date)
    futures = Future.expiring_within_days(5)
    @positions = []
    futures.each do |future|
      # @positions << future.claim.positions.open
      @positions << future.claim.positions.joins(:account, :claim).open.select("accounts.code as account_code, claims.code as claim_code, sum(positions.bot) as bot, sum(positions.sld) as sld, sum(positions.net) as net").group("accounts.code, claims.code")
    end
    @positions.flatten!

    # @positions.each do |position|
    #   puts '*' * 100
    #   puts position.class
    #   puts position.to_json
    # end

    @positions
  end

  def get_picker_report_tracks
    {
        m05: PickerReport.where("created_at > ?", 5.minutes.ago).count,
        m15: PickerReport.where("created_at > ?", 15.minutes.ago).count,
        h01: PickerReport.where("created_at > ?", 1.hour.ago).count,
        d01: PickerReport.where("created_at > ?", 1.day.ago).count,
        e01: PickerReport.where("created_at > ? and goof_error is not null", 1.day.ago).count
    }
  end

  def get_packer_report_tracks
    {
        m05: PackerReport.where("created_at > ?", 5.minutes.ago).count,
        m15: PackerReport.where("created_at > ?", 15.minutes.ago).count,
        h01: PackerReport.where("created_at > ?", 1.hour.ago).count,
        d01: PackerReport.where("created_at > ?", 1.day.ago).count,
        e01: PackerReport.where("created_at > ? and goof_error is not null", 1.day.ago).count
    }
  end

  def get_booker_report_tracks
    {
        m05: BookerReport.where("created_at > ?", 5.minutes.ago).count,
        m15: BookerReport.where("created_at > ?", 15.minutes.ago).count,
        h01: BookerReport.where("created_at > ?", 1.hour.ago).count,
        d01: BookerReport.where("created_at > ?", 1.day.ago).count,
        e01: BookerReport.where("created_at > ? and goof_error is not null", 1.day.ago).count
    }
  end

  def get_volumes_by_claim
    {
        m05: BookerReport.where("created_at > ?", 5.minutes.ago).count,
        m15: BookerReport.where("created_at > ?", 15.minutes.ago).count,
        h01: BookerReport.where("created_at > ?", 1.hour.ago).count,
        d01: BookerReport.where("created_at > ?", 1.day.ago).count,
        e01: BookerReport.where("created_at > ? and goof_error is not null", 1.day.ago).count
    }
  end

  def positions_by_claim
    Position.open.joins(:claim).select('claims.code as claim_code, sum(bot) as bot, sum(sld) as sld, sum(net) as net').group('claims.code').order('claims.code')
  end

  def volumes_by_claim
    ViewPoint.volumes_by_claim
  end

  def volumes_by_claim_set
    ViewPoint.volumes_by_claim_set
  end

end

json.array!(@deal_leg_fills) do |deal_leg_fill|
  json.extract! deal_leg_fill, :id, :deal_leg_id, :system_id, :dealing_venue_id, :dealing_venue_done_id, :account_id, :claim_id, :done, :price, :price_traded, :posted_on, :traded_on, :traded_at, :position_id, :booker_report_id, :kind
  json.url deal_leg_fill_url(deal_leg_fill, format: :json)
end

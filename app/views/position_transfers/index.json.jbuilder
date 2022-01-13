json.array!(@position_transfers) do |position_transfer|
  json.extract! position_transfer, :id, :fm_position, :to_position, :bot_transfered, :sld_transfered, :user
  json.url position_transfer_url(position_transfer, format: :json)
end

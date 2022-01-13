FactoryBot.define do

  factory :position_transfer do
    fm_position
    to_position
    bot_transfered {9.99}
    sld_transfered {9.99}
    user
  end

end

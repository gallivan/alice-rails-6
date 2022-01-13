system = System.find_by_code('BKO')
date = Date.parse('2019-07-29')

ActiveRecord::Base.transaction do
  ClaimMark.create!({system: system, claim: Claim.find_by_code('CBT:17U19'), posted_on: date, mark: 154.78125, mark_traded: "154'25", approved: true})
  ClaimMark.create!({system: system, claim: Claim.find_by_code('CBT:21U19'), posted_on: date, mark: 127.453125, mark_traded: "127'145", approved: true})
  ClaimMark.create!({system: system, claim: Claim.find_by_code('CBT:25U19'), posted_on: date, mark: 117.6796875, mark_traded: "117'217", approved: true})
  ClaimMark.create!({system: system, claim: Claim.find_by_code('CBT:TNU19'), posted_on: date, mark: 137.515625, mark_traded: "137'165", approved: true})
  ClaimMark.create!({system: system, claim: Claim.find_by_code('CBT:UBEU19'), posted_on: date, mark: 175.90625, mark_traded: "175'29", approved: true})
  ClaimMark.create!({system: system, claim: Claim.find_by_code('CME:EDZ19'), posted_on: date, mark: 97.9250, mark_traded: "97.9250", approved: true})
  ClaimMark.create!({system: system, claim: Claim.find_by_code('CME:EDH20'), posted_on: date, mark: 98.1600, mark_traded: "98.1600", approved: true})
  ClaimMark.create!({system: system, claim: Claim.find_by_code('CME:EDM20'), posted_on: date, mark: 98.2550, mark_traded: "98.2550", approved: true})
  ClaimMark.create!({system: system, claim: Claim.find_by_code('CME:EDU20'), posted_on: date, mark: 98.3250, mark_traded: "98.3250", approved: true})
  ClaimMark.create!({system: system, claim: Claim.find_by_code('CME:EDZ20'), posted_on: date, mark: 98.3300, mark_traded: "98.3300", approved: true})
  ClaimMark.create!({system: system, claim: Claim.find_by_code('CME:EDH21'), posted_on: date, mark: 98.3750, mark_traded: "98.3750", approved: true})
  ClaimMark.create!({system: system, claim: Claim.find_by_code('CME:EDM21'), posted_on: date, mark: 98.3600, mark_traded: "98.3600", approved: true})
  ClaimMark.create!({system: system, claim: Claim.find_by_code('CME:EDU21'), posted_on: date, mark: 98.3500, mark_traded: "98.3500", approved: true})
  ClaimMark.create!({system: system, claim: Claim.find_by_code('CME:EDZ21'), posted_on: date, mark: 98.3200, mark_traded: "98.3200", approved: true})
end
task :create_quandl_claim_set_aliases => :environment do

  list = [
      ['MNP:FCE', 'LIFFE/FCE'],
      ['MATIF:EBM', 'LIFFE/EBM'],
      ['IFEU:G', 'ICE/G'],
      ['NYMEX:CL', 'CME/CL'],
      ['NYMEX:HO', 'CME/HO'],
      ['NYMEX:NG', 'CME/NG'],
      ['CBT:C', 'CME/C'],
      ['CBT:S', 'CME/S'],
      ['CBT:W', 'CME/W'],
      ['CBT:KW', 'CME/KW'],
      ['CBT:07', 'CME/BO'],
      ['CBT:06', 'CME/SM'],
      ['CBT:17', 'CME/US'],
      ['CBT:21', 'CME/TY'],
      ['CBT:25', 'CME/FV'],
      ['CBT:26', 'CME/TU'],
      ['CBT:UBE', 'CME/UL'],
      ['CBT:YM', 'CME/YM'],
      ['CME:ED', 'CME/ED'],
      ['CME:48', 'CME/LC'],
      ['CME:62', 'CME/FC'],
      ['EUREX:FBTS', 'BCEUX/IA'],
      ['EUREX:FDAX', 'BCEUX/DY'],
      ['EUREX:FESX', 'BCEUX/FX'],
      ['EUREX:FGBL', 'BCEUX/GG'],
      ['EUREX:FGBM', 'BCEUX/HR'],
      ['EUREX:FGBS', 'BCEUX/HF'],
      ['EUREX:FGBX', 'BCEUX/GX']
  ]

  system = System.where(code: 'QDL').first

  list.each do |e|
    claim_set = ClaimSet.find_by_code(e.first)
    if claim_set.blank?
      puts "Missing ClaimSet with code #{e.first}. Skipping."
      next
    end
    claim_set_alias = ClaimSetAlias.where(system_id: system.id, claim_set_id: claim_set.id).first
    if claim_set_alias.blank?
      puts "ClaimSetAlias for #{e.first} missing. Creating."
      ClaimSetAlias.create!(system_id: system.id, claim_set_id: claim_set.id, code: e.last)
    else
      puts "ClaimSetAlias for #{e.first} exists. Skipping."
    end
  end
end
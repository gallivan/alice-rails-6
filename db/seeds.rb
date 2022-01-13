# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create!([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create!(name: 'Daley', :city => cities.first)

#
# Admin Users
#

strong_password = 'xMV1vkl4528NVDVvmNMXMV1vkl4528NVD'

User.create!(:email => 'root@jackijack.com', :password => strong_password, :password_confirmation => strong_password)
User.create!(:email => 'back@jackijack.com', :password => strong_password, :password_confirmation => strong_password)
User.create!(:email => 'head@jackijack.com', :password => strong_password, :password_confirmation => strong_password)
User.create!(:email => 'user@jackijack.com', :password => strong_password, :password_confirmation => strong_password)

#
# Legal Entity Roles
#

# pty_entity_role = EntityRole.create!(code: 'PTY', name: 'Party Role')
# bkr_entity_role = EntityRole.create!(code: 'BKR', name: 'Broker Role')
# mkt_entity_role = EntityRole.create!(code: 'MKT', name: 'Market Role')
# clr_entity_role = EntityRole.create!(code: 'CLR', name: 'Clearing House Role')
# reg_entity_role = EntityRole.create!(code: 'REG', name: 'Regulator Role')
# cry_entity_role = EntityRole.create!(code: 'CRY', name: 'Carrying Broker Role')

#
# Entity Types
#

crp = EntityType.where(code: 'CRP', name: 'Corporation').first_or_create
ind = EntityType.where(code: 'IND', name: 'Individual').first_or_create

#
# Entities
#

emm = Entity.where(code: 'EMM', name: 'Eagle Market Makers', entity_type: crp).first_or_create
frt = Entity.where(code: 'FORTIS', name: 'Fortis', entity_type: crp).first_or_create
cme = Entity.where(code: 'CME', name: 'Chicago Mercantile Exchange', entity_type: crp).first_or_create
ice = Entity.where(code: 'ICE', name: 'Inter-Continental Commodity Exchange', entity_type: crp).first_or_create
icecl = Entity.where(code: 'ICECL', name: 'Inter-Continental Commodity Exchange - NOT SURE', entity_type: crp).first_or_create
eurex = Entity.where(code: 'EUREX', name: 'Eurex', entity_type: crp).first_or_create
matif = Entity.where(code: 'MATIF', name: 'Marché à Terme International de France', entity_type: crp).first_or_create
monep = Entity.where(code: 'MONEP', name: 'Marche des Options Negociables de Paris', entity_type: crp).first_or_create
asx = Entity.where(code: 'ASX', name: 'Australian Securities Exchange', entity_type: crp).first_or_create
mgex = Entity.where(code: 'MGEX', name: 'Minniapolis Grain Exchange', entity_type: crp).first_or_create
nyse_euronext = Entity.where(code: 'NYSE_EURONEXT', name: 'NYSE Euronext', entity_type: crp).first_or_create
nyce = Entity.where(code: 'NYCE', name: 'New York Cotton Exchange', entity_type: crp).first_or_create

#
# Clearing Venue Type
#

futures_clearing = ClearingVenueType.where(code: 'FUT', name: 'Futures Clearing').first_or_create
fi_derivatives_clearing = ClearingVenueType.where(code: 'FID', name: 'Fixed Income Derivatives').first_or_create

#
# Clearing Venues
#

ccl = ClearingVenue.where(code: 'CCL', name: 'Clearing Corporation Link', entity: cme, clearing_venue_type: futures_clearing).first_or_create
icecl = ClearingVenue.where(code: 'ICECL', name: 'Inter-Continental Exchange Clearing', entity: ice, clearing_venue_type: futures_clearing).first_or_create
nypc = ClearingVenue.where(code: 'NYPC', name: 'New York Portfolio Clearing', entity: nyse_euronext, clearing_venue_type: fi_derivatives_clearing).first_or_create

#
# Dealing Venue Types
#

dv_system = DealingVenueType.where(code: 'SYS', name: 'Electronic System').first_or_create

#
# Dealing Venues
#

globex_dv = DealingVenue.where(code: 'GLOBEX', name: 'CME Globex', entity: cme, dealing_venue_type: dv_system).first_or_create
cbt_dv = DealingVenue.where(code: 'CBT', name: 'Chicago Board of Exchange', entity: cme, dealing_venue_type: dv_system).first_or_create
liffe_dv = DealingVenue.where(code: 'LIFFE', name: "London International Financial Futures Exchange", entity: ice, dealing_venue_type: dv_system).first_or_create
nymex_dv = DealingVenue.where(code: 'NYMEX', name: 'New York Mercantile Exchange', entity: cme, dealing_venue_type: dv_system).first_or_create
comex_dv = DealingVenue.where(code: 'COMEX', name: 'Commodity Exchange', entity: cme, dealing_venue_type: dv_system).first_or_create
imm_dv = DealingVenue.where(code: 'IMM', name: 'International Monetary Market', entity: cme, dealing_venue_type: dv_system).first_or_create
ice_dv = DealingVenue.where(code: 'ICE', name: 'Inter-Continental Exchange', entity: ice, dealing_venue_type: dv_system).first_or_create
ifeu_dv = DealingVenue.where(code: 'IFEU', name: 'ICE Futures Europe', entity: ice, dealing_venue_type: dv_system).first_or_create
icecl_dv = DealingVenue.where(code: 'ICECL', name: 'Inter-Continental Exchange ????', entity: ice, dealing_venue_type: dv_system).first_or_create
mnp_dv = DealingVenue.where(code: 'MNP', name: 'Monep', entity: ice, dealing_venue_type: dv_system).first_or_create
matif_dv = DealingVenue.where(code: 'MATIF', name: 'matif', entity: ice, dealing_venue_type: dv_system).first_or_create
monep_dv = DealingVenue.where(code: 'MONEP', name: 'monep', entity: ice, dealing_venue_type: dv_system).first_or_create
eurex_dv = DealingVenue.where(code: 'EUREX', name: 'Eurex', entity: eurex, dealing_venue_type: dv_system).first_or_create
dtb_dv = DealingVenue.where(code: 'DTB', name: 'Deutsche Terminborse', entity: eurex, dealing_venue_type: dv_system).first_or_create

aex_dv = DealingVenue.where(code: 'AEX', name: 'Amsterdam Exchange', entity: ice, dealing_venue_type: dv_system).first_or_create
nylf_dv = DealingVenue.where(code: 'NYLF', name: 'NYSE LIFFE', entity: ice, dealing_venue_type: dv_system).first_or_create
csc_dv = DealingVenue.where(code: 'CSC', name: 'Coffee Sugar Cocoa', entity: ice, dealing_venue_type: dv_system).first_or_create
kcbt_dv = DealingVenue.where(code: 'KCBT', name: 'Kansas City Board of Trade', entity: cme, dealing_venue_type: dv_system).first_or_create

sfe_dv = DealingVenue.where(code: 'SFE', name: 'Sydney Futures Exchange', entity: asx, dealing_venue_type: dv_system).first_or_create
mgex_dv = DealingVenue.where(code: 'MGEX', name: 'Minneapolis Grain Exchange', entity: mgex, dealing_venue_type: dv_system).first_or_create

nyce_dv = DealingVenue.where(code: 'NYCE', name: 'New York Cotton Exchange', entity: nyce, dealing_venue_type: dv_system).first_or_create

#otc = DealingVenue.where(code: 'OTC', name: 'Over the Counter', dealing_venue_role_id: mkt_entity_role.id).first_or_create

#
# System Type
#

clr_brk = SystemType.where(code: 'BRK', name: 'Clearing Broker').first_or_create
clr_sys = SystemType.where(code: 'CLR', name: 'Clearing System').first_or_create

#
# Systems
#

aacc_fix_itd = System.where(code: 'AACC', name: 'ABN AMRO Clearing Corporation - FIX Intraday Drop Copy', entity: frt, system_type: clr_brk).first_or_create
cme_eod_file = System.where(code: 'CME_EOD_FILE', name: 'CME FIX End-of-Day FileS', entity: cme, system_type: clr_sys).first_or_create

hou_sys_typ = SystemType.where(code: 'HOU', name: 'House System Type').first_or_create
hou_sys = System.where(code: 'BKO', name: 'Backoffice Entry', entity: emm, system_type: hou_sys_typ).first_or_create

# cme_fix_itd = System.where(code: 'CME_FIX_ITD', name: 'CME FIX Intraday Drop Copy', system_role_id: src_system.id).first_or_create

# bite = System.where(code: 'ALICE', name: 'Bite System', system_role_id: src_system.id).first_or_create

#
# Entity Aliases
#

# EntityAlias.where(:entity => cme, code: 'CME', system: bite).first_or_create

# EntityAlias.where(:entity => emm, code: '353', system: cme_fix_itd).first_or_create

#
# Dealing Venue Aliases
#
[
    {dealing_venue: globex_dv, code: '02', system: aacc_fix_itd},
    {dealing_venue: comex_dv, code: '04', system: aacc_fix_itd},
    {dealing_venue: liffe_dv, code: '05', system: aacc_fix_itd},
    {dealing_venue: csc_dv, code: '06', system: aacc_fix_itd},
    {dealing_venue: nymex_dv, code: '07', system: aacc_fix_itd},
    {dealing_venue: kcbt_dv, code: '08', system: aacc_fix_itd},
    {dealing_venue: eurex_dv, code: '10', system: aacc_fix_itd},
    {dealing_venue: liffe_dv, code: '11', system: aacc_fix_itd},
    {dealing_venue: nyce_dv, code: '13', system: aacc_fix_itd},
    {dealing_venue: ifeu_dv, code: '16', system: aacc_fix_itd},
    {dealing_venue: matif_dv, code: '17', system: aacc_fix_itd},
    {dealing_venue: aex_dv, code: '28', system: aacc_fix_itd},
    {dealing_venue: mnp_dv, code: '30', system: aacc_fix_itd},
    {dealing_venue: nylf_dv, code: '9N', system: aacc_fix_itd},
    {dealing_venue: matif_dv, code: '25', system: aacc_fix_itd},
    {dealing_venue: monep_dv, code: '??', system: aacc_fix_itd},
].each do |params|
  DealingVenueAlias.where(params).first_or_create
end

#
# Currencies
#

usd = Currency.where(code: 'USD', name: 'United States Dollar').first_or_create
eur = Currency.where(code: 'EUR', name: 'European Euro').first_or_create
gbp = Currency.where(code: 'GBP', name: 'Great British Pound').first_or_create
jpy = Currency.where(code: 'JPY', name: 'Japanese Yen').first_or_create
chf = Currency.where(code: 'CHF', name: 'Swiss Frank').first_or_create
dkk = Currency.where(code: 'DKK', name: 'Danish Krone').first_or_create
sek = Currency.where(code: 'SEK', name: 'Swedish Krona').first_or_create
nok = Currency.where(code: 'NOK', name: 'Norwegin Krone').first_or_create
ukn = Currency.where(code: 'UKN', name: 'Unknown').first_or_create

#
# Currency Rates
#

posted_on = Date.parse('2015-10-23')

[
    {currency_id: Currency.usd.id, posted_on: posted_on, mark: 1.0},
    {currency_id: Currency.eur.id, posted_on: posted_on, mark: (1 / 1.1000).round(4)},
    {currency_id: Currency.gbp.id, posted_on: posted_on, mark: (1 / 1.4700).round(4)},
    {currency_id: Currency.jpy.id, posted_on: posted_on, mark: 120.27},
    {currency_id: Currency.chf.id, posted_on: posted_on, mark: 1.0014},
    {currency_id: Currency.dkk.id, posted_on: posted_on, mark: 6.87},
    {currency_id: Currency.sek.id, posted_on: posted_on, mark: 8.44},
    {currency_id: Currency.nok.id, posted_on: posted_on, mark: 8.83},
    {currency_id: Currency.ukn.id, posted_on: posted_on, mark: 1.00},
].each do |params|
  CurrencyMark.where(params).first_or_create
end

#
# Claim Types ?
#

ClaimType.where(code: 'MNY', name: 'Money').first_or_create
ClaimType.where(code: 'FUT', name: 'Future').first_or_create

#
# Adjustment Types
#

[
    {code: 'FEE', name: 'Fee Adjustment'},
    {code: 'COM', name: 'Copmmission Adjustment'},
    {code: 'MSC', name: 'Miscellaneous Adjustment'}
].each do |params|
  AdjustmentType.where(params).first_or_create
end

#
# Journal Types
#

journal_type_params = [
    {code: 'SOLE', name: 'Sole Journal Type'}
]

journal_type_params.each do |params|
  JournalType.where(params).first_or_create
end

#
# Journals
#

journal_params = [
    {code: 'SOLE', name: 'Sole Journal', journal_type: JournalType.find_by_code('SOLE')}
]

journal_params.each do |params|
  Journal.where(params).first_or_create
end

#
# Journal Entry Types
#

journal_entry_type_params = [
    {code: 'ADJ', name: 'Adjustment'},
    {code: 'CSH', name: 'Cash'},
    {code: 'FEE', name: 'Fee'},
    {code: 'COM', name: 'Commission'},
    {code: 'PNL', name: 'Profit and Loss'},
    {code: 'OTE', name: 'Open Trade Equity'}
]

journal_entry_type_params.each do |params|
  JournalEntryType.where(params).first_or_create
end

#
# Ledger Types
#

ledger_type_params = [
    {code: 'SOLE', name: 'Sole Ledger Type'}
]

ledger_type_params.each do |params|
  LedgerType.where(params).first_or_create
end

#
# Ledgers
#

ledger_params = [
    {code: 'SOLE', name: 'Sole Ledger', ledger_type: LedgerType.find_by_code('SOLE')}
]

ledger_params.each do |params|
  Ledger.where(params).first_or_create
end

#
# Ledger Entry Types
#

ledger_entry_type_params = [
    {code: 'BEG', name: 'Beginging Balance'},
    {code: 'COM', name: 'Commissions Balance'},
    {code: 'PNLFUT', name: 'Futures Profit and Loss Balance'},
    {code: 'FEE', name: 'Fee Balance'},
    {code: 'LEG', name: 'Ledger Balance'},
    {code: 'OTE', name: 'Open Trade Equity Balance'},
    {code: 'NPV', name: 'Net Present Value Balance'},
    {code: 'CSHACT', name: 'Cash Account Balance'},
    {code: 'LIQ', name: 'Liquidating Balance'},
    {code: 'ADJ', name: 'Adjustment'},
    {code: 'CHG', name: 'Charge'}
]

ledger_entry_type_params.each do |params|
  LedgerEntryType.where(params).first_or_create
end

#
# Position Status
#

position_status_params = [
    {code: 'OPN', name: 'Open'},
    {code: 'CLO', name: 'Closed'}
]

position_status_params.each do |params|
  PositionStatus.where(params).first_or_create
end

#
# Position Offset Types
#

position_netting_type_params = [
    {code: 'SCH', name: 'Scratch Trade'},
    {code: 'DAY', name: 'Day Trade'},
    {code: 'OVR', name: 'Overnight Trade'}
]

position_netting_type_params.each do |params|
  PositionNettingType.where(params).first_or_create
end

#
# Account Types
#

AccountType.delete_all # should not need to do this.

[
    {code: 'REG', name: 'Regular'},
    {code: 'GRP', name: 'Group'}
].each do |params|
  AccountType.where(params).first_or_create
end

#
# Accounts
#

reg = AccountType.find_by_code('REG')

account_params = [
    {entity: Entity.find_by_code("EMM"), code: "00001", name: "Eagle Market Makers 00001", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00002", name: "Eagle Market Makers 00002", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00004", name: "Eagle Market Makers 00004", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00005", name: "Eagle Market Makers 00005", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00019", name: "Eagle Market Makers 00019", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00022", name: "Eagle Market Makers 00022", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00024", name: "Eagle Market Makers 00024", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00033", name: "Eagle Market Makers 00033", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00071", name: "Eagle Market Makers 00071", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00077", name: "Eagle Market Makers 00077", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00099", name: "Eagle Market Makers 00099", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00085", name: "Eagle Market Makers 00085", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00123", name: "Eagle Market Makers 00123", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00201", name: "Eagle Market Makers 00201", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00212", name: "Eagle Market Makers 00212", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00250", name: "Eagle Market Makers 00250", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00333", name: "Eagle Market Makers 00333", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00375", name: "Eagle Market Makers 00375", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00429", name: "Eagle Market Makers 00429", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00444", name: "Eagle Market Makers 00444", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00451", name: "Eagle Market Makers 00451", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00454", name: "Eagle Market Makers 00454", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00455", name: "Eagle Market Makers 00455", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00525", name: "Eagle Market Makers 00525", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00567", name: "Eagle Market Makers 00567", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00624", name: "Eagle Market Makers 00624", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00700", name: "Eagle Market Makers 00700", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00708", name: "Eagle Market Makers 00708", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00712", name: "Eagle Market Makers 00712", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00789", name: "Eagle Market Makers 00789", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00800", name: "Eagle Market Makers 00800", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00877", name: "Eagle Market Makers 00877", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00898", name: "Eagle Market Makers 00898", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00902", name: "Eagle Market Makers 00902", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00934", name: "Eagle Market Makers 00934", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00944", name: "Eagle Market Makers 00944", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "00945", name: "Eagle Market Makers 00945", account_type: reg, active: true},
    {entity: Entity.find_by_code("EMM"), code: "01500", name: "Ronald T. Manaster 01500", account_type: reg, active: true}
]

account_params.each {|params| Account.where(params).first_or_create}

# user = User.find_by_email('user@bite.com')
# user.accounts << Account.find_by_code('00250')
# user.accounts << Account.find_by_code('00877')

#
# CME EOD FIXML related
#

clr_sys = SystemType.find_by_code('CLR')

crp = EntityType.find_by_code('CRP')

cbt = Entity.create!(code: 'CBT', name: 'Chicago Board of Trade', entity_type: crp)
nymex = Entity.create!(code: 'NYMEX', name: 'New York Mercantile Exchange', entity_type: crp)

cme = Entity.find_by_code('CME')
cme_sys = System.create!(code: 'CMEsys', name: 'CME System', entity: cme, system_type: clr_sys)

dv_system = DealingVenueType.find_by_code('SYS')

cme_dv = DealingVenue.create!(code: 'CME', name: 'Chicago Mercantile Exchange', entity: cme, dealing_venue_type: dv_system)
cbt_dv = DealingVenue.find_by_code('CBT')

[
    {dealing_venue: cme_dv, code: 'CME', system: cme_sys},
    {dealing_venue: cbt_dv, code: 'CBT', system: cme_sys},
    {dealing_venue: nymex_dv, code: 'NYMEX', system: cme_sys}
].each do |params|
  DealingVenueAlias.where(params).first_or_create
end
[
    {system_id: cme_sys.id, entity_id: cbt.id, code: 'CBT'},
    {system_id: cme_sys.id, entity_id: cme.id, code: 'CME'},
    {system_id: cme_sys.id, entity_id: nymex.id, code: 'NYMEX'}
].each do |params|
  EntityAlias.where(params).first_or_create
end

#
# Quandl related
#

crp = EntityType.find_by_code('CRP')
qdl = Entity.create!(code: 'QDL', name: 'Quandl (quandl.com)', entity_type: crp)
typ = SystemType.create(code: 'MKTDAT', name: 'Market Data System')
sys = System.create!(code: 'QDL', name: 'quandl.com', entity: qdl, system_type: typ)

#
# ABN CSV Dealing Venue Aliases
#

crp = EntityType.find_by_code('CRP')
dv_system = DealingVenueType.find_by_code('SYS')

aacc_sys = System.find_by_code('AACC')

ice_ca = Entity.create!(code: 'IFCA', name: 'ICE Futures Canada', entity_type: crp)

liffe_dv = DealingVenue.find_by_code('LIFFE')
DealingVenueAlias.create!(dealing_venue: liffe_dv, code: '05', system: aacc_sys)

wge_dv = DealingVenue.create!(code: 'WGE', name: 'Winnipeg Grain Exchange', entity: ice_ca, dealing_venue_type: dv_system)
DealingVenueAlias.create!(dealing_venue: wge_dv, code: '11', system: aacc_sys)

ice_eu_dv = DealingVenue.find_by_code('IFEU')
DealingVenueAlias.create!(dealing_venue: ice_eu_dv, code: '19', system: aacc_sys)

matif_dv = DealingVenue.find_by_code('EUREX')
DealingVenueAlias.create!(dealing_venue: matif_dv, code: '25', system: aacc_sys)

eurex_dv = DealingVenue.find_by_code('EUREX')
DealingVenueAlias.create!(dealing_venue: eurex_dv, code: '27', system: aacc_sys)

#
# ABN CSV Claim Set Aliases
#


#
# Setup Segregations
#

[
    {code: 'SEGD', name: 'SEG', note: 'Segregated'},
    {code: 'SEGN', name: 'NON', note: 'Non-Segregated'},
    {code: 'SEGU', name: 'UKN', note: 'Unknown Segregated'},
    {code: 'SEG7', name: '30.7', note: '30.7 Segregated'},
    {code: 'NONE', name: 'NONE', note: 'Not Segregated'},
    {code: 'SEGB', name: 'Base', note: 'Base Segregated'}
].each do |params|
  Segregation.create!(params)
end

#
# ClaimSets
#

filename = "#{Rails.root}/etc/data/static/claim_sets.tab"
puts filename

if File.exist? filename
  File.open(filename).readlines.each do |line|
    next if line.match(/^code/)
    puts line
    ary = line.split("\t")
    next unless ary.size == 2
    params = {
        code: ary[0],
        name: ary[0]
    }
    ClaimSet.create! params
  end
else
  puts "#{filename} does not exist. Exiting."
  exit
end

#
# Claims
#

filename = "#{Rails.root}/etc/data/static/claims.tab"
puts filename

if File.exist? filename
  File.open(filename).readlines.each do |line|
    next if line.match(/^claim/)
    puts line
    ary = line.split("\t")
    next unless ary.size > 2
    params = {
        code: ary[3],
        expires_on: ary[-1]
    }
    puts params.inspect
    future = Future.create! params
    params = {
        claim_set: ClaimSet.find_by_code(ary[0]),
        claim_type: ClaimType.find_by_code(ary[1]),
        entity: Entity.find_by_code(ary[2]),
        code: ary[3],
        name: ary[4],
        size: ary[5],
        point_value: ary[6],
        point_currency: Currency.find_by_code(ary[7]),
        claimable: future
    }
    puts params.inspect
    Claim.create! params
  end
else
  puts "#{filename} does not exist. Exiting."
  exit
end

#
# Setup User/Duty/UserDuty defaults
#

[
    %W(ROOT Root),
    %W(BACK Back\ Officer),
    %W(HEAD Head\ Trader),
    %W(TRADER Trader),
    %W(RISK, Risk\ Manager),
    %W(COMP, Compliance\ Officer)
].each do |ary|
  params = {code: ary.first, name: ary.last}
  Duty.where(params).first_or_create
end

[
    %W(root@bite.com ROOT),
    %W(back@bite.com BACK),
    %W(head@bite.com HEAD),
    %W(user@bite.com TRADER)
].each do |ary|
  params = {
      user: User.find_by_email(ary.first),
      duty: Duty.find_by_code(ary.last)
  }
  UserDuty.where(params).first_or_create
end

# account = Account.find_by_code('00022')
# user = User.find_by_email('user@bite.com')
# user.accounts << account
# user.save!

#
# Chargeable Types
#

[
    {code: 'SRV', name: 'Service'},
    {code: 'EXG', name: 'Exchange'},
    {code: 'BRK', name: 'Brokerage'}
].each do |params|
  ChargeableType.where(params).first_or_create
end

#
# Chargeable
#

filename = "#{Rails.root}/etc/data/static/chargeables.tab"
puts filename

if File.exist? filename
  File.open(filename).readlines.each do |line|
    next if line.match(/^claim/)
    puts line
    ary = line.split("\t")
    next unless ary.size > 2
    params = {
        chargeable_type: ChargeableType.find_by_code(ary[1]),
        claim_set: ClaimSet.find_by_code(ary[0]),
        currency: Currency.find_by_code(ary[2]),
        amount: ary[3],
        begun_on: ary[4],
        ended_on: ary[5]
    }
    puts params.inspect
    Chargeable.create! params
  end
else
  puts "#{filename} does not exist. Exiting."
  exit
end


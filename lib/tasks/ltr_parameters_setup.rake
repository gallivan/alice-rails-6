lines = <<HERE
CBT:C,250,Corn
NYCE:28,100,Cotton
CME:62,50,Feeder Cattle
CME:LN,100,Lean Hogs
CME:48,100,Live Cattle
CBT:S,150,Soybeans
CBT:07,200,Soybean Meal
CBT:06,200,Soybean Oil
CBT:KW,150,Wheat
CBT:W,150,Wheat
CME:ES,1000,S&P 500 Stock Price Index
CBT:YM,200,Other Broad-Based Securities Indexes
CME:RTY,200,Other Broad-Based Securities Indexes
NYCE:TF,200,Other Broad-Based Securities Indexes
CBT:26,1000,2-Year U.S. Treasury Notes
CBT:25,2000,5-Year U.S. Treasury Notes
CBT:21,2000,10-Year U.S. Treasury Notes
CBT:17,1500,30-Year U.S. Treasury Bonds
CBT:UBE,1500,30-Year U.S. Treasury Bonds
CME:ED,3000,3-Month Eurodollar Time Deposit Rates
CME:C1,400,Major Foreign Currencies
CME:EC,400,Major Foreign Currencies
NYMEX:CL,350,"Crude Oil, Sweet"
NYMEX:NG,200,Natural Gas
NYMEX:HO,250,No. 2 Heating Oil
NYMEX:RB,150,Unleaded Gasoline
IFEU:G,150,Gas Oil Futures
HERE

task :ltr_parameters_setup => :environment do

  report_type = ReportType.find_by_code('LTR')

  if report_type.blank?
    report_type = ReportType.create! do |t|
      t.code = 'LTR'
      t.name = 'Large Trader Report'
    end
  end

  # TODO this seems really stupid - but it works.
  # TODO this seems really stupid - but it works.
  # TODO this seems really stupid - but it works.

  ReportTypeReportTypeParameter.delete_all
  ReportTypeParameter.delete_all

  lines.split("\n").each do |line|
    puts line
    elements = line.split(/,/)

    report_type_parameter = ReportTypeParameter.create! do |p|
      p.handle = elements[0]
      p.bucket = elements[1]
    end

    report_type.report_type_parameters << report_type_parameter
  end

end
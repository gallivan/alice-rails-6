task :clear_dynamic_data_for_date, [:date] => :environment do |t, args|
  begin
    date = Date.parse(args[:date])
    puts "Running with #{date}..."
  rescue Exception => e
    puts "Invalid argument: #{e}"
    puts "Usage: clear_dynamic_data_for_date['yyyy-mm-dd']"
    exit
  end

  print "Clearing dynamic data for #{date}..."

  DealLegFill.posted_on(date).delete_all

  Charge.posted_on(date).delete_all
  Adjustment.posted_on(date).delete_all

  JournalEntry.posted_on(date).delete_all
  LedgerEntry.posted_on(date).delete_all
  MoneyLine.posted_on(date).delete_all

  PositionNetting.posted_on(date).delete_all
  Position.posted_on(date).delete_all
  StatementCharge.posted_on(date).delete_all
  StatementAdjustment.posted_on(date).delete_all
  # PositionPositionTransfer.posted_on(date).delete_all
  StatementPositionNetting.posted_on(date).delete_all
  StatementPosition.posted_on(date).delete_all
  StatementMoneyLine.posted_on(date).delete_all
  StatementDealLegFill.posted_on(date).delete_all
  StatementPositionNetting.posted_on(date).delete_all

  BookerReport.where(posted_on: date).delete_all
  PackerReport.where(posted_on: date).delete_all
  PickerReport.where(posted_on: date).delete_all

  puts "done"
end

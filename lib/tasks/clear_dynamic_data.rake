task :clear_dynamic_data => :environment do

  puts "Clearing dynamic data."
  puts "Have you BACKEDUP the DB? Exit if not."
  print "Sleeping 15 seconds..."
  sleep 15
  puts "done."

  names = [
      Adjustment,
      Charge,

      JournalEntry,
      LedgerEntry,
      MoneyLine,

      # PositionTransfer,
      # PositionNetting,

      StatementFee,
      StatementCommission,
      StatementAdjustment,
      StatementPosition,
      StatementMoneyLine,
      StatementDealLegFill,
      StatementPositionNetting,

      # ClaimMark
  ]

  names.each do |c|
    puts c.name
    puts "\tBegun at #{Time.now}"
    puts "\tRows to delete: #{c.send('count')}"
    print "\tDeleting..."
    c.send('delete_all')
    puts "done."
    puts "\tEnded at: #{Time.now}"
  end

  puts 'Truncations'
  puts "\tBegun at #{Time.now}"
  # Will cover deal_leg_fills, position_nettings and position_transfers
  Position.connection.execute('TRUNCATE TABLE positions CASCADE')
  BookerReport.connection.execute('TRUNCATE TABLE booker_reports CASCADE')
  PackerReport.connection.execute('TRUNCATE TABLE packer_reports')
  PickerReport.connection.execute('TRUNCATE TABLE picker_reports')
  puts "\tEnded at: #{Time.now}"

  date = Date.parse('20161230')

  Claim.all.each do |claim|
    next if claim.expired?
    puts "Posting ClaimMark on #{date} for #{claim.code}"
    Workers::QuandlDAO.get_quandl_mark(date, claim)
  end

  puts "All done"
end
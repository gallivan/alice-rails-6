task :baseline_2016_june => :environment do
  Rake::Task["clear_dynamic_data"].invoke
  Rake::Task["baseline_balances_2016_june"].invoke
  Rake::Task["baseline_positions_2016_june"].invoke
  Rake::Task["baseline_reports_2016_june"].invoke
  Rake::Task["drop_copy:load"].invoke
end
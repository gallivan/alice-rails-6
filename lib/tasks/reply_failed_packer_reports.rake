task :reply_failed_packer_reports => :environment do
  PackerReport.fail.each do |packer_report|
    packer_report.root =~/EOD_CME/

  end
end

namespace :abn_itd do

  # multitask :run => [:abn_itd_pick, :abn_itd_pack, :abn_itd_post] do
  #   puts "Completed parallel execution of tasks pick, pack and post."
  # end

  task :pick, [:date] => :environment do |t, args|
    if args[:date].blank?
      puts "Usage: rails abn_itd:pick[YYYYMMDD]"
      puts "Usage: rails abn_itd:pick[20191122]"
      exit
    else
      picker = Workers::PickerOfItdAbn.new
      picker.pick(args[:date])
    end
  end

  task :pack => :environment do
    packer = Workers::PackerOfItdAbn.new('itd.abn.picked.all', 'itd.abn.packed.all')
    packer.pack
  end

  task :book => :environment do
    booker = Workers::BookerOfItdAbn.new('itd.abn.packed.all')
    booker.book
  end

  task :test, [:date] => :environment do |t, args|
    if args[:date].blank?
      puts "Usage: rails abn_itd:test[YYYYMMDD]"
      puts "Usage: rails abn_itd:test[20191122]"
      exit
    else
      puts args[:date]
    end
  end

end

task :seed_claim_sets => :environment do

  #code name
  #CBT:06	CBT:SOYBEAN MEAL FUTURES

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
    puts "#{filename} does not exist."
  end

end
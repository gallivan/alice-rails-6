namespace (:cqg) do

  task :load_spread_directory, [:dirname] => :environment do |t, args|
    dirname = args[:dirname]
    unless dirname
      puts "Usage: #{t}[dirname]"
      puts "Usage: #{t}[/path/to/files"
      exit
    end

    filenames = Dir.entries(dirname).sort

    filenames.each do |filename|
      next unless filename.match(/bd$/)
      puts filename
      path = "#{dirname}/#{filename}"
      Rake::Task['cqg:load_spread_bd_file'].invoke(path)
      # https://michaelrigart.be/rake-basics/
      Rake::Task['cqg:load_spread_bd_file'].reenable
    end

    filenames.each do |filename|
      next unless filename.match(/vd$/)
      puts filename
      path = "#{dirname}/#{filename}"
      Rake::Task['cqg:load_spread_vd_file'].invoke(path)
      Rake::Task['cqg:load_spread_vd_file'].reenable
    end
  end

  task :load_spread_vd_file, [:filename] => :environment do |t, args|
    filename = args[:filename]

    unless filename
      puts "Usage: #{t}[filename]"
      puts "Usage: #{t}[/path/to/F.US.ZCES2H09_20080701_20180504.vd"
      exit
    end

    entity_type = EntityType.find_by_code('CRP')
    entity = Entity.find_or_create_by!(code: 'CQG', name: 'Commodity Quote Graphics', entity_type: entity_type)

    system_type = SystemType.find_by_code('MKTDAT')
    system = System.find_or_create_by!(code: 'CQG-FACT', name: 'Commodity Quote Graphics Data Factory', entity: entity, system_type: system_type)

    claim = build_spread_from_filename(filename)

    # read file and load volumes

    File.open(filename).each_line {|line| claim_volume_from_line(system, claim, line)}

  end

  task :load_spread_bd_file, [:filename] => :environment do |t, args|
    filename = args[:filename]

    unless filename
      puts "Usage: #{t}[filename]"
      puts "Usage: #{t}[/path/to/F.US.ZCES2H09_20080701_20180504.bd"
      exit
    end

    entity_type = EntityType.find_by_code('CRP')
    entity = Entity.find_or_create_by!(code: 'CQG', name: 'Commodity Quote Graphics', entity_type: entity_type)

    system_type = SystemType.find_by_code('MKTDAT')
    system = System.find_or_create_by!(code: 'CQG-FACT', name: 'Commodity Quote Graphics Data Factory', entity: entity, system_type: system_type)

    claim = build_spread_from_filename(filename)

    File.open(filename).each_line {|line| claim_mark_from_line(system, claim, line)}
  end

  def claim_mark_from_line(system, claim, line)
    fields = line.split(' ')
    # puts fields
    posted_on = Date.parse(fields[1])
    # want to be able to re-run
    claim.claim_marks.posted_on(posted_on).first.delete unless claim.claim_marks.posted_on(posted_on).blank?
    ClaimMark.create! do |m|
      m.system_id = system.id
      m.claim = claim
      m.posted_on = posted_on
      m.mark = s_to_f(fields[5])
      m.open = s_to_f(fields[2])
      m.high = s_to_f(fields[3])
      m.low = s_to_f(fields[4])
      m.last = m.mark
      m.approved = true
    end
  end

  def claim_volume_from_line(system, claim, line)
    # puts line
    fields = line.split(' ')
    # puts fields
    posted_on = Date.parse(fields[1])
    claim_mark = claim.claim_marks.posted_on(posted_on).first
    if claim_mark
      claim_mark.update_attribute(:volume, fields[2])
    else
      puts "ClaimMark blank for #{claim.code} posted on #{posted_on}"
    end
  end

  def s_to_f(s)
    # puts s
    if s.to_i == 0
      return 0
    else
      neg = s.match(/^-/)
      s = s.sub('-', '') if neg
      tail = s.last
      tail = tail.to_i / 8.0
      # puts tail
      head = s.length > 1 ? s.slice(0, s.length - 1).to_i : 0
      # puts head
      rslt = head + tail
      # puts rslt
      if neg
        rslt * -1
      else
        rslt
      end
    end
  end

  def build_spread(legs)
    params = {
        leg_claims: legs,
        weights: [+1, -1]
    }
    Builders::SpreadBuilder.build_cqg_spread(params)
  end

  def build_leg_2_claim_code(leg_1_claim)

    # CBT:CH09 to CBT:CN09
    # CBT:CH18 to CBT:CN18
    # CBT:CZ18 to CBT:CK19

    mapping = {
        'H' => 'N',
        'K' => 'U',
        'N' => 'Z',
        'U' => 'H',
        'Z' => 'K',
    }

    claim_set = leg_1_claim.claim_set

    leg_1_month_code = leg_1_claim.code[-3]
    leg_2_month_code = mapping[leg_1_month_code]

    leg_1_year_code = leg_1_claim.code[-2..-1]

    if leg_1_month_code < leg_2_month_code
      # Leg 2 contract expires same year.
      leg_2_year_code = leg_1_year_code
    else
      # Leg 2 contract expires following year.
      leg_2_year_code = leg_1_year_code.to_i + 1
      if leg_2_year_code < 10
        leg_2_year_code = "0#{leg_2_year_code}"
      else
        leg_2_year_code = "#{leg_2_year_code}"
      end
    end

    "#{claim_set.code}#{leg_2_month_code}#{leg_2_year_code}"
  end

  def build_spread_from_filename(filename)
    # Leg 1

    # F.US.ZCES2Z14_20080701_20180504.bd
    # F.US.ZCES2Z14_20080701_20180504.vd
    code = File.basename(filename)
    code = code.split('_').first
    code = code.sub('F.US.Z', '').sub('ES2', '')
    code = 'CBT:' + code
    leg_1_claim = (Claim.find_by_code(code).blank?) ? Builders::ClaimBuilder.future_given_code(code) : Claim.find_by_code(code)

    # Leg 2

    code = build_leg_2_claim_code(leg_1_claim)
    leg_2_claim = (Claim.find_by_code(code).blank?) ? Builders::ClaimBuilder.future_given_code(code) : Claim.find_by_code(code)

    # Show both claims

    # puts leg_1_claim.code
    # puts leg_2_claim.code

    spread_code = "#{leg_1_claim.code}-#{leg_2_claim.code}"
    claim = (Claim.find_by_code(spread_code).blank?) ? build_spread([leg_1_claim, leg_2_claim]) : Claim.find_by_code(spread_code)

    puts spread_code

    claim
  end
end
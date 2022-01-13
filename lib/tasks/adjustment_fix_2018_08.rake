=begin
An error was made on creating Adjustments.
Several were assigned a Segregation of SEGB.

This code identifies the bad Adjustments,
reverses those and creates corred Adjustmennts.
=end

task :adjustment_fix_2018_08, [:date] => :environment do |t, args|

  unless args[:date]
    puts "Usage: #{t}[yyyy-mm-dd]"
    exit 0
  end

  segregation = Segregation.find_by_code('SEGB')
  bad_boys = Adjustment.where("segregation_id = ?", segregation.id)

  ActiveRecord::Base.transaction do
    posted_on = args[:date]
    segregation = Segregation.find_by_code('SEGN')

    bad_boys.each do |b|
      puts "Adjustment #{b.id}: reversing SEGB and applying SEGN."
      params = b.attributes
      params = params.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

      params.delete(:id)
      params.delete(:as_of_on)
      params.delete(:posted_on)
      params.delete(:created_at)
      params.delete(:updated_at)
      params.delete(:journal_entry_id)

      # general

      memo = params[:memo]
      params[:posted_on] = posted_on

      # reverse bad adjustment

      params[:memo] = "#{memo} reversal"
      params[:amount] = params[:amount] * -1
      Builders::AdjustmentBuilder.build(params)

      # apply good adjustment

      params[:memo] = "#{memo} with corrected SEG"
      params[:amount] = params[:amount] * -1
      params[:segregation_id] = segregation.id
      Builders::AdjustmentBuilder.build(params)
    end
  end
end

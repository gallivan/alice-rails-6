task :delete_portfolio, [:id] => :environment do |t, args|
  puts "begun #{t.name}"

  if args[:id].blank?
    puts "Usage: rake t.name[<portfolio_id>]"
    puts "Usage: rake t.name['23432']"
    exit
  end

  id = args[:id]

  portfolio = Portfolio.find(id)

  begin
    portfolio.margins.each do |margin|
      margin.margin_requests.each do |margin_request|
        margin_request.margin_response.delete
        margin_request.delete
      end
      margin.delete
      portfolio.portfolio_positions.each do |portfolio_position|
        portfolio_position.delete
      end
      portfolio.account_portfolio.delete
    end
    portfolio.delete
  rescue Exception => e
    puts "Failed: #{e}"
  end

  puts "ended #{t.name}"
end

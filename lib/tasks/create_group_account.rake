task :create_group_account, [:code, :name] => :environment do |t, args|
  puts "begun #{t.name}"

  puts t.name

  if args[:code].blank? or args[:name].blank?
    puts "Usage: rake t.name[<code>,<name>]"
    puts "Usage: rake t.name['ABC','ABC GROUP ACCOUNT']"
    exit
  end

  code = args[:code]
  name = args[:name]

  params = {
      code: code,
      name: name,
      entity: Entity.find_by_code('EMM'),
      account_type: AccountType.find_by_code('GRP')
  }

  begin
    account = Account.where(params).first_or_create
    account.group_members.delete_all
    account.group_members << Account.reg.active.order(:id)
  rescue Exception => e
    puts "Failed: #{e}"
  end

  puts "ended #{t.name}"
end

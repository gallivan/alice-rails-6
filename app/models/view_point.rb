# == Schema Information
#
# Table name: view_points
#
#  id         :integer          not null, primary key
#  name       :string
#  note       :text
#  code       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ViewPoint < ApplicationRecord

  def self.seasonal_spreads_data(claim_id)
    sql = "
    select code, posted_on, open, high, low, mark, volume
    from claims c, claim_marks m
    where claim_id = #{connection.quote(claim_id)} and c.id = m.claim_id
    order by m.posted_on"

    ActiveRecord::Base.connection.execute(sql)
  end

  def self.who_what_when(current_user, start_date, end_date)
    date_conditions = ViewPoint.sanitize_sql_for_conditions(['posted_on between ? and ?', start_date, end_date])
    if current_user.is_trader? or current_user.duties.blank?
      account_codes = "('" + current_user.accounts.pluck(:code).join(',').gsub(",", "','") + "')"
      sql = "select * from inc_exp_usds where account_code in #{account_codes} and #{date_conditions} order by posted_on, account_code"
    else
      sql = "select * from inc_exp_usds where #{date_conditions} order by posted_on, account_code"
    end

    ActiveRecord::Base.connection.execute(sql)
  end

  def self.firm_what_when(start_date, end_date)
    date_conditions = ViewPoint.sanitize_sql_for_conditions(['posted_on between ? and ?', start_date, end_date])
    sql = "select * from inc_exp_usds where #{date_conditions} order by posted_on, account_code"
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.account_dashboard_data(account)
    data = {positions: [], statement_money_lines: []}

    positions = account.positions.joins(:claim).open.order('claims.code')
    statement_money_lines = account.statement_money_lines.base.order(stated_on: :desc).limit(10)

    data[:positions] = positions unless positions.empty?
    data[:statement_money_lines] = statement_money_lines unless statement_money_lines.empty?

    data
  end

  def self.statement_money_lines_ytd(account_id)
    account = Account.find(account_id)
    account.statement_money_lines.base.order(stated_on: :asc)
  end

  def self.statement_money_lines_since(account_id, date)
    account = Account.find(account_id)
    account.statement_money_lines.base.since(date).order(stated_on: :asc)
  end

  def self.firm_statement_money_lines_since(date)
    select = "
    stated_on,
    sum(charges) as charges,
    sum(pnl_futures) as pnl_futures,
    sum(open_trade_equity) as open_trade_equity,
    sum(net_liquidating_balance) as net_liquidating_balance"
    StatementMoneyLine.base.since(date).select(select).group(:stated_on).order(stated_on: :asc)
  end

  def self.positions
    account = Account.find_by_code(SUBJECT_ACCOUNT_CODE)
    account.positions.select('claims.code', :bot, :sld, :net).joins(:claim).open.order('claims.code')
  end

  def self.positions_by_claim_data(account_id)
    account = Account.find(account_id)
    account.positions.open.joins(:claim).select('claims.code as claim_code, sum(bot) as bot, sum(sld) as sld, sum(bot) - sum(sld) as net').group('claims.code').order('claims.code')
  end

  def self.statement_positions_by_claim_on(account_id, date)
    account = Account.find(account_id)
    # account.statement_positions.stated_on(date).select('claim_code as claim_code, sum(bot) as bot, sum(sld) as sld, sum(bot) - sum(sld) as net').group(:claim_code).order(:claim_code)
    account.statement_positions.stated_on(date).select('claim_name as claim_name, sum(bot) as bot, sum(sld) as sld, sum(bot) - sum(sld) as net').group(:claim_name).order(:claim_name)
  end

  def self.firm_positions_by_claim_data
    Position.open.joins(:claim).select('claims.code as claim_code, sum(bot) as bot, sum(sld) as sld, sum(bot) - sum(sld) as net').group('claims.code').order('claims.code')
  end

  def self.firm_statement_positions_by_claim_on(date)
    StatementPosition.stated_on(date).select('claim_name, sum(bot) as bot, sum(sld) as sld, sum(bot) - sum(sld) as net').group('stated_on, claim_name').order(:claim_name)
  end

  def self.claim_codes_traded_since(cut_at)
    DealLegFill.joins(:claim).where('deal_leg_fills.created_at > ?', 1.day.ago).pluck('distinct claims.code').sort
  end

  def self.volumes_for_claim_data(claim_id, cut_at)
    DealLegFill.joins(:claim).where('claim_id = ? and deal_leg_fills.created_at > ?', claim_id, cut_at).group('claims.code').pluck('sum(abs(done)) as done').first
  end

  def self.claim_set_codes_traded_since(cut_at)
    sql = "
      SELECT DISTINCT
          s.code
      FROM
          deal_leg_fills f,
          claims c,
          claim_sets s
      WHERE
          s.id = c.claim_set_id AND
          c.id = f.claim_id AND
          f.created_at > ?
      ORDER BY
          s.code
      "

    # query = sanitize_sql(sql, cut_at.strftime('%Y-%m-%d %H:%M:%S'))
    query = sanitize_sql([sql, cut_at])

    results = ActiveRecord::Base.connection.execute(query)
    results.values.flatten
  end

  def self.volumes_for_claim_set_data(claim_set_id, cut_at)
    sql = "
      SELECT
          sum(abs(done)) as done
      FROM
          deal_leg_fills f,
          claims c,
          claim_sets s
      WHERE
          s.id = ? AND
          s.id = c.claim_set_id AND
          c.id = f.claim_id AND
          f.created_at > ?
      GROUP BY
          s.code
      "
    query = sanitize_sql([sql, claim_set_id, cut_at])

    results = ActiveRecord::Base.connection.execute(query)
    results.values.flatten.first
  end

  def self.volumes_by_claim
    volumes = []
    cut_names = [:m05, :m15, :h01, :d01]
    cut_times = [5.minutes.ago, 15.minutes.ago, 1.hour.ago, 1.day.ago]
    claim_codes = ViewPoint.claim_codes_traded_since(24.hours.ago)
    claim_codes.each do |claim_code|
      claim = Claim.find_by_code(claim_code)
      hash = {claim_code: claim_code}
      cut_times.each_with_index do |cut_point, i|
        name = cut_names[i]
        done = ViewPoint.volumes_for_claim_data(claim.id, cut_point)
        hash[name] = done.blank? ? 0 : done.to_i
      end
      volumes << hash
    end
    puts volumes
    volumes
  end

  def self.volumes_by_claim_set
    volumes = []
    cut_names = [:m05, :m15, :h01, :d01]
    cut_times = [5.minutes.ago, 15.minutes.ago, 1.hour.ago, 1.day.ago]
    claim_set_codes = ViewPoint.claim_set_codes_traded_since(24.hours.ago)
    claim_set_codes.each do |code|
      claim_set = ClaimSet.find_by_code(code)
      hash = {claim_set_code: code}
      cut_times.each_with_index do |cut_point, i|
        name = cut_names[i]
        done = ViewPoint.volumes_for_claim_set_data(claim_set.id, cut_point)
        hash[name] = done.blank? ? 0 : done.to_i
      end
      volumes << hash
    end
    puts volumes
    volumes
  end

  def self.income_to_expense_ratio_by_claim_set(account_id)
    sql = "
      SELECT
        account_code,
        claim_set_code,
        claim_set_name,
        SUM(done::INTEGER)                AS done,
        SUM(inc)                          AS total_inc,
        SUM(ABS(exp))                     AS total_exp,
        SUM(net)                          AS total_net,
        ROUND(SUM(inc)/SUM(done), 2)      AS unit_inc,
        ROUND(SUM(ABS(exp))/SUM(done), 2) AS unit_exp,
        ROUND(SUM(net)/SUM(done), 2)      AS unit_net,
        ROUND(SUM(inc)/SUM(ABS(exp)), 2)  AS inc_exp_ratio
      FROM
          inc_exp_usds
      WHERE
          account_code = ?
      GROUP BY
          account_code,
          claim_set_code,
          claim_set_name
      ORDER BY
          account_code,
          claim_set_code
    "
    account_code = Account.find(account_id).code
    query = sanitize_sql([sql, account_code])
    ActiveRecord::Base.connection.execute(query)
  end

  def self.income_to_expense_ratio_by_claim_set_for_firm
    sql = "
      SELECT
        claim_set_code,
        claim_set_name,
        SUM(done::INTEGER)                AS done,
        SUM(inc)                          AS total_inc,
        SUM(ABS(exp))                     AS total_exp,
        SUM(net)                          AS total_net,
        ROUND(SUM(inc)/SUM(done), 2)      AS unit_inc,
        ROUND(SUM(ABS(exp))/SUM(done), 2) AS unit_exp,
        ROUND(SUM(net)/SUM(done), 2)      AS unit_net,
        ROUND(SUM(inc)/SUM(ABS(exp)), 2)  AS inc_exp_ratio
      FROM
          inc_exp_usds
      GROUP BY
          claim_set_code,
          claim_set_name
      ORDER BY
          claim_set_code
    "
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.spread_claim_marks(claim_set_id)
    # data : {
    #     xs: {
    #         'CBT:CK13-CBT:CU13': 'x1',
    #         'CBT:CK14-CBT:CU14': 'x2'
    #     },
    #     columns: [
    #         ['x1', -500, -499, -498, -497, -496, -495],
    #         ['x2', -501, -400, -499, -498, -497, -496],
    #         ['CBT:CK13-CBT:CU13', 10, 11, 12, 13, 11, 10],
    #         ['CBT:CK14-CBT:CU14', 20, 21, 23, 19, 18, 17]
    #     ]
    # }

    xs = {}
    columns = []

    claim_set = ClaimSet.find(claim_set_id)
    claims = claim_set.claims

    x = 0
    claims.each do |claim|
      puts claim.code

      x = x + 1
      x_name = "x#{x}"
      c_name = claim.code
      x_data = [x_name]
      c_data = [c_name]
      xs[c_name] = x_name

      expires_on = claim.claimable.spread_legs.first.claim.claimable.expires_on

      if expires_on.blank?
        expires_on = claim.claim_marks.order(posted_on: :desc).limit(1).first.posted_on
      end

      claim.claim_marks.order(:posted_on).each do |claim_mark|
        x_data << (claim_mark.posted_on - expires_on).to_s.split('/').first.to_i
        c_data << claim_mark.mark
      end
      columns << x_data
      columns << c_data
    end
    [xs, columns]
  end

  def self.claim_set_marks_by_date(claim_set_id)
    tags = []
    data = []

    claim_set = ClaimSet.find(claim_set_id)
    claims = claim_set.claims

    claims.each do |claim|
      tags << claim.code
      data << claim_marks_by_date(claim)
    end
    {tags: tags, data: data}
  end

  def self.claim_marks_by_date(claim)
    results = claim.claim_marks.order(:posted_on).pluck(:posted_on, :mark)
    x_data = []
    y_data = []
    results.each do |result|
      x_data << result.first
      y_data << result.last
    end
    {x: x_data, y: y_data}
  end

end


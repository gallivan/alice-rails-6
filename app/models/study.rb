class Study < ApplicationRecord
  # attr_accessible :title, :body

  def self.matches
    select_matches
    # StudyMatch.where("matched_on >= ? and matched_on <= ?", Date.parse('20140202'), Date.parse('20140208')).order(:offset_id)
  end

  def self.gross_by_tradeable_set
    select_gross_by_tradeable_set
  end

  def self.offset_flows(account_code, tradeable_code, tradeable_set_code, posting_date)
    OffsetFlow.where(account_code: account_code, tradeable_code: tradeable_code, tradeable_set_code: tradeable_set_code, posting_date: posting_date)
  end

  #
  # sql
  #

  def self.select_gross_by_tradeable_set
    sql = %Q(
      SELECT
          a.code                             AS acc_code,
          TO_CHAR(n.posted_on, 'YYYY-MM-DD') AS posted_on,
          split_part(s.code, ':', 1)         AS exg_code,
          split_part(s.name, ':', 2)         AS set_name,
          SUM(n.done * 2)::INTEGER           AS traded,
          SUM(n.pnl * m.mark):: INTEGER      AS grs
      FROM
          position_nettings n,
          claims c,
          claim_sets s,
          accounts a,
          currency_marks m
      WHERE
          a.id = n.account_id AND
          s.id = c.claim_set_id AND
          c.id = n.claim_id AND
          n.currency_id = m.currency_id AND
          n.posted_on = m.posted_on
      GROUP BY
          a.code,
          s.code,
          n.posted_on,
          s.name
      ORDER BY
          n.posted_on,
          s.name
    )
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.select_matches
    sql = %q(
      SELECT
          post,
          hour,
          acct,
          exch,
          code,
          name,
          CASE
              WHEN hour >= 22 AND hour <= 23 THEN 1
              WHEN hour >  00 AND hour <= 06 THEN 1
              WHEN hour >  07 AND hour <= 14 THEN 2
              ELSE 3
          END AS team,
          done,
          flow,
          ROUND(CAST(cost AS NUMERIC),3) AS cost
      FROM
          study_matches
    )
    ActiveRecord::Base.connection.execute(sql)
  end
end

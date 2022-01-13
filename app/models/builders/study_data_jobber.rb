class StudyDataJobber

  def self.perform(params)
    self.send(params[:action], params) unless params[:action].blank?
  end

  private

  def self.update(params)
    sql =  sanitize_sql(["delete from bot_tbl where posting_date = ?;", params[:posting_date]])
    sql += sanitize_sql(["delete from sld_tbl where posting_date = ?;", params[:posting_date]])
    sql += sanitize_sql(["INSERT INTO bot_tbl SELECT * FROM bot where posting_date = ?;", params[:posting_date]])
    sql += sanitize_sql(["INSERT INTO sld_tbl SELECT * FROM sld where posting_date = ?;", params[:posting_date]])
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.create(params)
    puts 'Building materialized elements supporting executions view....'
    puts 'Cleaning up.'
    sql = '
       DROP VIEW IF EXISTS executions;
       DROP VIEW IF EXISTS bot;
       DROP VIEW IF EXISTS sld;
       DROP TABLE IF EXISTS study_matches;
       DROP TABLE IF EXISTS matches;
       DROP TABLE IF EXISTS off_tbl;
       DROP TABLE IF EXISTS bot_tbl;
       DROP TABLE IF EXISTS sld_tbl;
     '
    ActiveRecord::Base.connection.execute(sql)

    puts 'Building bot view.'
    sql = %q(
       CREATE VIEW
           bot AS
       SELECT
           i.id as ind_id,
           e.id as eod_id,
           e.account_id,
           e.tradeable_id,
           e.done,
           e.price,
           e.posting_date,
           i.transacted_at,
           e.order_id,
           e.client_order_id,
           e.feeder_trade_id,
           e.feeder_execution_id,
           f.*
       FROM
           postings i,
           postings e,
           accounts a,
           tradeables t,
           trade_posting_fees_grouped f
       WHERE
           i.transacted_at is not null AND
           e.transacted_at is not null AND
           i.tod_code = 'IND' AND
           e.tod_code = 'EOD' AND
           i.type_code = 'REG' AND
           e.type_code = 'REG' AND
           e.done > 0 and
           a.id = i.account_id AND
           t.id = i.tradeable_id AND
           a.id = e.account_id AND
           t.id = e.tradeable_id AND
           e.id = f.posting_id AND
           i.feeder_trade_id = e.feeder_trade_id AND
           i.feeder_execution_id = e.feeder_execution_id;
     )
    ActiveRecord::Base.connection.execute(sql)

    puts 'Building sld view.'
    sql = %q(
       CREATE VIEW
           sld AS
       SELECT
           i.id as ind_id,
           e.id as eod_id,
           e.account_id,
           e.tradeable_id,
           e.done,
           e.price,
           e.posting_date,
           i.transacted_at,
           e.order_id,
           e.client_order_id,
           e.feeder_trade_id,
           e.feeder_execution_id,
           f.*
       FROM
           postings i,
           postings e,
           accounts a,
           tradeables t,
           trade_posting_fees_grouped f
       WHERE
           i.transacted_at is not null AND
           e.transacted_at is not null AND
           i.tod_code = 'IND' AND
           e.tod_code = 'EOD' AND
           i.type_code = 'REG' AND
           e.type_code = 'REG' AND
           e.done < 0 and
           a.id = i.account_id AND
           t.id = i.tradeable_id AND
           a.id = e.account_id AND
           t.id = e.tradeable_id AND
           e.id = f.posting_id AND
           i.feeder_trade_id = e.feeder_trade_id AND
           i.feeder_execution_id = e.feeder_execution_id;
     )
    ActiveRecord::Base.connection.execute(sql)

    puts 'Building bot_tbl.'
    sql = %q(
       SELECT * INTO bot_tbl FROM (SELECT * FROM bot) x;
       CREATE UNIQUE INDEX ON bot_tbl (ind_id);
       CREATE UNIQUE INDEX ON bot_tbl (eod_id);
       CREATE INDEX ON bot_tbl (account_id);
       CREATE INDEX ON bot_tbl (tradeable_id);
       CREATE INDEX ON bot_tbl (posting_date);
     )
    ActiveRecord::Base.connection.execute(sql)

    puts 'Building sld_tbl.'
    sql = %q(
       SELECT * INTO sld_tbl FROM (SELECT * FROM sld) x;
       CREATE UNIQUE INDEX ON sld_tbl (ind_id);
       CREATE UNIQUE INDEX ON sld_tbl (eod_id);
       CREATE INDEX ON sld_tbl (account_id);
       CREATE INDEX ON sld_tbl (tradeable_id);
       CREATE INDEX ON sld_tbl (posting_date);
     )
    ActiveRecord::Base.connection.execute(sql)

    puts 'Building off_tbl.'
    sql = %q(
       SELECT * INTO off_tbl FROM (SELECT * FROM off_set) x;
       CREATE INDEX ON off_tbl (account_id);
       CREATE INDEX ON off_tbl (tradeable_id);
       CREATE INDEX ON off_tbl (bot_posting_id);
       CREATE INDEX ON off_tbl (sld_posting_id);
       CREATE INDEX ON off_tbl (posting_date);
     )
    ActiveRecord::Base.connection.execute(sql)

    puts 'Building matches.'
    sql = %q(
      SELECT * INTO matches FROM (
        SELECT
            CASE
                WHEN b.transacted_at > s.transacted_at
                THEN b.transacted_at
                ELSE s.transacted_at
            END AS matched_at,
            CASE
                WHEN b.transacted_at > s.transacted_at
                THEN date_part('hour', b.transacted_at)::INTEGER
                ELSE date_part('hour', s.transacted_at)::INTEGER
            END                                          AS matched_hr,
            o.posting_date                               AS matched_on,
            a.code                                       AS account_code,
            t.sector                                     AS sector_code,
            t.discriminator                              AS exchange_code,
            t.code                                       AS tradeable_code,
            t.set_code                                   AS tradeable_set_code,
            t.name                                       AS tradeable_name,
            t.set_name                                   AS tradeable_set_name,
            o.rule                                       AS rule,
            o.done                                       AS done,
            o.price                                      AS price,
            o.flow                                       AS flow,
            (o.done * b.fee) + (o.done * s.fee)          AS cost,
            t.currency_code                              AS pnl_currency_code,
            o.pnl_posting_id                             AS pnl_posting_id,
            o.account_id                                 AS account_id,
            o.tradeable_id                               AS tradeable_id,
            o.id                                         AS offset_id,
            b.ind_id                                     AS bot_ind_id,
            b.eod_id                                     AS bot_eod_id,
            s.ind_id                                     AS sld_ind_id,
            s.eod_id                                     AS sld_eod_id
        FROM
            bot_tbl b,
            sld_tbl s,
            off_tbl o,
            accounts a,
            tradeables t
        WHERE
            o.bot_posting_id = b.eod_id AND
            o.sld_posting_id = s.eod_id AND
            o.account_id = a.id AND
            o.tradeable_id = t.id
        ) x
     )
    ActiveRecord::Base.connection.execute(sql)

    puts 'Building study_matches.'
    sql = %q(
      SELECT * INTO study_matches FROM (
        SELECT
            matched_on         AS post,
            matched_hr         AS hour,
            account_code       AS acct,
            exchange_code      AS exch,
            tradeable_set_code AS code,
            tradeable_set_name AS name,
            SUM(done * 2)      AS done,
            SUM(flow)          AS flow,
            SUM(cost)          AS cost
        FROM
            matches
        GROUP BY
            matched_on,
            matched_hr,
            account_code,
            exchange_code,
            tradeable_set_code,
            tradeable_set_name,
            pnl_currency_code
      )x
    )
    ActiveRecord::Base.connection.execute(sql)

    puts 'Done.'
  end

end


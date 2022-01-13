class AlterCommissionsByExchangeAndPostedOnProxy < ActiveRecord::Migration[5.2]
  def up
    sql = %q(
              DROP VIEW IF EXISTS commissions_by_exchange_and_posted_on_view;
              CREATE VIEW
                 commissions_by_exchange_and_posted_on_view AS
              SELECT
                  f.posted_on,
                  t.id                    AS commission_chargeable_type_id,
                  x.id                    AS currency_id,
                  e.id                    AS entity_id,
                  SUM(ROUND(f.amount, 2)) AS amount
              FROM
                  commissions f,
                  entities e,
                  currencies x,
                  claim_sets s,
                  commission_chargeables c,
                  commission_chargeable_types t
              WHERE
                  s.id = c.claim_set_id AND
                  x.id = c.currency_id AND
                  c.id = f.commission_chargeable_id AND
                  t.id = c.commission_chargeable_type_id AND
                  e.code = split_part(s.code, ':', 1)
              GROUP BY
                  f.posted_on,
                  t.id,
                  x.id,
                  e.id
              ORDER BY
                  posted_on DESC,
                  e.code,
                  t.code,
                  x.code
             )
    execute(sql)
  end

  def down
    sql = %q(
              DROP VIEW IF EXISTS commissions_by_exchange_and_posted_on_view;
              CREATE VIEW
                 commissions_by_exchange_and_posted_on_view AS
              SELECT
                  f.posted_on,
                  t.code                     AS commission_code,
                  split_part(s.code, ':', 1) AS exg_code,
                  SUM(ROUND(f.amount, 2))    AS amount,
                  x.code                     AS ccy_code
              FROM
                  commissions f,
                  currencies x,
                  claim_sets s,
                  commission_chargeables c,
                  commission_chargeable_types t
              WHERE
                  s.id = c.claim_set_id AND
                  x.id = c.currency_id AND
                  c.id = f.commission_chargeable_id AND
                  t.id = c.commission_chargeable_type_id
              GROUP BY
                  f.posted_on,
                  t.code,
                  x.code,
                  split_part(s.code, ':', 1)
              ORDER BY
                  posted_on DESC,
                  exg_code,
                  commission_code,
                  ccy_code
             )
    execute(sql)
  end
end

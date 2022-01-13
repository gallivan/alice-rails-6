class AddNetChargedByAccountAndClaimSetView < ActiveRecord::Migration[5.2]
  def up
    sql = %q(
          DROP VIEW IF EXISTS net_charged_by_account_and_claim_set_view;
          CREATE VIEW
              net_charged_by_account_and_claim_set_view AS
          SELECT
              x.posted_on   AS posted_on,
              a.code        AS account_code,
              s.code        AS claim_set_code,
              t.code        AS chargeable_type_code,
              f.code        AS currency_code,
              SUM(x.amount) AS amount
          FROM
              chargeable_types t,
              chargeables c,
              claim_sets s,
              currencies f,
              accounts a,
              charges x
          WHERE
              t.id = c.chargeable_type_id AND
              c.id = x.chargeable_id AND
              s.id = c.claim_set_id AND
              f.id = c.currency_id AND
              a.id = x.account_id
          GROUP BY
              posted_on,
              account_code,
              currency_code,
              claim_set_code,
              chargeable_type_code
          ORDER BY
              posted_on,
              account_code,
              claim_set_code,
              chargeable_type_code,
              currency_code
          )
    execute(sql)
  end

  def down
    sql = %q(DROP VIEW IF EXISTS net_charged_by_account_and_claim_set_view;)
    execute(sql)
  end
end

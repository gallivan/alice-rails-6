class AddAbsDoneByAccountAndClaimSetView < ActiveRecord::Migration[5.2]
  def up
    sql = %q(
          DROP VIEW IF EXISTS abs_done_by_account_and_claim_set_view;
          CREATE VIEW
              abs_done_by_account_and_claim_set_view AS
          SELECT
              t.posted_on               AS posted_on,
              a.code                    AS account_code,
              s.code                    AS claim_set_code,
              SUM(ABS(t.done))::INTEGER AS done
          FROM
              deal_leg_fills t,
              claim_sets s,
              accounts a,
              claims c
          WHERE
              a.id = t.account_id AND
              c.id = t.claim_id AND
              s.id = c.claim_set_id
          GROUP BY
              posted_on,
              account_code,
              claim_set_code
          )
    execute(sql)
  end

  def down
    sql = %q(DROP VIEW IF EXISTS abs_done_by_account_and_claim_set_view;)
    execute(sql)
  end
end

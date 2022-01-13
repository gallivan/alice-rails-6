class AddAbsDoneByClaimSetView < ActiveRecord::Migration[5.2]
  def up
    sql = %q(
          DROP VIEW IF EXISTS abs_done_by_claim_set_view;
          CREATE VIEW
              abs_done_by_claim_set_view AS
          SELECT
              t.posted_on               AS posted_on,
              s.code                    AS claim_set_code,
              SUM(ABS(t.done))::INTEGER AS done
          FROM
              deal_leg_fills t,
              claim_sets s,
              claims c
          WHERE
              c.id = t.claim_id AND
              s.id = c.claim_set_id
          GROUP BY
              posted_on,
              claim_set_code
          )
    execute(sql)
  end

  def down
    sql = %q(DROP VIEW IF EXISTS abs_done_by_claim_set_view;)
    execute(sql)
  end
end

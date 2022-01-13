class IncByExgHeldView < ActiveRecord::Migration[5.2]
  def up
    sql = %q(
          DROP VIEW IF EXISTS inc_by_exg_held;
          CREATE VIEW
              inc_by_exg_held AS
          SELECT
              posted_on,
              split_part((claim_set_code)::text, ':'::text, 1) AS exg_code,
              SUM(inc) AS inc,
              currency_code
          FROM
              inc_held_view h
          GROUP BY
              posted_on,
              split_part((claim_set_code)::text, ':'::text, 1),
              currency_code
    )
    execute(sql)
  end

  def down
    sql = %q(DROP VIEW IF EXISTS inc_by_exg_held;)
    execute(sql)
  end
end

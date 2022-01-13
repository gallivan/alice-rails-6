class CreateStatementPositionByClaimViewProxies < ActiveRecord::Migration[5.2]
  def up
    sql = %q(
            DROP VIEW IF EXISTS statement_position_by_claim_view;
            CREATE VIEW
                statement_position_by_claim_view AS
            SELECT
                currency_id,
                claim_id,
                stated_on,
                bot,
                sld,
                net,
                avg_bot_px,
                avg_sld_px,
                CASE
                    WHEN bot > 0 AND
                        sld > 0
                    THEN ROUND((avg_bot_px + avg_sld_px) /2, 6)
                    ELSE (avg_bot_px + avg_sld_px)
                END           AS price,
                mark          AS mark,
                ROUND(ote, 2) AS ote
            FROM
                (
                 SELECT
                        f.id AS currency_id,
                        c.id AS claim_id,
                        p.claim_code,
                        stated_on,
                        SUM(bot) AS bot,
                        SUM(sld) AS sld,
                        SUM(net) AS net,
                        CASE
                            WHEN SUM(bot) > 0
                            THEN ROUND(SUM(bot * price)/SUM(bot), 6)
                            ELSE 0
                        END AS avg_bot_px,
                        CASE
                            WHEN SUM(sld) > 0
                            THEN ROUND(SUM(sld * price)/SUM(sld), 6)
                            ELSE 0
                        END      AS avg_sld_px,
                        mark     AS mark,
                        SUM(ote) AS ote
                   FROM
                        claims c,
                        currencies f,
                        statement_positions p
                  WHERE
                        f.code = p.currency_code AND
                        c.code = p.claim_code
               GROUP BY
                        c.id,
                        f.id,
                        p.claim_code,
                        stated_on,
                        mark
               ORDER BY
                        stated_on DESC,
                        claim_code
               ) x
            )
    execute(sql)
  end

  def down
    execute('drop view if exists statement_position_by_claim_view')
  end
end

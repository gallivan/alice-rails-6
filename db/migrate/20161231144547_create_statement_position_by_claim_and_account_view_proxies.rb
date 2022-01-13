class CreateStatementPositionByClaimAndAccountViewProxies < ActiveRecord::Migration[5.2]
  def up
    sql = %q(
            DROP VIEW IF EXISTS statement_position_by_claim_and_account_view;
            CREATE VIEW
                statement_position_by_claim_and_account_view AS
            SELECT
                currency_id,
                account_id,
                claim_id,
                stated_on,
                bot,
                sld,
                net,
                ROUND(price / net, 6) AS price,
                ROUND(mark / net, 6)  AS mark,
                ROUND(ote, 2)         AS ote
            FROM
                (
                 SELECT
                        f.id AS currency_id,
                        a.id AS account_id,
                        c.id AS claim_id,
                        p.account_code,
                        p.claim_code,
                        stated_on,
                        SUM(bot)         AS bot,
                        SUM(sld)         AS sld,
                        SUM(net)         AS net,
                        SUM(net * price) AS price,
                        SUM(net * mark)  AS mark,
                        SUM(ote)         AS ote
                   FROM
                        currencies f,
                        accounts a,
                        claims c,
                        statement_positions p
                  WHERE
                        f.code = p.currency_code AND
                        a.code = p.account_code AND
                        c.code = p.claim_code
               GROUP BY
                        f.id,
                        a.id,
                        c.id,
                        p.account_code,
                        p.claim_code,
                        p.stated_on
               ORDER BY
                        stated_on DESC,
                        account_code,
                        claim_code
               ) x
            )
    execute(sql)
  end

  def down
    execute('drop view if exists statement_position_by_claim_and_account_view')
  end
end

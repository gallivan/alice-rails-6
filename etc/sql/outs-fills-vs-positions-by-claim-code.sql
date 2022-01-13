SELECT
    f.code,
    p.bot,
    p.sld,
    p.net,
    f.done,
    p.net - f.done AS diff
FROM
    (
     SELECT
            c.code                                 AS code,
            SUM(bot + bot_off)                     AS bot,
            SUM(sld + sld_off)                     AS sld,
            SUM((bot + bot_off) - (sld + sld_off)) AS net
       FROM
            claims c,
            positions p
      WHERE
            --c.code LIKE '%M16' AND
            c.id = p.claim_id
   GROUP BY
            c.code ) p,
    (
     SELECT
            c.code    AS code,
            SUM(done) AS done
       FROM
            claims c,
            deal_leg_fills f
      WHERE
            --c.code LIKE '%M16' AND
            c.id = f.claim_id
   GROUP BY
            c.code)f
WHERE
    p.code = f.code AND
    p.net - f.done != 0
ORDER BY
    f.code
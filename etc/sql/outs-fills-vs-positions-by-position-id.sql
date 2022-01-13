SELECT
    f.pid,
    f.code,
    p.bot,
    p.sld,
    p.net,
    f.done,
    p.net - f.done AS diff
FROM
    (
     SELECT
            p.id                                   AS pid,
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
            p.id,
            c.code ) p,
    (
     SELECT
            f.position_id AS pid,
            c.code        AS code,
            SUM(done)     AS done
       FROM
            claims c,
            deal_leg_fills f
      WHERE
            --c.code LIKE '%M16' AND
            c.id = f.claim_id
   GROUP BY
            f.position_id,
            c.code)f
WHERE
    p.net - f.done != 0 and
    p.pid = f.pid
ORDER BY
    f.code
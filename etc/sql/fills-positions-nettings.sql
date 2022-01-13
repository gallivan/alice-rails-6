SELECT
    f.code,
    f.done_net,
    f.done_grs,
    p.bot,
    p.sld,
    p.net,
    p.grs,
    n.netted,
    ((f.done_grs/2) - n.netted)::INTEGER AS outs
FROM
    (
     SELECT
            c.code    AS code,
            SUM(done) AS netted
       FROM
            claims c,
            position_nettings n
      WHERE
            --c.code LIKE '%M16' AND
            c.id = n.claim_id
   GROUP BY
            c.code ) n,
    (
     SELECT
            c.code                                 AS code,
            SUM(bot + bot_off)                     AS bot,
            SUM(sld + sld_off)                     AS sld,
            SUM((bot + bot_off) - (sld + sld_off)) AS net,
            SUM((bot + bot_off) + (sld + sld_off)) AS grs
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
            c.code         AS code,
            SUM(done)      AS done_net,
            SUM(ABS(done)) AS done_grs
       FROM
            claims c,
            deal_leg_fills f
      WHERE
            --c.code LIKE '%M16' AND
            c.id = f.claim_id
   GROUP BY
            c.code)f
WHERE
    f.code LIKE '%M16' AND
    f.code = p.code AND
    f.code = n.code
ORDER BY
    f.code
SELECT
    p.cid,
    p.code,
    p.bot,
    p.sld,
    p.net,
    n.netted,
    (((p.bot + p.sld)/2) - n.netted)::INTEGER AS OUT
FROM
    (
     SELECT
            c.id                                   AS cid,
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
            c.code,
            c.id ) p,
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
            c.code) n
WHERE
    p.code LIKE '%M16' AND
    p.code = n.code AND (((
                p.bot + p.sld)/2) - n.netted)::INTEGER != 0
ORDER BY
    p.code,
    p.cid
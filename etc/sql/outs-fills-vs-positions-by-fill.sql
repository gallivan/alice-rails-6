SELECT
    *
FROM
    (
     SELECT
            p.id,
            c.code                                          AS code,
            p.posted_on                                     AS posted_on,
            bot + bot_off                                   AS bot,
            sld + sld_off                                   AS sld,
            (bot + bot_off) - (sld + sld_off)               AS net,
            SUM(done)                                       AS done,
            ((bot + bot_off) - (sld + sld_off)) - SUM(done) AS diff
       FROM
            deal_leg_fills f,
            positions p,
            claims c
      WHERE
            c.id = p.claim_id AND
            p.id = f.position_id
   GROUP BY
            p.id,
            c.code,
            p.posted_on)x
WHERE
    net != done
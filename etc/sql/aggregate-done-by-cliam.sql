SELECT
    code,
    SUM(bot),
    SUM(sld)
FROM
    (
     SELECT
            d.code,
            CASE
                WHEN done > 0
                THEN done
                ELSE 0
            END AS bot,
            CASE
                WHEN done < 0
                THEN 0
                ELSE done
            END AS sld
       FROM
            claims c,
            dealing_venues d,
            deal_leg_fills f
      WHERE
            f.posted_on = '2016-02-01' AND
            c.id = f.claim_id AND
            d.id = f.dealing_venue_id)x
GROUP BY
    code
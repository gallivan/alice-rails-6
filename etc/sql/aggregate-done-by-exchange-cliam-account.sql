SELECT
    exg,
    act,
    cac,
    SUM(bot),
    ABS(SUM(sld))
FROM
    (
     SELECT
            a.code AS act,
            d.code AS exg,
            c.code AS cac,
            CASE
                WHEN done > 0
                THEN done
                ELSE 0
            END AS bot,
            CASE
                WHEN done < 0
                THEN done
                ELSE 0
            END AS sld
       FROM
            claims c,
            accounts a,
            dealing_venues d,
            deal_leg_fills f
      WHERE
            --a.code = '00877' AND
            --c.code = 'IFEU:GJ16' AND
            f.posted_on = '2016-02-01' AND
            c.id = f.claim_id AND
            a.id = f.account_id AND
            d.id = f.dealing_venue_id)x
GROUP BY
    act,
    exg,
    cac
ORDER BY
    exg,
    act,
    cac
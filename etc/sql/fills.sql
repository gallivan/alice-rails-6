SELECT
    --a.code,
    c.code,
    SUM(done)      AS net,
    SUM(ABS(done)) AS grs
FROM
    deal_leg_fills f,
    accounts a,
    claims c
WHERE
    c.code = 'EUREX:FESXM16' AND
    a.id = f.account_id AND
    c.id = f.claim_id
GROUP BY
    --a.code,
    c.code
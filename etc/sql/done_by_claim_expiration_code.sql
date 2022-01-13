SELECT
    a.code,
    c.code,
    SUM(d.done) AS done
FROM
    claims c,
    accounts a,
    deal_leg_fills d
WHERE
    a.code = '00002' AND
    c.id = d.claim_id AND
    claim_id IN
    (
     SELECT
            claimable_id AS claim_id
       FROM
            Futures
      WHERE
            code LIKE '%M16' )
GROUP BY
    a.code,
    c.code
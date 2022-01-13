SELECT
    a.code,
    c.code,
    s.code,
    c.id,
    SUM(bot)            AS bot,
    SUM(sld)            AS sld,
    SUM(bot) - SUM(sld) AS net
FROM
    claims c,
    futures f,
    accounts a,
    positions p,
    position_statuses s
WHERE
    s.code = 'OPN' AND
    a.code = '00002' AND
    f.expires_on = '2016-06-08' AND
    c.id = f.claimable_id AND
    c.id = p.claim_id AND
    a.id = p.account_id
GROUP BY
    a.code,
    c.code,
    s.code,
    c.id
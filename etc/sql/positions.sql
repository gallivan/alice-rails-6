SELECT
    p.id,
    a.code,
    c.code,
    c.id,
    s.code,
    p.*
FROM
    claims c,
    accounts a,
    positions p,
    position_statuses s
WHERE
    p.net != 0 AND
    s.code = 'OPN' AND
    a.code = '00002' AND
    --c.code LIKE '%FESXM16' AND
    c.id = p.claim_id AND
    a.id = p.account_id AND
    s.id = p.position_status_id
ORDER BY
    a.code,
    c.code,
    p.posted_on
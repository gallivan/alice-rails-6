SELECT
    c.code,
    p.*
FROM
    claims c,
    positions p,
    position_statuses s
WHERE
    --bot = 0 AND
    --sld = 0 AND
    s.code = 'OPN' AND
    c.id = p.claim_id AND
    s.id = p.position_status_id
ORDER BY
    c.code,
    p.posted_on
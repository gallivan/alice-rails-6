SELECT
    *
FROM
    reports
WHERE
    head = 'MQ ITD' AND
    body LIKE '%COMBO%' and
    body LIKE '%GEH4-GEM4%' and
    body like '%ID="00022"%'
ORDER BY
    id ASC
SELECT
    account_code,
    claim_set_code,
    SUM(done::INTEGER)                AS done,
    SUM(inc)                          AS total_inc,
    SUM(ABS(exp))                     AS total_exp,
    SUM(net)                          AS total_net,
    ROUND(SUM(inc)/SUM(done), 5)      AS unit_inc,
    ROUND(SUM(ABS(exp))/SUM(done), 5) AS unit_exp,
    ROUND(SUM(net)/SUM(done), 5)      AS unit_net,
    ROUND(SUM(inc)/SUM(ABS(exp)), 5)  AS inc_exp_ratio
FROM
    inc_exp_view
WHERE
    account_code = '39009'
GROUP BY
    account_code,
    claim_set_code
ORDER BY
    account_code,
    claim_set_code
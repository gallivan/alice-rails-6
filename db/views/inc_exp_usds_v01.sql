SELECT
  i.posted_on,
  i.account_code,
  i.claim_set_code,
  s.name                AS claim_set_name,
  i.done,
  i.inc_usd             AS inc,
  e.exp_usd             AS exp,
  i.inc_usd + e.exp_usd AS net
FROM
  inc_view i,
  exp_view e,
  claim_sets s
WHERE
  i.posted_on = e.posted_on AND
  i.account_code = e.account_code AND
  i.claim_set_code = e.claim_set_code AND
  e.claim_set_code = s.code
ORDER BY
  posted_on,
  account_code,
  claim_set_code
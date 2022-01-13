SELECT
  posted_on,
  split_part((claim_set_code) :: TEXT, ':' :: TEXT, 1) AS exg_code,
  SUM(ccy_ote)                                         AS ccy_ote,
  currency_code
FROM
  ccy_otes
GROUP BY
  posted_on,
  (split_part((claim_set_code) :: TEXT, ':' :: TEXT, 1)),
  currency_code;
SELECT
  posted_on,
  account_code,
  claim_set_code,
  SUM(ABS(net))                AS gross,
  (SUM(ote)) :: NUMERIC(16, 2) AS ccy_ote,
  currency_code
FROM
  (
    SELECT
      p.posted_on,
      a.code AS account_code,
      s.code AS claim_set_code,
      p.net,
      p.ote,
      x.code AS currency_code
    FROM
      claims c,
      claim_sets s,
      accounts a,
      currencies x,
      currency_marks m,
      positions p,
      position_statuses t
    WHERE
      ((
         t.id = p.position_status_id AND
         t.code = 'OPN' AND
         c.id = p.claim_id) AND (
         a.id = p.account_id) AND (
         x.id = c.point_currency_id) AND (
         s.id = c.claim_set_id) AND (
         x.id = m.currency_id) AND (
         p.posted_on = m.posted_on))) z
GROUP BY
  z.posted_on,
  z.account_code,
  z.claim_set_code,
  z.currency_code
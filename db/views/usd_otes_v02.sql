SELECT
  x.posted_on,
  x.account_code,
  x.claim_set_code,
  SUM(x.net)                         AS net,
  (SUM(x.ote_usd)) :: NUMERIC(16, 2) AS usd_ote
FROM
  (
    SELECT
      p.posted_on,
      a.code AS account_code,
      s.code AS claim_set_code,
      p.net,
      CASE
      WHEN ((x_1.code) :: TEXT = ANY
            (ARRAY [('EUR' :: CHARACTER VARYING) :: TEXT, ('GBP' :: CHARACTER VARYING) :: TEXT, ('AUD' :: CHARACTER VARYING) :: TEXT, ('NZD' :: CHARACTER VARYING) :: TEXT]))
        THEN (p.ote * m.mark)
      ELSE (p.ote / m.mark)
      END    AS ote_usd
    FROM
      claims c,
      claim_sets s,
      accounts a,
      currencies x_1,
      currency_marks m,
      positions p,
      position_statuses t
    WHERE
      ((
         t.id = p.position_status_id AND
         t.code = 'OPN' AND
         c.id = p.claim_id) AND (
         a.id = p.account_id) AND (
         x_1.id = c.point_currency_id) AND (
         s.id = c.claim_set_id) AND (
         x_1.id = m.currency_id) AND (
         p.posted_on = m.posted_on))) x
GROUP BY
  x.posted_on,
  x.account_code,
  x.claim_set_code;
WITH utm_sessions AS (
  SELECT DISTINCT session__id
  FROM `ga_processed.ga4_data`
  WHERE
    company = 'chillblast'
    AND page__url LIKE '%amazon-pay-deal-id=amzn1.rewards.ZF6ST3TUQZDJA%'
    AND DATE = '2025-12-17'
),

purchases AS (
  SELECT DISTINCT
    session__id,
    item__id
  FROM `ga_processed.ga4_data`
  WHERE
    company = 'chillblast'
    AND event__name = 'purchase'
    AND DATE = '2025-12-17'
)

SELECT
  p.item__id,
  COUNT(DISTINCT u.session__id) AS converting_sessions
FROM utm_sessions u
JOIN purchases p
  USING (session__id)
GROUP BY
  p.item__id
ORDER BY
  converting_sessions DESC;

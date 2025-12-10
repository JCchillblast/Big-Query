WITH viewers AS (
  SELECT DISTINCT session__id
  FROM `ga_processed.ga4_data`
  WHERE company = 'ccl'
    AND DATE BETWEEN '2025-12-01' AND '2025-12-07'
    AND page__url LIKE '%/tech-the-halls/best-pcs/%'
)

SELECT
  a.item__id,
  COUNT(*) AS purchases
FROM `ga_processed.ga4_data` a
JOIN viewers v USING (session__id)
WHERE a.company = 'ccl'
  AND a.date BETWEEN '2025-12-01' AND '2025-12-07'
  AND a.event__name = 'purchase'
GROUP BY
  a.item__id
ORDER BY
  purchases DESC;

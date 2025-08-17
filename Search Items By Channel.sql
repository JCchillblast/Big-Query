WITH params AS (
  SELECT 
    DATE('2025-08-14') AS start_date,
    DATE('2025-08-15') AS end_date,
    'VGA7356' AS item__id
)

SELECT
  a.date AS Date,
  a.user__id AS User_id,
  a.session__channel AS Channel
FROM `midyear-destiny-391009.ga_processed.ga4_data` a
JOIN params p 
  ON a.date >= p.start_date 
  AND a.date <= p.end_date
WHERE a.company = 'ccl'
  AND a.event__name = 'purchase'
  AND a.item__id LIKE p.item__id
ORDER BY a.date ASC, a.user__id ASC;

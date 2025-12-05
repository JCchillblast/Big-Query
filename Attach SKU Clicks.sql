SELECT
  item__id,
  COUNT(*) AS event_count
FROM ga_processed.ga4_data
WHERE company = 'chillblast'
  AND date >= '2025-12-02'
  AND event__name = 'attach'
  AND item__id IS NOT NULL
GROUP BY item__id
ORDER BY event_count DESC;

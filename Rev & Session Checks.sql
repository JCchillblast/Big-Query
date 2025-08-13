SELECT
  EXTRACT(HOUR from event__timestamp) as hour,
  COUNT(DISTINCT session__id) as sessions,
  SUM(item__revenue) as revenue

FROM ga_processed.ga4_data
WHERE date = '2025-08-12'
AND company = 'chillblast'
AND session__country = 'United Kingdom'
AND session__flag <> 'possible_bot'
AND row_type = 'processed'

GROUP BY hour
ORDER BY hour desc

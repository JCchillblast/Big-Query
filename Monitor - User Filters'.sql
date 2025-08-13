SELECT
  TRIM(event__section) as event__section,
  TRIM(event__element) as event__element,
  COUNT(DISTINCT session__id) as sessions
 
FROM ga_processed.ga4_data
 
WHERE date >= '2025-08-07'
AND company = 'ccl'
AND event__name = 'plp_filters'
AND page__url LIKE '%monitors%'
 
GROUP BY
  event__section,
  event__element
 
ORDER BY
  sessions DESC

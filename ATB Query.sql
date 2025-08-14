WITH totals_data AS (
  SELECT
  COUNT(DISTINCT session__id) AS total_sessions,
  COUNT(DISTINCT CASE WHEN event__name = 'add_to_cart' THEN session__id END) AS atb_customers

FROM
  ga_processed.ga4_data
WHERE
  date = '2025-08-07'
  AND company = 'chillblast'
  AND session__country = 'United Kingdom'
  AND session__flag <> 'possile_bot'
  AND session__channel = 'Paid Search'
)

SELECT 
  total_sessions,
  atb_customers,
  atb_customers / total_sessions * 100 AS atb_rate

FROM
  totals_data

SELECT
  COUNT(DISTINCT(CASE WHEN item__price >= 2500 THEN session__id END)) AS two_orders,
  COUNT(DISTINCT(CASE WHEN item__price >= 4500 THEN session__id END)) AS four_orders

FROM
  `ga_processed.ga4_data`


WHERE 
company = 'chillblast'
AND DATE = '2025-09-16'
AND session__flag <> 'possible_bot'
AND session__country = 'United Kingdom'
AND event__name = 'view_item'

SELECT
COUNT(DISTINCT user__id) AS users


FROM
`ga_processed.ga4_data`

WHERE
company = 'chillblast'
AND DATE = '2025-12-07'
AND session__flag <> 'possible_bot'
AND session__country  = 'United Kingdom'
AND event__name = 'add_to_cart'
AND item__price >= 800

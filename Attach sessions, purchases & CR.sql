SELECT
TRIM(event__element) AS event__element,
COUNT(DISTINCT session__id) AS sessions,
COUNT(session__purchase) AS purchases,
ROUND(COUNT(DISTINCT IF(session__purchase, session__id, NULL)) / COUNT(DISTINCT session__id)*100, 2) as conv_rate



FROM
`ga_processed.ga4_data`

WHERE
event__name = 'attach'
AND company = 'chillblast'
AND date = '2025-11-26'
AND event__section <> 'product'
AND event__element <> 'null'

GROUP BY
event__element,
event__section

ORDER BY
sessions DESC

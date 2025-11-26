SELECT
event__section,
COUNT(DISTINCT session__id) AS sessions,
ROUND(COUNT(DISTINCT session__id) / SUM(COUNT(DISTINCT session__id)) OVER ()*100, 2) AS pct_of_total,
ROUND(COUNT(DISTINCT IF(session__purchase, session__id, NULL)) / COUNT(DISTINCT session__id)*100, 2) as conv_rate,
COUNT(session__purchase) AS purchases

FROM
`ga_processed.ga4_data`

WHERE
event__name = 'attach'
AND company = 'chillblast'
AND date BETWEEN '2025-11-13'AND '2025-11-25'


GROUP BY
event__section

ORDER BY
sessions DESC

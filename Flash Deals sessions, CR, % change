SELECT
date,
SPLIT(page__url, '?') [SAFE_OFFSET(0)] AS page_url,
COUNT(DISTINCT session__id) AS sessions,
ROUND(
  SAFE_DIVIDE(
    COUNT(DISTINCT session__id) - LAG(COUNT(DISTINCT session__id)) OVER (ORDER BY DATE), 
    LAG(COUNT(DISTINCT session__id)) OVER (ORDER BY DATE)) * 100, 2) AS pct_change,
ROUND(COUNT(DISTINCT IF(session__purchase, session__id, NULL)) / COUNT(DISTINCT session__id)*100, 2) as conv_rate

FROM
`ga_processed.ga4_data`

WHERE
company = 'ccl'
AND DATE BETWEEN '2025-11-20' AND '2025-11-23'
AND page__url LIKE '%com/flash-deals/%'
AND session__country = 'United Kingdom'
AND session__flag <> 'possible_bot'
AND page__url NOT LIKE '%/y/%'

GROUP BY
DATE,
page_url

ORDER BY
DATE ASC

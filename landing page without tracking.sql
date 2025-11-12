SELECT
SPLIT(session__landing_page, '?') [SAFE_OFFSET(0)] AS landing_page,
COUNT(DISTINCT session__id) AS sessions


FROM
`ga_processed.ga4_data`

WHERE
company = 'chillblast'
AND DATE = '2025-11-12'
AND session__country = 'United Kingdom'
AND session__flag <> 'possible_bot'

GROUP BY
landing_page

ORDER BY
sessions DESC

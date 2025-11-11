SELECT 
DATE,
COUNT(DISTINCT session__id) AS sessions,
ROUND(
    SAFE_DIVIDE(
      COUNT(DISTINCT session__id) - LAG(COUNT(DISTINCT session__id)) OVER (ORDER BY DATE),
      LAG(COUNT(DISTINCT session__id)) OVER (ORDER BY DATE)
    ) * 100,
    2
) AS pct_change_vs_prev_day

FROM
`ga_processed.ga4_data`

WHERE
company = 'ccl'
AND DATE BETWEEN '2025-11-07' AND '2025-11-11'
AND session__country = 'United Kingdom'
AND session__flag <> 'possible bot'
AND item__id LIKE '%BRB0795%'

GROUP BY
DATE

ORDER BY
DATE ASC

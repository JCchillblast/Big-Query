SELECT
COUNT (*) AS total_orders,
item__id,
session__channel AS last_click_channel

FROM
  `midyear-destiny-391009.ga_processed.ga4_data`

WHERE
  company = 'chillblast'
  AND DATE BETWEEN '2025-10-03' AND '2025-10-05'
  AND item__id IN ('CB-GAM-ND-A4', 'CBS-EDGE-Y60-ND', 'CB-GAM-CORE-CLSV3')
  AND event__name = 'purchase'
  
GROUP BY
  session__channel,
  item__id

ORDER BY
  item__id,
  total_orders DESC

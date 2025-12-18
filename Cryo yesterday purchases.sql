SELECT
  item__id,
  session__channel,
  item__order_id,
  COUNT(DISTINCT session__id) AS purchases
FROM `ga_processed.ga4_data`
WHERE
  company IN ('chillblast', 'ccl')
  AND DATE = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
  AND event__name = 'purchase'
  AND item__id IN (
            'CB-GAM-CORE-016',
            'SPK4224',
            'MOU3799',
            'KBD2808',
            'MON9690',
            'MON9691',
            'BUN0204',
            'CB-GAM-CORE-016_CBB-CHILLBLAST',
            'CLR3485'
          )
GROUP BY
  item__id,
  session__channel,
  item__order_id
ORDER BY
  item__id,
  purchases DESC;

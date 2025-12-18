SELECT
  session__channel,
  COUNT(DISTINCT session__id) AS purchasers
FROM `ga_processed.ga4_data`
WHERE
  company IN ('chillblast', 'ccl')
  AND DATE BETWEEN '2025-10-07' AND DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
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
  session__channel
ORDER BY
  purchasers DESC;

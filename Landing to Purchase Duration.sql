WITH purchases AS (
  SELECT
    user__id,
    MAX(event__timestamp) AS purchase_ts,
    DATE(event__timestamp) AS purchase_date
  FROM `ga_processed.ga4_data`
  WHERE company = 'chillblast'
    AND event__name = 'purchase'
    AND date BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 8 DAY)
                AND DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
  GROUP BY user__id, purchase_date
),

landings AS (
  SELECT
    p.user__id,
    p.purchase_ts,
    p.purchase_date,
    (
      SELECT MIN(e.event__timestamp)
      FROM `ga_processed.ga4_data` e
      WHERE e.company = 'chillblast'
        AND e.user__id = p.user__id
        AND e.event__timestamp <= p.purchase_ts
        AND e.date BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 14 DAY)
                       AND DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
    ) AS landing_ts
  FROM purchases p
),

durations AS (
  SELECT
    purchase_date,
    TIMESTAMP_DIFF(purchase_ts, landing_ts, MINUTE) AS total_time_minutes
  FROM landings
  WHERE landing_ts IS NOT NULL
    AND TIMESTAMP_DIFF(purchase_ts, landing_ts, MINUTE) > 0  -- discard zeros
)


SELECT
  purchase_date,
  ROUND(AVG(total_time_minutes),0) AS avg_minutes,
    ROUND(
    (AVG(total_time_minutes) - LAG(AVG(total_time_minutes)) OVER (ORDER BY purchase_date))
    / LAG(AVG(total_time_minutes)) OVER (ORDER BY purchase_date) * 100, 2
  ) AS pct_change_avg,
  APPROX_QUANTILES(total_time_minutes, 2)[OFFSET(1)] AS median_minutes,
  ROUND(
    (APPROX_QUANTILES(total_time_minutes, 2)[OFFSET(1)]
     - LAG(APPROX_QUANTILES(total_time_minutes, 2)[OFFSET(1)]) OVER (ORDER BY purchase_date))
    / LAG(APPROX_QUANTILES(total_time_minutes, 2)[OFFSET(1)]) OVER (ORDER BY purchase_date) * 100, 2
  ) AS pct_change_median
FROM durations
GROUP BY purchase_date
ORDER BY purchase_date DESC

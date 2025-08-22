WITH base AS (
  SELECT
    user__id,
    session__id,
    event__timestamp,
    event__name,
    page__url,
    session__channel,
    CASE
      WHEN item__price <= 1000 THEN 'Under £1k'
      WHEN item__price <= 2500 THEN '£1-2.5k'
      ELSE 'Over £2.5k'
    END AS price_bracket,
    CASE
      WHEN REGEXP_CONTAINS(item__id, r'(-CREATE|-SPARK|CBE-I5-4060TI-STJA|CBE-I5-4060TI-STWH|CBE-R5-4070-SCNB|CBE-R5-4070-SCNW)') THEN 'Creative'
      WHEN REGEXP_CONTAINS(item__id, r'(-FS|-RC)') THEN 'Sim'
      WHEN REGEXP_CONTAINS(item__id, r'(-LCS|CB-GAM-EDGE-VRG01|CB-GAM-EDGE-VRGFM|CB-GAM-ORIGIN-OBS|CB-HEJ-R9-XL)') THEN 'Gamer'
      WHEN REGEXP_CONTAINS(item__id, r'(-CONFIG|^(CBB-All|SYSTEM)$)') THEN 'Gamer'
      WHEN REGEXP_CONTAINS(item__id, r'-GAM') THEN 'Gamer'
      WHEN REGEXP_CONTAINS(item__id, r'(CB-F1-LC|CBS-EDGE-Y40|CBS-EDGE-Y60|CBS-EDGE-Y60-ND)') THEN 'Gamer'
      ELSE 'Other'
    END AS base_category
  FROM `ga_processed.ga4_data`
  WHERE company = 'chillblast'
    AND date BETWEEN '2025-07-01' AND '2025-08-20'
    AND session__country = 'United Kingdom'
    AND session__flag <> 'possible_bot'
    AND event__name IN ('view_item', 'purchase')
    AND item__category IN ('PCs', 'Configurators', 'View All PC Systems')
),
 
base_with_segments AS (
  SELECT
    *,
    CASE
      WHEN base_category = 'Gamer' AND price_bracket = 'Over £2.5k' THEN 'Hardcore Gamer'
      WHEN base_category = 'Gamer' THEN 'Gamer'
      WHEN base_category = 'Sim' THEN 'Sim'
      WHEN base_category = 'Creative' THEN 'Creative'
      ELSE 'Other'
    END AS final_segment
  FROM base
),
 
-- Count events per segment for each user
user_segment_counts AS (
  SELECT
    user__id,
    final_segment,
    COUNT(*) AS segment_events
  FROM base_with_segments
  GROUP BY user__id, final_segment
),
 
-- Get the top segment
user_segments AS (
  SELECT
    user__id,
    final_segment AS user_segment,
    segment_events,
    ROW_NUMBER() OVER (PARTITION BY user__id ORDER BY segment_events DESC) AS rn
  FROM user_segment_counts
),
 
-- Discard everything else
dominant_user_segment AS (
  SELECT
    user__id,
    user_segment
  FROM user_segments
  WHERE rn = 1
),
 
-- User data
user_data AS (
  SELECT
    base_with_segments.user__id,
    dominant_user_segment.user_segment,
    COUNT(DISTINCT session__id) as sessions,
    MIN(event__timestamp) AS landing,  -- Landing time
    MAX(CASE WHEN event__name = 'purchase' THEN event__timestamp END) AS purchase, -- Purchase time
    COUNT(DISTINCT page__url) AS pages_count,
    MAX(CASE WHEN event__name = 'purchase' THEN 1 ELSE 0 END) AS has_purchase,
    ROUND(CAST(TIMESTAMP_DIFF(MAX(CASE WHEN event__name = 'purchase' THEN event__timestamp END), MIN(event__timestamp), HOUR) AS FLOAT64) / 24.0) as time_to_purchase
  FROM base_with_segments
  LEFT JOIN dominant_user_segment ON dominant_user_segment.user__id = base_with_segments.user__id
  GROUP BY user__id, user_segment
)
 
 
SELECT
  user_segment,
  COUNT(DISTINCT user__id) AS user_volumes,
  SUM(sessions) as sessions,
  SAFE_DIVIDE(SUM(sessions), COUNT(DISTINCT user__id)) as sessions_per_user,
  COUNTIF(has_purchase = 1) AS order_volumes,
  ROUND(SAFE_DIVIDE(COUNTIF(has_purchase = 1), COUNT(DISTINCT user__id)) * 100, 2) AS conversion_rate_pct,
  ROUND(AVG(time_to_purchase), 1) AS avg_time_to_purchase_days
FROM user_data
GROUP BY user_segment

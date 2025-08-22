WITH base AS (
  SELECT
    user__id,
    session__id,
    event__timestamp,
    event__name,
    page__url,
    session__channel,
    CASE
      WHEN item__price <= 1500 THEN 'Under £1.5k'
      WHEN item__price BETWEEN 1501 AND 4000 THEN '£1.5k - £4k'
      ELSE 'Over £4k'
    END AS price_bracket,
    CASE
      WHEN REGEXP_CONTAINS(item__id, r'ND') THEN 'Next Day'
      WHEN REGEXP_CONTAINS(item__id, r'CONFIG') THEN 'Configurator'
      WHEN REGEXP_CONTAINS(item__id, r'(-CREATE|-SPARK|CBE-I5-4060TI-STJA|CBE-I5-4060TI-STWH|CBE-R5-4070-SCNB|CBE-R5-4070-SCNW|CBS-XELA-B)') THEN 'Creative'
      WHEN REGEXP_CONTAINS(item__id, r'(-FS|-RC|WIL)') THEN 'Sim'
      WHEN REGEXP_CONTAINS(item__id, r'(-LCS|CB-GAM-EDGE-VRG01|CB-GAM-EDGE-VRGFM|CB-GAM-ORIGIN-OBS|CB-HEJ-R9-XL|CBE-R5-3060-GM|CBE-R5-7600-GM)') THEN 'Gamer'
      WHEN REGEXP_CONTAINS(item__id, r'(-CONFIG|^(CBB-All|SYSTEM)$)') THEN 'Gamer'
      WHEN REGEXP_CONTAINS(item__id, r'-GAM') THEN 'Gamer'
      WHEN REGEXP_CONTAINS(item__id, r'(CB-F1-LC|CBS-EDGE-Y40|CBS-EDGE-Y60)') THEN 'Gamer'
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
      WHEN base_category = 'Gamer' AND price_bracket = 'Under £1.5k' THEN 'Gamer - sub £1500'
      WHEN base_category = 'Gamer' AND price_bracket = '£1.5k - £4k' THEN 'Gamer - £1.5k - £4k'
      WHEN base_category = 'Gamer' AND price_bracket = 'Over £4k' THEN 'Gamer - £4k+'
      WHEN base_category = 'Next Day' THEN 'Next Day'
      WHEN base_category = 'Configurator' THEN 'Configurator'
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
 
-- Flag users who have any Sim or Creative events
sim_creative_flags AS (
  SELECT
    user__id,
    MAX(CASE WHEN final_segment = 'Sim' THEN 1 ELSE 0 END) AS has_sim,
    MAX(CASE WHEN final_segment = 'Creative' THEN 1 ELSE 0 END) AS has_creative
  FROM base_with_segments
  GROUP BY user__id
),
 
-- Get the top segment for other users
user_segments AS (
  SELECT
    usc.user__id,
    usc.final_segment AS dominant_segment,
    usc.segment_events,
    ROW_NUMBER() OVER (PARTITION BY usc.user__id ORDER BY usc.segment_events DESC) AS rn
  FROM user_segment_counts usc
),
 
dominant_user_segment AS (
  SELECT
    u.user__id,
    -- Assign Sim or Creative if present, otherwise dominant
    CASE
      WHEN scf.has_sim = 1 THEN 'Sim'
      WHEN scf.has_creative = 1 THEN 'Creative'
      ELSE u.dominant_segment
    END AS user_segment
  FROM user_segments u
  JOIN sim_creative_flags scf ON u.user__id = scf.user__id
  WHERE rn = 1
),
 
-- User data remains the same
user_data AS (
  SELECT
    base_with_segments.user__id,
    dominant_user_segment.user_segment,
    COUNT(DISTINCT session__id) as sessions,
    MIN(event__timestamp) AS landing,
    MAX(CASE WHEN event__name = 'purchase' THEN event__timestamp END) AS purchase,
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
ORDER BY sessions DESC;

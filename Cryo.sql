WITH atb_customers AS (
  SELECT
    user__id,
    item__id,
    TRUE AS atb

FROM
  `ga_processed.ga4_data`

WHERE
company = 'chillblast'
AND DATE BETWEEN '2025-10-13' AND '2025-12-01'
AND item__id = 'SPK4224'
AND event__name = 'add_to_cart'
),

attach_customers AS (
  SELECT
  user__id,
  item__id,
  TRUE AS attach

FROM
  `ga_processed.ga4_data`

WHERE
company = 'chillblast'
AND DATE BETWEEN '2025-10-13' AND '2025-12-01'
AND item__id = 'SPK4224'
AND event__name = 'attach'
),

purchase_customers AS (
  SELECT
  user__id,
  item__id,
  TRUE AS purchase

FROM
  `ga_processed.ga4_data`

WHERE
company = 'chillblast'
AND DATE BETWEEN '2025-10-13' AND '2025-12-01'
AND item__id = 'SPK4224'
AND event__name = 'purchase'
),

all_customers AS (
  SELECT DISTINCT user__id, item__id
  FROM atb_customers
  UNION DISTINCT
  SELECT DISTINCT user__id, item__id
  FROM attach_customers
  UNION DISTINCT
  SELECT DISTINCT user__id, item__id
  FROM purchase_customers
)

SELECT
  c.user__id,
  c.item__id,
  atb,
  attach,
  purchase,
  CASE
    WHEN purchase IS TRUE AND attach IS TRUE THEN 'Purchased via attach'
    WHEN purchase IS TRUE AND (attach IS NULL OR attach IS FALSE) THEN 'Purchased via product page'
    ELSE 'No purchase'
  END AS purchase_path
FROM all_customers c
LEFT JOIN atb_customers a USING (user__id, item__id)
LEFT JOIN attach_customers b USING (user__id, item__id)
LEFT JOIN purchase_customers p USING (user__id, item__id)
ORDER BY user__id;

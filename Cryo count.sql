WITH filtered_events AS (
  SELECT
    user__id,
    item__id,
    event__name
  FROM `ga_processed.ga4_data`
  WHERE company = 'chillblast'
    AND DATE = '2025-12-02'
    AND item__id IN (
      'CB-GAM-CORE-016',
      'SPK4224',
      'MOU3799',
      'KBD2808',
      'MON9690',
      'MON9691',
      'BUN0204',
      'CB-GAM-CORE-016_CBB-CHILLBLAST'
    )
),

atb_customers AS (
  SELECT DISTINCT user__id, item__id
  FROM filtered_events
  WHERE event__name = 'add_to_cart'
),

attach_customers AS (
  SELECT DISTINCT user__id, item__id
  FROM filtered_events
  WHERE event__name = 'attach'
),

purchase_customers AS (
  SELECT DISTINCT user__id, item__id
  FROM filtered_events
  WHERE event__name = 'purchase'
),

all_users AS (
  SELECT 
    u.user__id,
    u.item__id,
    IF(a.user__id IS NOT NULL, TRUE, FALSE) AS atb,
    IF(b.user__id IS NOT NULL, TRUE, FALSE) AS attach,
    IF(p.user__id IS NOT NULL, TRUE, FALSE) AS purchase
  FROM (
    SELECT DISTINCT user__id, item__id FROM atb_customers
    UNION DISTINCT
    SELECT DISTINCT user__id, item__id FROM attach_customers
    UNION DISTINCT
    SELECT DISTINCT user__id, item__id FROM purchase_customers
  ) u
  LEFT JOIN atb_customers a USING (user__id, item__id)
  LEFT JOIN attach_customers b USING (user__id, item__id)
  LEFT JOIN purchase_customers p USING (user__id, item__id)
)

SELECT
  item__id,
  COUNTIF(atb) AS atb_users,
  COUNTIF(attach) AS attach_users,
  COUNTIF(purchase) AS purchasers_total,
  COUNTIF(purchase AND attach) AS purchasers_via_attach,
  COUNTIF(purchase AND NOT attach) AS purchasers_via_pdp
FROM all_users
GROUP BY item__id
ORDER BY item__id;

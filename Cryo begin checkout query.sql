WITH filtered_events AS (
  SELECT
    user__id,
    item__id,
    event__name
  FROM `ga_processed.ga4_data`
  WHERE DATE = '2025-12-07'            -- partition filter required
    AND company = 'chillblast'
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
  WHERE event__name = 'begin_checkout'
),

all_users AS (
  SELECT 
    u.user__id,
    u.item__id,
    IF(a.user__id IS NOT NULL, TRUE, FALSE) AS atb,       -- was there a match from Left Joins against the Union
    IF(b.user__id IS NOT NULL, TRUE, FALSE) AS attach,
    IF(p.user__id IS NOT NULL, TRUE, FALSE) AS purchase
  FROM (
    SELECT DISTINCT user__id, item__id FROM atb_customers
    UNION DISTINCT
    SELECT DISTINCT user__id, item__id FROM attach_customers
    UNION DISTINCT                                                 -- each event line by line, multiple lines per user id in one table
    SELECT DISTINCT user__id, item__id FROM purchase_customers
  ) u
  LEFT JOIN atb_customers a USING (user__id, item__id)
  LEFT JOIN attach_customers b USING (user__id, item__id)
  LEFT JOIN purchase_customers p USING (user__id, item__id)            -- addds boolean colunns
)

SELECT
  item__id,
  COUNTIF(attach) AS attach_total,   -- all attach clicks
  COUNT(attach) - COUNTIF(attach AND atb) AS attach_pdp_session, 
  COUNTIF(atb AND NOT attach) AS atb_pdp,
  COUNTIF(attach AND atb) AS attach_atb,
  COUNTIF(purchase) AS purchasers_total,
  COUNTIF(purchase AND attach) AS purchasers_via_attach,
  COUNTIF(purchase AND NOT attach) AS purchasers_via_pdp,
  ROUND(SAFE_DIVIDE(COUNTIF(attach AND atb) , COUNT(attach))*100, 2) AS atb_rate
FROM all_users
GROUP BY item__id
ORDER BY item__id;


WITH user_ids AS (
    SELECT DISTINCT
      user__id
  
FROM 
  `midyear-destiny-391009.ga_processed.ga4_data` a
WHERE
  company = 'ccl'
  AND event__name = 'purchase'
  AND a.item__id = 'MON9497'
  AND a.date BETWEEN '2025-08-04' AND '2025-08-20'
)

SELECT DISTINCT
    a.user__id,
    event__timestamp,
    event__name,
    page__url,
    a.item__id,
    event__section,
    event__element,
    event__link_url,
    session__channel

FROM 
  `midyear-destiny-391009.ga_processed.ga4_data` a
WHERE
  a.user__id IN (SELECT user__id FROM user_ids)
  AND event__name <> 'view_item_list'
  AND a.date BETWEEN '2025-08-04' AND '2025-08-20'
ORDER BY
  event__timestamp ASC;

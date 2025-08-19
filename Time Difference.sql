WITH dates AS (
SELECT
  user__id,
  MIN(event__timestamp) AS landing,
  MAX(CASE WHEN event__name = 'purchase' THEN event__timestamp END) AS purchase

FROM
  `midyear-destiny-391009.ga_processed.ga4_data` a

WHERE
  company = 'chillblast'
  AND user__id IN (
    'tm3hTnApZJNpWO5fRYDUb8sf8DynHiBVdHoqG9sJkSI=.1739961341',
    'hRQILjxrm8HUz9a2/qYfPxqAvTYKH5H9YBecwO8FHOY=.1749000780',
    'zXRUb4fJ31J8vuQgr4Y2VUSZabzRsounv94JYSnQlZI=.1749233454',
    'IyTV93HSBMUTW2hOfMXO56ygFX50HnMYeJ1Yvex5lZQ=.1747901629',
    'pgLdYvaEjrvoigJzplfVOKWytuP5SMK8f1SSHlPg8B4=.1750220068',
    'RdFG/sO5sEK3KJ4gyYWmN0mc/X22f8koJAUMIoMSz58=.1750333366',
    'WxCzHBNcYWNAwlDkL60puh8ppiVOUggJ2eg5ylqO23s=.1750457865',
    'i81o07Zhk8siBeeyRQMS0+av1CDu7YDuYQcbmahpw6I=.1750705062',
    'D7pow8Orr5QRNtZaVLhL8esy/WpvQBc+p/hPQnO7ckw=.1751278851',
    '0u5t8u7s4KKLwFQBCiP5a6v/+yotj/tqsgecIrmTIuw=.1751436399',
    'VmD6wZliM12KB3GF5wCZt4XovDqMFHjHOUBjuBhyylE=.1751653293',
    'auTnWcXWH4uqREU5dDNXNeAVXjkUvueHGi4qEfhhaV8=.1751883728',
    'TPwEo4H3R82/nyl49Jru4hhpo8RcvW45ZoextIURYpc=.1753754269',
    'cm_uid-15718508623417',
    'wjxC4Dv2VsaZiGPXA5GgXvbfAv0h2BJ1gVzfdObXR+s=.1754086905',
    '6Dr6P4WApOeUK31Qvenum+qfQAzEWpgN6NrS69bjA20=.1754288010',
    'FtOyJ76j7G8mTxhUL5BnBxd+mHM6ieCyRQgpWai+Y1c=.1754743262',
    'MSKQMdaX5XG9M3FE1EiCLtzgRzFMExLDOvPWtpZEAMk=.1754828262'
    )

  AND a.item__id IN (
      'CB-GAM-FRG-LCS',
      'CB-GAM-ORIGIN-OBS',
      'CBS-EDGE-LCS',
      'CB-GAM-EDGE-VRG01'
      )
  AND DATE BETWEEN '2025-06-01' AND '2025-08-18'
  GROUP BY
    user__id
)
SELECT
  user__id,
  TIMESTAMP_DIFF(purchase, landing, MINUTE) AS total_time_seconds

FROM
  dates
WHERE
  purchase IS NOT NULL
  
ORDER BY
  total_time_seconds ASC;

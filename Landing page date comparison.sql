-- Base filtered data (parameters)
WITH base AS (
  SELECT
    SPLIT(session__landing_page, '?') [SAFE_OFFSET(0)] AS session__landing_page,
    session__id,
    date
  FROM `ga_processed.ga4_data`
  WHERE 
    company = 'ccl'
    AND session__country = 'United Kingdom'
    AND session__flag <> 'possible_bot'
    AND session__channel = 'Affiliates'
),

-- Sessions on 10th Dec
thenth AS (
  SELECT
    session__landing_page,
    COUNT(DISTINCT session__id) AS sessions
  FROM base
  WHERE date = '2025-12-10'
  GROUP BY session__landing_page
),

-- Sessions on 11th Dec
eleventh AS (
  SELECT
    session__landing_page,
    COUNT(DISTINCT session__id) AS sessions
  FROM base
  WHERE date = '2025-12-11'
  GROUP BY session__landing_page
)

SELECT
  t.session__landing_page,
  t.sessions AS thenth_sessions,
  e.sessions AS eleventh_sessions,
  ROUND(SAFE_DIVIDE(e.sessions - t.sessions, t.sessions),2) AS pct_change_dod
FROM thenth t
JOIN eleventh e 
  ON t.session__landing_page = e.session__landing_page
ORDER BY eleventh_sessions DESC;

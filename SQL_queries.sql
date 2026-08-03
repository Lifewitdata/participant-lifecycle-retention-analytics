-- =============================================================================
-- Participant Lifecycle & Retention Analytics — MySQL 8.0 Interview Query Bank
-- Schema: participants, onboarding, studies, submissions, payments, engagement_events
-- Run this file top to bottom in a single session (the @report_date variable
-- persists across statements within one session/connection).
-- =============================================================================

-- Reference "as-of" date for all time-relative queries in this session.
-- In production, replace every use of @report_date with CURDATE().
SET @report_date := (SELECT MAX(event_timestamp) FROM engagement_events);


-- =============================================================================
-- QUERY 1: Total Participants
-- Business Objective: Baseline platform size metric.
-- =============================================================================
SELECT
    COUNT(*) AS total_participants
FROM participants;


-- =============================================================================
-- QUERY 2: Daily / Weekly / Monthly Signups
-- Business Objective: Acquisition velocity at three granularities.
-- =============================================================================

-- 2a. Daily signups
SELECT
    DATE(signup_date) AS signup_day,
    COUNT(*)          AS signups
FROM participants
GROUP BY DATE(signup_date)
ORDER BY signup_day;

-- 2b. Weekly signups (ISO week, Monday-start)
SELECT
    YEARWEEK(signup_date, 3) AS signup_iso_week,
    MIN(DATE(signup_date))   AS week_start_approx,
    COUNT(*)                 AS signups
FROM participants
GROUP BY YEARWEEK(signup_date, 3)
ORDER BY signup_iso_week;

-- 2c. Monthly signups
SELECT
    DATE_FORMAT(signup_date, '%Y-%m-01') AS signup_month,
    COUNT(*)                              AS signups
FROM participants
GROUP BY DATE_FORMAT(signup_date, '%Y-%m-01')
ORDER BY signup_month;


-- =============================================================================
-- QUERY 3: Acquisition Channel Performance
-- Business Objective: Which channels bring in the most participants.
-- =============================================================================
SELECT
    acquisition_channel,
    COUNT(*)                                           AS total_signups,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total_signups
FROM participants
GROUP BY acquisition_channel
ORDER BY total_signups DESC;


-- =============================================================================
-- QUERY 4: Activation Rate by Acquisition Channel
-- Business Objective: Which channels bring participants who actually activate.
-- =============================================================================
SELECT
    p.acquisition_channel,
    COUNT(*)                                                AS total_signups,
    SUM(CASE WHEN o.is_activated = 1 THEN 1 ELSE 0 END)     AS activated_participants,
    ROUND(
        100.0 * SUM(CASE WHEN o.is_activated = 1 THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS activation_rate_pct
FROM participants p
LEFT JOIN onboarding o
    ON p.participant_id = o.participant_id
GROUP BY p.acquisition_channel
ORDER BY activation_rate_pct DESC;


-- =============================================================================
-- QUERY 5: Onboarding Funnel Conversion
-- Business Objective: Which onboarding step loses the most participants.
-- =============================================================================
WITH funnel_counts AS (
    SELECT
        COUNT(*)                                                                AS c_signup,
        SUM(CASE WHEN email_verified_date IS NOT NULL THEN 1 ELSE 0 END)        AS c_email_verified,
        SUM(CASE WHEN profile_completed_date IS NOT NULL THEN 1 ELSE 0 END)     AS c_profile_completed,
        SUM(CASE WHEN demographic_survey_completed_date IS NOT NULL THEN 1 ELSE 0 END)
                                                                                  AS c_survey_completed,
        SUM(CASE WHEN first_study_completed_date IS NOT NULL THEN 1 ELSE 0 END) AS c_activated
    FROM onboarding
),
funnel_stages AS (
    SELECT 1 AS stage_order, 'Signup' AS stage_name, c_signup AS stage_count FROM funnel_counts
    UNION ALL
    SELECT 2, 'Email Verified',          c_email_verified     FROM funnel_counts
    UNION ALL
    SELECT 3, 'Profile Completed',       c_profile_completed  FROM funnel_counts
    UNION ALL
    SELECT 4, 'Eligibility Survey',      c_survey_completed   FROM funnel_counts
    UNION ALL
    SELECT 5, 'First Study (Activation)', c_activated         FROM funnel_counts
)
SELECT
    stage_order,
    stage_name,
    stage_count,
    ROUND(100.0 * stage_count / FIRST_VALUE(stage_count) OVER (ORDER BY stage_order), 2)
                                                            AS pct_of_signups,
    ROUND(100.0 * stage_count / LAG(stage_count) OVER (ORDER BY stage_order), 2)
                                                            AS pct_conversion_from_prev_stage
FROM funnel_stages
ORDER BY stage_order;


-- =============================================================================
-- QUERY 6: Average Time From Signup to First Completed Study
-- Business Objective: Measure onboarding speed, by acquisition channel.
-- =============================================================================
SELECT
    p.acquisition_channel,
    COUNT(*)                                                                 AS activated_participants,
    ROUND(AVG(DATEDIFF(o.first_study_completed_date, o.signup_date)), 1)     AS avg_days_to_activation
FROM onboarding o
JOIN participants p
    ON o.participant_id = p.participant_id
WHERE o.first_study_completed_date IS NOT NULL
GROUP BY p.acquisition_channel
ORDER BY avg_days_to_activation ASC;


-- =============================================================================
-- QUERY 7: DAU, WAU, and MAU
-- Business Objective: Core engagement health metrics.
-- =============================================================================
SELECT
    COUNT(DISTINCT CASE
        WHEN event_timestamp >= @report_date - INTERVAL 1 DAY
        THEN participant_id END)  AS dau,
    COUNT(DISTINCT CASE
        WHEN event_timestamp >= @report_date - INTERVAL 7 DAY
        THEN participant_id END)  AS wau,
    COUNT(DISTINCT CASE
        WHEN event_timestamp >= @report_date - INTERVAL 30 DAY
        THEN participant_id END)  AS mau
FROM engagement_events
WHERE event_timestamp <= @report_date;


-- =============================================================================
-- QUERY 8: Top 10 Most Active Participants
-- Business Objective: Identify platform power users.
-- =============================================================================
SELECT
    p.participant_id,
    p.country,
    p.acquisition_channel,
    COUNT(s.submission_id)                                   AS total_submissions,
    SUM(CASE WHEN s.status = 'completed' THEN 1 ELSE 0 END)  AS completed_submissions,
    ROUND(SUM(s.reward_earned), 2)                            AS lifetime_reward_earned
FROM participants p
JOIN submissions s
    ON p.participant_id = s.participant_id
GROUP BY p.participant_id, p.country, p.acquisition_channel
ORDER BY completed_submissions DESC
LIMIT 10;


-- =============================================================================
-- QUERY 9: Participant Engagement Score
-- Business Objective: Composite 0-100 score combining volume + event activity + recency.
-- =============================================================================
WITH submission_stats AS (
    SELECT
        participant_id,
        COUNT(*)                                                  AS submission_count,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END)     AS completed_count
    FROM submissions
    GROUP BY participant_id
),
event_stats AS (
    SELECT
        participant_id,
        COUNT(*)               AS event_count,
        MAX(event_timestamp)   AS last_event_date
    FROM engagement_events
    GROUP BY participant_id
),
combined AS (
    SELECT
        p.participant_id,
        COALESCE(ss.completed_count, 0)                                     AS completed_count,
        COALESCE(es.event_count, 0)                                         AS event_count,
        DATEDIFF(@report_date, COALESCE(es.last_event_date, p.signup_date)) AS days_since_last_event
    FROM participants p
    LEFT JOIN submission_stats ss ON p.participant_id = ss.participant_id
    LEFT JOIN event_stats es      ON p.participant_id = es.participant_id
)
SELECT
    participant_id,
    completed_count,
    event_count,
    days_since_last_event,
    ROUND(
        LEAST(100,
            40 * (completed_count / NULLIF(MAX(completed_count) OVER (), 0)) +
            30 * (event_count     / NULLIF(MAX(event_count)     OVER (), 0)) +
            30 * (1 - LEAST(days_since_last_event, 90) / 90.0)
        ), 1
    ) AS engagement_score
FROM combined
ORDER BY engagement_score DESC;


-- =============================================================================
-- QUERY 10: Cohort Retention (Monthly)
-- Business Objective: % of each signup cohort still active N months later.
-- =============================================================================
WITH cohorts AS (
    SELECT
        participant_id,
        DATE_FORMAT(signup_date, '%Y-%m-01') AS cohort_month
    FROM participants
),
cohort_sizes AS (
    SELECT cohort_month, COUNT(*) AS cohort_size
    FROM cohorts
    GROUP BY cohort_month
),
activity AS (
    SELECT DISTINCT
        participant_id,
        DATE_FORMAT(submission_date, '%Y-%m-01') AS activity_month
    FROM submissions
    WHERE status = 'completed'
),
cohort_activity AS (
    SELECT
        c.cohort_month,
        TIMESTAMPDIFF(MONTH, c.cohort_month, a.activity_month) AS months_since_signup,
        COUNT(DISTINCT c.participant_id)                        AS active_participants
    FROM cohorts c
    JOIN activity a
        ON c.participant_id = a.participant_id
       AND a.activity_month >= c.cohort_month
    GROUP BY c.cohort_month, months_since_signup
)
SELECT
    ca.cohort_month,
    cs.cohort_size,
    ca.months_since_signup,
    ca.active_participants,
    ROUND(100.0 * ca.active_participants / cs.cohort_size, 1) AS retention_pct
FROM cohort_activity ca
JOIN cohort_sizes cs
    ON ca.cohort_month = cs.cohort_month
WHERE ca.months_since_signup BETWEEN 0 AND 6
ORDER BY ca.cohort_month, ca.months_since_signup;


-- =============================================================================
-- QUERY 11: Churned Participant Identification (90+ Days Inactive)
-- Business Objective: Actionable win-back candidate list.
-- =============================================================================
SELECT
    p.participant_id,
    p.country,
    p.acquisition_channel,
    p.last_activity_date,
    DATEDIFF(@report_date, p.last_activity_date) AS days_inactive,
    o.first_study_completed_date                  AS activated_on
FROM participants p
JOIN onboarding o
    ON p.participant_id = o.participant_id
WHERE o.is_activated = 1
  AND p.last_activity_date IS NOT NULL
  AND DATEDIFF(@report_date, p.last_activity_date) >= 90
ORDER BY days_inactive DESC;


-- =============================================================================
-- QUERY 12: Reactivated Participants
-- Business Objective: Participants with a 30+ day dormancy gap who returned.
-- =============================================================================
WITH submission_gaps AS (
    SELECT
        participant_id,
        submission_date,
        LAG(submission_date) OVER (
            PARTITION BY participant_id ORDER BY submission_date
        ) AS previous_submission_date
    FROM submissions
    WHERE status = 'completed'
)
SELECT
    participant_id,
    COUNT(*)                                                  AS reactivation_events,
    MAX(DATEDIFF(submission_date, previous_submission_date))  AS longest_dormancy_days,
    MIN(submission_date)                                      AS first_reactivation_date
FROM submission_gaps
WHERE previous_submission_date IS NOT NULL
  AND DATEDIFF(submission_date, previous_submission_date) >= 30
GROUP BY participant_id
ORDER BY reactivation_events DESC, longest_dormancy_days DESC;


-- =============================================================================
-- QUERY 13: Average Reward Earned by Country
-- Business Objective: Geographic earnings patterns for marketing & finance.
-- =============================================================================
SELECT
    p.country,
    COUNT(DISTINCT p.participant_id)                AS participants_with_earnings,
    ROUND(SUM(pay.amount), 2)                        AS total_paid_out,
    ROUND(AVG(pay.amount), 2)                        AS avg_payment_amount,
    ROUND(SUM(pay.amount) / COUNT(DISTINCT p.participant_id), 2)
                                                       AS avg_lifetime_earnings_per_participant
FROM participants p
JOIN payments pay
    ON p.participant_id = pay.participant_id
GROUP BY p.country
HAVING COUNT(DISTINCT p.participant_id) >= 5
ORDER BY avg_lifetime_earnings_per_participant DESC;


-- =============================================================================
-- QUERY 14: Study Completion Rate by Category
-- Business Objective: Which study categories participants finish vs abandon.
-- =============================================================================
SELECT
    st.category,
    COUNT(*)                                                    AS total_attempts,
    SUM(CASE WHEN sub.status = 'completed'  THEN 1 ELSE 0 END)  AS completed,
    SUM(CASE WHEN sub.status = 'returned'   THEN 1 ELSE 0 END)  AS returned,
    SUM(CASE WHEN sub.status = 'timed_out'  THEN 1 ELSE 0 END)  AS timed_out,
    SUM(CASE WHEN sub.status = 'rejected'   THEN 1 ELSE 0 END)  AS rejected,
    ROUND(
        100.0 * SUM(CASE WHEN sub.status = 'completed' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS completion_rate_pct
FROM submissions sub
JOIN studies st
    ON sub.study_id = st.study_id
GROUP BY st.category
ORDER BY completion_rate_pct ASC;


-- =============================================================================
-- QUERY 15: Researcher Performance Dashboard
-- Business Objective: Study volume, fill rate, completion rate by researcher type.
-- =============================================================================
WITH study_submission_stats AS (
    SELECT
        st.study_id,
        st.researcher_type,
        st.places_available,
        st.reward_amount,
        COUNT(sub.submission_id)                                  AS total_submissions,
        SUM(CASE WHEN sub.status = 'completed' THEN 1 ELSE 0 END) AS completed_submissions
    FROM studies st
    LEFT JOIN submissions sub
        ON st.study_id = sub.study_id
    GROUP BY st.study_id, st.researcher_type, st.places_available, st.reward_amount
)
SELECT
    researcher_type,
    COUNT(DISTINCT study_id)                                            AS total_studies_posted,
    SUM(places_available)                                               AS total_places_available,
    SUM(completed_submissions)                                          AS total_completions,
    ROUND(100.0 * SUM(completed_submissions) / NULLIF(SUM(places_available), 0), 2)
                                                                          AS fill_rate_pct,
    ROUND(100.0 * SUM(completed_submissions) / NULLIF(SUM(total_submissions), 0), 2)
                                                                          AS completion_rate_pct,
    ROUND(AVG(reward_amount), 2)                                        AS avg_reward_per_study,
    ROUND(SUM(completed_submissions * reward_amount), 2)                AS total_payout_estimate
FROM study_submission_stats
GROUP BY researcher_type
ORDER BY total_studies_posted DESC;


-- =============================================================================
-- QUERY 16: Marketplace Supply vs Demand Analysis
-- Business Objective: Is participant supply keeping up with researcher demand.
-- =============================================================================
WITH monthly_supply AS (
    SELECT
        DATE_FORMAT(posted_date, '%Y-%m-01') AS month,
        category,
        SUM(places_available)                 AS supply_places
    FROM studies
    GROUP BY DATE_FORMAT(posted_date, '%Y-%m-01'), category
),
monthly_demand AS (
    SELECT
        DATE_FORMAT(sub.submission_date, '%Y-%m-01') AS month,
        st.category,
        COUNT(*)                                       AS demand_attempts,
        SUM(CASE WHEN sub.status = 'completed' THEN 1 ELSE 0 END) AS demand_completions
    FROM submissions sub
    JOIN studies st ON sub.study_id = st.study_id
    GROUP BY DATE_FORMAT(sub.submission_date, '%Y-%m-01'), st.category
)
SELECT
    COALESCE(s.month, d.month)         AS month,
    COALESCE(s.category, d.category)   AS category,
    COALESCE(s.supply_places, 0)       AS supply_places,
    COALESCE(d.demand_completions, 0)  AS demand_completions,
    ROUND(
        100.0 * COALESCE(d.demand_completions, 0) / NULLIF(s.supply_places, 0), 2
    ) AS marketplace_liquidity_pct
FROM monthly_supply s
LEFT JOIN monthly_demand d
    ON s.month = d.month AND s.category = d.category
ORDER BY month, category;


-- =============================================================================
-- QUERY 17: Participant Lifetime Earnings Ranking (Window Function)
-- Business Objective: Rank all participants by lifetime earnings for VIP tiering.
-- =============================================================================
WITH lifetime_earnings AS (
    SELECT
        p.participant_id,
        p.country,
        p.account_status,
        COALESCE(SUM(pay.amount), 0) AS total_earnings
    FROM participants p
    LEFT JOIN payments pay
        ON p.participant_id = pay.participant_id
    GROUP BY p.participant_id, p.country, p.account_status
)
SELECT
    participant_id,
    country,
    account_status,
    total_earnings,
    RANK()    OVER (ORDER BY total_earnings DESC) AS earnings_rank,
    NTILE(10) OVER (ORDER BY total_earnings DESC) AS earnings_decile,
    ROUND(100.0 * PERCENT_RANK() OVER (ORDER BY total_earnings DESC), 1) AS pct_rank
FROM lifetime_earnings
ORDER BY earnings_rank
LIMIT 100;


-- =============================================================================
-- QUERY 18: Fraud / Low-Quality Participant Detection
-- Business Objective: Flag participants with high rejection rates or suspiciously fast completions.
-- =============================================================================
WITH participant_quality AS (
    SELECT
        sub.participant_id,
        COUNT(*)                                                          AS total_submissions,
        SUM(CASE WHEN sub.status = 'rejected' THEN 1 ELSE 0 END)          AS rejected_count,
        SUM(CASE WHEN sub.status = 'completed'
                  AND sub.completion_time_minutes < 0.3 * st.avg_completion_minutes
             THEN 1 ELSE 0 END)                                            AS suspiciously_fast_count,
        ROUND(AVG(sub.completion_time_minutes / NULLIF(st.avg_completion_minutes, 0)), 2)
                                                                             AS avg_speed_ratio
    FROM submissions sub
    JOIN studies st
        ON sub.study_id = st.study_id
    GROUP BY sub.participant_id
    HAVING COUNT(*) >= 5
)
SELECT
    participant_id,
    total_submissions,
    rejected_count,
    ROUND(100.0 * rejected_count / total_submissions, 1)          AS rejection_rate_pct,
    suspiciously_fast_count,
    ROUND(100.0 * suspiciously_fast_count / total_submissions, 1) AS fast_completion_rate_pct,
    avg_speed_ratio,
    CASE
        WHEN rejected_count / total_submissions >= 0.30
             OR suspiciously_fast_count / total_submissions >= 0.30
        THEN 'HIGH_RISK'
        WHEN rejected_count / total_submissions >= 0.15
             OR suspiciously_fast_count / total_submissions >= 0.15
        THEN 'MEDIUM_RISK'
        ELSE 'LOW_RISK'
    END AS quality_flag
FROM participant_quality
WHERE rejected_count / total_submissions >= 0.15
   OR suspiciously_fast_count / total_submissions >= 0.15
ORDER BY rejection_rate_pct DESC, fast_completion_rate_pct DESC;


-- =============================================================================
-- QUERY 19: Executive KPI Dashboard Query
-- Business Objective: Single-row summary of acquisition, activation, engagement,
--                      retention, churn, and revenue KPIs.
-- =============================================================================
WITH activation AS (
    SELECT
        COUNT(*)                                          AS total_participants,
        SUM(CASE WHEN is_activated = 1 THEN 1 ELSE 0 END) AS total_activated
    FROM onboarding
),
engagement AS (
    SELECT
        COUNT(DISTINCT CASE WHEN event_timestamp >= @report_date - INTERVAL 1 DAY
                             THEN participant_id END) AS dau,
        COUNT(DISTINCT CASE WHEN event_timestamp >= @report_date - INTERVAL 30 DAY
                             THEN participant_id END) AS mau
    FROM engagement_events
),
retention AS (
    SELECT
        SUM(CASE WHEN account_status = 'active'  THEN 1 ELSE 0 END) AS active_count,
        SUM(CASE WHEN account_status = 'at_risk' THEN 1 ELSE 0 END) AS at_risk_count,
        SUM(CASE WHEN account_status = 'churned' THEN 1 ELSE 0 END) AS churned_count
    FROM participants
),
revenue AS (
    SELECT
        ROUND(SUM(amount), 2) AS total_payouts,
        ROUND(SUM(CASE WHEN payment_date >= @report_date - INTERVAL 30 DAY
                        THEN amount ELSE 0 END), 2) AS payouts_last_30d
    FROM payments
)
SELECT
    a.total_participants,
    a.total_activated,
    ROUND(100.0 * a.total_activated / a.total_participants, 1) AS activation_rate_pct,
    e.dau,
    e.mau,
    ROUND(100.0 * e.dau / NULLIF(e.mau, 0), 1)                 AS stickiness_ratio_pct,
    r.active_count,
    r.at_risk_count,
    r.churned_count,
    ROUND(100.0 * r.churned_count /
          NULLIF(r.active_count + r.at_risk_count + r.churned_count, 0), 1)
                                                                AS churn_rate_pct,
    rev.total_payouts,
    rev.payouts_last_30d
FROM activation a
CROSS JOIN engagement e
CROSS JOIN retention r
CROSS JOIN revenue rev;


-- =============================================================================
-- QUERY 20: Complex Business Case
-- High-Value At-Risk Participant Win-Back Targeting
-- Business Objective: Rank top-quartile lifetime earners who are at_risk/churned
--                      and quality-screened, for a targeted win-back campaign.
-- =============================================================================
WITH lifetime_value AS (
    SELECT
        p.participant_id,
        p.country,
        p.acquisition_channel,
        p.account_status,
        p.last_activity_date,
        COALESCE(SUM(pay.amount), 0) AS total_earnings,
        NTILE(4) OVER (ORDER BY COALESCE(SUM(pay.amount), 0) DESC) AS earnings_quartile
    FROM participants p
    LEFT JOIN payments pay
        ON p.participant_id = pay.participant_id
    GROUP BY p.participant_id, p.country, p.acquisition_channel,
             p.account_status, p.last_activity_date
),
quality_check AS (
    SELECT
        sub.participant_id,
        COUNT(*)                                                 AS total_submissions,
        SUM(CASE WHEN sub.status = 'rejected' THEN 1 ELSE 0 END) AS rejected_count,
        ROUND(
            100.0 * SUM(CASE WHEN sub.status = 'rejected' THEN 1 ELSE 0 END)
            / COUNT(*), 1
        ) AS rejection_rate_pct
    FROM submissions sub
    GROUP BY sub.participant_id
),
recent_engagement AS (
    SELECT
        participant_id,
        MAX(event_timestamp) AS last_event_date
    FROM engagement_events
    WHERE event_timestamp >= @report_date - INTERVAL 60 DAY
    GROUP BY participant_id
)
SELECT
    lv.participant_id,
    lv.country,
    lv.acquisition_channel,
    lv.account_status,
    lv.total_earnings,
    lv.earnings_quartile,
    DATEDIFF(@report_date, lv.last_activity_date)             AS days_since_last_activity,
    COALESCE(qc.rejection_rate_pct, 0)                         AS rejection_rate_pct,
    CASE WHEN re.participant_id IS NOT NULL THEN 'Y' ELSE 'N' END
                                                                AS browsed_in_last_60d,
    ROUND(
        (5 - lv.earnings_quartile) * 20
        + CASE WHEN re.participant_id IS NOT NULL THEN 15 ELSE 0 END
        - LEAST(DATEDIFF(@report_date, lv.last_activity_date) / 10, 20)
    , 1) AS winback_priority_score
FROM lifetime_value lv
LEFT JOIN quality_check qc
    ON lv.participant_id = qc.participant_id
LEFT JOIN recent_engagement re
    ON lv.participant_id = re.participant_id
WHERE lv.account_status IN ('at_risk', 'churned')
  AND lv.earnings_quartile = 1
  AND COALESCE(qc.rejection_rate_pct, 0) < 20
ORDER BY winback_priority_score DESC
LIMIT 200;

-- =============================================================================
-- End of file — 20 queries covering the full lifecycle:
-- Acquisition(1-3) | Activation(4-6) | Engagement(7-9) | Retention(10)
-- Churn(11) | Reactivation(12) | Quality & Revenue(13-18) | Executive(19-20)
-- =============================================================================

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=220&section=header&text=Participant%20Lifecycle%20%26%20Retention%20Analytics&fontSize=32&fontColor=ffffff&animation=fadeIn&fontAlignY=35&desc=A%20Pandas-Powered%20Deep%20Dive%20into%20Acquisition%2C%20Activation%2C%20Retention%20%26%20Churn&descAlignY=55&descSize=16" width="100%"/>

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=22&duration=3000&pause=900&color=6C5CE7&center=true&vCenter=true&multiline=true&repeat=true&width=800&height=90&lines=Acquisition+%E2%86%92+Onboarding+%E2%86%92+Activation+%E2%86%92+Engagement;Retention+%E2%86%92+Churn+%E2%86%92+Reactivation;15%2B+Engineered+Features+%7C+8+Participant+Segments;Cohort+Retention+%7C+A%2FB+Testing+%7C+Executive+KPIs" alt="Typing SVG" />

<br/>

[![Python](https://img.shields.io/badge/Python-3.10%2B-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Pandas](https://img.shields.io/badge/Pandas-2.2-150458?style=for-the-badge&logo=pandas&logoColor=white)](https://pandas.pydata.org/)
[![NumPy](https://img.shields.io/badge/NumPy-1.26-013243?style=for-the-badge&logo=numpy&logoColor=white)](https://numpy.org/)
[![Matplotlib](https://img.shields.io/badge/Matplotlib-3.9-11557C?style=for-the-badge&logo=plotly&logoColor=white)](https://matplotlib.org/)
[![SciPy](https://img.shields.io/badge/SciPy-1.13-8CAAE6?style=for-the-badge&logo=scipy&logoColor=white)](https://scipy.org/)
[![Jupyter](https://img.shields.io/badge/Jupyter-Notebook-F37626?style=for-the-badge&logo=jupyter&logoColor=white)](https://jupyter.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

![Repo Size](https://img.shields.io/github/repo-size/your-username/participant-lifecycle-analytics?style=flat-square&color=6C5CE7)
![Last Commit](https://img.shields.io/github/last-commit/your-username/participant-lifecycle-analytics?style=flat-square&color=00b894)
![Stars](https://img.shields.io/github/stars/your-username/participant-lifecycle-analytics?style=flat-square&color=fdcb6e)
![Views](https://komarev.com/ghpvc/?username=participant-lifecycle-analytics&style=flat-square&color=e17055&label=Repo+Views)

</div>

<br/>

## 🧭 What this is

A complete, notebook-driven analysis of the **participant lifecycle** for a research-participant marketplace (Prolific-style) — built entirely in **pandas**, from raw CSVs to an executive KPI dashboard, cohort retention heatmaps, behavioral segmentation, and a statistically validated A/B test recommendation.

This repo ships **both**:
- 📓 **`Participant_Lifecycle_Analysis.ipynb`** — the original, cell-by-cell exploratory notebook
- 🐍 **`analysis_pipeline.py`** — that same analysis, cleaned into an 11-phase, standalone Python script (portable file paths, `display()` fallback for non-Jupyter execution, section banners)

Every chart below was rendered directly from this codebase against the project's synthetic dataset (3,000 participants · 10,378 submissions · 9,062 payments · 35,364 events).

<br/>

## 📚 Table of Contents

- [Lifecycle Coverage](#-lifecycle-coverage)
- [Visual Highlights](#-visual-highlights)
- [Executive KPI Snapshot](#-executive-kpi-snapshot-real-output)
- [Python Query Cookbook](#-python-query-cookbook)
- [Statistical Findings](#-statistical-findings)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Business Insights](#-business-insights)
- [License](#-license)

<br/>

## 🔬 Lifecycle Coverage

The analysis runs through **11 phases**, each mapping to one link in the participant lifecycle chain:

| Phase | Focus | What it answers |
|:---:|---|---|
| 1 | 🧹 Data Loading & Validation | Duplicate IDs, null funnel fields, invalid rewards, payment/submission reconciliation |
| 2 | 🔎 Exploratory Data Analysis | Acquisition channel mix, age distribution, account status split |
| 3 | 🛠️ Feature Engineering | 15 business features — account age, activation delay, quality score, engagement score, LTV, churn/reactivation flags |
| 4 | 📈 Acquisition & Activation | Channel × device breakdown, time-to-activation distributions |
| 5 | 📉 Churn & Reactivation | Churned vs. active profiles, what reactivated users do when they come back |
| 6 | 🧮 Cohort Retention | Monthly cohort retention matrix, cohort revenue & ARPU heatmaps |
| 7 | 🕹️ Behavioral Analytics | Login frequency, browse→attempt conversion, notification effectiveness, hour/day activity heatmap |
| 8 | 🧩 Participant Segmentation | 8-segment rule-based model: New, Active, Power, High Earners, At-Risk, Dormant, Reactivated, Churned |
| 9 | 📊 Executive KPI Dashboard | Single-call `calculate_kpis()` + 6-month trend lines |
| 10 | 🧪 Statistics & A/B Testing | Welch's t-test, 95% CI, two-proportion z-test |
| 11 | 🎨 Advanced Visualizations | Trend regression, funnel, retention curve, DAU/WAU/MAU |

<br/>

## 🖼️ Visual Highlights

<table>
<tr>
<td width="50%"><img src="assets/cohort_retention_heatmap.png" width="100%"/></td>
<td width="50%"><img src="assets/average_retention_curve.png" width="100%"/></td>
</tr>
<tr>
<td align="center"><sub><b>Monthly Cohort Retention Heatmap</b> — every acquisition cohort × months-since-signup</sub></td>
<td align="center"><sub><b>Average Retention Curve</b> — the Month 0→1 cliff, annotated</sub></td>
</tr>
<tr>
<td width="50%"><img src="assets/activation_funnel.png" width="100%"/></td>
<td width="50%"><img src="assets/segment_distribution.png" width="100%"/></td>
</tr>
<tr>
<td align="center"><sub><b>User Activation Funnel</b> — Signup → Verified → Profile → Survey → Activated</sub></td>
<td align="center"><sub><b>Participant Segments</b> — rule-based 8-way lifecycle segmentation</sub></td>
</tr>
<tr>
<td width="50%"><img src="assets/dau_wau_mau_trend.png" width="100%"/></td>
<td width="50%"><img src="assets/activity_heatmap.png" width="100%"/></td>
</tr>
<tr>
<td align="center"><sub><b>DAU / WAU / MAU Trend</b> — last 6 months</sub></td>
<td align="center"><sub><b>Activity Heatmap</b> — day-of-week × hour-of-day</sub></td>
</tr>
<tr>
<td width="50%"><img src="assets/account_status_distribution.png" width="100%"/></td>
<td width="50%"><img src="assets/feature_correlation_matrix.png" width="100%"/></td>
</tr>
<tr>
<td align="center"><sub><b>Account Status Split</b> — active / at-risk / churned / never-activated</sub></td>
<td align="center"><sub><b>Feature Correlation Matrix</b> — what actually drives LTV</sub></td>
</tr>
</table>

<br/>

## 📟 Executive KPI Snapshot (real output)

This is the literal console output of `calculate_kpis()` run against the dataset — not a mockup:

```text
📊 EXECUTIVE KPI DASHBOARD (As of: 2025-06-29)
=============================================
👥 USER METRICS
   Acquisition (30d):      358 new users
   Activation Rate:        43.30%
   DAU:                    86
   WAU:                    310
   MAU:                    553
   Stickiness (DAU/MAU):   15.55%
---------------------------------------------
🔄 LIFECYCLE METRICS
   Retention Rate (MoM):   63.27%
   Churn Rate (MoM):       36.73%
   Reactivation Rate:      3.62% of MAU
---------------------------------------------
💰 FINANCIAL METRICS
   Avg Reward (30d):       $3.00
   Total Payouts (30d):    $3,908.03
   Average LTV:            $21.97
---------------------------------------------
🏥 PLATFORM HEALTH
   Participant Quality:    69.50 / 100
   Marketplace Health:     44.20 / 100
=============================================
```

<br/>

## 🐍 Python Query Cookbook

Curated, ready-to-run snippets pulled straight from `analysis_pipeline.py` — each one answers a specific business question against the feature-engineered dataset.

<details>
<summary><b>1. 🎯 Activation funnel conversion rates</b></summary>

```python
total_signups = len(df_events)
email_verified = df_events['email_verified_date'].notnull().sum()
profile_completed = df_events['profile_completed_date'].notnull().sum()
activated = df_events['is_activated'].sum()

funnel_df = pd.DataFrame({
    'Stage': ['Signups', 'Email Verified', 'Profile Completed', 'Activated'],
    'Count': [total_signups, email_verified, profile_completed, activated]
})
funnel_df['Conversion Rate'] = (funnel_df['Count'] / total_signups * 100).round(2)
print(funnel_df.to_string(index=False))
```
</details>

<details>
<summary><b>2. 🛠️ Engagement score & lifetime value (feature engineering)</b></summary>

```python
# Recency score: 100 if active today, 0 if >90 days. Linear decay.
df_features['recency_score'] = 100 - (df_features['days_since_last_activity'].clip(upper=90) * (100/90))

# Volume score: studies completed, capped at 20 for 100 pts
df_features['volume_score'] = (df_features['studies_completed'].clip(upper=20) / 20) * 100

# Interaction score: engagement events, capped at 100 for 100 pts
df_features['interaction_score'] = (df_features['total_events'].clip(upper=100) / 100) * 100

# Weighted composite: 40% recency + 30% volume + 30% interaction
df_features['engagement_score'] = (
    (df_features['recency_score'] * 0.4) +
    (df_features['volume_score'] * 0.3) +
    (df_features['interaction_score'] * 0.3)
).round(2)

# LTV = current earnings, boosted by how engaged (and likely to keep earning) they are
df_features['ltv'] = (
    df_features['total_earnings'] * (1 + (df_features['engagement_score'] / 100))
).round(2)
```
</details>

<details>
<summary><b>3. 📉 Churn flag & reactivation flag</b></summary>

```python
# Churned: no activity in 90+ days
df_features['churn_flag'] = np.where(df_features['days_since_last_activity'] > 90, 1, 0)

# Reactivated: currently active (<=30d), account is old (>90d), but historically sporadic
df_features['reactivation_flag'] = np.where(
    (df_features['days_since_last_activity'] <= 30) &
    (df_features['account_age_days'] > 90) &
    (df_features['activity_frequency'] < 0.5),
    1, 0
)
```
</details>

<details>
<summary><b>4. 🧮 Cohort retention matrix</b></summary>

```python
df_active = df_submissions[df_submissions['status'] == 'completed'].copy()
df_cohort = df_active.merge(df_participants[['participant_id', 'signup_date']], on='participant_id')

df_cohort['signup_month'] = df_cohort['signup_date'].dt.to_period('M')
df_cohort['active_month'] = df_cohort['submission_date'].dt.to_period('M')
df_cohort['cohort_index'] = (df_cohort['active_month'] - df_cohort['signup_month']).apply(lambda x: x.n)
df_cohort = df_cohort[df_cohort['cohort_index'] >= 0]

cohort_active = df_cohort.groupby(['signup_month', 'cohort_index'])['participant_id'].nunique().reset_index()
cohort_matrix = cohort_active.pivot(index='signup_month', columns='cohort_index', values='participant_id')

cohort_sizes = df_participants.groupby(df_participants['signup_date'].dt.to_period('M'))['participant_id'].nunique()
retention_matrix = cohort_matrix.divide(cohort_sizes, axis=0) * 100   # -> feeds the heatmap above
```
</details>

<details>
<summary><b>5. 🧩 Rule-based participant segmentation</b></summary>

```python
def assign_segment(row):
    if row['churn_flag'] == 1:
        return 'Churned Users'
    if row['reactivation_flag'] == 1:
        return 'Reactivated Users'
    if row['account_age_days'] <= 14 and row['studies_completed'] == 0:
        return 'New Users'
    if row['studies_completed'] == 0 and row['account_age_days'] > 14:
        return 'Dormant Users'
    if 31 <= row['days_since_last_activity'] <= 90:
        return 'At-Risk Users'
    if row['days_since_last_activity'] <= 30:
        if row['total_earnings'] >= high_earner_threshold and row['total_earnings'] > 0:
            return 'High Earners'
        if row['studies_completed'] >= power_user_studies_threshold and row['studies_completed'] > 0:
            return 'Power Users'
        return 'Active Users'
    return 'Active Users'

df_segments['segment'] = df_segments.apply(assign_segment, axis=1)
```
</details>

<details>
<summary><b>6. 📊 One-call executive KPI dashboard</b></summary>

```python
def calculate_kpis(participants, funnel, submissions, events, payments, as_of_date):
    """Returns acquisition, activation, DAU/WAU/MAU, retention, churn,
    reactivation, revenue, LTV, quality, and a composite health score —
    all as of a single snapshot date."""
    kpis = {}
    date_m = as_of_date - timedelta(days=30)

    kpis['activation_rate'] = funnel['is_activated'].sum() / len(funnel) * 100
    kpis['dau'] = events[events['event_timestamp'].dt.date == as_of_date.date()]['participant_id'].nunique()
    kpis['mau'] = events[events['event_timestamp'] >= date_m]['participant_id'].nunique()
    kpis['stickiness_ratio'] = (kpis['dau'] / kpis['mau'] * 100) if kpis['mau'] > 0 else 0
    # ...retention, churn, reactivation, revenue, LTV, quality omitted for brevity...

    kpis['marketplace_health_score'] = round(
        kpis['activation_rate'] * 0.3 + kpis['stickiness_ratio'] * 0.3 +
        kpis.get('participant_quality', 0) * 0.2 + kpis.get('retention_rate', 0) * 0.2, 1
    )
    return kpis

exec_kpis = calculate_kpis(df_participants_enriched, df_events, df_submissions,
                            df_funnel, df_payments, pd.to_datetime(snapshot_date))
```
</details>

<details>
<summary><b>7. 🧪 Hypothesis test — Academic vs. Commercial completion time</b></summary>

```python
from scipy import stats

academic_times = academic_subs[academic_subs['researcher_type'] == 'Academic']['completion_time_minutes']
commercial_times = academic_subs[academic_subs['researcher_type'] == 'Commercial']['completion_time_minutes']

# Welch's t-test — does not assume equal variances between groups
t_stat, p_value = stats.ttest_ind(academic_times, commercial_times, equal_var=False)

print(f"T-Statistic: {t_stat:.2f} | P-Value: {p_value:.4e}")
# -> Reject H0 if p < 0.05: completion times genuinely differ by researcher type
```
</details>

<details>
<summary><b>8. 🔬 A/B test — two-proportion z-test on activation rate</b></summary>

```python
from statsmodels.stats.proportion import proportions_ztest, proportion_confint

results = df_ab.groupby('group')['sim_activated'].agg(['count', 'sum'])
count, nobs = results['sum'].values, results['count'].values

z_stat, p_val = proportions_ztest(count, nobs)
lower_ci, upper_ci = proportion_confint(count, nobs, alpha=0.05)

if p_val < 0.05:
    print("➡️ Statistically significant. Roll out the treatment to 100%.")
```
</details>

<details>
<summary><b>9. 💵 95% confidence interval — implied hourly rate</b></summary>

```python
completed['implied_hourly_rate'] = (completed['reward_earned'] / completed['completion_time_minutes']) * 60
valid_rates = completed[(completed['implied_hourly_rate'] > 0) & (completed['implied_hourly_rate'] < 100)]['implied_hourly_rate']

mean, se = valid_rates.mean(), valid_rates.std() / np.sqrt(len(valid_rates))
margin = 1.96 * se
print(f"95% CI: [${mean - margin:.2f}, ${mean + margin:.2f}]")
```
</details>

<details>
<summary><b>10. 📈 DAU trend regression (is engagement growing or declining?)</b></summary>

```python
from scipy import stats

dau_ts['date_ordinal'] = pd.to_datetime(dau_ts['date']).apply(lambda x: x.toordinal())
slope, intercept, r_value, p_value, std_err = stats.linregress(dau_ts['date_ordinal'], dau_ts['dau'])

if p_value < 0.05:
    direction = "UPWARD 📈" if slope > 0 else "DOWNWARD 📉"
    print(f"Statistically significant {direction} trend (R² = {r_value**2:.3f})")
```
</details>

<br/>

## 🧪 Statistical Findings

| Test | Result | Interpretation |
|---|---|---|
| **Welch's t-test** — Academic vs. Commercial completion time | t = −5.00, p = 5.78e-07 | ✅ Significant — Commercial studies (18.89 min) take measurably longer than Academic (17.68 min) |
| **95% CI** — implied hourly rate | [$10.28, $10.37], mean $10.32 | Platform's $10.50/hr target sits just outside the CI, skewed low — worth a pricing review |
| **A/B test** — "Quick Match" feature, 7-day activation | A: 19.5% → B: 23.9%, z = −5.34, p < 0.0001 | ✅ Significant lift — recommend shipping to 100% |
| **DAU trend regression** — last 180 days | slope = +0.31/day, R² = 0.798, p < 0.0001 | ✅ Significant upward trend in daily engagement |
| **LTV correlation** | `total_earnings` 0.98, `studies_completed` 0.95, `activity_frequency` 0.51 | LTV is driven almost entirely by realized volume, not just intent-to-engage signals |

<br/>

## 🗂️ Project Structure

```
participant-lifecycle-analytics/
├── README.md
├── LICENSE
├── requirements.txt
├── Participant_Lifecycle_Analysis.ipynb   # original exploratory notebook
├── analysis_pipeline.py                    # same analysis, 11-phase standalone script
├── data/                                   # 6 source CSVs (not committed if large — see below)
│   ├── participants.csv
│   ├── onboarding.csv
│   ├── studies.csv
│   ├── submissions.csv
│   ├── payments.csv
│   └── engagement_events.csv
├── assets/                                 # chart images embedded in this README
│   ├── cohort_retention_heatmap.png
│   ├── activation_funnel.png
│   ├── segment_distribution.png
│   ├── dau_wau_mau_trend.png
│   ├── average_retention_curve.png
│   ├── activity_heatmap.png
│   ├── account_status_distribution.png
│   └── feature_correlation_matrix.png
└── outputs/
    └── figures/                             # regenerated chart output when you re-run the script
```

<br/>

## ⚙️ Getting Started

```bash
# 1. Clone
git clone https://github.com/Lifewitdata/participant-lifecycle-analytics.git
cd participant-lifecycle-analytics

# 2. Set up environment
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

# 3. Place the 6 source CSVs in ./data/

# 4a. Run as a script (saves nothing to disk by default — add savefig calls if you want files)
python analysis_pipeline.py

# 4b. ...or explore interactively
jupyter notebook Participant_Lifecycle_Analysis.ipynb
```

<br/>

## 💡 Business Insights

- **The funnel doesn't leak evenly.** The steepest single drop is Signup → Email Verified, not deeper in the funnel — the highest-leverage fix is at the very top of onboarding, not activation itself.
- **Retention has a Month-0→1 cliff.** The average retention curve shows the sharpest decline immediately after the first month — this is the single highest-ROI window for a lifecycle-marketing nudge.
- **LTV is a volume story, not an intent story.** `total_earnings` and `studies_completed` correlate with LTV at 0.98 and 0.95 respectively, while softer engagement signals sit far lower — pricing/incentive levers will move LTV more than engagement-only nudges.
- **"Quick Match" is a shippable win.** The simulated A/B test shows a statistically significant +4.4pt activation lift (p < 0.0001) — a strong, low-risk candidate for a 100% rollout.
- **Engagement is trending up, not down.** A statistically significant positive DAU slope over the trailing 6 months (p < 0.0001) says the platform's underlying health is improving even with a 36.7% MoM churn rate — the story is "more new engagement," not "less churn," and the two need separate playbooks.

<br/>

## 📄 License

Released under the [MIT License](LICENSE).

<br/>

<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=120&section=footer" width="100%"/>

</div>

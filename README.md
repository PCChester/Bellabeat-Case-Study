# Bellabeat Case Study
### Google Data Analytics Certificate — Capstone Project
**Author:** Peter Christopher Chester | **Date:** November 2025

---

## Overview

This case study explores how Bellabeat — a wellness technology company focused on women's health — can use smart device usage data to inform its marketing and product strategy.

Using Fitbit user data as a proxy for smart wearable behaviour, the analysis identifies a critical gap in Bellabeat's product offering and builds a data-driven argument for a new **Stress/Recovery Analysis** feature.

---

## Business Task

Analyse competitor device trends to guide Bellabeat's marketing and product development, using Fitbit usage data and a comparative assessment of device features.

**Key Question:** What user behaviours in the Fitbit dataset justify a new product feature, and how should Bellabeat position it?

---

## Tools Used

| Phase | Tool |
|---|---|
| Data organisation & initial cleaning | Google Sheets |
| Deduplication, parsing, aggregation | SQL (BigQuery) |
| Feature engineering & merging | R / tidyverse |
| Visualisation | Tableau Public |

---

## Repository Structure

```
bellabeat-case-study/
│
├── README.md
├── Bellabeat_Case_Study_v.2.pdf    ← Full written analysis
└── scripts/
    ├── bellabeat_r_analysis.R      ← Full R workflow (cleaning → export)
    └── bellabeat_queries.sql       ← Full SQL workflow (cleaning → export)
```

---

## Data Source

**Source data:** [FitBit Fitness Tracker Data on Kaggle](https://www.kaggle.com/datasets/arashnic/fitbit/) — Kaggle (arashnic/fitbit)

- 30 Fitbit users, ~3 months (March–May 2016)
- Collected via Amazon Mechanical Turk
- Public domain — free to use, modify, and distribute

**Datasets used:**
- `dailyActivity_merged.csv`
- `sleepDay_merged.csv`
- `heartrate_seconds_merged.csv`

**Access the dataset directly on Kaggle:** [https://www.kaggle.com/datasets/arashnic/fitbit/](https://www.kaggle.com/datasets/arashnic/fitbit/)

**Key limitations:** Small sample (n=30), no demographic data, collected in 2016. Findings indicate broad trends rather than statistically definitive conclusions.

---

## Key Findings

### 1. Competitive Gap Identified
A feature comparison of Bellabeat, Fitbit, and Garmin revealed two significant gaps: **Stress/Recovery Analysis** and **GPS**. The rest of the analysis focuses on validating Stress/Recovery as the higher-priority recommendation.

### 2. The Compensation Discovery
The data contradicted the expected hypothesis. Users logged **~500–1,000 more steps** the day after poor sleep — not fewer. This indicates widespread **compensatory over-exertion**: users are ignoring physiological signals for rest.

### 3. High Physiological Strain Segment Validated
A measurable high-risk user segment was identified — users simultaneously experiencing elevated resting heart rate **and** poor sleep recovery — who continued to maintain high activity levels. This group is the clearest target for intervention.

### 4. Feature Pivot
Based on the above, the recommendation pivots the Stress/Recovery feature from a *performance optimisation tool* to a **Burnout Prevention and Health Alert System** — better aligned with Bellabeat's wellness-first brand and its majority Moderate/Sedentary user base.

---

## Visualisations

All visualisations are published on [Tableau Public](https://public.tableau.com/app/profile/chris.chester/vizzes).

- **Tableau Public profile:** [https://public.tableau.com/app/profile/chris.chester/vizzes](https://public.tableau.com/app/profile/chris.chester/vizzes)
- **Viz 1:** [Better Sleep Doesn't Change Next-Day Activity](https://public.tableau.com/app/profile/chris.chester/viz/BetterSleepDoesntChangeNext-DayActivity/SleepQualityvsNextDayActivity2) — Sleep quality vs. next-day steps comparison
- **Viz 2:** [High Strain Validation: Users Push Harder When They Should Rest](https://public.tableau.com/views/HighStrainValidationUsersPushHarderWhenTheyShouldRest/HighStrainValidation) — Dual dashboard showing next-day activity and resting heart rate by strain segment

---

## Recommendations Summary

1. **Build Stress/Recovery Analysis** as a Burnout Prevention feature — not an athletic metric
2. **Target Moderate and Sedentary users** (66%+ of logged days) with non-exercise interventions: guided meditation, hydration prompts, rest day suggestions
3. **Align push notification timing** with weekly activity patterns — motivation prompts on peak days (Mon–Sat), recovery prompts midweek and Sunday
4. **Integrate phone-connected GPS** for walking/hiking route tracking tied to stress and readiness scores — not pace racing
5. **Position Bellabeat** as the leader in whole-person wellness: *"We don't just track your wellbeing — we actively help you achieve it"*

---

## About This Project

This is my capstone project for the **Google Data Analytics Certificate**. It was my first end-to-end data analysis project, taking raw Kaggle data through cleaning, SQL aggregation, R feature engineering, and Tableau visualisation — all in service of a real business recommendation.

Feedback welcome — feel free to open an issue or connect on [LinkedIn](#).

# Bellabeat Case Study
### Google Data Analytics Certificate — Capstone Project
**Author:** Peter Christopher Chester | **Date:** November 2025, corrected November 2026 (v3)

---

> ## What changed in v3 (November 2026)
>
> While reviewing this project with an AI-assisted code review, I found a bug in the R script. `as.integer()` turned 26 of the 33 Fitbit user IDs into missing values, because the IDs are larger than R's 32-bit integer limit. The joins then matched those missing IDs to each other and mixed different users' data: 940 daily records became 9,911 rows.
>
> I fixed the script (`scripts/bellabeat_r_analysis.R`, v3) and reran the analysis on the original Kaggle files. The corrected results change two key findings:
>
> - **The "Compensation Discovery" does not hold.** Pooled across all users, next-day steps are higher after poor-recovery nights (about 9,300 vs. 8,100). But one very active user accounts for 28 of the 81 poor nights. Comparing each user with themselves, the typical user took about 500 *fewer* steps after a poor night, and 9 of the 14 users with both kinds of nights walked less.
> - **The High Physiological Strain segment is too small to use:** 5 days from 3 users.
>
> The full corrected write-up is `Bellabeat_Case_Study_v3.pdf`. The original report (`archive/Bellabeat_Case_Study_v.2.pdf`) is kept for transparency.

---

## Overview

This case study explores how Bellabeat, a wellness technology company focused on women's health, can use smart device usage data to inform its marketing and product strategy.

Using Fitbit user data as a proxy for smart wearable behavior, together with a feature comparison of Bellabeat, Fitbit and Garmin, the analysis makes the case for a new **Stress/Recovery Analysis** feature, and shows how a data error nearly turned that case into a false finding.

---

## Business Task

Analyze competitor device trends to guide Bellabeat's marketing and product development, using Fitbit usage data and a comparative assessment of device features.

**Key Question:** What user behaviors in the Fitbit dataset support a new product feature, and how should Bellabeat position it?

---

## Tools Used

| Phase | Tool |
|---|---|
| Data organization & initial cleaning | Google Sheets |
| Deduplication, parsing, aggregation | SQL (BigQuery) |
| Feature engineering, merging & analysis | R / tidyverse |
| Visualization | Tableau Public |

---

## Repository Structure

```
bellabeat-case-study/
│
├── README.md
├── Bellabeat_Case_Study_v3.pdf     ← Full written analysis (corrected)
├── archive/
│   └── Bellabeat_Case_Study_v.2.pdf ← Original report, superseded
├── data/
│   ├── dailyActivity_engineered.csv
│   ├── master_analysis_data_for_tableau.csv   ← v3 export, 940 rows
│   └── within_user_comparison.csv             ← v3 export, 14 users
└── scripts/
    ├── bellabeat_r_analysis.R      ← Full R workflow (cleaning → analysis → export)
    └── bellabeat_queries.sql       ← Full SQL workflow (cleaning → export)
```

---

## Data Source

**Source data:** [FitBit Fitness Tracker Data on Kaggle](https://www.kaggle.com/datasets/arashnic/fitbit/) (arashnic/fitbit)

- About 30 Fitbit users (33 unique IDs in the files), collected through Amazon Mechanical Turk between March 12 and May 12, 2016
- This analysis uses the April 12 – May 12, 2016 files
- Public domain: free to use, modify, and distribute

**Datasets used:**
- `dailyActivity_merged.csv`
- `sleepDay_merged.csv`
- `heartrate_seconds_merged.csv`

**Key limitations:** Small, self-selected sample, no demographic data, one month of data from 2016, and heart rate data for only 14 users. Findings indicate directions to test, not statistically definitive conclusions.

---

## Key Findings (v3)

### 1. Competitive Gap Identified
A feature comparison of Bellabeat, Fitbit, and Garmin revealed two significant gaps: **Stress/Recovery Analysis** and **GPS**.

### 2. The Pooled Average Misleads
Pooled across all users, next-day steps look higher after a poor-recovery night (more than 10% of time in bed awake): about **9,300 vs. 8,100**. But one very active user accounts for **28 of the 81** poor nights.

### 3. Compared With Themselves, Most Users Walk Less
Of the 14 users with both kinds of nights, **9 walked less** after a poor night. The typical user took about **500 fewer steps**. With 14 users this is a pattern, not proof, but it points the opposite way from the original finding.

### 4. Withdrawn From v.2
- **The Compensation Discovery** (users walk more after poor sleep): an artifact of the merge bug and one very active user.
- **The High Physiological Strain segment:** 5 days from 3 users after the fix.
- **"Resting" heart rate:** the daily metric is an all-day average, now labeled that way.

---

## Visualizations

All visualizations are published on [Tableau Public](https://public.tableau.com/app/profile/chris.chester/vizzes).

- **Chart A, the average:** pooled next-day steps after normal vs. poor-recovery nights
- **Chart B, who's behind it:** poor-recovery nights per user
- **Chart C, each user vs. themselves:** next-day steps after normal vs. poor nights, one line per user

The two original v.2 visualizations are kept on the profile, labeled as superseded.

---

## Recommendations Summary

1. **Build Stress/Recovery Analysis** as an everyday wellness feature, justified by the competitor gap and Bellabeat's wellness-first brand, and test it on Bellabeat's own user data before investing
2. **Target Moderate and Sedentary users** (about two-thirds of logged days) with gentle, non-exercise guidance after poor nights: guided meditation, hydration prompts, lighter days
3. **Align push notification timing** with weekly activity patterns: motivation prompts on peak days (Mon–Sat), recovery prompts midweek and Sunday
4. **Integrate phone-connected GPS** for walking/hiking route tracking tied to stress and readiness, not pace racing
5. **Position Bellabeat** as the leader in whole-person wellness: *"We don't just track your wellbeing — we actively help you achieve it"*

---

## What I Learned From the Correction

- **Check row counts after every join.** A merge that multiplies rows is a red flag, even when nothing errors.
- **Look behind averages.** Ask who is in the number before trusting it.
- **The better the story, the harder you check it.** The original finding was surprising and easy to sell, which is exactly why it needed more scrutiny.
- **Correct in public.** Say what changed and why.

---

## About This Project

This is my capstone project for the **Google Data Analytics Certificate**. It was my first end-to-end data analysis project, taking raw Kaggle data through cleaning, SQL aggregation, R feature engineering, and Tableau visualization, all in service of a real business recommendation.

Feedback welcome: feel free to open an issue or connect on my [LinkedIn](https://www.linkedin.com/in/peter-christopher-chester-8b262353/).

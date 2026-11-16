# ============================================================
# Bellabeat Case Study - R/tidyverse Analysis Script (v2, corrected)
# Google Data Analytics Certificate Capstone
# Author: Peter Christopher Chester | November 2025, corrected November 2026
#
# What changed in v2:
#   - Fitbit Ids are kept as text. v1 converted them with as.integer(),
#     which turned 26 of the 33 Ids into NA (they are larger than R's
#     32-bit integer limit of 2,147,483,647). The joins then matched NA to
#     NA and multiplied rows (940 -> 9,911), mixing different users' data.
#   - Row-count checks after every join so this can't happen silently again.
#   - Daily heart rate is labeled as an all-day average, not resting HR.
#   - Adds a within-user comparison of next-day steps.
# ============================================================


# ── LIBRARIES ────────────────────────────────────────────────
library(tidyverse)


# ── 1. LOAD DATA ─────────────────────────────────────────────
# col_types makes Id text from the start. This is the core fix.

dailyActivity    <- read_csv("dailyActivity_merged.csv",
                             col_types = cols(Id = col_character()))
sleepDay         <- read_csv("sleepDay_merged.csv",
                             col_types = cols(Id = col_character()))

# CHECKPOINT 1: expect 940 rows / 33 users and 413 rows / 24 users
cat("dailyActivity:", nrow(dailyActivity), "rows,", n_distinct(dailyActivity$Id), "users\n")
cat("sleepDay:     ", nrow(sleepDay),      "rows,", n_distinct(sleepDay$Id),      "users\n")


# ── 2. CLEAN: dailyActivity ───────────────────────────────────

dailyActivity <- dailyActivity %>%
  distinct(Id, ActivityDate, .keep_all = TRUE) %>%
  mutate(Date = as.Date(ActivityDate, format = "%m/%d/%Y")) %>%
  filter(!is.na(TotalSteps))


# ── 3. CLEAN: sleepDay ───────────────────────────────────────
# 3 exact duplicate rows in the raw file -> 410 rows after this step

sleepDay <- sleepDay %>%
  distinct(Id, SleepDay, .keep_all = TRUE) %>%
  mutate(Date = as.Date(as.POSIXct(SleepDay, format = "%m/%d/%Y %I:%M:%S %p", tz = "UTC")))


# ── 4. HOURLY HEART RATE ─────────────────────────────────────
# Option A: use the hourly file exported from BigQuery (your SQL query).
# Option B: if that file isn't here, build it in R from the raw seconds file.
# Either way: expect 6,013 hourly rows from 14 users.

if (file.exists("hourly_heartrate_aggregated.csv")) {
  hourly_hr <- read_csv("hourly_heartrate_aggregated.csv",
                        col_types = cols(Id = col_character()))
} else {
  hourly_hr <- read_csv("heartrate_seconds_merged.csv",
                        col_types = cols(Id = col_character())) %>%
    mutate(Time = as.POSIXct(Time, format = "%m/%d/%Y %I:%M:%S %p", tz = "UTC"),
           Hour_Timestamp = as.POSIXct(format(Time, "%Y-%m-%d %H:00:00"), tz = "UTC")) %>%
    group_by(Id, Hour_Timestamp) %>%
    summarise(Avg_Hourly_HeartRate = mean(Value), Readings_Count = n(), .groups = "drop")
}

# CHECKPOINT 2
cat("hourly_hr:", nrow(hourly_hr), "rows,", n_distinct(hourly_hr$Id), "users\n")

# Daily average heart rate per user (all-day average, NOT resting heart rate)
daily_hr <- hourly_hr %>%
  mutate(Date = as.Date(Hour_Timestamp)) %>%
  group_by(Id, Date) %>%
  summarise(Avg_Daily_HeartRate = mean(Avg_Hourly_HeartRate, na.rm = TRUE),
            .groups = "drop")


# ── 5. MERGE ─────────────────────────────────────────────────
# dailyActivity is the base: one row per user per day.

master_data <- dailyActivity %>%
  left_join(sleepDay %>% select(Id, Date, TotalMinutesAsleep, TotalTimeInBed),
            by = c("Id", "Date")) %>%
  left_join(daily_hr, by = c("Id", "Date"))

# CHECKPOINT 3: a left join must not add rows. Expect 940.
cat("master_data:", nrow(master_data), "rows\n")
stopifnot(nrow(master_data) == nrow(dailyActivity))
stopifnot(!any(is.na(master_data$Id)))


# ── 6. DERIVED METRICS ───────────────────────────────────────

master_data <- master_data %>%
  group_by(Id) %>%
  arrange(Date, .by_group = TRUE) %>%
  mutate(
    Next_Day_Steps     = lead(TotalSteps, n = 1),
    Sleep_Inefficiency = (TotalTimeInBed - TotalMinutesAsleep) / TotalTimeInBed
  ) %>%
  ungroup()


# ── 7. SEGMENTATION ──────────────────────────────────────────

hr_threshold           <- median(master_data$Avg_Daily_HeartRate, na.rm = TRUE)  # 76.3
inefficiency_threshold <- 0.10  # more than 10% of time in bed awake = poor recovery

master_data <- master_data %>%
  mutate(
    Elevated_HR   = Avg_Daily_HeartRate > hr_threshold,
    Poor_Recovery = Sleep_Inefficiency  > inefficiency_threshold,

    High_Strain_Segment = case_when(
      Poor_Recovery & Elevated_HR ~ "High Physiological Strain",
      Poor_Recovery               ~ "General Recovery Need",
      TRUE                        ~ "Normal Day"
    ),

    Activity_Level = case_when(
      TotalSteps > 10000 ~ "Active",
      TotalSteps > 5000  ~ "Moderate",
      TRUE               ~ "Sedentary"
    )
  )


# ── 8. ANALYSIS ──────────────────────────────────────────────
# Only days with a sleep record and a following day of steps

sleep_days <- master_data %>%
  filter(!is.na(TotalMinutesAsleep), !is.na(Next_Day_Steps))

# 8a. Pooled comparison (the v1 view): all users mixed together
pooled <- sleep_days %>%
  group_by(Poor_Recovery) %>%
  summarise(days = n(), users = n_distinct(Id),
            avg_next_day_steps = round(mean(Next_Day_Steps)), .groups = "drop")
print(pooled)

# 8b. Who is behind the poor-recovery days?
print(sleep_days %>% filter(Poor_Recovery) %>% count(Id, sort = TRUE) %>% head(5))

# 8c. Segment sizes
print(sleep_days %>% count(High_Strain_Segment))

# 8d. Within-user comparison: each user compared with themselves
within_user <- sleep_days %>%
  group_by(Id, Poor_Recovery) %>%
  summarise(avg_next = mean(Next_Day_Steps), .groups = "drop") %>%
  pivot_wider(names_from = Poor_Recovery, values_from = avg_next,
              names_prefix = "poor_") %>%
  filter(!is.na(poor_TRUE), !is.na(poor_FALSE)) %>%
  mutate(diff = poor_TRUE - poor_FALSE)

cat("\nWithin-user: ", nrow(within_user), " users with both kinds of nights\n",
    "Mean difference in next-day steps after a poor night: ", round(mean(within_user$diff)), "\n",
    "Median difference: ", round(median(within_user$diff)), "\n",
    "Users who walked MORE after a poor night: ", sum(within_user$diff > 0), "\n", sep = "")


# ── 9. EXPORT FOR TABLEAU ────────────────────────────────────

write_csv(master_data, "master_analysis_data_for_tableau.csv")
write_csv(within_user,  "within_user_comparison.csv")

message("Export complete: ", nrow(master_data), " rows | ", ncol(master_data), " columns")

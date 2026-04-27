# ============================================================
# Bellabeat Case Study - R/tidyverse Analysis Script
# Google Data Analytics Certificate Capstone
# Author: Peter Christopher Chester | November 2025
# ============================================================


# ── LIBRARIES ────────────────────────────────────────────────
library(tidyverse)


# ── 1. LOAD DATA ─────────────────────────────────────────────

dailyActivity    <- read_csv("dailyActivity_merged.csv")
sleepDay         <- read_csv("sleepDay_merged.csv")
heartrate_second <- read_csv("heartrate_seconds_merged.csv")


# ── 2. CLEAN: dailyActivity ───────────────────────────────────

# Remove duplicates by Id + ActivityDate
dailyActivity <- dailyActivity %>%
  distinct(Id, ActivityDate, .keep_all = TRUE)

# Trim whitespace in text columns
dailyActivity <- dailyActivity %>%
  mutate_if(is.character, str_trim)

# Convert ActivityDate to Date type
dailyActivity <- dailyActivity %>%
  mutate(ActivityDate = as.Date(ActivityDate, format = "%m/%d/%Y"))

# Check for missing values
dailyActivity %>% summarise_all(~sum(is.na(.)))

# Remove rows with NA in essential columns
dailyActivity <- dailyActivity %>%
  filter(!is.na(TotalSteps))


# ── 3. CLEAN: heartrate_second ────────────────────────────────

# Remove duplicates by Id + Time
heartrate_second <- heartrate_second %>%
  distinct(Id, Time, .keep_all = TRUE)

# Parse timestamp
heartrate_second <- heartrate_second %>%
  mutate(Time = as.POSIXct(Time, format = "%m/%d/%Y %I:%M:%S %p"))

# Check for missing values
heartrate_second %>% summarise_all(~sum(is.na(.)))


# ── 4. CLEAN: sleepDay ───────────────────────────────────────

# Remove duplicates by Id + SleepDay
sleepDay <- sleepDay %>%
  distinct(Id, SleepDay, .keep_all = TRUE)

# Parse timestamp
sleepDay <- sleepDay %>%
  mutate(SleepDay = as.POSIXct(SleepDay, format = "%m/%d/%Y %I:%M:%S %p"))

# Check for missing values
sleepDay %>% summarise_all(~sum(is.na(.)))


# ── 5. FEATURE ENGINEERING ───────────────────────────────────

# Load SQL-aggregated hourly heart rate data (output from BigQuery)
hourly_hr <- read_csv("hourly_heartrate_aggregated.csv")

# Ensure Id columns are consistent integer type to prevent join failures
dailyActivity    <- dailyActivity    %>% mutate(Id = as.integer(Id))
sleepDay         <- sleepDay         %>% mutate(Id = as.integer(Id))
hourly_hr        <- hourly_hr        %>% mutate(Id = as.integer(Id))

# Aggregate hourly HR to daily average per user
daily_hr <- hourly_hr %>%
  mutate(Date = as.Date(Hour_Timestamp)) %>%
  group_by(Id, Date) %>%
  summarise(Avg_Daily_HeartRate = mean(Avg_Hourly_HeartRate, na.rm = TRUE),
            .groups = "drop")

# Extract date from sleepDay for joining
sleepDay <- sleepDay %>%
  mutate(Date = as.Date(SleepDay))

# Extract date from dailyActivity for joining
dailyActivity <- dailyActivity %>%
  mutate(Date = ActivityDate)

# Left join: start with dailyActivity as the base (largest, most complete)
master_data <- dailyActivity %>%
  left_join(sleepDay  %>% select(Id, Date, TotalMinutesAsleep, TotalTimeInBed),
            by = c("Id", "Date")) %>%
  left_join(daily_hr, by = c("Id", "Date"))


# ── 6. DERIVED METRICS ───────────────────────────────────────

master_data <- master_data %>%
  group_by(Id) %>%
  arrange(Date) %>%
  mutate(
    # Next-day steps: did poor recovery affect following day activity?
    Next_Day_Steps = lead(TotalSteps, n = 1),

    # Sleep inefficiency: proportion of bed time NOT spent asleep
    Sleep_Inefficiency = (TotalTimeInBed - TotalMinutesAsleep) / TotalTimeInBed
  ) %>%
  ungroup()


# ── 7. SEGMENTATION ──────────────────────────────────────────

# Define thresholds (based on dataset medians/distributions)
rhr_threshold        <- median(master_data$Avg_Daily_HeartRate, na.rm = TRUE)
inefficiency_threshold <- 0.10  # 10% of time in bed not asleep = poor recovery

master_data <- master_data %>%
  mutate(
    Elevated_RHR   = Avg_Daily_HeartRate > rhr_threshold,
    Poor_Recovery  = Sleep_Inefficiency  > inefficiency_threshold,

    High_Strain_Segment = case_when(
      # Primary target: physiological strain AND poor recovery
      (Poor_Recovery == TRUE & Elevated_RHR == TRUE) ~ "High Physiological Strain",
      (Poor_Recovery == TRUE)                         ~ "General Recovery Need",
      TRUE                                            ~ "Normal Day"
    ),

    # Activity level segmentation (marketing tiers)
    Activity_Level = if_else(TotalSteps > 10000, "Active",
                     if_else(TotalSteps > 5000,  "Moderate", "Sedentary"))
  )


# ── 8. EXPORT FOR TABLEAU ────────────────────────────────────

write_csv(master_data, "master_analysis_data_for_tableau.csv")

message("Export complete: master_analysis_data_for_tableau.csv")
message(paste("Rows:", nrow(master_data), "| Columns:", ncol(master_data)))

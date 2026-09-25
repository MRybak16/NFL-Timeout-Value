library(nflfastR)
library(dplyr)
library(tibble)
library(tidyr)

pbp <- nflreadr::load_pbp(2016:2025)

analysis_data <- pbp |>
  filter(
    qtr >= 3,
    qtr <= 4,
    game_seconds_remaining <= 1800,
    game_seconds_remaining >= 180,
    score_differential %in% c(-14, -7, -3, 0, 3, 7, 14),
    
    !is.na(wp),
    !is.na(posteam),
    !is.na(home_team),
    !is.na(score_differential),
    !is.na(half_seconds_remaining),
    !is.na(game_seconds_remaining),
    !is.na(spread_line),
    !is.na(down),
    !is.na(ydstogo),
    !is.na(yardline_100),
    !is.na(posteam_timeouts_remaining),
    !is.na(defteam_timeouts_remaining)
  ) |>
  mutate(
    # Required by calculate_win_probability().
    # Because every observation is in Q3 or Q4,
    # the second-half kickoff has already occurred.
    receive_2h_ko = 0L
  )

# 3. Scenario A:
#
# Team has 2 timeouts remaining.
# Everything else remains exactly as observed.

scenario_2_timeout <- analysis_data |>
  mutate(
    posteam_timeouts_remaining = 2L
  ) |>
  select(
    receive_2h_ko,
    home_team,
    posteam,
    score_differential,
    half_seconds_remaining,
    game_seconds_remaining,
    spread_line,
    down,
    ydstogo,
    yardline_100,
    posteam_timeouts_remaining,
    defteam_timeouts_remaining
  ) |>
  nflfastR::calculate_win_probability() |>
  pull(wp)


# Scenario B:
# Team takes a delay of game
#
# 5 yards farther back
# 5 additional yards to go
# All 3 timeouts remaining

scenario_delay <- analysis_data |>
  mutate(
    posteam_timeouts_remaining = 3L,
    yardline_100 = pmin(yardline_100 + 5, 100),
    ydstogo = pmin(ydstogo + 5, 100)
  ) |>
  select(
    receive_2h_ko,
    home_team,
    posteam,
    score_differential,
    half_seconds_remaining,
    game_seconds_remaining,
    spread_line,
    down,
    ydstogo,
    yardline_100,
    posteam_timeouts_remaining,
    defteam_timeouts_remaining
  ) |>
  nflfastR::calculate_win_probability() |>
  pull(wp)

# 3. ANALYSIS

timeout_analysis <- analysis_data |>
  mutate(
    wp_2_timeout = scenario_2_timeout,
    wp_delay_of_game = scenario_delay,
    
    wp_difference =
      wp_delay_of_game - wp_2_timeout
  )

head(
  timeout_analysis |>
    select(
      game_id,
      posteam,
      qtr,
      game_seconds_remaining,
      score_differential,
      down,
      ydstogo,
      yardline_100,
      wp_2_timeout,
      wp_delay_of_game,
      wp_difference
    )
)

# 4. CREATE HEAT MAP

library(ggplot2)

# Function to create a heatmap for one score differential
make_heatmap <- function(score_diff) {
  
  ggplot(
    timeout_analysis |>
      filter(score_differential == score_diff),
    aes(
      x = yardline_100,
      y = game_seconds_remaining,
      z = wp_difference
    )
  ) +
    stat_summary_2d(
      fun = mean,
      bins = c(20, 18)
    ) +
    scale_y_reverse(
      name = "Seconds Remaining"
    ) +
    scale_x_continuous(
      name = "Yardline (0 = Own Goal Line, 100 = Opponent Goal Line)",
      breaks = c(0, 20, 40, 50, 60, 80, 100)
    ) +
    scale_fill_gradient2(
      name = "WP Difference",
      midpoint = 0,
      limits = c(-0.12, 0.12),
      labels = scales::percent
    ) +
    labs(
      title = paste0(
        "Win Probability Effect of Accepting Delay of Game Penalty: ",
        ifelse(score_diff > 0, "+", ""),
        score_diff,
        " Points"
      ),
      subtitle = "NFL plays from 2016-2025 | Q3 through 3:00 remaining in Q4",
      caption = "WP difference = WP with 3 timeouts after a 5-yard penalty − WP with 2 timeouts at the original spot"
    ) +
    theme_minimal()
}


# Generate one heat map for each score differential

heatmap_minus14 <- make_heatmap(-14)
heatmap_minus7  <- make_heatmap(-7)
heatmap_minus3  <- make_heatmap(-3)
heatmap_0       <- make_heatmap(0)
heatmap_plus3   <- make_heatmap(3)
heatmap_plus7   <- make_heatmap(7)
heatmap_plus14  <- make_heatmap(14)


# Display the seven heat maps

heatmap_minus14
heatmap_minus7
heatmap_minus3
heatmap_0
heatmap_plus3
heatmap_plus7
heatmap_plus14

# 5. CREATE SUMMARY TABLE

timeout_summary <- timeout_analysis |>
  group_by(score_differential) |>
  summarise(
    n = sum(!is.na(wp_difference)),
    mean_wp_difference = mean(wp_difference, na.rm = TRUE),
    median_wp_difference = median(wp_difference, na.rm = TRUE),
    sd_wp_difference = sd(wp_difference, na.rm = TRUE),
    pct_positive = mean(wp_difference > 0, na.rm = TRUE),
    pct_negative = mean(wp_difference < 0, na.rm = TRUE)
  )
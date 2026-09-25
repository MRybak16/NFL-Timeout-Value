# NFL Timeout vs. Delay of Game: Win Probability Analysis

## Overview

This project investigates whether an NFL team should use a timeout to avoid a delay-of-game penalty or allow the five-yard penalty in order to retain the timeout.

The analysis compares the modeled win probability (WP) of two counterfactual game states:

1. **Use a timeout:** The offense uses a timeout to avoid the delay-of-game penalty.
2. **Accept the delay:** The offense keeps the timeout but accepts a five-yard penalty.

The difference between these two scenarios is evaluated across different score differentials, field positions, and amounts of time remaining in the game.

---

## Research Question

**When an NFL team faces a potential delay-of-game penalty, is it more valuable to use a timeout to avoid the five-yard penalty, or to accept the penalty and keep the timeout?**

The analysis focuses on the second half of games, when timeouts have the most value and the greatest impact on win probability.

---

## Data

The analysis uses NFL play-by-play data from the **2016–2025 NFL seasons** through the `nflfastR`/`nflreadr` ecosystem.

The analysis is restricted to game states meeting the following conditions:

* Third or fourth quarter
* Between 3:00 and 30:00 remaining in the game
* Score differential between -16 and +16 points
* Non-missing win probability and game-state variables
* Valid offensive and defensive timeout counts
* Valid down, distance, field position, and betting spread information

Seven score differentials were examined individually:

* -14
* -7
* -3
* 0
* +3
* +7
* +14

These score differentials represent common game situations ranging from a two-touchdown deficit to a two-touchdown lead.

---

## Methodology

### Scenario A: Use a Timeout

The first counterfactual represents a team using a timeout to prevent a delay-of-game penalty.

For each observed game state:

* The offense is assigned **2 timeouts remaining** after using one timeout.
* The original field position is maintained.
* The original yards-to-go is maintained.
* Win probability is calculated using `nflfastR::calculate_win_probability()`.

This produces:

**WP with 2 timeouts at the original game state**

---

### Scenario B: Accept the Delay of Game

The second counterfactual represents a team allowing the delay-of-game penalty and retaining all three timeouts.

For each observed game state:

* The offense is assigned **3 timeouts remaining**.
* Field position is moved back five yards.
* Yards-to-go is increased by five yards.
* Win probability is recalculated using the modified game state.

The five-yard penalty is modeled as:

```r
yardline_100 = yardline_100 + 5
ydstogo = ydstogo + 5
```

with the values capped at 100 where necessary.

This produces:

**WP with 3 timeouts after accepting the five-yard penalty**

---

## WP Difference

The primary metric is:

```text
WP Difference = WP after Delay of Game − WP after Using Timeout
```

Therefore:

* **Positive WP difference:** Retaining the timeout and accepting the five-yard penalty has higher modeled WP.
* **Negative WP difference:** Using the timeout to avoid the penalty has higher modeled WP.
* **WP difference near zero:** The modeled value of the two choices is similar.

For example, a WP difference of `-0.02` means that the modeled win probability is approximately **2 percentage points higher when the timeout is used** than when the delay-of-game penalty is accepted.

---

## Analysis

### Win Probability Difference Heatmaps

Heatmaps are used to examine how the value of using a timeout changes based on:

* Field position
* Time remaining
* Score differential

The x-axis represents `yardline_100`, the number of yards from the opponent's goal line.

The y-axis represents `game_seconds_remaining`.

Each heatmap displays the average WP difference for game states within each field-position/time bin.

The analysis uses a common color scale centered at zero so that positive and negative values can be compared consistently across score differentials.

---

### Distribution of WP Differences

In addition to examining average WP differences, the distribution of the differences is analyzed using:

* Mean
* Median
* Standard deviation
* Number of observations
* Percentage of observations with a positive WP difference
* Percentage of observations with a negative WP difference

This helps distinguish the overall average effect from the consistency of the result across individual game states.

---

## Results

Across all seven score differentials examined, the **mean WP difference was negative**.

This means that, within the modeled game states, using a timeout to avoid the five-yard penalty generally produced a higher modeled win probability than accepting the penalty and retaining the timeout.

| Score Differential |     N | Mean WP Difference |   Median |       SD | % Positive | % Negative |
| -----------------: | ----: | -----------------: | -------: | -------: | ---------: | ---------: |
|                -14 | 6,250 |           -0.00578 | -0.00448 | 0.005842 |      6.26% |     93.74% |
|                 -7 | 8,392 |           -0.01409 | -0.01234 | 0.011602 |      5.51% |     94.49% |
|                 -3 | 8,717 |           -0.02624 | -0.02600 | 0.014816 |      4.43% |     95.57% |
|                  0 | 9,803 |           -0.02006 | -0.01898 | 0.014070 |      5.95% |     94.05% |
|                 +3 | 8,302 |           -0.01698 | -0.01685 | 0.010688 |      5.12% |     94.88% |
|                 +7 | 7,841 |           -0.01017 | -0.00900 | 0.008847 |     11.30% |     88.70% |
|                +14 | 4,808 |           -0.00291 | -0.00197 | 0.004723 |     15.87% |     84.13% |

### Main Findings

The largest average difference occurred when the offense was trailing by **3 points**.

* Mean WP difference: **-0.02624**
* Median WP difference: **-0.02600**

This corresponds to approximately a **2.6 percentage-point modeled WP advantage for using the timeout** rather than accepting the delay-of-game penalty.

The smallest average difference occurred when teams were leading by **14 points**:

* Mean WP difference: **-0.00291**
* Median WP difference: **-0.00197**

This corresponds to an approximately **0.3 percentage-point modeled WP advantage for using the timeout**.

The negative result was also highly consistent across the observations. The percentage of observations with a negative WP difference ranged from:

* **84.13%** when leading by 14
* **95.57%** when trailing by 3

Thus, negative WP differences were more common than positive differences at every score differential examined.

The standard deviation was largest when trailing by 3 points (`0.014816`) and smallest when leading by 14 points (`0.004723`).

---

## Interpretation

The results suggest that the five-yard penalty generally has a larger modeled effect on win probability than the value of retaining the additional timeout in the game states examined.

The effect is not constant, however. The magnitude of the difference varies substantially depending on the score differential and the specific game state.

For example, when a team is trailing by three points, the average modeled difference is approximately -2.6 percentage points. When a team is leading by two touchdowns, the average difference is less than -0.3 percentage points.

The heatmaps provide additional context by showing how the difference changes with field position and time remaining rather than relying only on score differential.

Importantly, the percentages in the results table describe the proportion of observed game-state rows with positive or negative **modeled counterfactual WP differences**. They should not be interpreted as causal probabilities that a timeout will improve a team's actual chance of winning.

---

## Limitations

### Counterfactual Win Probability

This analysis compares two modeled game states rather than observing the exact same situation under both decisions.

The WP difference therefore represents a **counterfactual model comparison**, not a direct causal estimate of the effect of using a timeout.

### Modeling the Delay-of-Game Penalty

The five-yard penalty is constructed by modifying the observed game state:

```r
yardline_100 + 5
ydstogo + 5
```

This approximates the resulting state but does not capture every consequence of an actual delay-of-game event.

### Strategic Considerations

The analysis focuses on the measurable game-state variables used by the win-probability model. It does not directly account for factors such as:

* Communication between coaches and players
* Substitutions
* Defensive substitutions
* Play-call changes
* Offensive cadence
* Player fatigue
* Momentum
* Potential procedural mistakes
* The strategic value of saving a timeout for a later non-clock-management situation

### Timeout Availability

The modeled scenarios standardize the offense to either two or three timeouts. This allows the two scenarios to be compared consistently, but it means the analysis should be interpreted as a comparison of modeled game states rather than a direct estimate for every individual real-world timeout decision.

### Win Probability Model

The conclusions depend on the win-probability model used by `nflfastR`. Different modeling approaches could produce somewhat different estimates.

---

## Visualizations

The project includes heatmaps showing the average WP difference across:

* Field position
* Time remaining
* Score differential

The project also examines the overall distribution of WP differences and summarizes the distribution by score differential.

The heatmaps use a common scale centered at zero:

* Positive values indicate higher modeled WP from retaining the timeout and accepting the penalty.
* Negative values indicate higher modeled WP from using the timeout to avoid the penalty.

---

## Technologies

* **R**
* **nflfastR**
* **nflreadr**
* **tidyverse**
* **ggplot2**
* **dplyr**
---

## How to Run

### 1. Install the required R packages

```r
install.packages(c(
  "tidyverse",
  "ggplot2",
  "dplyr",
))

install.packages("nflreadr")
```

Install `nflfastR` if it is not already installed:

```r
install.packages("nflfastR")
```

### 2. Load the packages

```r
library(nflfastR)
library(nflreadr)
library(tidyverse)
library(ggplot2)
library(dplyr)
```

### 3. Load the NFL play-by-play data

```r
pbp <- nflreadr::load_pbp(2016:2025)
```

### 4. Run the analysis

Run the analysis script from beginning to end to:

1. Filter the relevant game states.
2. Construct the two counterfactual scenarios.
3. Calculate win probabilities.
4. Calculate WP differences.
5. Produce summary statistics.
6. Generate the heatmaps and distribution plots.

---

## Key Metric

The central metric in this project is:

```r
wp_difference = wp_delay_of_game - wp_2_timeout
```

where:

```text
wp_delay_of_game = modeled WP after accepting a five-yard penalty
wp_2_timeout     = modeled WP after using a timeout
```

The sign of this metric determines which modeled game state has the higher win probability.

---

## Conclusion

Across the 2016–2025 NFL plays included in this analysis, the modeled win probability was generally higher when a team used a timeout to avoid a five-yard delay-of-game penalty than when it accepted the penalty and retained the timeout.

This difference varied considerably by score differential and game state. The largest average differences occurred in closer game situations, particularly when trailing by three points, while the differences were considerably smaller when teams held larger leads.

The analysis provides a framework for examining the trade-off between the immediate five-yard cost of a delay of game and the strategic value of retaining a timeout. These results are somewhat surprising to me and could be skewed by including some late game situations but it is still a

very interesting result that shows the value of five yards in close games. 

---

## Author

**Miles Rybak**
University of Toronto
milesrybak16@gmail.com

---
title: "Thermal Tolerance Pilot Experiments"
author: "FiG-T"
date: "2023-08-29"
output:
  html_document:
    keep_md: yes
  pdf_document: default
editor_options:
  markdown:
    wrap: 80
---

## Introduction

While the T.I.M.E project will primarily focus on genetic changes through time,
it has the potential to provide insight into associated phenotypic changes.\
This will require regular (every 4 months) measurements of fitness in each of
the populations. Given the large number of populations (16 as of Aug 2023) many
of the standard fitness assays (lifespan, activity) are not pragmatically
feasible. Included among the list of unsuitable fitness assays are the
"conventional" heat and cold tolerance assays (CT-50, CCRT, Tmax) which require
assessment of individual flies and hence large amounts of time and manual
effort.

To bypass these issues and enable the efficient generation of larger volumes of
data a different protocol has been suggested: Survival, measured 2 hours and 24
hours post thermal-treatment. Such methods have been used to assess differences
between *species*, however whether this could be used to identify variation
between (closely related) populations has not been previously explored (to the
best of my knowledge).

These Pilot experiments thus aim to identify:

1.  Whether survival can be used to discriminate between closely related
    *Drosophila melanogaster* populations.

2.  What temperatures (hot and cold) are required to differentiate the
    populations.

3.  What duration of treatments (hot and cold) are required to differentiate the
    populations.

Additionally, the following secondary objectives have been set:

1.  Does the presence of food in the vials impact survival? (for cold assays)

2.  Does the use of a water-bath impact survival for cold assays?

## Experimental methods

### Fly sorting

1.  Leave mated flies to lay eggs on a petri dish for 4-12 hours (depending on
    the number of flies), then remove the adults (no longer needed).

2.  Cut small squares with eggs on from the petri dish and transfer to new empty
    vials with standard sugar yeast food.

3.  Allow flies to develop, emerge and mate (for 48h).

4.  Using 5ppm CO~2~ knock out the flies and separate the sexes.

5.  Transfer 10 flies (of a single sex) to a new vial with food and leave to
    recover for 48h. Repeat for the number of desired replicates.

### Heat Assay

1.  Preheat a water-bath[^1] to the desired temperature.

2.  Transfer the flies (see above for setup) into new **labelled** empty (glass)
    vials. (Extra tall vials were used here).

3.  Record the number of flies alive in each vial.

4.  Simultaneously transfer the vials to the water-bath, ensuring that the
    bottom of the vials are submerged and that the vials are plugged in such a
    way to ensure that the flies cannot escape the heated section of the tube.

5.  Leave the vials for the specified amount of time.

6.  Remove the vials from the water-bath and leave to cool at room temperature.

7.  After 2 hours (from when they were removed from the heat) record the number
    of surviving flies in each vial.

8.  After 24 hours, recount and record the number of survivors in each vial.

[^1]: Note: a water-bath will likely give significantly different results to an
    incubator.

### Cold Assay

1.  If using an ice treatment - set this up by transferring ice to a watertight
    icebox and covering with a salt solution (125g table salt per 1 litre RO
    water). This should be of a slushy consistency.

2.  Transfer the flies (see above for setup) into new **labelled** empty (glass)
    vials. (Extra tall vials were used here). Skip this stage for flies in the
    food treatment group.

3.  Record the number of flies alive in each vial.

4.  If using an ice-bath; seal the vials inside a watertight Ziploc bag.

5.  Transfer all the vials to the cold environment (Cold Control Temperature
    room, \~5ºC used for this pilot). If testing different time limits, this
    step can be staggered.

6.  Leave in the cold environment for the specified amount of time.

7.  Remove the vials and return to room temperature.

8.  After 2 hours, record the number of *moving* flies (which are visibly no
    longer in the chill-coma or dead).

9.  After 24 hours, record the number of *moving* flies (which are visibly no
    longer in the chill-coma or dead).

### Treatment conditions used

#### For heat:

| Temperature (ºC) | 10 min | 30 min | 60 min | 16 hours (overnight) | Custom                   |
|--------------|--------------|--------------|--------------|--------------|--------------|
| 28.5             |        |        |        | 2                    |                          |
| 30               |        |        |        | 1                    |                          |
| 33               | 2      |        |        |                      |                          |
| 35               |        |        | 1      |                      |                          |
| 35.5             | 2      | 2      |        |                      |                          |
| 36.5             | 3      |        |        |                      |                          |
| 37               | 2 , 3  | 2      |        |                      |                          |
| 37.5             | 3      |        |        |                      |                          |
| 38.5             | 2      | 2      |        |                      |                          |
| 40               |        |        | 1      |                      | sexes till drop, 25 min. |

: Representation of temperatures and timings tested. Number indicates lay used.
1 & 2 are from stock population 2, lay 3 derive from stock population 1. Blank
spaces indicate that the temperature time combination was not tested.

#### For Cold:

| Temperature (ºC) | 22 hours | 24 hours | 25 hours   | 26 hours | 28 hours |
|------------------|----------|----------|------------|----------|----------|
| 5 + ice (\~1)    | 1        | 1        | 1          |          |          |
| 5                | 1^f^     | 1        | 1, 2^f, w^ | 1        | 1        |

: Representation of the cold temperatures and timings used. Number indicates lay
used for the run. 1 and 3 derive from stock populations 2 and 1 respectively.
Blank spaces indicate the combination was not included in the pilot. f and w
represent that additional tests were taken with vials containing food ( ^f^ ) or
within a water bath (^w^).

## Analysis and results

### Data processing and formats

Survival was recorded for each vial and written into an excel document with the
following columns:

-   **genotype**: the genetic background of the line
-   **sex**
-   **replicate**: per experimental group
-   **lay**: the date on which the eggs were laid
-   **batch**: corresponding to the three different days on which experiments
    were conducted.
-   **food**: whether the treatment vial contained food (y) or was empty (n). i
    indicates a cold water bath was used (with empty vials).
-   **temperature:** the temperature in ºC of the thermal treatment
-   **time**: the duration of time spent at the experimental temperature **in
    minutes**
-   **start_no**: The number of alive individuals in the vial before any thermal
    treatments have been applied.
-   **post_treatment**: The number of alive individuals in the vial 2 hours
    after the thermal treatment has ended.
-   **final_survival:** The number of alive individuals 24 hours after the
    thermal treatment has ended.

This was imported into R:



As there are different initial numbers of flies in each vial, the absolute
number of flies is not accurately informative. Instead, survival fractions are
calculated:



This appends two columns, `per_post` (fraction alive 2h post treatment) and
`per_final` (fraction alive 24h after treatment) to the data set.

To ensure the variables are in convenient formats for later grouping and
plotting, some are converted into factors:



### Summarising the data

Summaries of the data are subsequently used for convenient later plots.


```
## `summarise()` has grouped output by 'genotype', 'sex', 'batch', 'temperature',
## 'time'. You can override using the `.groups` argument.
```

### Plots - Heat shock tolerance

**Note** this is a pilot study and as such the following figures are accordingly
rough / unpolished.

#### Looking at an overview:

The following plot shows an overview of all the heat thermal tolerance
experiments.

![Panel columns show the temperature:time combinations (ºC):(minutes), panel rows show the batch number (1 & 2 originate from the same source population). Points show mean values, errors bars show +/- standard errors. Paler points represent survival after 24h](pilot_thermal_writeup_files/figure-html/heat_overview-1.png)

#### Batch 1

This batch was used to establish potential outer limits for temperatures and
times (based on discussion with other group members). Runs were done either
overnight (1080 mins) or for 60 minutes at a higher temperature. Aside from 35ºC
for 60 minutes, all treatments resulted in 0% survival in all groups, as shown
below.

![](pilot_thermal_writeup_files/figure-html/heat_batch1-1.png)<!-- -->

Given the complete mortality observed here, it was decided to use much shorter
treatment durations going forward.

#### Batch 2

Batch 2 are derived from the Population 2 stocks. This covered a wide range of
temperatures and times to gauge the approximate range.

![Panel columns show the temperature:time combinations (ºC):(minutes), panel rows show the batch number (1 & 2 originate from the same source population). Points show mean values, errors bars show +/- standard errors. Paler points represent survival after 24h](pilot_thermal_writeup_files/figure-html/heat_batch2-1.png)

This suggests that 37ºC is the approximate temperature which allows for
differentiation of the genotypes within each sex. Lower temperatures fail to
split genotypes in females and higher temperatures lead to 100% mortality rates
in males after 24h (and no differences after 2h). 10 minutes appears to lead to
greater disparity between groups, with 30 minute treatments leading to reduced
survival in all groups to comparable levels.

#### Batch 3

Building upon the findings from Batch 2, Batch 3 had a more focused temperature
range (36.5-37.5 with 0.5ºC increments) with larger sample sizes.

![Panel columns show the temperature:time combinations (ºC):(minutes), panel rows show the batch number (1 & 2 originate from the same source population). Points show mean values, errors bars show +/- standard errors. Paler points represent survival after 24h](pilot_thermal_writeup_files/figure-html/heat_batch3-1.png)

These results replicate the findings from Batch 2 and confirm that 37ºC results
in identifiable differences between the populations within each sex. 37.5ºC
leads to greater differentiation in females after 24h but results in 0% survival
in Townsville (tT) males at the same time point. For this reason **37ºC is
proposed to be the most suitable temperature for future thermal shock fitness
assays.**

### Plots - Cold Thermal Tolerance

The following plot shows the results of the different thermal tolerance
treatments:

![Panel columns show the temperature:time combinations (ºC):(minutes), panel rows show the batch number. Points show mean values, errors bars show +/- standard errors. Paler points represent survival after 24h](pilot_thermal_writeup_files/figure-html/cold_overview-1.png)

This plot shows that on ice survival is 0% across all groups (first 3 plots on
top row). Differences between groups are observed for each of the runs at 5ºC,
regardless of the time used. 25h (1500 minutes) was selected for batch 3 as this
had large differences between both males and females, enabling efficient
experimental setup. The second run (using batch 3, bottom row) used a larger
sample size and further confirmed that 25h (1500 minutes) at 5ºC led to
reproducible differences between genotypes within both males and females.

> It is therefore suggested that 25h at 5ºC is used for future cold tolerance
> fitness experiments.

#### Secondary questions

This pilot also aimed to investigate whether the use of standard food-containing
vials or a water bath impacted survival in cold conditions. The following plot
shows the result of these treatments; water-bath (i)[^2], food vials (y), or
control empty vials (n), as used in all the other temperature assays.

[^2]: I cannot remember why I chose "i" to represent this... your guess is as
    good as mine.

![Panel columns show the temperature:time:batch combinations (ºC):(minutes), panel rows show the treatment. i = water-bath, n = no food (empty vial), y = yes food (standard vial with food used).  Points show mean values, errors bars show +/- standard errors. Paler points represent survival after 24h](pilot_thermal_writeup_files/figure-html/cold_secondary-1.png)

The use of a water bath appears to have no effect on male survival but decreases
female survival at the 2h time-point. Differences in females between survival at
the 2h and 24h measurement point further disappear in vials placed in the water
bath. It is unclear why this might be the case.

The use of standard food vials increases survival rates at 1ºC but decreases
survival at the 2h time-point when placed at 5ºC. This is contrasted by an
increase in survival at the 24h time-point. This results in overlap between
survival fractions at the two measurement time-points. Given the inconsistency
observed when using food vials and water baths, neither of these treatment
options are recommended for future use.

## Discussion & Key Takeaways

**These pilot experiments successfully demonstrate that survival 2h and 24h
after a stressful heat treatment (hot or cold) can be used to show differences
in fitness between closely related populations of *Drosophila melanogaster*.**

This outcome will allow for a high-throughput approach to thermal assays (1 vial
with 10 flies takes \~5 seconds to count), suitable for large scale experimental
evolution studies, including T.I.M.E. .

The use of a water bath for heat treatments appears to have a greatly
exaggerated impact on fitness relative to the use of an incubator or CT room,
with survival highly reduced when a water-bath is used. For example, batch 1
included a series of overnight assays at 28.5ºC and 30ºC. In both instances this
lead to 0% survival 24 hours post treatment. In contrast, group members have
previously maintained flies at 29ºC for several months in incubators. Possible
explanations are that the water bath maintains a more consistent temperature
throughout the tank (fluctuations are known to occur in both incubators and CT
rooms), and that the water heats the glass such that it is noticeably warmer to
the touch, forcing the flies to come into contact with a warmer surface. The use
of cardboard boxes in incubators may further act to insulate the vials against
the temperature changes. While the effect of the boxes and incubator temperature
fluctuations are likely to be slight, batch 3 experiments show that small 0.5ºC
changes in temperature are sufficient to have identifiable effects on survival
(bodes well for climate change...).

The margin between 100% and 0% survival in heat treated groups appears to be
very fine. Furthermore there is not a direct link between dropped flies
(following heat exposure) and survival. In treatment groups placed at 40ºC and
removed when the vast majority (\~95%) of flies had collapsed no differences
were observed between genotypes, with the vast majority of flies successfully
recovering by the 2h measurement point. Attempts to identify a temperature:time
combination that resulted in 75%:25% (or similar) survival ratio between
genotypes was ultimately unsuccessful. This was partly due to the
greater-than-expected differences between males and females, which greatly
increased the spread of survival values, as well as due to the significant
drop-off by the 24h measurement point. Measurement at more regular intervals may
lead to the identification of a time-point with more intermediate survival
fractions however such an approach was not taken here (due to time restraints
and practicality (of measuring throughout the night).

A curiously inconsistent effect was observed for cold-treated vials with either
of the additional treatments (cold water bath or food vials). Prior to the
experiment it was suspected that flies would stick to the food while in the cold
coma state, resulting in reduced survival. This hypothesis is potentially
supported by the results of the batch 3 cold tests, which show reduced survival
relative to empty controls at the 2h time-point. However, unlike the control
vials, no further drop in survival fraction was observed at the 24h time-point.
This may suggest that the mortality observed was indeed due to sticking into the
food during the coma stage, rather than the cold treatment. Furthermore, the
impact the food has on controlling/ modulating the temperature change is
unknown, which introduces another variable into the experiment. The increase
survival in food-containing vials at 1ºC relative to control may be explained by
the avoidance of freeze-burn for flies on the food (an issue with glass vials on
ice that was not known about at the start of the experiment).

### Key conclusions

-    Heat treatment of **37ºC for 10 minutes** is the best option for
    differentiating survival rates in Australian *Drosophila melanogaster*
    populations from Townsville and Melbourne.

-   Cold treatment of **5ºC for 25 hours** is the best option for
    differentiating survival rates in Australian *Drosophila melanogaster*
    populations from Townsville and Melbourne.

-   Such thermal conditions and experimental setups are suitable for
    high-throughput fitness assays.

-   The use of empty vials is preferential over food-containing vials (specific
    to the cold assays).

-   The use of a cold water bath is not advantageous for cold assays.

-   The use of a hot water bath likely gives significantly different results
    compared to incubators or CT rooms.

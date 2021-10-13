###############################
# exploration script

# this script loads the processed data and conducts exploratory data analysis (EDA)


# main continuous outcome of interest: body temperature
# main categorical outcome of interest: nausea 
# goal: are other symptoms correlated with those outcomes?

# other symptoms that we will consider:

# for each symptom, the exploration script will do the following:
# (1) produce and print some numerical output (e.g. table, summary statistics)
# (2) create histogram or density plot (continuous variables only)
# (3) scatterplot or boxplots or similar plots against main outcome of interest
# (4) any other exploration steps that may be useful
# for each variable, the EDA steps will be labeled by the numbers listed above


# load the required packages for this script
library(here) #to set paths
library(summarytools) #to create overall dataframe summary
library(ggplot2) #to create figures
library(car) #to create QQ plots
library(table1) #to create tables for summary statistics / other numerical outputs
library(scales) #to calculate percents
library(dplyr) #for piping
library(magrittr) # for sequential piping


# formatting for script to avoid scientific notation output
options(scipen=999)

# globally set theme for ggplots
theme_set(theme_classic())

###############################

# path to data
# note the use of the here() package and not absolute paths
data_location <- here::here("data","processed_data","processeddata.rds")

# load data using the "ReadRDS" function in base R.
processeddata <- base::readRDS(data_location)

# create a mirror dataset to avoid manipulating the cleaned dataset
EDAdata <- processeddata

###############################

# summarize data to see list of variables and types
# I like to use the summary tools package for this as it gives a good understanding across the data frame
summarytools::dfSummary(EDAdata)

# looking at the data summary, there are multiple variables for the same symptom (e.g. category and presence)
# additionally, several of categorical variables have an uneven proportion distribution
# the body temperature variable also looks like it may have some skew

# since our outcome variables have been preemptively specified, what predictor variables may be relevant?
# the data is about influenza, so certainly symptoms commonly associated with influenza
# runny nose, pharyngitis, nasal congestion, chills / sweating, and myalgia
# one of the outcomes of interest is nausea, and it often presents with nausea and vomiting

###############################

# start with main continuous outcome of interest: body temperature
# (1) since it is continuous, we can calculate summary statistics with the base summary function
base::summary(EDAdata$BodyTemp)

# (2) create a density plot for body temperature
ggplot2::ggplot(data = EDAdata, aes(x = BodyTemp)) +
  geom_density()

# looking at the histogram and summary statistics, there appears to be a left skew from a normal distribution
# (3) create a boxplot to better visualize
# since body temperature is the main outcome of interest, no need to plot it against anything
ggplot2::ggplot(data = EDAdata, aes(y = BodyTemp)) +
  geom_boxplot()
# there is clearly a skew in the data towards normal body temperature (98.6F)
# choosing to keep the points in the 101 - 103 F range as these are clinically reasonable values for influenza patients
# in other words, they are unlikely to be clinically  significant outliers

# it is still worth examining the normality assumption, especially since we are moving to linear model fitting next
# (4) create a QQ-plot for body temperature
car::qqPlot(EDAdata$BodyTemp)
# this clearly shows the body temperature data violates the normality assumption for linear models

###############################

# now move onto main categorical outcome of interest: nausea
# before any analysis, create a label for nausea so outputs are more interpretable
EDAdata$Nausea <- base::factor(processeddata$Nausea, levels = c("No", "Yes"), labels = c("Nausea Absent", "Nausea Present"))

# (1) since it is categorical, we can only examine frequency and proportions of the variable
# this can be done with the summary tools package function "freq" and options to hide NAs (removed during processing)
summarytools::freq(EDAdata$Nausea, report.nas = FALSE)

# (2) skip as nausea is not a continuous variable

# (3) as this is a main outcome of interest, we can only create a bar plot in ggplot to illustrate distribution
# the two geom_text statements tell ggplot to calculate and display count and percentages at the top of each bar
ggplot2::ggplot(data = EDAdata, aes(x = Nausea)) +
  geom_bar() +
  geom_text(
    aes(label = after_stat(count)),
    stat = 'count',
    nudge_x = -0.06,
    nudge_y = 0.2,
    vjust = -1) +
  geom_text(
    aes(label = after_stat(scales::percent(prop, prefix = "(", suffix = "%)", accuracy = 0.1)), group = 1),
    stat = 'count',
    nudge_x = 0.06,
    nudge_y = 0.2,
    vjust = -1)
# it is almost a 2/3 vs 1/3 split for nausea in patients captured in this dataset
# there isn't much more descriptive work we can do here

###############################
# moving onto predictor variables
# start with runny nose
# (1) since it is categorical, we can only examine frequency and proportions of the variable
# this can be done with the summary tools package function "freq" and options to hide NAs (removed during processing)
summarytools::freq(EDAdata$RunnyNose, report.nas = FALSE)
# almost 3/4 of the patients captured in the dataset had a runny nose

# (2) skip as runny nose is not a continuous variable

# (3) examine graphical relationship with outcomes
# start with body temperature (i.e. create a box plot)
# include a jitter function to have a better idea of number of measurements and distribution
ggplot2::ggplot(data = EDAdata, aes(x = RunnyNose, y = BodyTemp)) +
  geom_boxplot() +
  geom_jitter(alpha = 0.5, width = 0.2, height = 0.2, color = "tomato")
# looking at this graph, it appears that patients with runny nose are  potentially less likely to have a fever
# but this requires further analysis

# (3) now with nausea
# first create a table output of runny nose by nausea
# we can do this using the table 1 package
table1::label(EDAdata$RunnyNose) <- "Runny Nose"
table1::table1(~ RunnyNose | Nausea, data = EDAdata)

# since both are categorical variables, we can use a stacked bar plot to understand the distribution of runny nose within nausea symptoms
# to be able to include the percentages within each group, we will to calculate percentages before creating a graph
# first need to define a sequential piping operator so the function knows to use objects defined in the operation
`%s>%` <- magrittr::pipe_eager_lexical

# the first part of this piping operation calculates the counts and percentages within the Nausea grouping
# the second part plots it using the ggplot2 package
# trying to visualize the proportion of runny nose patients report outcome of interest (nausea)
# spacing on the labels isn't ideal, so would need to adjust for an actual manuscript
EDAdata %s>%
  dplyr::group_by(RunnyNose, Nausea) %s>%
  dplyr::summarise(count_Nausea = n()) %s>%
  dplyr::group_by(RunnyNose) %s>%
  dplyr::mutate(count_RunnyNose = sum(count_Nausea)) %s>%
  dplyr::mutate(pct = count_Nausea / count_RunnyNose) %s>% {
    ggplot2::ggplot(., aes(x = RunnyNose,
                           y = count_Nausea,
                           fill = Nausea)) +
      ggplot2::geom_bar(
        position = "stack",
        stat = "identity") +
      ggplot2::geom_text(
        aes(label = count_Nausea),
        .,
        stat = 'identity',
        size = 4,
        position = position_stack(vjust = 0.7, reverse = FALSE)) +
      ggplot2::geom_text(
        aes(label = scales::percent(pct)),
        .,
        stat = 'identity',
        size = 4,
        position = position_stack(vjust = 0.5, reverse = FALSE)) +
      ggplot2::labs(.,
                    title = "Frequency of Nausea among Runny Nose Patients",
                    x = "Runny Nose?",
                    y = "Frequency of Nausea")
  }
# looking at the results of this graph, it seems that the distribution of the nausea outcome isn't affected by the presence of a runny nose

###############################
# nasal congestion
# (1) since it is categorical, we can only examine frequency and proportions of the variable
# this can be done with the summary tools package function "freq" and options to hide NAs (removed during processing)
summarytools::freq(EDAdata$NasalCongestion, report.nas = FALSE)
# more than 3/4 of the patients captured in the dataset had nasal congestion

# (2) skip as nasal congestion is not a continuous variable

# (3) examine graphical relationship with outcomes
# start with body temperature (i.e. create a box plot)
# include a jitter function to have a better idea of number of measurements and distribution
ggplot2::ggplot(data = EDAdata, aes(x = NasalCongestion, y = BodyTemp)) +
  geom_boxplot() +
  geom_jitter(alpha = 0.5, width = 0.2, height = 0.2, color = "tomato")
# looking at this graph, hard to tell potential difference
# likely due to totals in each group (yes = 563, no = 167)

# (3) now with nausea
# first create a table output of nasal congestion by nausea
# we can do this using the table 1 package
table1::label(EDAdata$NasalCongestion) <- "Nasal Congestion"
table1::table1(~ NasalCongestion | Nausea, data = EDAdata)

# since both are categorical variables, we can use a stacked bar plot to understand the distribution of nausea and nasal congestion symptoms
# to be able to include the percentages within each group, we will to calculate percentages before creating a graph
# first need to define a sequential piping operator so the function knows to use objects defined in the operation
`%s>%` <- magrittr::pipe_eager_lexical

# the first part of this piping operation calculates the counts and percentages within the Nausea grouping
# the second part plots it using the ggplot2 package
# trying to visualize the proportion of nasal congestion patients report outcome of interest (nausea)
# spacing on the labels isn't ideal, so would need to adjust for an actual manuscript
EDAdata %s>%
  dplyr::group_by(NasalCongestion, Nausea) %s>%
  dplyr::summarise(count_Nausea = n()) %s>%
  dplyr::group_by(NasalCongestion) %s>%
  dplyr::mutate(count_NasalCongestion = sum(count_Nausea)) %s>%
  dplyr::mutate(pct = count_Nausea / count_NasalCongestion) %s>% {
    ggplot2::ggplot(., aes(x = NasalCongestion,
                           y = count_Nausea,
                           fill = Nausea)) +
      ggplot2::geom_bar(
        position = "stack",
        stat = "identity") +
      ggplot2::geom_text(
        aes(label = count_Nausea),
        .,
        stat = 'identity',
        size = 4,
        position = position_stack(vjust = 0.7, reverse = FALSE)) +
      ggplot2::geom_text(
        aes(label = scales::percent(pct)),
        .,
        stat = 'identity',
        size = 4,
        position = position_stack(vjust = 0.5, reverse = FALSE)) +
      ggplot2::labs(.,
                    title = "Frequency of Nausea among Nasal Congestion Patients",
                    x = "Nasal Congestion?",
                    y = "Frequency of Nausea")
  }
# looking at the results of this graph, potentially more likely to have nausea without nasal congestion

###############################
# pharyngitis
# (1) since it is categorical, we can only examine frequency and proportions of the variable
# this can be done with the summary tools package function "freq" and options to hide NAs (removed during processing)
summarytools::freq(EDAdata$Pharyngitis, report.nas = FALSE)
# more than 80% of patients captured in this dataset have pharyngitis

# (2) skip as phyarngitis is not a continuous variable

# (3) examine graphical relationship with outcomes
# start with body temperature (i.e. create a box plot)
# include a jitter function to have a better idea of number of measurements and distribution
ggplot2::ggplot(data = EDAdata, aes(x = Pharyngitis, y = BodyTemp)) +
  geom_boxplot() +
  geom_jitter(alpha = 0.5, width = 0.2, height = 0.2, color = "tomato")
# looking at this graph, hard to tell potential difference
# likely due to totals in each group (yes = 611, no = 119)

# (3) now with nausea
# first create a table output of Pharyngitis by nausea
# we can do this using the table 1 package
table1::label(EDAdata$Pharyngitis) <- "Pharyngitis"
table1::table1(~ Pharyngitis | Nausea, data = EDAdata)

# since both are categorical variables, we can use a stacked bar plot to understand the distribution of nausea and Pharyngitis
# to be able to include the percentages within each group, we will to calculate percentages before creating a graph
# first need to define a sequential piping operator so the function knows to use objects defined in the operation
`%s>%` <- magrittr::pipe_eager_lexical

# the first part of this piping operation calculates the counts and percentages within the Nausea grouping
# the second part plots it using the ggplot2 package
# trying to visualize the proportion of Pharyngitis patients report outcome of interest (nausea)
# spacing on the labels isn't ideal, so would need to adjust for an actual manuscript
EDAdata %s>%
  dplyr::group_by(Pharyngitis, Nausea) %s>%
  dplyr::summarise(count_Nausea = n()) %s>%
  dplyr::group_by(Pharyngitis) %s>%
  dplyr::mutate(count_Pharyngitis = sum(count_Nausea)) %s>%
  dplyr::mutate(pct = count_Nausea / count_Pharyngitis) %s>% {
    ggplot2::ggplot(., aes(x = Pharyngitis,
                           y = count_Nausea,
                           fill = Nausea)) +
      ggplot2::geom_bar(
        position = "stack",
        stat = "identity") +
      ggplot2::geom_text(
        aes(label = count_Nausea),
        .,
        stat = 'identity',
        size = 4,
        position = position_stack(vjust = 0.7, reverse = FALSE)) +
      ggplot2::geom_text(
        aes(label = scales::percent(pct)),
        .,
        stat = 'identity',
        size = 4,
        position = position_stack(vjust = 0.5, reverse = FALSE)) +
      ggplot2::labs(.,
                    title = "Frequency of Nausea among Pharyngitis Patients",
                    x = "Pharyngitis?",
                    y = "Frequency of Nausea")
  }
# looking at the results of this graph, hard to see any real difference

###############################
# chills / sweating
# (1) since it is categorical, we can only examine frequency and proportions of the variable
# this can be done with the summary tools package function "freq" and options to hide NAs (removed during processing)
summarytools::freq(EDAdata$ChillsSweats, report.nas = FALSE)
# more than 80% of patients captured in this dataset have chills

# (2) skip as chills is not a continuous variable

# (3) examine graphical relationship with outcomes
# start with body temperature (i.e. create a box plot)
# include a jitter function to have a better idea of number of measurements and distribution
ggplot2::ggplot(data = EDAdata, aes(x = ChillsSweats, y = BodyTemp)) +
  geom_boxplot() +
  geom_jitter(alpha = 0.5, width = 0.2, height = 0.2, color = "tomato")
# more chills / sweats reported with higher body temperature
# this difference makes sense as chills / sweats are often the result of a fever

# (3) now with nausea
# first create a table output of chills by nausea
# we can do this using the table 1 package
table1::label(EDAdata$ChillsSweats) <- "ChillsSweats"
table1::table1(~ ChillsSweats | Nausea, data = EDAdata)

# since both are categorical variables, we can use a stacked bar plot to understand the distribution of nausea and chills
# to be able to include the percentages within each group, we will to calculate percentages before creating a graph
# first need to define a sequential piping operator so the function knows to use objects defined in the operation
`%s>%` <- magrittr::pipe_eager_lexical

# the first part of this piping operation calculates the counts and percentages within the Nausea grouping
# the second part plots it using the ggplot2 package
# trying to visualize the proportion of chills patients report outcome of interest (nausea)
# spacing on the labels isn't ideal, so would need to adjust for an actual manuscript
EDAdata %s>%
  dplyr::group_by(ChillsSweats, Nausea) %s>%
  dplyr::summarise(count_Nausea = n()) %s>%
  dplyr::group_by(ChillsSweats) %s>%
  dplyr::mutate(count_ChillsSweats = sum(count_Nausea)) %s>%
  dplyr::mutate(pct = count_Nausea / count_ChillsSweats) %s>% {
    ggplot2::ggplot(., aes(x = ChillsSweats,
                           y = count_Nausea,
                           fill = Nausea)) +
      ggplot2::geom_bar(
        position = "stack",
        stat = "identity") +
      ggplot2::geom_text(
        aes(label = count_Nausea),
        .,
        stat = 'identity',
        size = 4,
        position = position_stack(vjust = 0.7, reverse = FALSE)) +
      ggplot2::geom_text(
        aes(label = scales::percent(pct)),
        .,
        stat = 'identity',
        size = 4,
        position = position_stack(vjust = 0.5, reverse = FALSE)) +
      ggplot2::labs(.,
                    title = "Frequency of Nausea among Chills / Sweats",
                    x = "Chills or Sweats?",
                    y = "Frequency of Nausea")
  }
# looking at the results of this graph, potentially more nausea with chills / sweats
# requires further analysis to determine significance

###############################
# now examine myalgia
# there are multiple variables for myalgia, but we can focus on the one that gives a severity scale of myalgia

# (1) since it is categorical, we can only examine frequency and proportions of the variable
# this can be done with the summary tools package function "freq" and options to hide NAs (removed during processing)
summarytools::freq(EDAdata$Myalgia, report.nas = FALSE)
# nearly half of the patients in the dataset reported moderate myalgia
# approximately 3/4 of the patients in the dataset reported mild or moderate myalgia

# (2) skip as myalgia is not a continuous variable

# (3) examine graphical relationship with outcomes
# start with body temperature (i.e. create a box plot)
# include a jitter function to have a better idea of number of measurements and distribution
ggplot2::ggplot(data = EDAdata, aes(x = Myalgia, y = BodyTemp)) +
  geom_boxplot() +
  geom_jitter(alpha = 0.5, width = 0.2, height = 0.2, color = "tomato")
# looking at this graph, it appears that patients with no myalgia were less likely to have a fever
# it doesn't appear to have a great variation among the severity of myalgia symptoms
# but this requires further analysis

# (3) now with nausea
# first create a table output of runny nose by nausea
# we can do this using the table 1 package
table1::label(EDAdata$Myalgia) <- "Myalgia"
table1::table1(~ Myalgia | Nausea, data = EDAdata)

# since both are categorical variables, we can use a stacked bar plot to understand the distribution of nausea within myalgia symptoms
# to be able to include the percentages within each group, we will to calculate percentages before creating a graph
# first need to define a sequential piping operator so the function knows to use objects defined in the operation
`%s>%` <- magrittr::pipe_eager_lexical

# the first part of this piping operation calculates the counts and percentages within the Nausea grouping
# the second part plots it using the ggplot2 package
# trying to visualize the proportion of myalgia patients report outcome of interest (nausea)
# spacing on the labels isn't ideal, so would need to adjust for an actual manuscript
EDAdata %s>%
  dplyr::group_by(Myalgia, Nausea) %s>%
  dplyr::summarise(count_Nausea = n()) %s>%
  dplyr::group_by(Myalgia) %s>%
  dplyr::mutate(count_Myalgia = sum(count_Nausea)) %s>%
  dplyr::mutate(pct = count_Nausea / count_Myalgia) %s>% {
    ggplot2::ggplot(., aes(x = Myalgia,
                           y = count_Nausea,
                           fill = Nausea)) +
      ggplot2::geom_bar(
        position = "stack",
        stat = "identity") +
      ggplot2::geom_text(
        aes(label = count_Nausea),
        .,
        stat = 'identity',
        size = 4,
        position = position_stack(vjust = 0.7, reverse = FALSE)) +
      ggplot2::geom_text(
        aes(label = scales::percent(pct)),
        .,
        stat = 'identity',
        size = 4,
        position = position_stack(vjust = 0.5, reverse = FALSE)) +
      ggplot2::labs(.,
                    title = "Frequency of Nausea among Myalgia Severity",
                    x = "Myalgia Severity",
                    y = "Frequency of Nausea")
  }
# looking at the results of this graph, it seems that increasing myalgia severity is associated with decreased nausea
# this makes sense clinically
# need further evaluation for significance

###############################
# diarrhea
# (1) since it is categorical, we can only examine frequency and proportions of the variable
# this can be done with the summary tools package function "freq" and options to hide NAs (removed during processing)
summarytools::freq(EDAdata$Diarrhea, report.nas = FALSE)
# more than 80% of patients captured in this dataset have Diarrhea

# (2) skip as Diarrhea is not a continuous variable

# (3) examine graphical relationship with outcomes
# start with body temperature (i.e. create a box plot)
# include a jitter function to have a better idea of number of measurements and distribution
ggplot2::ggplot(data = EDAdata, aes(x = Diarrhea, y = BodyTemp)) +
  geom_boxplot() +
  geom_jitter(alpha = 0.5, width = 0.2, height = 0.2, color = "tomato")
# no clear difference in body temperature

# (3) now with nausea
# first create a table output of Diarrhea by nausea
# we can do this using the table 1 package
table1::label(EDAdata$Diarrhea) <- "Diarrhea"
table1::table1(~ Diarrhea | Nausea, data = EDAdata)

# since both are categorical variables, we can use a stacked bar plot to understand the distribution of nausea and Diarrhea
# to be able to include the percentages within each group, we will to calculate percentages before creating a graph
# first need to define a sequential piping operator so the function knows to use objects defined in the operation
`%s>%` <- magrittr::pipe_eager_lexical

# the first part of this piping operation calculates the counts and percentages within the Nausea grouping
# the second part plots it using the ggplot2 package
# trying to visualize the proportion of Diarrhea patients report outcome of interest (nausea)
# spacing on the labels isn't ideal, so would need to adjust for an actual manuscript
EDAdata %s>%
  dplyr::group_by(Diarrhea, Nausea) %s>%
  dplyr::summarise(count_Nausea = n()) %s>%
  dplyr::group_by(Diarrhea) %s>%
  dplyr::mutate(count_Diarrhea = sum(count_Nausea)) %s>%
  dplyr::mutate(pct = count_Nausea / count_Diarrhea) %s>% {
    ggplot2::ggplot(., aes(x = Diarrhea,
                           y = count_Nausea,
                           fill = Nausea)) +
      ggplot2::geom_bar(
        position = "stack",
        stat = "identity") +
      ggplot2::geom_text(
        aes(label = count_Nausea),
        .,
        stat = 'identity',
        size = 4,
        position = position_stack(vjust = 0.7, reverse = FALSE)) +
      ggplot2::geom_text(
        aes(label = scales::percent(pct)),
        .,
        stat = 'identity',
        size = 4,
        position = position_stack(vjust = 0.5, reverse = FALSE)) +
      ggplot2::labs(.,
                    title = "Frequency of Nausea among Diarrhea",
                    x = "Diarrhea?",
                    y = "Frequency of Nausea")
  }
# based on the results, it appears that more patients with diarrhea had nausea
# this makes sense clinically as nausea and diarrhea often co-present

###############################
# vomit
# (1) since it is categorical, we can only examine frequency and proportions of the variable
# this can be done with the summary tools package function "freq" and options to hide NAs (removed during processing)
summarytools::freq(EDAdata$Vomit, report.nas = FALSE)
# more than 80% of patients captured in this dataset report vomiting

# (2) skip as Vomit is not a continuous variable

# (3) examine graphical relationship with outcomes
# start with body temperature (i.e. create a box plot)
# include a jitter function to have a better idea of number of measurements and distribution
ggplot2::ggplot(data = EDAdata, aes(x = Vomit, y = BodyTemp)) +
  geom_boxplot() +
  geom_jitter(alpha = 0.5, width = 0.2, height = 0.2, color = "tomato")
# most obviously far fewer patients reporting vomiting
# but, potentially associated with an increased body temperature

# (3) now with nausea
# first create a table output of Vomit by nausea
# we can do this using the table 1 package
table1::label(EDAdata$Vomit) <- "Vomit"
table1::table1(~ Vomit | Nausea, data = EDAdata)

# since both are categorical variables, we can use a stacked bar plot to understand the distribution of nausea and vomiting
# to be able to include the percentages within each group, we will to calculate percentages before creating a graph
# first need to define a sequential piping operator so the function knows to use objects defined in the operation
`%s>%` <- magrittr::pipe_eager_lexical

# the first part of this piping operation calculates the counts and percentages within the Nausea grouping
# the second part plots it using the ggplot2 package
# trying to visualize the proportion of vomiting patients report outcome of interest (nausea)
# spacing on the labels isn't ideal, so would need to adjust for an actual manuscript
EDAdata %s>%
  dplyr::group_by(Vomit, Nausea) %s>%
  dplyr::summarise(count_Nausea = n()) %s>%
  dplyr::group_by(Vomit) %s>%
  dplyr::mutate(count_Vomit = sum(count_Nausea)) %s>%
  dplyr::mutate(pct = count_Nausea / count_Vomit) %s>% {
    ggplot2::ggplot(., aes(x = Vomit,
                           y = count_Nausea,
                           fill = Nausea)) +
      ggplot2::geom_bar(
        position = "stack",
        stat = "identity") +
      ggplot2::geom_text(
        aes(label = count_Nausea),
        .,
        stat = 'identity',
        size = 4,
        position = position_stack(vjust = 0.7, reverse = FALSE)) +
      ggplot2::geom_text(
        aes(label = scales::percent(pct)),
        .,
        stat = 'identity',
        size = 4,
        position = position_stack(vjust = 0.5, reverse = FALSE)) +
      ggplot2::labs(.,
                    title = "Frequency of Nausea among Vomiting",
                    x = "Vomiting?",
                    y = "Frequency of Nausea")
  }
# based on the results, it appears that more patients with vomiting had nausea
# this makes sense clinically as nausea and vomiting often co-present

###############################
# creating "Table 1" for the categorical outcome (nausea)
# often the first table of a manuscript lists the predictors on each row with columns representing the outcome in question
# we can use this using the "Table 1" package in R, which easily generates summary
# statistics and places them into a well-formatted table.

# first, create the summary statistics within the Table1 package for predictor variables
# already created earlier, but placed here for reference
table1::label(EDAdata$RunnyNose) <- "Runny Nose"
table1::label(EDAdata$Pharyngitis) <- "Pharyngitis"
table1::label(EDAdata$NasalCongestion) <- "Nasal Congestion"
table1::label(EDAdata$CoughIntensity) <- "Cough Intensity"
table1::label(EDAdata$ChillsSweats) <- "Chills / Sweating"
table1::label(EDAdata$Myalgia) <- "Myalgia"
table1::label(EDAdata$Vomit) <- "Vomit"
table1::label(EDAdata$Diarrhea) <- "Diarrhea"

# now, load all into a table 1 where columns represent nausea categories
table1::table1(~ RunnyNose + Pharyngitis + NasalCongestion + CoughIntensity + ChillsSweats + Myalgia + Vomit + Diarrhea 
               | Nausea, data = EDAdata)

# in a real analysis, we could also use this table for our univariate analysis, so we could conduct a chi-square test
# to test for differences in each variable across the Nausea strata.

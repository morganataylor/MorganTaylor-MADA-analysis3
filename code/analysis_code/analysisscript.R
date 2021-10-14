######################################
#Analysis Script
######################################

#this script loads the processed, cleaned data, does some model fitting
#and saves the results to the results folder

#load needed packages. make sure they are installed.
library(here) #for data loading/saving
library(summarytools) #to create overall dataframe summary
library(ggplot2) #for data visualization and plotting
library(tidymodels) #for the tidymodels suite
library(broom.mixed) #for converting bayesian models to tidy tibbles
library(broom) #for visualizing regression results
library(dotwhisker) # for visualizing regression results
library(gtsummary) #for converting regression results to table
library(modelsummary) #to compare results of models
library(car) #for anova 

######################################
#Overall Model Fitting Strategy
######################################
#as this is an exercise for the UGA MADA 2021 course, there are 7 steps for this code to include:
#(1) Load cleaned data
#(2) Fit a linear model to the continuous outcome using only main predictor of interest
#(3) Fit another linear model to the continuous outcome using all (important) predictors of interest
#(4) Compare model results for models created in steps (2) and (3)
#(5) Fit a logistic model to the categorical outcome using only the main predictor of interest
#(6) Fit another logistic model to the categorical outcome using all (important) predictors of interest
#(7) Compare model results for models created in steps (5) and (6)

#for this analysis, the following definitions exist:
# main predictor of interest = RunnyNose
# continuous outcome of interest = BodyTemp
# categorical outcome of interest = Nausea

#whichever outcome is not currently fitted should be considered a predictor of interest
#all variables will be included (even when there are multiple variables for the same symptom)

#most of the code for this script comes from the TidyModels' "Build a Model" tutorial
#link: https://www.tidymodels.org/start/models/

######################################
#(1) Loading Data
######################################
#path to data
#note the use of the here() package and not absolute paths
data_location <- here::here("data","processed_data","processeddata.rds")

#load data. 
mydata <- readRDS(data_location)

######################################
#Exploring Data
######################################
#a more robust exploratory data analysis is located in the 'exploration.R' script
#but for reference, look at the dataframe summary
summarytools::dfSummary(mydata)

######################################
#(2) Linear Model for BodyTemp with Runny Nose
######################################
#the first linear model to create is a simple one using the continuous outcome of interest (BodyTemp) and main predictor of interest (RunnyNose)
#using the parsnip package, specify the functional form of the model (linear regression) and method for fitting the model, aka engine ("lm")
#save the model object as lm_mod
lm_mod <-
  parsnip::linear_reg() %>%
  parsnip::set_engine("lm")

#now estimate the model using the fit function
lm_fit1 <- lm_mod %>%
              fit(BodyTemp ~ RunnyNose, data = mydata)

#summarize linear model
broom.mixed::tidy(lm_fit1)
#The intercept estimate (no runny nose) is 99.1F, which would make these patients febrile
#Interpretation of slope estimate: Patients with a runny nose on average have a 0.293F lower body temperature than patients without a runny nose.

#box and whisker plot for lm_fit1 output
broom.mixed::tidy(lm_fit1) %>%
  dotwhisker::dwplot(dot_args = list(size = 2, color = "blue"),
                     whisker_args = list(color = "blue"),
                     vline = geom_vline(xintercept = 0, colour = "grey50", linetype = 2))
#doesn't really mean anything since we only have one category

#use the glance function to examine goodness of fit measures
glance(lm_fit1)
#extremely low R^2, high AIC, BIC

######################################
#(3) Linear Model for BodyTemp with all predictors
######################################
#the second linear model to create includes all variables in the dataset as predictors with the main outcome of interest as BodyTemp
#we can use the same lm_mod function, so no need to respecify

#create model including all predictors (defined using the . instead of specifying all variable names)
#doesn't include interaction terms
lm_fit2 <- lm_mod %>%
              fit(BodyTemp ~ ., data = mydata)

#summarize linear model
print(broom.mixed::tidy(lm_fit2), n = 38)
#the NA lines are where all patients are reporting the symptom (so no comparison possibility)

#export results into a table using the gtsummary package
gtsummary::tbl_regression(lm_fit2)
#significant predictors at alpha = 0.05: Sneeze, SubjectiveFever, & Pharyngitis 

#box and whisker plot for lm_fit2 output
broom.mixed::tidy(lm_fit2) %>%
  dotwhisker::dwplot(dot_args = list(size = 2, color = "blue"),
                     whisker_args = list(color = "blue"),
                     vline = geom_vline(xintercept = 0, colour = "grey50", linetype = 2))
#there's a lot of information here, but hard to identify the ones that are significant due to volume

#box and whisker plot for lm_fit2 significant predictors
#first filter significant results
lm_fit2_sig <- broom.mixed::tidy(lm_fit2) %>%
                  dplyr::filter(p.value < 0.05)

#box and whisker plot for lm_fit2 significant predictors
lm_fit2_sig %>%
  dotwhisker::dwplot(dot_args = list(size = 2, color = "blue"),
                     whisker_args = list(color = "blue"),
                     vline = geom_vline(xintercept = 0, colour = "grey50", linetype = 2))

#use the glance function to examine goodness of fit measures
glance(lm_fit2)
#in comparison to lm_fit1, increased R^2, slightly lower AIC, BIC
#need the formal comparison to better understand

######################################
#(4) Compare the results of models in steps (2) and (3)
######################################
#combine results of the two models into one table
lm_models <- list(lm_fit1, lm_fit2)
modelsummary::modelsummary(lm_models)
#the significance of the runny nose estimate decreases, the runny nose Beta estimate gets closer to zero
#in comparison to lm_fit1, lm_fit2 has increased R^2, slightly lower AIC, BIC, log likelihood

#conduct an ANOVA to compare the two linear regression models
car::Anova(lm_fit1$fit, lm_fit2$fit)
#based on the p-value from the ANOVA, we can conclude the more complex model better describes the data than the SLR
#this is also supported by the comparison of AIC and BIC above

######################################
#Saving Results
######################################

# save fit results table  
table_file = here("results", "resulttable.rds")
saveRDS(lmtable, file = table_file)

#save figure
figure_file = here("results","resultfigure.png")
ggsave(filename = figure_file, plot=p1)   
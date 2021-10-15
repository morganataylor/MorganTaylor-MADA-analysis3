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
library(flextable) #for exporting tables

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
lm_fit1_summary <- broom.mixed::tidy(lm_fit1)
lm_fit1_summary
#The intercept estimate (no runny nose) is 99.1F, which would make these patients febrile
#Interpretation of slope estimate: Patients with a runny nose on average have a 0.293F lower body temperature than patients without a runny nose.

#box and whisker plot for lm_fit1 output
lm_fit1_bp <- broom.mixed::tidy(lm_fit1) %>%
                dotwhisker::dwplot(dot_args = list(size = 2, color = "blue"),
                                   whisker_args = list(color = "blue"),
                                   vline = geom_vline(xintercept = 0, colour = "grey50", linetype = 2))
lm_fit1_bp
#shows us the estimate is significant (i.e. doesn't cross the null hypothesis)
#runny nose is a protective factor against increased body temperature

#use the glance function to examine goodness of fit measures
lm_fit1_gf <- modelsummary::glance(lm_fit1)
lm_fit1_gf
#extremely low R^2, high AIC, BIC

#save results from this model
# save fit results table  
lm_fit1_sum = here("results", "lm_fit1_sumtable.rds")
saveRDS(lm_fit1_summary, file = lm_fit1_sum)

#save box whisker plot
lm_fit1_bwplot = here("results","lm_fit1_plot.png")
ggsave(filename = lm_fit1_bwplot, plot = lm_fit1_bp) 

#save goodness of fit results
lm_fit1_gof = here("results", "lm_fit1_gftable.rds")
saveRDS(lm_fit1_gf, file = lm_fit1_gof)

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
#add print function to show all rows
lm_fit2_summary <- print(broom.mixed::tidy(lm_fit2), n = 38)
lm_fit2_summary
#the NA lines are where all patients are reporting the symptom (so no comparison possibility)

#export results into a table using the gtsummary package
gtsummary::tbl_regression(lm_fit2)
#significant predictors at alpha = 0.05: Sneeze, SubjectiveFever, & Pharyngitis 

#box and whisker plot for lm_fit2 output
lm_fit2_bp1 <- broom.mixed::tidy(lm_fit2) %>%
                dotwhisker::dwplot(dot_args = list(size = 2, color = "blue"),
                                   whisker_args = list(color = "blue"),
                                   vline = geom_vline(xintercept = 0, colour = "grey50", linetype = 2))
lm_fit2_bp1
#there's a lot of information here, but hard to identify the ones that are significant due to volume

#box and whisker plot for lm_fit2 significant predictors
#first filter significant results
lm_fit2_sig <- broom.mixed::tidy(lm_fit2) %>%
                  dplyr::filter(p.value < 0.05)

#box and whisker plot for lm_fit2 significant predictors
lm_fit2_bp2 <- lm_fit2_sig %>%
                  dotwhisker::dwplot(dot_args = list(size = 2, color = "blue"),
                                     whisker_args = list(color = "blue"),
                                     vline = geom_vline(xintercept = 0, colour = "grey50", linetype = 2))
lm_fit2_bp2

#use the glance function to examine goodness of fit measures
lm_fit2_gf <- modelsummary::glance(lm_fit2)
lm_fit2_gf
#in comparison to lm_fit1, increased R^2, slightly lower AIC, BIC
#need the formal comparison to better understand

#save results from this model
# save fit results table  
lm_fit2_sum = here("results", "lm_fit2_sumtable.rds")
saveRDS(lm_fit2_summary, file = lm_fit2_sum)

#don't have permission to export the gtsummary table on UGA computer
#manually export for report?

#save first box whisker plot
lm_fit2_bwplot1 = here("results","lm_fit2_plot1.png")
ggsave(filename = lm_fit2_bwplot1, plot = lm_fit2_bp1) 

#save second box whisker plot
lm_fit2_bwplot2 = here("results","lm_fit2_plot2.png")
ggsave(filename = lm_fit2_bwplot2, plot = lm_fit2_bp2)

#save goodness of fit results
lm_fit2_gof = here("results", "lm_fit2_gftable.rds")
saveRDS(lm_fit2_gf, file = lm_fit2_gof)

######################################
#(4) Compare the results of models in steps (2) and (3)
######################################
#combine results of the two models into one table
#create a list of the two models
lm_models <- list(lm_fit1, lm_fit2)

#define path for saving
#don't have permission to save it as png on a UGA computer
lm_models_comp = here("results", "lm_models_comparison.docx")

#using the model summary package
#list estimate, 95% confidence intervals, and highlight ones with significant p-values
#hide intercept estimate
modelsummary::modelsummary(lm_models, 
                           stars = TRUE, 
                           fmt = '%.3f',
                           estimate  = "{estimate} [{conf.low}, {conf.high}] {stars}",
                           statistic = NULL,
                           coef_omit = "Intercept",
                           output = lm_models_comp)
#the significance of the runny nose estimate decreases, the runny nose Beta estimate gets closer to zero
#in comparison to lm_fit1, lm_fit2 has increased R^2, slightly lower AIC, BIC, log likelihood

#conduct an ANOVA to compare the two linear regression models
lm_anova <- anova(lm_fit1$fit, lm_fit2$fit, test = "Chisq")
lm_anova
#based on the p-value from the ANOVA, we can conclude the more complex model better describes the data than the SLR
#this is also supported by the comparison of AIC and BIC above

#save results from anova
lm_anova_comp = here("results", "lm_anova_comparison.rds")
saveRDS(lm_anova, file = lm_anova_comp)
######################################
#(5) Logistic model for Nausea with Runny Nose
######################################
#the next model to create is a simple one using the categorical outcome of interest (Nausea) and main predictor of interest (RunnyNose)
#using the parsnip package, specify the functional form of the model (logistic regression) and method for fitting the model, aka engine ("glm")
#save the model object as log_mod
log_mod <-
  parsnip::logistic_reg() %>%
  parsnip::set_engine("glm")

#now estimate the model using the fit function
log_fit1 <- log_mod %>%
  fit(Nausea ~ RunnyNose, data = mydata)

#summarize logistic model with the tidy function
#exponentiate estimates to make them interpretable ORs
log_fit1_summary <- broom.mixed::tidy(log_fit1, exponentiate = TRUE)
log_fit1_summary
#Not a significant result (p > 0.05)

#box and whisker plot for log_fit1 output
log_fit1_bp <- broom.mixed::tidy(log_fit1) %>%
                dotwhisker::dwplot(dot_args = list(size = 2, color = "blue"),
                                   whisker_args = list(color = "blue"),
                                   vline = geom_vline(xintercept = 0, colour = "grey50", linetype = 2))
log_fit1_bp
#doesn't really mean anything since we only have one category beyond not significant results

#use the glance function to examine goodness of fit measures
log_fit1_gf <-modelsummary::glance(log_fit1)
log_fit1_gf 
#lower AIC, BIC, loglikelihood than linear model
#not a direct comparison but still an interesting result

#save results from this model
# save fit results table  
log_fit1_sum = here("results", "log_fit1_sumtable.rds")
saveRDS(log_fit1_summary, file = log_fit1_sum)

#save box whisker plot
log_fit1_bwplot = here("results","log_fit1_plot.png")
ggsave(filename = log_fit1_bwplot, plot = log_fit1_bp) 

#save goodness of fit results
log_fit1_gof = here("results", "log_fit1_gftable.rds")
saveRDS(log_fit1_gf, file = log_fit1_gof)

######################################
#(6) Logistic model for Nausea with all predictors
######################################
#the second logistic model to create includes all variables in the dataset as predictors with the main outcome of interest as Nausea
#we can use the same log_mod function, so no need to respecify

#create model including all predictors (defined using the . instead of specifying all variable names)
#doesn't include interaction terms
log_fit2 <- log_mod %>%
  fit(Nausea ~ ., data = mydata)

#summarize logistic model with the tidy function
#exponentiate estimates to make them interpretable ORs
#adding the print function to see all rows
log_fit2_summary <- print(broom.mixed::tidy(log_fit2, exponentiate = TRUE), n = 38)
log_fit2_summary
#the NA lines are where all patients are reporting the symptom (so no comparison possibility)

#export results into a table using the gtsummary package
log_fit2_gtsummary <- gtsummary::tbl_regression(log_fit2, exponentiate = TRUE)
log_fit2_gtsummary
#significant predictors at alpha = 0.05: AbPain, Diarrhea, Breathless, ToothPn, Vomit
#Vomit and Diarrhea makes sense as they often co-present with nausea
#tooth pain, abdominal pain, and breathlessness are interesting results

#box and whisker plot for log_fit2 output
log_fit2_bp1 <- broom.mixed::tidy(log_fit2) %>%
                  dotwhisker::dwplot(dot_args = list(size = 2, color = "blue"),
                                     whisker_args = list(color = "blue"),
                                     vline = geom_vline(xintercept = 0, colour = "grey50", linetype = 2))
log_fit2_bp1
#there's a lot of information here, but hard to identify the ones that are significant due to volume

#box and whisker plot for log_fit2 significant predictors
#first filter significant results
log_fit2_sig <- broom.mixed::tidy(log_fit2) %>%
  dplyr::filter(p.value < 0.05)

#box and whisker plot for log_fit2 significant predictors
log_fit2_bp2 <- log_fit2_sig %>%
                  dotwhisker::dwplot(dot_args = list(size = 2, color = "blue"),
                                     whisker_args = list(color = "blue"),
                                     vline = geom_vline(xintercept = 0, colour = "grey50", linetype = 2))
log_fit2_bp2
#all significant predictors increase odds of having nausea
#makes sense vomit and diarrhea have the highest OR

#use the glance function to examine goodness of fit measures
log_fit2_gf <- modelsummary::glance(log_fit2)
log_fit2_gf
#in comparison to log_fit1, lower log likelihood, AIC, BIC, deviance
#need the formal comparison to better understand

#save results from this model
# save fit results table  
log_fit2_sum = here("results", "log_fit2_sumtable.rds")
saveRDS(log_fit2_summary, file = log_fit2_sum)

#don't have permission to export the gtsummary table on UGA computer
#manually export for report?

#save first box whisker plot
log_fit2_bwplot1 = here("results","log_fit2_plot1.png")
ggsave(filename = log_fit2_bwplot1, plot = log_fit2_bp1) 

#save second box whisker plot
log_fit2_bwplot2 = here("results","log_fit2_plot2.png")
ggsave(filename = log_fit2_bwplot2, plot = log_fit2_bp2)

#save goodness of fit results
log_fit2_gof = here("results", "log_fit2_gftable.rds")
saveRDS(log_fit2_gf, file = log_fit2_gof)

######################################
#(7) Compare the results of models in steps (5) and (6)
######################################
#combine results of the two models into one table
log_models <- list(log_fit1, log_fit2)

#define path for saving
#don't have permission to save it as png on a UGA computer
log_models_comp = here("results", "log_models_comparison.docx")

#list estimate, 95% confidence intervals, and highlight ones with significant p-values
#hide intercept estimate
modelsummary::modelsummary(log_models, 
                           stars = TRUE, 
                           fmt = '%.3f', 
                           exponentiate = TRUE,
                           estimate  = "{estimate} [{conf.low}, {conf.high}] {stars}",
                           statistic = NULL,
                           coef_omit = "Intercept",
                           output = log_models_comp)
#runny nose is not a significant predictor in either model
#in comparison to log_fit1, log_fit2 has a slightly lower AIC and log likelihood, but higher BIC

#conduct an ANOVA to compare the two linear regression models
log_anova <- anova(log_fit1$fit, log_fit2$fit, test = "Chisq")
log_anova
#based on the p-value from the ANOVA, we can conclude the more complex model better describes the data than the simple logistic regression
#this is also supported by the comparison of measures above
#however, the higher BIC suggests the significance noted may be a result from the number of parameters included in the model

#save results from anova
log_anova_comp = here("results", "log_anova_comparison.rds")
saveRDS(log_anova, file = log_anova_comp)
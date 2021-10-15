THe 'processing_code' folder contains an R script that loads, cleans, and exports the processed data.

The 'analysis_code' folder contains two R scripts. 'exploration.R' conducts a brief exploratory data analysis, and 'analysisscript.R' loads the processed data and fits various models.


Further details:
processingscript.R
* this script loads the raw data and cleans/processes it
* removes all variables that contain: Score, Total, FluA, FluB, Dxname, Activity
* removes Unique.Visit variable


exploration.R
* this script loads the processed data and conducts exploratory data analysis (EDA)
* main continuous outcome = body temperature
* main categorical outcome = nausea
* for each symptom, the exploration script will do the following:
 (1) produce and print some numerical output (e.g. table, summary statistics)
 (2) create histogram or density plot (continuous variables only)
 (3) scatterplot or boxplots or similar plots against main outcome of interest
 (4) any other exploration steps that may be useful


analysisscript.R
* this script loads the processed data and fits a few sample models
* main predictor of interest = RunnyNose
* continuous outcome of interest = BodyTemp
* categorical outcome of interest = Nausea
* seven total parts
 (1) Load cleaned data
 (2) Fit a linear model to the continuous outcome using only main predictor of interest
 (3) Fit another linear model to the continuous outcome using all (important) predictors of interest
 (4) Compare model results for models created in steps (2) and (3)
 (5) Fit a logistic model to the categorical outcome using only the main predictor of interest
 (6) Fit another logistic model to the categorical outcome using all (important) predictors of interest
 (7) Compare model results for models created in steps (5) and (6)

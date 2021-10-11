###############################
# exploration script

# this script loads the processed data and conducts exploratory data analysis (EDA)


# main continuous outcome of interest: body temperature
# main categorical outcome of interest: nausea 
# goal: are other symptoms correlated with those outcomes?

# other symptoms that we will consider:

# for each symptom, the exploration script will do the following:
# produce and print some numerical output (e.g. table, summary statistics)
# create histogram or density plot (continuous variables only)
# scatterplot against main outcome of interest
# any other exploration steps that may be useful


# load the required packages for this script
library(here) #to set paths
library(vtable) #to create summary tables

# formatting for script to avoid scientific notation output
options(scipen=999)

# path to data
# note the use of the here() package and not absolute paths
data_location <- here::here("data","processed_data","processeddata.rds")

# load data using the "ReadRDS" function in base R.
processeddata <- base::readRDS(data_location)

# summarize data to see list of variables and types
base::summary(processeddata)

# start with main continuous outcome of interest: body temperature
# since it is continuous, we can calculate summary statistics
vtable::st(processeddata)


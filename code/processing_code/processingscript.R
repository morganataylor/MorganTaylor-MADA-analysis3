###############################
# processing script
#
#this script loads the raw data, processes and cleans it 
#and saves it as Rds file in the processed_data folder


#the raw data for this exercise comes from the following citation:
#McKay, Brian et al. (2020), Virulence-mediated infectiousness and activity trade-offs 
#and their impact on transmission potential of patients infected with influenza, Dryad, Dataset,
#https://doi.org/10.5061/dryad.51c59zw4v

#load needed packages. make sure they are installed.
library(here) #to set paths
library(dplyr) #for data processing

#path to data
#note the use of the here() package and not absolute paths
data_location <- here::here("data","raw_data","SympAct_Any_Pos.Rda")

#load data. 
#because the data is in an .Rda format, we can use the "ReadRDS" function in base R.
#the typical "load" function does not work (data is RDS not RDA)
rawdata <- base::readRDS(data_location)

#take a look at the data
dplyr::glimpse(rawdata)

#based on the assignment directions, the first step is to remove all variables that have "Score"
#or "Total" or "FluA" or "FluB" or "Dxname" or "Activity" in the name as well as "Unique.Visit"
#this can be accomplished using the select function in dplyr / tidyverse

#while we could pipe this into one operation, separating each line makes de-bugging issues easier

#remove variables containing "Score"
data1 <- rawdata %>% select(-contains("Score"))

#remove variables containing "Total"
data2 <- data1 %>% select(-contains("Total"))

#remove variables containing "FluA"
data3 <- data2 %>% select(-contains("FluA"))

#remove variables containing "FluB"
data4 <- data3 %>% select(-contains("FluB"))

#remove variables containing "Dxname"
data5 <- data4 %>% select(-contains("Dxname"))

#remove variables containing "Activity"
data6 <- data5 %>% select(-contains("Activity"))

#remove variable "Unique.Visit"
data7 <- data6 %>% select(-contains("Unique.Visit"))

#check to make sure we have the correct columns remaining
dplyr::glimpse(data7)
utils::summary(data7)

#last step is to remove any NA observations
processed_data <- stats::na.omit(data7)

#processed_data has 730 observations and 32 variables, which is our goal.
#now we can save the data

# location to save file
save_data_location <- here::here("data","processed_data","processeddata.rds")

# save data as RDS
saveRDS(processed_data, file = save_data_location)



#Task 1 
library(tidyverse)
# Read the CSV file, ensuring Longitude and Latitude are character types
crimes <- read_csv("C:\\Users\\Sona\\Documents\\Sem 2\\Intro to Data Science\\Assignment5-\\data\\crimes-reduced.csv", col_types = cols(
                   Longitude = col_character(),
                   Latitude = col_character()
))
# Replace whitespaces with underscores and convert to lowercase in variable names
library(stringr)
names(crimes) <- names(crimes)%>% 
  str_replace_all("\\s", "_") %>%
  str_to_lower()

#Task2 
crimes <- crimes %>% 
  filter(primary_type == "HOMICIDE")
filter(crimes, !is.na(longitude) & !is.na(latitude))
library(dplyr)
library(lubridate)
rm (crimes1)
crimes$date <- mdy(crimes$date)
crimes <- crimes %>%
  filter(date >= today() - years(10))

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
filter(crimes, !is.na(longitude), !is.na(latitude))
library(dplyr)
library(lubridate)
crimes$date <- mdy_hms(crimes$date)
crimes <- crimes %>%
filter(date>= Sys.Date() - years(10) & date<= Sys.Date())
table(year(crimes$date))
min(crimes$date)

#Task 3
library(sf)
crimes_sf <- st_as_sf(crimes, coords = c("longitude", "latitude"), crs = 4326)
library(ggplot2)
crimes_sf %>%
  ggplot()+
  geom_sf(data = crimes_sf, aes(color = arrest))+
  scale_color_manual(values = c("FALSE" = "blue", "TRUE" = "red"), name = "arrest") +
  labs(title = "Crime Map")+
  theme_minimal()

#Task 4
chicago_shape <- st_read("C:\\Users\\Sona\\Documents\\Sem 2\\Intro to Data Science\\Assignment5-\\data\\Boundaries - Census Tracts - 2010") %>%
  select(geoid10, geometry)
crimescensus <- st_join(crimes_sf, chicago_shape)  
head(crimescensus)
chicago_merged_agg <- crimescensus %>% 
  group_by(geoid10) %>% 
  summarize(
    homicides = sum(primary_type == "HOMICIDE", na.rm = TRUE),
    arrests = sum(arrest == TRUE, na.rm = TRUE),
    total_crimes = n()
  ) %>% 
  mutate(
    arrest_rate = (arrests/homicides)*100
  ) %>% 
  ungroup()
chicagomergedwithgeom <- st_join(chicago_merged_agg, crimescensus, join = st_intersects, left = TRUE)
select(chicagomergedwithgeom,id, date, primary_type, arrest, x_coordinate, y_coordinate)
# Plot the map showing count of homicides by census tract
ggplot() +
  geom_sf(data = chicagomergedwithgeom, aes(fill = homicides), color = "black") +
  scale_fill_gradient(name = "Homicides", low = "lightblue", high = "darkblue") +
  labs(title = "Count of Homicides by Census Tract") +
  theme_minimal()
# Plot the map showing arrest rate for homicides by census tract
ggplot() +
  geom_sf(data = chicagomergedwithgeom, aes(fill = arrest_rate), color = "black") +
  scale_fill_gradient(name = "Arrest Rate (%)", low = "lightgreen", high = "darkgreen") +
  labs(title = "Arrest Rate for Homicides by Census Tract") +
  theme_minimal()


#Task 5
install.packages("tidycensus")
library(tidycensus)
census_api_key("7b8c369df1da95704806ec474103c9a1509935ef", install = TRUE)
#5.1 

choropleth_map <- function(year, variable_code, variable_name, state_fips, county_fips) {
  # Query census data
  census_data <- get_acs(
    geography = "tract",
    variables = variable_code,
    year = year,
    state = state_fips,
    county = county_fips,
    geometry = TRUE
  )
  map <- ggplot(census_data) +
    geom_sf(aes(fill = estimate), color = "black") +
    scale_fill_viridis_c(name = variable_name) +  
    labs(title = paste(variable_name, "by Census Tract"),
         caption = "Source: US Census Bureau") +
    theme_minimal()
  
  return(map)
}
choropleth_map(year = 2020,
                      variable_code = "B19013_001",
                      variable_name = "Median Household Income",
                      state_fips = "17",
                      county_fips = "031")
#5.2
library(stringr)

# Define a function to create a map based on a demographic variable and a geographic level
create_demographic_map <- function(variable, geographic_level, state, county, title_prefix) {
  # Load data from the ACS using tidycensus
  map_data <- get_acs(
    geography = geographic_level,
    variables = variable,
    state = state,
    county = county,
    geometry = TRUE,
    year = 2022,
    survey = "acs5"
  )
  
  # Use stringr to parse the NAME column and create a title
  map_data <- map_data %>%
    mutate(Title = str_c(title_prefix, " by Tract in ", str_extract(NAME, "^(.*?),")))
  
  
  # Create the map with ggplot2
  ggplot(map_data) +
    geom_sf(aes(fill = estimate), color = NA) +
    scale_fill_viridis_c(option = "C") +
    labs(title = unique(map_data$Title), fill = title_prefix) +
    theme_void()
}
map_for_bachelors <- create_demographic_map(
  variable = "B15003_022E",
  geographic_level = "tract",
  state = "DC",
  county = "District of Columbia",
  title_prefix = "Population With Bachelor's Degree"
)

map_for_poverty <- create_demographic_map(
  variable = "B17001_002E",
  geographic_level = "tract",
  state = "NY",
  county = "New York",
  title_prefix = "Population Below Poverty Level"
)

# Print the maps
print(map_for_bachelors)
print(map_for_poverty)

#5.3
save_map_image <- function(map_plot, title_prefix, state, base_image_directory, subfolder) {
  image_directory <- file.path(base_image_directory, subfolder)
  if (!dir.exists(image_directory)) {
    dir.create(image_directory, recursive = TRUE)
  }
  file_name <- paste0(title_prefix, " in ", state, ".png")
  file_path <- file.path(image_directory, file_name)
  
  # Save the image
  ggsave(file_path, map_plot, device = "png", width = 10, height = 8, units = "in")
}
save_map_image(
  map_plot = map_for_bachelors,
  title_prefix = "Population With Bachelor's Degree",
  state = "DC",
  base_image_directory = "images",
  subfolder = "Assignment5-"
)

save_map_image(
  map_plot = map_for_poverty,
  title_prefix = "Population Below Poverty Level",
  state = "NY",
  base_image_directory = "images",
  subfolder = "Assignment5-"
)

#5.4 
library(tidycensus)
library(ggplot2)
library(purrr)
library(dplyr)
library(stringr)
census_api_key("7b8c369df1da95704806ec474103c9a1509935ef")
create_demographic_map1 <- function(year, variable, state, county, geographic_level, title_prefix, base_image_directory, specific_folder) {
  census_data <- get_acs(
    geography = geographic_level,
    variables = variable,
    year = year,
    state = state,
    county = county,
    geometry = TRUE
  )
  map <- ggplot(census_data) +
    geom_sf(aes(fill = estimate), color = "black") +
    scale_fill_viridis_c() +  
    labs(title = paste(title_prefix, "by Census Tract", sep=" "),
         caption = "Source: US Census Bureau") +
    theme_minimal()
  image_directory <- file.path(base_image_directory, specific_folder)
  if (!dir.exists(image_directory)) {
    dir.create(image_directory, recursive = TRUE)
  }
  file_name <- paste0(title_prefix, " in ", state, " ", year, ".png")
  file_path <- file.path(image_directory, file_name)
  ggsave(file_path, map, device = "png", width = 10, height = 8, units = "in")
}
combinations <- tibble(
  year = c(2019, 2019, 2020, 2020, 2021),
  variable = c("B01003_001E", "B02001_002E", "B01003_001E", "B02001_002E", "B01003_001E"),
  state = c("NY", "NY", "CA", "CA", "TX"),
  county = c("New York", "New York", "Los Angeles", "Los Angeles", "Travis"),
  geographic_level = "tract",
  title_prefix = c("Total Population", "Population White Alone", "Total Population", "Population White Alone", "Total Population"),
  base_image_directory = rep("images", 5),
  specific_folder = rep("Assignment5-", 5)
)

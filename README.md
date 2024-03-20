# Assignment5-
##Title: Assignment5 , Author: Sona Sarin

## Brief Overview 
The following assignment is centered around the use of API's and geospatial analysis. It is focused on creating a detailed report on the geographic distribution of crime in Chicago, with a particular emphasis on homicides.  In this codes we engage with data loading and cleaning, geospatial analysis, and API interaction to analyze and visualize crime data in Chicago, specifically focusing on homicides within the last ten years. The process begins with importing and standardizing a dataset on Chicago crimes, followed by filtering to include only recent homicides with valid geolocations. These data points are then converted into spatial geometries, facilitating their plotting on a map. Further, we perform a spatial join with census tract data to aggregate crime statistics, enabling the creation of choropleth maps that highlight homicide counts and arrest rates by area. The final component introduces you to automated data retrieval through APIs, where we write a function for querying the U.S. Census Bureau and generating maps based on different demographic parameters. This is achieved by iterating over various combinations of years, variables, and locations using the purrr package, illustrating the power of programmable report generation and geospatial visualization in public policy analysis.

##Files in your Repository 
1. Read ME file - It has a description of the code and the files present in the code 
2. .gitignore file - The data files that should not be pushed to GIT repository 
3. Index.qmd and Index.html - The html file of the code chunks available 
4. Images - The images that were created through the code 
5. A5 - The R script with the codes 

##Steps to Replicate Analysis 
1. Create a Git Repository 
2. Clone your repository into the terminal of R studio. Make sure you are cloning it in the desired file path 
3. Load the data files into a folder called data in the folder that was cloned 
4. Push your .gitignore file by putting the desired data that you want git to ignore 
5. Create a quarto document with the appropriate YAML header and push it to git 
6. Set your API Key 
7. Install the following packages - tidyverse, sf, tidycensus, purr, stringr, dyplr, ggplot 

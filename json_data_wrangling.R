#This code takes JSON data from APIs broadcasting available scooters' locations
#and stores it to a CSV

#Load packages
library(pacman)

p_load(jsonlite, dplyr, readr)

#Bring in raw JSON data and reformat it to tibbles
bird_current <- fromJSON('./bird_current.json')
bird_current <- bird_current$data$bikes %>% #Unnest the data frame
    mutate(company_name = "Bird",
           time = Sys.time()) %>% 
    select(company_name, bike_id, lat, lon, vehicle_type, is_reserved, 
           is_disabled, time)

helbiz_current <- fromJSON('./helbiz_current.json')
helbiz_current <- helbiz_current$data$bikes %>%  #Unnest the data frame
    mutate(company_name = "Helbiz",
           time = Sys.time()) %>% 
    select(company_name, bike_id, lat, lon, vehicle_type, is_reserved, 
           is_disabled, time)

lime_current <- fromJSON('./lime_current.json')
lime_current <- lime_current$data$bikes %>%  #Unnest the data frame
    mutate(company_name = "Lime",
           time = Sys.time()) %>% 
    select(company_name, bike_id, lat, lon, vehicle_type, is_reserved, 
           is_disabled, time)

lyft_current <- fromJSON('./lyft_current.json')
lyft_current <- lyft_current$data$bikes %>% #Unnest the data frame
    rename(vehicle_type = type) %>% #Standardize column naming
    mutate(company_name = "Lyft",
           time = Sys.time()) %>% 
    select(company_name, bike_id, lat, lon, vehicle_type, is_reserved, 
           is_disabled, time)

spin_current <- fromJSON('./spin_current.json')
spin_current <- spin_current$data$bikes %>% #Unnest the data frame
    mutate(company_name = "Spin",
           vehicle_type = "scooter",
           time = Sys.time()) %>% 
    select(company_name, bike_id, lat, lon, vehicle_type, is_reserved, 
           is_disabled, time)

#Combine the data into a single dataframe
scooters <- bind_rows(bird_current,
                      helbiz_current,
                      lime_current,
                      lyft_current,
                      spin_current)

#If first iteration, initialize main file
if (file.exists("./scooters_main.csv") == FALSE) {
    scooters %>% 
        write_csv(file = "./scooters_main.csv")
} else {
    #If the file already exists, save it to a dataframe and append it to the
    #new one
    old_df <- read_csv("./scooters_main.csv")
    new_df <- bind_rows(old_df, scooters)
    
    #Deduplicate new entries
    new_df <- new_df %>% 
        distinct(across(.cols = 1:7), .keep_all = TRUE)
    
    #Save the new datframe to a csv
    new_df %>% 
        write_csv(file = "./scooters_main.csv")
}


# Libraries ---------------------------------------------------------------

  library(haven)  # for stata
  library(dplyr)  # for %>% 

  library(rvest)  # read website

# Define path -------------------------------------------------------------

  # define file path
  current_script_path <- dirname(rstudioapi::getActiveDocumentContext()$path)
  parent_folder_path <- file.path(current_script_path, "..")
  data_folder_path <- file.path(parent_folder_path, "data")
  Berkely_Earth_path <- file.path(data_folder_path, "Berkeley Earth")
  Berkely_Earth_Country_path <- file.path(Berkely_Earth_path, "country-by-country")
  Berkeley_Earth_Global_path <- file.path(Berkely_Earth_path, "global")


  # Create a new folder
  DTA_folder_path <- file.path(Berkely_Earth_path, "country-by-country-DTA")
  if (!dir.exists(DTA_folder_path)) {
    dir.create(DTA_folder_path)
  }
  
  global_DTA_folder_path <- file.path(Berkely_Earth_path, "global-DTA")
  if (!dir.exists(global_DTA_folder_path)) {
    dir.create(global_DTA_folder_path)
  }
  
  


# Country Data ------------------------------------------------------------
## Define the files to work on ---------------------------------------------

  # Define column names (use later)
  column_names <- c("Year", "Month", "Anomaly", "Uncertainty", 
                    "Annual_Anomaly", "Annual_Uncertainty", 
                    "FiveYear_Anomaly", "FiveYear_Uncertainty",
                    "TenYear_Anomaly", "TenYear_Uncertainty", 
                    "TwentyYear_Anomaly", "TwentyYear_Uncertainty")
  
  # Extract country names from TXT files in the folder
  txt_files <- list.files(Berkely_Earth_Country_path, pattern = "-TAVG-Trend\\.txt$", full.names = FALSE)
  country_name_list <- gsub("-TAVG-Trend\\.txt$", "", txt_files)
  


## ISO3 extraction ---------------------------------------------------------

  ## Extract the table (assume it's the first table on the page)
  ISO3url <- "https://www.iban.com/country-codes"
  webpage <- read_html(ISO3url)
  
  ISO3 <- webpage %>%
    html_table(fill = TRUE) %>%
    .[[1]] # Extract the first table as a data frame

  ## Clean column names
  colnames(ISO3) <- c("Country_Name", "ISO2", "ISO3", "Num")
  
  
  ## Change names of the ISO country_name so that it can match with the file names
  {
    ### change the format to file-name format
    ISO3 <- ISO3 %>%
      mutate(Country_Name = tolower(gsub(" ", "-", Country_Name)))
    
    
    ### Find mismatched country names
    list_1 <- setdiff(country_name_list, ISO3$Country_Name) # In country_name_list but not in ISO3
    list_2 <- setdiff(ISO3$Country_Name, country_name_list) # In ISO3 but not in country_name_list
    
    max_length <- max(length(list_1), length(list_2))       # Ensure equal length by padding with NA
    list_1 <- c(list_1, rep(NA, max_length - length(list_1)))
    list_2 <- c(list_2, rep(NA, max_length - length(list_2)))
    
    ### Create a data frame for the unmatched country-names (just to make comparison easier)
    unmatched_countries <- data.frame(
      In_Country_List_Not_In_ISO3 = list_1,
      In_ISO3_Not_In_Country_List = list_2
    )
    
    rm(list_1,list_2)
    
    
    ### Manually change the ISO3 name
    {
      ISO3 <- ISO3 %>%
        # the un-found ones
        mutate(
          Country_Name = case_when(
            Country_Name == "" ~ "baker-island",                                # 2, from "united-states-minor-outlying-islands-(the)"
            Country_Name == "" ~ "gaza-strip",                                  # 20
            Country_Name == "" ~ "kingman-reef",                                # 22, from "united-states-minor-outlying-islands-(the)"
            Country_Name == "" ~ "palmyra-atoll",                               # 32, from "united-states-minor-outlying-islands-(the)"
            
            TRUE ~ Country_Name                                                 # Keep other values unchanged
          )
        ) %>%
        
        # the found ones
        mutate(
          Country_Name = case_when(
            Country_Name == "bahamas-(the)" ~ "bahamas",                                   # 1
            Country_Name == "bolivia-(plurinational-state-of)" ~ "bolivia",               # 3
            Country_Name == "bonaire,-sint-eustatius-and-saba" ~ "bonaire,-saint-eustatius-and-saba", # 4
            Country_Name == "virgin-islands-(british)" ~ "british-virgin-islands",        # 5
            Country_Name == "myanmar" ~ "burma",                                         # 6
            Country_Name == "cabo-verde" ~ "cape-verde",                                 # 7
            Country_Name == "cayman-islands-(the)" ~ "cayman-islands",                   # 8
            Country_Name == "central-african-republic-(the)" ~ "central-african-republic", # 9
            Country_Name == "comoros-(the)" ~ "comoros",                                 # 10
            Country_Name == "congo-(the-democratic-republic-of-the)" ~ "congo-(democratic-republic-of-the)", # 11
            Country_Name == "congo-(the)" ~ "congo",                                     # 12
            Country_Name == "denmark" ~ "denmark-(europe)",                              # 13
            Country_Name == "dominican-republic-(the)" ~ "dominican-republic",           # 14
            Country_Name == "falkland-islands-(the)-[malvinas]" ~ "falkland-islands-(islas-malvinas)", # 15
            Country_Name == "faroe-islands-(the)" ~ "faroe-islands",                     # 16
            Country_Name == "micronesia-(federated-states-of)" ~ "federated-states-of-micronesia", # 17
            Country_Name == "france" ~ "france-(europe)",                                # 18
            Country_Name == "gambia-(the)" ~ "gambia",                                   # 19
            Country_Name == "iran-(islamic-republic-of)" ~ "iran",                       # 21
            Country_Name == "lao-people's-democratic-republic-(the)" ~ "laos",           # 23
            Country_Name == "macao" ~ "macau",                                           # 24
            Country_Name == "republic-of-north-macedonia" ~ "macedonia",                 # 25
            Country_Name == "moldova-(the-republic-of)" ~ "moldova",                     # 26
            Country_Name == "netherlands-(the)" ~ "netherlands-(europe)",                # 27
            Country_Name == "niger-(the)" ~ "niger",                                     # 28
            Country_Name == "korea-(the-democratic-people's-republic-of)" ~ "north-korea", # 29
            Country_Name == "northern-mariana-islands-(the)" ~ "northern-mariana-islands", # 30
            Country_Name == "palestine,-state-of" ~ "palestina",                         # 31
            Country_Name == "philippines-(the)" ~ "philippines",                         # 33
            Country_Name == "réunion" ~ "reunion",                                       # 34
            Country_Name == "russian-federation-(the)" ~ "russia",                       # 35
            Country_Name == "saint-martin-(french-part)" ~ "saint-martin",               # 36
            Country_Name == "sint-maarten-(dutch-part)" ~ "sint-maarten",                # 37
            Country_Name == "south-georgia-and-the-south-sandwich-islands" ~ "south-georgia-and-the-south-sandwich-isla", # 38
            Country_Name == "korea-(the-republic-of)" ~ "south-korea",                   # 39
            Country_Name == "sudan-(the)" ~ "sudan",                                     # 40
            Country_Name == "eswatini" ~ "swaziland",                                    # 41
            Country_Name == "syrian-arab-republic" ~ "syria",                            # 42
            Country_Name == "taiwan-(province-of-china)" ~ "taiwan",                     # 43
            Country_Name == "tanzania,-united-republic-of" ~ "tanzania",                 # 44
            Country_Name == "turks-and-caicos-islands-(the)" ~ "turks-and-caicas-islands", # 45
            Country_Name == "united-arab-emirates-(the)" ~ "united-arab-emirates",       # 46
            Country_Name == "united-kingdom-of-great-britain-and-northern-ireland-(the)" ~ "united-kingdom-(europe)", # 47
            Country_Name == "united-states-of-america-(the)" ~ "united-states",          # 48
            Country_Name == "venezuela-(bolivarian-republic-of)" ~ "venezuela",          # 49
            Country_Name == "viet-nam" ~ "vietnam",                                      # 50
            Country_Name == "virgin-islands-(u.s.)" ~ "virgin-islands",                  # 51
            
            TRUE ~ Country_Name                                                          # Keep other values unchanged
          )
        )
    }
    
  }
  
  


  
  ## Save as a new data frame or export to .dta
  write_dta(ISO3, file.path(data_folder_path, "ISO_Codes.dta"))
  
  

## TXT to DTA --------------------------------------------------------------
  
  ## delete names without ISO3
  names_to_remove <- c("baker-island", "gaza-strip", "kingman-reef", "palmyra-atoll")
  country_name_list <- setdiff(country_name_list, names_to_remove)
  
  
  for (countryname in country_name_list) {
    
    # Specify the file path in the parent folder
    file_path <- file.path(Berkely_Earth_Country_path, paste0(countryname, "-TAVG-Trend.txt"))
    
    # Read the text file into R
    lines <- readLines(file_path)
    
    # Filter out lines starting with '%'
    cleaned_lines <- lines[!grepl("^%", lines)]
    
    # Convert the remaining lines into a data frame (space-separated)
    data <- read.table(text = paste(cleaned_lines, collapse = "\n"), header = FALSE, na.strings = "NaN")
    
    # Data modification
    {
      # Assign column names
      colnames(data) <- column_names
      
      # Add country ISO3 column
      country_iso3 <- ISO3 %>%
        filter(Country_Name == countryname) %>%
        pull(ISO3)
      
      data <- data %>%
        mutate(ISO3 = country_iso3)
    }
    
    # Save to Stata's .dta format in the new folder
    output_file_path <- file.path(DTA_folder_path, paste0(countryname, "_TAVG_Trend.dta"))
    write_dta(data, output_file_path)
    
  }
  
  
  

# Global Data --------------------------------------------------------------
  
  ## Define files ---------------------------------------------------------
  
  # Define column names (use later)
  column_names_summ1750 <- c("Year",
                             "Annual_Anomaly", "Annual_Uncertainty", 
                             "FiveYear_Anomaly", "FiveYear_Uncertainty")
  column_names_summ1850 <- c("Year", 
                             "Annual_Anomaly_Air", "Annual_Uncertainty", 
                             "FiveYear_Anomaly", "FiveYear_Uncertainty",
                             "Annual_Anomaly_Water", "Annual_Uncertainty", 
                             "FiveYear_Anomaly", "FiveYear_Uncertainty")
  
  # Extract country names from TXT files in the folder
  summ1750_txt_files <- "Complete_TAVG_summary.txt"
  summ1850_txt_files <- "Land_and_Ocean_summary.txt"
  
  
  ## TXT to DTA --------------------------------------------------------------
  
  for (dataname in c("summ1750", "summ1850")) {
    
    # Specify the file path in the parent folder
    txtfile_name <- get(paste0(dataname, "_txt_files"))
    column_names <- get(paste0("column_names_", dataname))
    
    file_path <- file.path(Berkeley_Earth_Global_path, txtfile_name)
    
    # Read the text file into R
    lines <- readLines(file_path)
    
    # Filter out lines starting with '%'
    cleaned_lines <- lines[!grepl("^%", lines)]
    
    # Convert the remaining lines into a data frame (space-separated)
    data <- read.table(text = paste(cleaned_lines, collapse = "\n"), header = FALSE, na.strings = "NaN")
    
    # Assign column names
    colnames(data) <- column_names
    
    # Save to Stata's .dta format in the new folder
    output_file_path <- file.path(global_DTA_folder_path, paste0(dataname, ".dta"))
    write_dta(data, output_file_path)
    
  }
  
  

  
  
* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* MERGE FINAL DATASETS
*

* ==============================================================================
* MERGE IN ALL DATASETS WHILE CHECKING CONSISTENCY 
* ==============================================================================


global Rterm_path "/usr/local/bin/R"
global Rterm_options "--vanilla --slave"

* Send initial message
cap gmdslack, send("`c(username)': Starting Excel file creation with documentation sheet")

* Run R code with error handling
cap rsource, terminator(END)

# Detect username
user <- Sys.info()[["user"]]

if (user == "lehbib") {
  path <- "C:/Users/lehbib/Documents/Github/Global-Macro-Project"
} else if (user == "mohamedlehbib") {
  path <- "/Users/mohamedlehbib/Downloads/GitHub/Global-Macro-Database-Internal"
} else if (user == "kmueller") {
  path <- "C:/Users/kmueller/Desktop/GitHub/Global-Macro-Project"
} else if (user == "simonchen") {
  path <- "/Users/simonchen/Documents/GitHub/Global-Macro-Project"
} else if (user == "coden") {
  path <- "C:/Users/coden/OneDrive/Documents/GitHub/Global-Macro-Project"
} else if (user == "Kororinpa") {
  path <- "D:/Singapore Management University/Research assistant/NUS/Global-Macro-Project"
} else if (user == "yaqi") {
  path <- "D:/Dropbox/Yaqi_misc/GMP_LPs/github_repository/Global-Macro-Project"
} else {
  stop("Unknown user — please define path manually")
}

Sys.setenv(
  data_raw   = file.path(path, "data/raw"),
  data_clean = file.path(path, "data/clean"),
  data_final = file.path(path, "data/final"),
  data_distr = file.path(path, "data/distribute"),
  
  data_helper = file.path(path, "data/helpers"),
  data_temp   = file.path(path, "data/tempfiles"),
  
  code          = file.path(path, "code"),
  code_functions = file.path(path, "code/functions"),
  code_initialize = file.path(path, "code/initialize"),
  code_download  = file.path(path, "code/download"),
  code_clean     = file.path(path, "code/clean"),
  code_merge     = file.path(path, "code/merge"),
  code_combine   = file.path(path, "code/combine"),
  code_paper     = file.path(path, "code/paper"),
  code_doc       = file.path(path, "code/documentation"),
  
  doc     = file.path(path, "output/doc"),
  graphs  = file.path(path, "output/graphs"),
  tables  = file.path(path, "output/tables"),
  numbers = file.path(path, "output/numbers")
)

Sys.getenv("data_final")
Sys.getenv("data_distr")

# Fetch the latest version from the online versions.csv file
versions_url <- "https://raw.githubusercontent.com/KMueller-Lab/Global-Macro-Database/main/data/helpers/versions.csv"

tryCatch({
  versions_df <- read.csv(versions_url, stringsAsFactors = FALSE)
  # Get the last row (most recent version)
  current_version <- versions_df[nrow(versions_df), 1]
  message("Fetched latest version from GitHub: ", current_version)
}, error = function(e) {
  # Fallback to date-based version if online fetch fails
  warning("Could not fetch versions.csv from GitHub: ", e$message)
  warning("Falling back to date-based version calculation")
  today <- Sys.Date()
  current_year <- format(today, "%Y")
  current_month <- format(today, "%m")
  current_version <- paste0(current_year, "_", current_month)
})

# Extract year from version
current_year <- substr(current_version, 1, 4)

# Save as env var
Sys.setenv(current_version = current_version, current_year = current_year)

message("Current version: ", Sys.getenv("current_version"))

Sys.setenv(
  isomapping = file.path(Sys.getenv("data_helper"), "countrylist"),
  eur_fx     = file.path(Sys.getenv("data_helper"), "EUR_irrevocable_FX"),
  docvars    = file.path(Sys.getenv("data_helper"), "docvars.csv")
)

library(haven)
library(openxlsx)
library(tidyverse)

# Define functions first
make_documentation_sheet <- function(file_path) {
  # Load or create workbook
  wb <- if (file.exists(file_path)) loadWorkbook(file_path) else createWorkbook()
  
  # Collect current sheets (we'll exclude the doc sheet itself)
  current_sheets <- names(wb)
  
  # If a Documentation sheet already exists, remove it (we'll recreate it fresh)
  if ("Documentation" %in% current_sheets) {
    removeWorksheet(wb, "Documentation")
  }
  
  # Get the list of remaining sheets (excluding Documentation)
  sheet_list <- setdiff(names(wb), "Documentation")
  
  # Sort sheet list to have data_final first, then alphabetical
  if ("data_final" %in% sheet_list) {
    other_sheets <- setdiff(sheet_list, "data_final")
    sheet_list <- c("data_final", sort(other_sheets))
  } else {
    sheet_list <- sort(sheet_list)
  }
  
  # Define sheet definitions mapping
  sheet_definitions <- list(
    "data_final" = "Main dataset with all variables combined",
    "SovDebtCrisis" = "Sovereign Debt Crisis",
    "CurrencyCrisis" = "Currency Crisis",
    "BankingCrisis" = "Banking Crisis",
    "nGDP" = "Nominal Gross Domestic Product",
    "nGDP_USD" = "Nominal Gross Domestic Product in USD",
    "rGDP" = "Real Gross Domestic Product, in 2015 prices",
    "deflator" = "GDP deflator",
    "rGDP_pc" = "Real Gross Domestic Product per Capita",
    "rGDP_USD" = "Real Gross Domestic Product in USD",
    "inv" = "Total Investment",
    "inv_USD" = "Total Investment in USD",
    "inv_GDP" = "Total Investment as % of GDP",
    "finv" = "Fixed Investment",
    "finv_GDP" = "Fixed Investment as % of GDP",
    "cons" = "Total Consumption",
    "cons_USD" = "Total Consumption in USD",
    "cons_GDP" = "Total Consumption as % of GDP",
    "exports" = "Total Exports",
    "exports_USD" = "Total Exports in USD",
    "exports_GDP" = "Total Exports as % of GDP",
    "imports" = "Total Imports",
    "imports_USD" = "Total Imports in USD",
    "imports_GDP" = "Total Imports as % of GDP",
    "CA" = "Current Account Balance",
    "CA_GDP" = "Current Account Balance as % of GDP",
    "cgovexp" = "Central Government Expenditure",
    "cgovexp_GDP" = "Central Government Expenditure as % of GDP",
    "cgovrev" = "Central Government Revenue",
    "cgovrev_GDP" = "Central Government Revenue as % of GDP",
    "cgovtax" = "Central Government Tax Revenue",
    "cgovtax_GDP" = "Central Government Tax Revenue as % of GDP",
    "cgovdef" = "Central Government Deficit",
    "cgovdef_GDP" = "Central Government Deficit as % of GDP",
    "cgovdebt" = "Central Government Debt",
    "cgovdebt_GDP" = "Central Government Debt as % of GDP",
    "gen_govexp" = "General Government Expenditure",
    "gen_govexp_GDP" = "General Government Expenditure as % of GDP",
    "gen_govrev" = "General Government Revenue",
    "gen_govrev_GDP" = "General Government Revenue as % of GDP",
    "gen_govtax" = "General Government Tax Revenue",
    "gen_govtax_GDP" = "General Government Tax Revenue as % of GDP",
    "gen_govdef" = "General Government Deficit",
    "gen_govdef_GDP" = "General Government Deficit as % of GDP",
    "gen_govdebt" = "General Government Debt",
    "gen_govdebt_GDP" = "General Government Debt as % of GDP",
	"govexp_GDP" = "Combined Government Expenditure as % of GDP",
	"govrev_GDP" = "Combined Government Revenue as % of GDP",
	"govtax_GDP" = "Combined Government Tax Revenue as % of GDP",
	"govdef_GDP" = "Combined Government Deficit as % of GDP",
	"govdebt_GDP" = "Combined Government Debt as % of GDP",
	"govexp" = "Combined Government Expenditure",
	"govrev" = "Combined Government Revenue",
	"govtax" = "Combined Government Tax Revenue",
	"govdef" = "Combined Government Deficit",
	"govdebt" = "Combined Government Debt",
    "CPI" = "Consumer Price Index, 2010 = 100",
    "HPI" = "House Price Index",
    "infl" = "Inflation Rate",
    "pop" = "Population",
    "unemp" = "Unemployment Rate",
    "USDfx" = "Exchange Rate against USD",
    "REER" = "Real Effective Exchange Rate, 2010 = 100",
    "strate" = "Short-term Interest Rate",
    "ltrate" = "Long-term Interest Rate",
    "cbrate" = "Central Bank Policy Rate",
    "M0" = "M0 Money Supply",
    "M1" = "M1 Money Supply",
    "M2" = "M2 Money Supply",
    "M3" = "M3 Money Supply",
    "M4" = "M4 Money Supply"
  )
  
  # Add the Documentation sheet first
  addWorksheet(wb, "Documentation", gridLines = FALSE, tabColour = "#2F5597")
  
  # Header + styles
  title_style <- createStyle(
    fontSize = 14, textDecoration = "bold"
  )
  link_style <- createStyle(
    fontColour = "#0000FF", textDecoration = "underline", valign = "top"
  )
  header_style <- createStyle(
    textDecoration = "bold", halign = "left", fgFill = "#F2F2F2",
    border = "Bottom", borderColour = "#D9D9D9"
  )
  
  # Write a title and small instruction
  writeData(wb, "Documentation", "Workbook Documentation", startRow = 1, startCol = 1)
  addStyle(wb, "Documentation", title_style, rows = 1, cols = 1, gridExpand = TRUE)
  writeData(wb, "Documentation", "Click a sheet name to jump to that sheet.", startRow = 2, startCol = 1)
  
  # Table header
  writeData(wb, "Documentation", data.frame(Sheet = character(), Definition = character(), stringsAsFactors = FALSE),
            startRow = 4, startCol = 1, colNames = TRUE)
  addStyle(wb, "Documentation", header_style, rows = 4, cols = 1:2, gridExpand = TRUE)
  
  # Add one row per sheet with internal hyperlink and definition
  if (length(sheet_list) > 0) {
    rows <- seq_along(sheet_list) + 4  # start adding below the header
    for (i in seq_along(sheet_list)) {
      sh <- sheet_list[i]
      # Get definition for this sheet (or use sheet name if no definition found)
      definition <- if (sh %in% names(sheet_definitions)) {
        sheet_definitions[[sh]]
      } else {
        sh  # fallback to sheet name if no definition
      }
      
      # Create hyperlink formula using makeHyperlinkString
      hyperlink_formula <- makeHyperlinkString(sheet = sh, row = 1, col = 1, text = sh)
      # Write the hyperlink formula in column A
      writeFormula(wb, "Documentation", x = hyperlink_formula, startRow = rows[i], startCol = 1)
      # Make it blue + underlined like a link
      addStyle(wb, "Documentation", link_style, rows = rows[i], cols = 1, gridExpand = TRUE)
      
      # Write the definition in column B
      writeData(wb, "Documentation", definition, startRow = rows[i], startCol = 2, colNames = FALSE)
    }
  } else {
    writeData(wb, "Documentation", "No other sheets found.", startRow = 5, startCol = 1)
  }
  
  # Nice column widths and freeze header
  setColWidths(wb, "Documentation", cols = 1, widths = 30)  # Sheet name column
  setColWidths(wb, "Documentation", cols = 2, widths = 60)  # Definition column
  freezePane(wb, "Documentation", firstActiveRow = 5, firstActiveCol = 1)
  
  # Note: Documentation sheet will be added first by default when created
  
  # Save
  saveWorkbook(wb, file_path, overwrite = TRUE)
  
  cat("Documentation sheet created successfully!\n")
  cat("Sheets found:", paste(sheet_list, collapse = ", "), "\n")
}

move_sheet_to_first <- function(file_path, sheet_name) {
  wb <- loadWorkbook(file_path)
  sheet_names <- names(wb)
  
  # Find the sheet index
  sheet_index <- which(sheet_names == sheet_name)
  
  if (length(sheet_index) == 0) {
    stop(paste("Sheet", sheet_name, "not found!"))
  }
  
  # Create new order with specified sheet first
  other_indices <- setdiff(1:length(sheet_names), sheet_index)
  new_order <- c(sheet_index, other_indices)
  
  # Set the order and save
  worksheetOrder(wb) <- new_order
  saveWorkbook(wb, file_path, overwrite = TRUE)
  
  cat(paste("Sheet", sheet_name, "moved to first position!\n"))
}

# Environment variables (mirroring your Stata globals)
data_final_dir <- Sys.getenv("data_final")
data_distr_dir <- Sys.getenv("data_distr")
version        <- Sys.getenv("current_version")

if (data_final_dir == "" || data_distr_dir == "" || version == "") {
  stop("Please set env vars: data_final, data_distr, current_version.")
}

# ---- Get all CSV files for current version ----
csv_files <- list.files(data_distr_dir, pattern = paste0("_", version, "\\.csv$"), full.names = TRUE)
csv_basenames <- basename(csv_files)

# Filter out GMD_2025_09.csv (this is the main dataset, not a variable-specific CSV)
csv_files <- csv_files[!grepl("^GMD_", csv_basenames)]
csv_basenames <- basename(csv_files)

# Extract variable names from CSV filenames
varnames <- gsub(paste0("_", version, "\\.csv$"), "", csv_basenames)

# ---- Export data_final.dta to Excel (sheet 'data_final') ----
data_final_path <- file.path(data_final_dir, "data_final.dta")
if (!file.exists(data_final_path)) {
  error_msg <- sprintf("File not found: %s", data_final_path)
  writeLines(paste("ERROR:", error_msg), "excel_creation_status.txt")
  stop(error_msg)
}

tryCatch({
  df_final <- read_dta(data_final_path)
  message("Successfully loaded data_final.dta")
}, error = function(e) {
  error_msg <- paste("ERROR loading data_final.dta:", e$message)
  writeLines(error_msg, "excel_creation_status.txt")
  stop(e)
})

# Create a fresh workbook and write data_final
out_xlsx <- file.path(data_distr_dir, "GMD.xlsx")
tryCatch({
  wb <- createWorkbook()
  addWorksheet(wb, "data_final")
  writeData(wb, "data_final", df_final)
  saveWorkbook(wb, out_xlsx, overwrite = TRUE)
  message("Successfully created initial Excel workbook")
}, error = function(e) {
  error_msg <- paste("ERROR creating initial Excel workbook:", e$message)
  writeLines(error_msg, "excel_creation_status.txt")
  stop(e)
})

# ---- Loop through CSV files and add each as its own sheet ----
success_count <- 0

# Check if any CSV files were found for the current version
if (length(csv_files) == 0) {
  warning_msg <- sprintf("No CSV files found for version %s in %s", version, data_distr_dir)
  message(warning_msg)
  # List available versions for debugging
  all_csvs <- list.files(data_distr_dir, pattern = "\\.csv$", full.names = FALSE)
  if (length(all_csvs) > 0) {
    versions_found <- unique(gsub(".*_(\\d{4}_\\d{2})\\.csv$", "\\1", all_csvs))
    message(sprintf("Available versions: %s", paste(versions_found, collapse = ", ")))
  }
  stop(warning_msg)
}

for (i in seq_along(csv_files)) {
  v <- varnames[i]
  csv_path <- csv_files[i]
  
  message(sprintf("Processing %s...", v))
  
  tryCatch({
    # Import CSV
    df <- read_csv(csv_path, show_col_types = FALSE)
    
    # Sort by ISO3 and year if both columns exist
    if ("ISO3" %in% names(df) && "year" %in% names(df)) {
      df <- df[order(df$ISO3, df$year), ]
    }
    
    # Add worksheet
    addWorksheet(wb, v)
    writeData(wb, v, df)
    success_count <- success_count + 1
    message(" done")
  }, error = function(e) {
    error_msg <- sprintf("ERROR processing CSV file %s (%s): %s", v, csv_path, e$message)
    message(error_msg)
    writeLines(error_msg, "excel_creation_status.txt")
    stop(e)
  })
}

# Save the workbook with all sheets
tryCatch({
  saveWorkbook(wb, out_xlsx, overwrite = TRUE)
  message(sprintf("Completed! Successfully added %d CSV sheets to Excel file: %s", 
                  success_count, out_xlsx))
}, error = function(e) {
  error_msg <- paste("ERROR saving final Excel workbook:", e$message)
  writeLines(error_msg, "excel_creation_status.txt")
  stop(e)
})

# Verify the final result
tryCatch({
  final_wb <- loadWorkbook(out_xlsx)
  message(sprintf("Final Excel file contains %d sheets", length(names(final_wb))))
}, error = function(e) {
  error_msg <- paste("ERROR verifying final Excel file:", e$message)
  writeLines(error_msg, "excel_creation_status.txt")
  stop(e)
})

# Create documentation sheet and move it to first position
message("Creating documentation sheet...")
tryCatch({
  make_documentation_sheet(out_xlsx)
  message("Documentation sheet created successfully")
}, error = function(e) {
  message("ERROR creating documentation sheet: ", e$message)
  writeLines(paste("ERROR: Documentation sheet creation failed -", e$message), "excel_creation_status.txt")
  stop(e)
})

message("Moving documentation sheet to first position...")
tryCatch({
  move_sheet_to_first(out_xlsx, "Documentation")
  message("Documentation sheet moved to first position successfully")
}, error = function(e) {
  message("ERROR moving documentation sheet: ", e$message)
  writeLines(paste("ERROR: Documentation sheet positioning failed -", e$message), "excel_creation_status.txt")
  stop(e)
})

# Final verification
final_wb <- loadWorkbook(out_xlsx)
message(sprintf("Final Excel file with documentation contains %d sheets", length(names(final_wb))))
message(sprintf("First sheet: %s", names(final_wb)[1]))

# Create versioned copy (GMD_2025_12.xlsx)
versioned_xlsx <- file.path(data_distr_dir, paste0("GMD_", version, ".xlsx"))
tryCatch({
  file.copy(out_xlsx, versioned_xlsx, overwrite = TRUE)
  message(sprintf("Created versioned copy: %s", versioned_xlsx))
}, error = function(e) {
  warning(sprintf("Could not create versioned copy: %s", e$message))
})

# Write success indicator to a file that Stata can read
writeLines("SUCCESS", "excel_creation_status.txt")

END

* Check if R code completed successfully and handle errors
if _rc != 0 {
    cap gmdslack, send("`c(username)': ERROR in Excel creation - R code failed with return code `=_rc'")
    exit `=_rc'
}

* Check if R code completed successfully
cap confirm file "excel_creation_status.txt"
if _rc == 0 {
    file open fh using "excel_creation_status.txt", read text
    file read fh status
    file close fh
    cap erase "excel_creation_status.txt"
    
    if "`status'" == "SUCCESS" {
        cap gmdslack, send("`c(username)': Excel file creation completed successfully with documentation sheet")
    }
    else {
        cap gmdslack, send("`c(username)': ERROR in Excel creation - `status'")
    }
}
else {
    cap gmdslack, send("`c(username)': ERROR in Excel creation - R code failed to create status file (return code: `=_rc')")
}

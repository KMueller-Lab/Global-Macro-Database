* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* COMPREHENSIVE DATABASE ASSERTIONS
* 
* Description: 
* This Stata program performs comprehensive validation of the database update
* including file existence, data integrity, and documentation completeness.
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 
* 2025-09-27
*
* ==============================================================================

* ==============================================================================
* COMPREHENSIVE DATABASE VALIDATION
* ==============================================================================

cap program drop gmd_comprehensive_assertions
program define gmd_comprehensive_assertions

    
    * Initialize counters and error tracking
    local error_count = 0
    local warning_count = 0
    local success_count = 0
    
    * ==============================================================================
    * 1. VALIDATE MAIN DATABASE FILES EXIST
    * ==============================================================================
    
    di as result "1. Validating main database files..."
    
    * Check GMD files in distribute folder
    local main_files "GMD.dta GMD.csv GMD.xlsx"
    foreach file of local main_files {
        cap confirm file "$data_distr/`file'"
        if _rc != 0 {
            di as error "ERROR: Missing main file: `file'"
            local error_count = `error_count' + 1
        }
        else {
            di as result "✓ Found: `file'"
            local success_count = `success_count' + 1
        }
    }
    
    * Check versioned GMD files
    local versioned_files "GMD_$current_version.dta GMD_$current_version.csv GMD_$current_version.xlsx"
    foreach file of local versioned_files {
        cap confirm file "$data_distr/`file'"
        if _rc != 0 {
            di as error "ERROR: Missing versioned file: `file'"
            local error_count = `error_count' + 1
        }
        else {
            di as result "✓ Found: `file'"
            local success_count = `success_count' + 1
        }
    }
    
    * ==============================================================================
    * 2. VALIDATE COUNTRY DOCUMENTATION
    * ==============================================================================
    
    di as result "2. Validating country documentation..."
    
    * Get all countries from isomapping
    qui use "$data_final/data_final", clear
    qui levelsof ISO3, local(countries) clean
    local total_countries = r(r)
    
    local missing_country_docs = 0
    foreach country of local countries {
        cap confirm file "$doc/`country'.pdf"
        if _rc != 0 {
            di as error "ERROR: Missing country documentation: `country'.pdf"
            local missing_country_docs = `missing_country_docs' + 1
            local error_count = `error_count' + 1
        }
        else {
            local success_count = `success_count' + 1
        }
    }
    
    if `missing_country_docs' == 0 {
        di as result "All `total_countries' countries have PDF documentation"
    }
    else {
        di as error "ERROR: `missing_country_docs' countries missing PDF documentation"
    }
    
    * ==============================================================================
    * 3. VALIDATE VARIABLE DOCUMENTATION AND FILES
    * ==============================================================================
    
    di as result "3. Validating variable documentation and files..."
    
    * Get variables that should have documentation
    qui use "$data_helper/final_varlist", clear
    qui keep if documentation == "Yes"
    qui levelsof codes, local(documented_variables) clean
    local total_documented_vars = r(r)
    
    local missing_var_docs = 0
    local missing_var_csvs = 0
    local missing_var_dtas = 0
    
    foreach variable of local documented_variables {
        * Check PDF documentation
        cap confirm file "$doc/`variable'.pdf"
        if _rc != 0 {
            di as error "ERROR: Missing variable documentation: `variable'.pdf"
            local missing_var_docs = `missing_var_docs' + 1
            local error_count = `error_count' + 1
        }
        else {
            local success_count = `success_count' + 1
        }
        
        * Check CSV file with current version
        cap confirm file "$data_distr/`variable'_$current_version.csv"
        if _rc != 0 {
            di as error "Missing variable CSV: `variable'_$current_version.csv"
            local missing_var_csvs = `missing_var_csvs' + 1
            local error_count = `error_count' + 1
        }
        else {
            local success_count = `success_count' + 1
        }	
 
    }
	
	* Check that the EXCEL has all the sheets 
	clear 
	set obs 100
	gen codes = "" 
	tempfile temp
	save `temp', replace
	import excel using "$data_distr/GMD.xlsx", describe
	
	local number_sheets = `r(N_worksheet)'
	forvalues i = 2 / `number_sheets' {
		local s`i' = r(worksheet_`i') 
		use `temp', clear 
		replace codes = "`s`i''" in `i'
		save `temp', replace
	}
	
	use `temp', clear
	drop if codes == ""
	merge 1:1 codes using "$data_helper/final_varlist"
	cap assert _merge == 3 if !inlist(codes, "cons_USD", "exports_USD", "finv_USD", "imports_USD", "inv_USD", "nGDP_USD", "data_final")
	qui levelsof codes if _merge != 3 & !inlist(codes, "cons_USD", "exports_USD", "finv_USD", "imports_USD", "inv_USD", "nGDP_USD", "data_final"), local(miss_vars) clean
	if _rc != 0 {
		di as error "Missing variable excel: `miss_vars'"

	}
	else {
		local success_count = `success_count' + 1
	}
    
    if `missing_var_docs' == 0 {
        di as result "All `total_documented_vars' documented variables have PDF documentation"
    }
    else {
        di as error "ERROR: `missing_var_docs' documented variables missing PDF documentation"
    }
    
    if `missing_var_csvs' == 0 {
        di as result "All `total_documented_vars' documented variables have CSV files"
    }
    else {
        di as error "ERROR: `missing_var_csvs' documented variables missing CSV files"
    }
    
    if `missing_var_dtas' == 0 {
        di as result "All `total_documented_vars' documented variables have DTA files"
    }
    else {
        di as error "ERROR: `missing_var_dtas' documented variables missing DTA files"
    }
    
    * ==============================================================================
    * 4. VALIDATE DATA INTEGRITY
    * ==============================================================================
    
    di as result "4. Validating data integrity..."
    
    * Load final dataset
    qui use "$data_final/data_final", clear
    
    * Check for missing countries
    qui merge m:1 ISO3 using $isomapping, keep(1 3)
    count if _merge == 1
    if r(N) > 0 {
        di as error "ERROR: `r(N)' countries in final data not in isomapping"
        local error_count = `error_count' + 1
    }
    else {
        di as result "All countries in final data are in isomapping"
        local success_count = `success_count' + 1
    }
    
    * Check year coverage
    qui sum year
    local min_year = r(min)
    local max_year = r(max)
    local year_range = `max_year' - `min_year' + 1
   
    di as result "Year coverage: `min_year' to `max_year' (`year_range' years)"
    local success_count = `success_count' + 1
    
    * Check country coverage
    qui count
    local total_obs = r(N)
    qui count if ISO3 != ""
    local valid_countries = r(N)
    
    if `valid_countries' == `total_obs' {
        di as result "All observations have valid country codes"
        local success_count = `success_count' + 1
    }
    else {
        di as error "`=`total_obs' - `valid_countries'' observations missing country codes"
        local error_count = `error_count' + 1
    }
 
    * ==============================================================================
    * 5. VALIDATE VERSION CONSISTENCY
    * ==============================================================================
    
    di as result "6. Validating version consistency..."
    
    * Check that current version files exist and are recent
    local version_files = 0
    foreach variable of local documented_variables {
        cap confirm file "$data_distr/`variable'_$current_version.csv"
        if _rc == 0 {
            local version_files = `version_files' + 1
        }
    }
    
    if `version_files' == `total_documented_vars' {
        di as result "`total_documented_vars' variables have current version files"
        local success_count = `success_count' + 1
    }
    else {
        di as error "Only `version_files' of `total_documented_vars' variables have current version files"
        local error_count = `error_count' + 1
    }
    
    * ==============================================================================
    * 6. FINAL SUMMARY
    * ==============================================================================
    
    di as result "=========================================="
    di as result "VALIDATION SUMMARY"
    di as result "=========================================="
    di as result "Total checks passed: `success_count'"
    di as result "Total warnings: `warning_count'"
    di as result "Total errors: `error_count'"
    
    if `error_count' == 0 {
        di as result "DATABASE VALIDATION PASSED"
        if `warning_count' > 0 {
            di as err "`warning_count' warnings found - please review"
        }
    }
    else {
        di as error "DATABASE VALIDATION FAILED"
        di as error "`error_count' errors found - database update incomplete"
    }
    
    * Send Slack notification
    if `error_count' == 0 {
        if `warning_count' == 0 {
            cap gmdslack, send("`c(username)': Database validation PASSED - All `success_count' checks successful")
        }
        else {
            cap gmdslack, send("`c(username)': Database validation PASSED with `warning_count' warnings - `success_count' checks successful")
        }
    }
    else {
        cap gmdslack, send("`c(username)': Database validation FAILED - `error_count' errors, `warning_count' warnings, `success_count' checks passed")
    }
    
    * Return error code if validation failed
    if `error_count' > 0 {
        exit 198
    }

end

* ==============================================================================
* RUN THE COMPREHENSIVE ASSERTIONS
* ==============================================================================

gmd_comprehensive_assertions

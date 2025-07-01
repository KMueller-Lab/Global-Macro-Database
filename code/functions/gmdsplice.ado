* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* A PROGRAM TO SPLICE TOGETHER DIFFERENT SOURCES TO CREATE A HARMONIZED TIME SERIES
* 
* Created: 
* 2024-06-28
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* ==============================================================================

capture program drop splice
program define splice

/*
Program: splice
Purpose: Combines time series data from multiple sources into a single harmonized 
         series using either direct combination or ratio splicing methods.
         
Input Parameters:
    priority    - String list of source prefixes in order of priority
    generate    - Name of the new variable to be generated
    varname     - Base name of the variables to be combined (without source prefix)
    base_year   - Year to anchor the splicing process
    method      - Optional: Splicing method ("chainlink" or "none", default: "chainlink")
	save 		- Optional: Used when you need to splice within a dataset

    
Output:
    - Creates a new variable combining data from all sources
    - Saves the resulting dataset with chainlinking ratios and source information
    
Notes:
    - Sources should be provided as prefixes.
    - The chainlink method adjusts values to prevent breaks at source transitions
    - The none method combines raw values without adjustment
	
Example: 
	- splice, priority(ADB AMF BIS IMF_IFS OECD_EO WDI CS1 CS2 AHSTAT BORDO HFS JST MOXLAD MW NBS Tena PWT) generate(USDfx) varname(USDfx) base_year(2018) method("none")
*/

syntax, priority(string) generate(name) varname(string) base_year(integer) [method(string)] [save(string)]

* Set default method to chainlink if not specified
if "`method'" == "" {
    local method "chainlink"
}

* Validate method option
if !inlist("`method'", "none", "chainlink") {
    di as error "Invalid method specified. Must be either 'none' or 'chainlink'"
    exit 198
}

* Set default save to nothing if not specified
if "`save'" == "" {
    local save ""
}


/*
Validation and preparation of dataset

	-Verifies the existence of all source variables specified in the priority list
	-Keeps only the necessary variables
	-Warn if a source has data but not included in the priority.
*/

* Set default name for generated variable if not provided
if "`generate'" == "" local generate "spliced"

* Check if all priority variables exist
foreach p of local priority {
	capture confirm variable `p'_`varname'
	if _rc {
		di as error "Variable `p'_`varname' not found"
	}
}

* Keep only necessary variables if save option is not specified
if "`save'" == "" {
	qui keep ISO3 year *_`varname' 
}
else {
	qui keep *
}

* Warn if columns with data were not included in the priority list
qui ds ISO3 year, not
local all_vars `r(varlist)'
local num_vars: word count `r(varlist)'
local count = 0

* Loop through each variable in the priority list
foreach var of local priority {
	
	* Check if the variable exists in the dataset
	if `:list var_`varlist' in all_vars' {
		local ++count
	}
}

* Output a warning if a column with data was not included
if `num_vars' > `count' {
	di as err "Warning: There are more sources than specified in the priority list."
}


/* 
Prepare panel for combination of different data sources
This section processes each country individually to:

	Check data availability across all sources
	Determine the earliest and most recent years with data
	Track source changes and prepare variables for splicing

Output:

	chainlinking_ratio: Stores adjustment factors for splicing
	source: Records which dataset provided each observation
	source_change: Flags points where data sources switch
*/

* Process each country separately
qui glevelsof ISO3, local(countries)
foreach country of local countries {
	
	* Check if the country has any data
	local has_any_data = 0
	local earliest_year = .
	local recent_year = .  
	
	* Loop over priority list 
	foreach p of local priority {
		
		* Get number of years with non-missing data 
		qui sum year if ISO3 == "`country'" & `p'_`varname' != ., meanonly
		
		* Extract earliest and most recent year 
		if r(N) > 0 {
			local has_any_data = 1
			local earliest_year = min(`earliest_year', r(min))
			local recent_year   = max(`recent_year', r(max))
		}
	}

	if `has_any_data' == 0 {
		di as text "No data available for country: `country'. Skipping."
		continue
	}

	di as text "Processing country: `country'"
	di as text "Earliest year with data: `earliest_year'"
	
	* Preserve panel with all countries and years
	preserve
	
	* Keep
	qui keep if ISO3 == "`country'" & year >= `earliest_year'
	
	* Drop empty columns
	
	
	* Initialize new variables
	qui gen `generate' = .
	qui gen chainlinking_ratio = 1
	qui gen source = "".
	qui gen source_change = .
	
	* Create local variables
	local prev_source = ""
	local prev_value = .
	local current_source = ""
	local current_value = .

	* Sort data by country and descending year
	gsort ISO3 -year  
	
	
/* 

Backward-splicing:
	- Combines data for years before and including the base year following priority order

*/
	* Check if there is data before the base year
	local has_data_before_base_year = 0
	
	* Loop over priority list 
	foreach p of local priority {
		
		* Check number of observations before base year 
		qui count if `p'_`varname' != . & year <= `base_year'
		
		* If there is data, continue 
		if r(N) > 0 {
			local has_data_before_base_year = 1
			continue, break
		}
	}

	* Process years before and including base year if data exists
	if `has_data_before_base_year' == 1 {
		
		qui glevelsof -year if year <= `base_year', local(yearsback)
		foreach y of local yearsback {
		
			* Find the first valid source and value for the current year
			foreach p of local priority {
				
				* Extract first source
				if `y' == `base_year' {
					local first_source = "`p'"
				}
				
				* Extract source name
				qui sum `p'_`varname' if year == `y'
				if r(N) > 0 {
					local current_source = "`p'"
					local current_value = r(mean)
					continue, break
				}
				else {
					local current_value = .
				}
				
			}
			
			* If a valid source is found, replace value for year y with 
			* data from the current source 
			if "`current_source'" != "" {
				if "`prev_source'" != "" & "`current_source'" != "`prev_source'" {
					di "Change of source from: `prev_source' to `current_source' at `y'"  
					qui replace source_change = 1 if year == `y'
				}
				
				* Assign value to the new column
				qui replace `generate' = `current_value' if year == `y' & `current_value' != . 
				qui replace source = "`current_source'"  if year == `y' 
				local prev_source = "`current_source'"
			}
		}
	}
	
	else {
		di "No data available before the base year: `base_year' for `country'"
	}
	
/* 

Forward-splicing:
	- Combines data for years after the base year following priority order

*/

	* Check if there is data after the base year
	local has_data_after_base_year = 0
	foreach p of local priority {			
		qui count if `p'_`varname' != . & year > `base_year'
		if r(N) > 0 {
			local has_data_after_base_year = 1
			continue, break
		}
	}

	* Process years after base year if data exists
	if `has_data_after_base_year' == 1 {
		
		qui glevelsof year if year > `base_year', local(yearsfwd)
		foreach y of local yearsfwd {
			
			* Find the first valid source and value for the current year
			foreach p of local priority {
				
				* Extract source name
				qui sum `p'_`varname' if year == `y'
				if r(N) > 0 {
					local current_source = "`p'"
					local current_value = r(mean)
					continue, break
				}
			}

			* If a valid source is found, process the data
			if "`current_source'" != "" {
				if "`first_source'" != "" & "`current_source'" != "`first_source'" {
					di "Change of source from: `first_source' to `current_source'"
					qui replace source_change = 1 if year == `y'
				}
				
				* Assign value to the new column
				qui replace `generate' = `current_value' if year == `y'
				qui replace source = "`current_source'" if year == `y'
				local first_source = "`current_source'"
			}
		}
	}
	
	else {
		di "No data available after the base year: `base_year' for `country'"
	}
	
	
	
	
/* 
Applies ratio splicing at source change points to ensure smooth transitions.

The ratio splicing process:
1. Identifies points where data sources change
2. For each change point:
	- Calculates the ratio between overlapping observations
	- Adjusts all subsequent/previous values by this ratio
	- Handles cases with no direct overlap using Stock-Watson method
*/

		* Check if there are any source changes and if method is chainlink
		* If there is only one source, then the method should be set to none
		qui count if source_change == 1
		if r(N) > 0 & "`method'" == "chainlink" {
			qui glevelsof -year if source_change == 1, local(years)
			foreach y of local years {
				
				* Splice data after the base year 
				if `y' > `base_year' {
					
					* Calculate the previous value
					qui levelsof source if year == `y' - 1
					local prev_source = `r(levels)'
					qui su `prev_source'_`varname' if year == `y' - 1, meanonly
					local prev_value = r(mean)
					
					* Calculate the current value
					qui levelsof source if year == `y'
					local current_source = `r(levels)'
					qui su `current_source'_`varname' if year == `y' - 1, meanonly
					local current_value = r(mean)
					
					* Calculate the ratio
					local ratio = `prev_value'/`current_value'
					qui replace chainlinking_ratio = `ratio'* chainlinking_ratio if year >= `y'
				}
				
				* Splice data before the base year 
				else {
				
					* Calculate the previous value
					qui levelsof source if year == `y' + 1
					local prev_source = `r(levels)'
					qui su `prev_source'_`varname' if year == `y' + 1, meanonly
					local prev_value = r(mean)
					
					* Calculate the current value
					qui levelsof source if year == `y'
					local current_source = `r(levels)'
					qui su `current_source'_`varname' if year == `y' + 1, meanonly
					
					* Check if there is an overlapping value between the previous and current sources
					if r(mean) != . {
						local current_value = r(mean)
					}
					
					* Check if the year of the change has data, this would indicate that there is a higher priority source with less data than the currently used source
					else {
						
						qui su `prev_source'_`varname' if year == `y', meanonly
						if r(mean) != . {
							local prev_value = r(mean)
							
							* Calculate the current value
							qui levelsof source if year == `y'
							local current_source = `r(levels)'
							qui su `current_source'_`varname' if year == `y', meanonly	
							local current_value = r(mean)
						}

						* If there is no overlapping data at all, then use Stock-Watson or indicate missing data
						else {
						* Check if there is data at the source change year, if not, use Stock-Watson (This indicates missing data in a high priority source)
							qui su `prev_source'_`varname' if year == `y'+1, meanonly
							if r(mean) != . {
								
								* Using Stock-Watson
								local ny = `y' + 1
								di "No overlapping values at `ny', used Stock-Watson"
								
								* Set panel 
								qui tset year 
								
								* Calculate the growth rates around the break
								qui gen growth_series1 = (`prev_source'_`varname' - L1.`prev_source'_`varname')/L1.`prev_source'_`varname' if inrange(year, `y'+1, `y'+3)
								qui gen growth_series2 = (`current_source'_`varname' - L1.`current_source'_`varname')/L1.`current_source'_`varname' if inrange(year, `y'-2, `y')
								qui gen growth_series3 = growth_series1
								qui replace growth_series3 = growth_series2 if growth_series3 == .
								
								* Extract the value from the first series 
								qui su `prev_source'_`varname' if year == `y'+1, meanonly
								local first_value = r(mean)
								
								* Find the median of the growth rates
								qui su growth_series3 if year != `y'+1 & growth_series3 != . , deta
								local prev_value = `first_value' / (1 + r(p50))
								
								* Extract the value from the second series
								qui su `current_source'_`varname' if year == `y', meanonly
								local current_value = r(mean)
								
								* Drop 
								qui drop growth_series1 growth_series2 growth_series3
							}	
							else {
								di "Missing data detected"
								local current_value = 1
								qui su chainlinking_ratio if year == `y' + 1, meanonly
								local prev_value = r(mean) 
						}						
					}						
				}
					
					* Calculate the ratio
					local ratio = `prev_value'/`current_value'
					qui replace chainlinking_ratio = `ratio' * chainlinking_ratio if year <= `y'
				}
			}
		}
		else {
				di as text "No source changes found for `country'. Chainlinking ratio remains 1."
			}
			
		* Finalize panel dataset - only apply ratio if method is chainlink
		if "`method'" == "chainlink" {
			qui replace `varname' = `varname' * chainlinking_ratio
		}
		else {
			qui replace `varname' = `varname' * 1	
			qui replace chainlinking_ratio = 1
		}
		qui keep if year >= `earliest_year'
		qui keep if year <= `recent_year'
		

		* For the first country, save directly
		if `"`temp_master'"' == "" {
			qui tempfile temp_master
			qui save `temp_master', replace
		}
		
		* For subsequent countries, append to existing data
		else {
			qui append using `temp_master'
			qui save `temp_master', replace
		}
		
		* Restore to go back to full panel of all countries and years 
		restore
}

* Output
use `temp_master', clear


* Sort the output
sort ISO3 year

* Save only when the option save is not specified
if "`save'" == "" {
	save "$data_final/chainlinked_`varname'", replace
}

else {
	drop chainlinking_ratio source* 
}




end

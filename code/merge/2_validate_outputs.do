* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* VALIDITY CHECKS ON DATABASE INTEGRITY
* 
* Description: 
* This Stata program checks the integrity of the overall database structure.
*
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 
* 2024-04-21
*
* ==============================================================================

* ==============================================================================
* MAKE HELPER PROGRAM THAT FLAGS INCONSISTENCIES IN UNITS 
* ==============================================================================

* Flag cases where values for the same variable but different sources deviate 
* by a factor of 1000 or more, indicating likely issues with inconsistent units 

cap program drop checkunits 
program define checkunits 
    syntax varlist(min=1)
    
    foreach var of varlist `varlist' {
        
		* Make temporary variables 
        tempvar ratio
        
        * Make the ratio of current value to previous value within each country
        qui bysort ISO3 (year): gen `ratio' = `var' / `var'[_n-1]
        
        * Check if there are any non-missing ratio values
        qui count if `ratio' != .
        if r(N) > 0 {
            * Perform sum only if there are non-missing values
            qui sum `ratio'
            if `r(max)' > 1000 | abs(`r(min)') < 1/1000 {
                di as err "Values for `var' differ by a factor of 1,000 or more:"
                list ISO3 year `var' if (`ratio' > 1000 | abs(`ratio') < 1/1000) & `ratio' != . & `ratio' != 0, fast noobs
            }
        }
        else {
            di as txt "Note: No valid ratios calculated for `var'. Skipping checks."
        }
        
        drop `ratio'
    }
end


* ==============================================================================
* CHECK WHETHER ALL INPUT SOURCES ARE ACTUALLY USED
* ==============================================================================
/*
* Make list of source in master source file 
gmdsourcelist 

* Check whether source is ever used in cleaned file 
use "$data_final/clean_data_wide", clear 
levelsof SOURCE_ABBR, loc(gmdsourcelist)

foreach s of loc masterlist {
	
	if `: list s in usinglist' { 
	} 
	else {
		di as error "`var' is not in the master variable list" 
		exit 198
	}
} 

* Check there are no outliers since merging in new data 
qui ds ISO3 year, not
foreach var in `r(varlist)' {  // Loop through all variables
    
    * Check if variable exists (this check might be redundant, but kept for consistency)
    cap confirm var `var'
    if _rc != 111 {
        
        * If it does, check units 
        checkunits `var'
    }
}

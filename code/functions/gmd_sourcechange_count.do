* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* A PROGRAM TO RAISE AN ERROR ABOUT SERIES THAT HAVE HAD MANY SOURCE CHANGES 
* 
* Created: 
* 2025-09-19
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Example: do "$functions/gmd_source_changes.do"
* ==============================================================================

* Raise a warning that there are many source changes 
qui import delimited using "$data_helper/docvars", clear 
qui levelsof codes if finalvarlist == "Yes" & derived != "Yes", local(check_vars)
foreach var of local check_vars {
	qui use "$data_final/chainlinked_`var'", clear
	qui levelsof ISO3 if source_change_count > 8, clean local(`var'_countries)
}
di as txt "Variable ---- Countries"

foreach var of local check_vars {
	
	di "`var' ``var'_countries'"
}

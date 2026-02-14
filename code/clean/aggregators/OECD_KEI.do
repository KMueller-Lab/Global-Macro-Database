* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-10
*
* Description: 
* This Stata script opens and cleans key economic indicators data from OECD
* 
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================

* Clear data 
clear 

* Define globals 
global input "${data_raw}/aggregators/OECD/OECD_KEI/OECD_KEI.dta"
global output "${data_clean}/aggregators/OECD/OECD_KEI/OECD_KEI.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open
use "$input", clear

* Drop regional aggregates
keep if strlen(ref_area) == 3
drop if ref_area == "G20"

* Add indicator and assing codes 
gen indicator = ""
replace indicator = "CPI"         if measure == "CP"     & unit_measure == "IX" & indicator == "" 						  // Consumer prices
replace indicator = "infl"    	  if measure == "CP"     & unit_measure == "GR" & v18       == "Growth rate, over 1 year" // Consumer prices
replace indicator = "CA_GDP"	  if measure == "CA_GDP" & indicator == ""     					  						  // Current account balance as percentage of GDP
replace indicator = "strate"      if measure == "IR3TIB" & indicator == ""      				  						      // Short-term interest rates
replace indicator = "unemp"       if measure == "UNEMP"  & indicator == ""      				  						 	  // Unemployment
replace indicator = "USDfx"       if measure == "CC"     & indicator == ""     				 	  						  	  // Nominal exchange rates
replace indicator = "ltrate"  	  if measure == "IRLT"   & indicator == ""      			  	  						  	  // Long-term interest rates

* Drop other indicators
keep if indicator != ""

* Assert that the observation status length is always 1
tempvar n
gen `n' = strlen(obs_status)
qui su `n', meanonly
assert r(mean) == 1
drop `n'

* Keep relevant variables
keep time_period obs_value ref_area indicator 

* Reshape
greshape wide obs_value, i(time_period ref_area) j(indicator)

* Rename
ren obs_value* *
ren (time_period ref_area) (year ISO3)

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	ren `var' OECD_KEI_`var'
}

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Sort
sort ISO3 year 

* Order
order ISO3 year 

* Check for duplicates
isid ISO3 year 

* Save 
save "${output}", replace

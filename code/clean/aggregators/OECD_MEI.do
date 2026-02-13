* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-07-04
*
* Description: 
* This Stata script opens and cleans MEI (main economic indicators) data from OECD.
* 
* Data Source: OECD
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================
* Clear data 
clear

* Define input and output files
global input "${data_raw}/aggregators/OECD/OECD_MEI/OECD_MEI.dta"
global output "${data_clean}/aggregators/OECD/OECD_MEI/OECD_MEI.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open
use "$input", clear

* Drop regional aggregates
keep if strlen(ref_area) == 3
drop if inlist(ref_area, "WXD", "W_O")

* Add indicator and assing codes 
gen indicator = ""
replace indicator = "M1"      if measure == "MANM"     & unitofmeasure == "National currency" & indicator == "" & adjustment  == "N" // M1
replace indicator = "M3"      if measure == "MABM"     & unitofmeasure == "National currency" & indicator == "" & adjustment  == "N" // M3

* Drop other indicators
keep if indicator != ""

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
	ren `var' OECD_MEI_`var'
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

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
* This Stata script opens and cleans HPI (main economic indicators) data from OECD.
* 
* Data Source: OECD
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================
* Clear data 
clear

* Define input and output files
global input "${data_raw}/aggregators/OECD/OECD_HPI/OECD_HPI.dta"
global output "${data_clean}/aggregators/OECD/OECD_HPI/OECD_HPI.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open
use "$input", clear

* Drop regional aggregates
keep if strlen(ref_area) == 3

* Add indicator and assing codes 
keep if freq == "A"

* Keep relevant variables
keep time_period obs_value ref_area

* Rename
ren obs_value HPI
ren (time_period ref_area) (year ISO3)

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	ren `var' OECD_HPI_`var'
}

* Destring 
destring year, replace 

* Rebase variables to $base_year
gmd_rebase OECD_HPI


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

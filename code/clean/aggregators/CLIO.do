* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Description: 
* This Stata script opens and cleans long term interest rate data from 
*
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2025-01-10
*
* URL:
* https://www.macrohistory.net/database/
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================

* Clear 
clear

* Define input and output files
global input "${data_raw}/aggregators/CLIO/CLIO.xlsx"
global output "${data_clean}/aggregators/CLIO/CLIO.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open 
import excel using "$input", clear sheet("Data Long Format") first

* Extract ISO3 
merge m:1 countryname using $isomapping, keepus(ISO3) nogen keep(1 3)
replace ISO3 = "RUS" if countryname == "Russia"

* Keep 
keep ISO3 year value

* Rename
ren value CLIO_ltrate

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Output
save "${output}", replace
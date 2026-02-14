* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN CBPOL FROM BIS
* 
* Author:
* Ziliang Chen
* National University of Singapore
* 
* Created: 2024-05-03
*
* Description: 
* This Stata script opens and cleans central bank policy rate from the BIS.
* 
* Data Source: Bank of International Settlements
*
* ==============================================================================

* ==============================================================================
* SET UP
* ==============================================================================

* Define input and output files 
clear
global input "${data_raw}/aggregators/BIS/BIS_cbrate/BIS_cbrate.dta"
global output "${data_clean}/aggregators/BIS/BIS_cbrate/BIS_cbrate.dta"

* ==============================================================================
* PROCESS
* ==============================================================================

* Open 
use "$input", clear

* Drop Euro Area
drop if ref_area == "XM"

* keep monthly data 
keep if freq == "M"

* Extract the year and month
gen year = substr(time, 1, 4)
gen month = substr(time, -2, 2)

* Destring
destring year obs month, replace ignore("NA")

* Drop missing observations 
drop if obs == .

* Keep only end-of-year observation
bysort ref year (month): keep if _n == _N 

* Rename
ren ref_area ISO2
ren obs BIS_cbrate

* Generate countries' ISO3 code
merge m:1 ISO2 using ${isomapping}, nogen assert(2 3) keep(3) keepusing(ISO3)

* Keep only relevant variables
keep ISO3 year BIS_cbrate

* ==============================================================================
* OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid year ISO3 

* Save
save "${output}", replace

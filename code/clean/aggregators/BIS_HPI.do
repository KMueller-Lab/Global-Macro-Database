* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN HOUSE PRICE DATA FROM BIS
* 
* Author:
* Ziliang Chen
* National University of Singapore
* 
* Created: 2024-04-24
*
* Description: This Stata script opens and cleans house price data from the BIS.
* 
* Data Source: Bank of International Settlements
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================

* Clear data 
clear

* Define globals 
global input "${data_raw}/aggregators/BIS/BIS_HPI/BIS_HPI.dta"
global output "${data_clean}/aggregators/BIS/BIS_HPI/BIS_HPI.dta"

* ==============================================================================
* 	PROCESSING
* ==============================================================================

* Open
use "$input", clear

* Keep nominal HPI
keep if value == "N" & unit_measure == 628

* Convert ISO2 to ISO3
ren ref_area ISO2
merge m:1 ISO2 using ${isomapping}, nogen keep(3) keepusing(ISO3)
drop ISO2

* Extract the year and month
gen year = substr(time, 1, 4)
gen qrtr = substr(time, -1, 1)

* Destring
destring year obs qrtr, replace ignore("NA")

* Drop missing observations 
drop if obs == .

* Keep only end-of-year observation
bysort ISO3 year (qrtr): keep if _n == _N 

* Rename
ren obs BIS_HPI

* Keep relevant variables
keep ISO3 year BIS_HPI

* Rebase variables to $base_year
gmd_rebase BIS

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid year ISO3 

* Save
save "${output}", replace

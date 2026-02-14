* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN REAL EFFECTIVE EXCHANGE RATE DATA FROM THE BIS
* 
* Author:
* Ziliang Chen
* National University of Singapore
* 
* Created: 2024-04-25
*
* Description: 
* This stata script cleans data on real exchange rates from the BIS.
*
* Source: Bank for International Settlements
*
* ==============================================================================

* ==============================================================================
* SET UP
* ==============================================================================

* Define input and output files 
clear
global input "${data_raw}/aggregators/BIS/BIS_REER/BIS_REER.dta"
global output "${data_clean}/aggregators/BIS/BIS_REER/BIS_REER.dta"

* ==============================================================================
* PROCESS
* ==============================================================================

* Open 
use "${input}", clear

* Keep real exchange rate broad basket 
keep if eer_type == "R" & eer_basket == "B"

* Keep 
keep time obs ref

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
ren obs BIS_REER

* Generate countries' ISO3 code
merge m:1 ISO2 using ${isomapping}, nogen keep(3) keepusing(ISO3)

* Keep only relevant variables
keep ISO3 year BIS_REER

* Destring
destring year BIS_REER, replace

* Rebase variables to $base_year
gmd_rebase BIS

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

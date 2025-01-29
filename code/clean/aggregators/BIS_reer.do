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
global input "${data_raw}/aggregators/BIS/BIS_REER.dta"
global output "${data_clean}/aggregators/BIS/BIS_REER.dta"

* ==============================================================================
* PROCESS
* ==============================================================================

* Open 
use "${input}", clear

* Drop Euro Area
drop if ref_area == "XM"

* Keep 
keep period value ref_area

* Keep only end-of-year observations
gen year = substr(period, 1, 4)
sort ref_area year period
by ref_area year: keep if _n == _N

* Rename
ren ref_area ISO2
ren value BIS_REER

* Generate countries' ISO3 code
merge m:1 ISO2 using ${isomapping}, nogen assert(2 3) keep(3) keepusing(ISO3)

* Keep only relevant variables
keep ISO3 year BIS_REER

* Destring
destring year BIS_REER, replace

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

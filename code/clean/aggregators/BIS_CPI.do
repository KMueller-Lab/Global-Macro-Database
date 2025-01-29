* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN INFLATION DATA FROM BIS
* 
* Author:
* Ziliang Chen
* National University of Singapore
* 
* Created: 2024-04-24
*
* Description: 
* This Stata script opens and cleans inflation data from the BIS.
* 
* Data Source: Bank of International Settlements
*
* ==============================================================================

* ==============================================================================
* SET UP
* ==============================================================================

* Define input and output files 
clear
global input "${data_raw}/aggregators/BIS/BIS_CPI.dta"
global output "${data_clean}/aggregators/BIS/BIS_CPI.dta"

* ==============================================================================
* PROCESS
* ==============================================================================

* Open 
use "$input", clear

* Drop Euro Area
drop if ref_area == "XM"

* Fix missing value
replace value = "" if value == "NA"

* Generate variable identifier column
gen id = ""
replace id = "CPI"  if unit_measure == 628
replace id = "infl" if unit_measure == 771

* Keep only relevant variables
keep period value ref_area id

* Rename
ren ref_area ISO2
ren period   year
ren value    BIS_

* Generate countries' ISO3 codes
merge m:1 ISO2 using ${isomapping}, nogen assert(2 3) keep(3) keepusing(ISO3)
drop ISO2

* Reshape
greshape wide BIS_, i(ISO3 year) j(id)

* Destring
qui ds ISO3, not
destring `r(varlist)', replace

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

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
global input "${data_raw}/aggregators/BIS/BIS_CPI/BIS_CPI.dta"
global output "${data_clean}/aggregators/BIS/BIS_CPI/BIS_CPI.dta"

* ==============================================================================
* PROCESS
* ==============================================================================

* Open 
use "$input", clear

* Keep annual frequency
keep if freq == "A"

* Generate variable identifier column
gen id = ""
replace id = "CPI"  if unit_measure == 628
replace id = "infl" if unit_measure == 771

* Keep only relevant variables
keep time obs ref_area id

* Rename
ren (ref_area time obs) (ISO2 year BIS_)

* Generate countries' ISO3 codes
merge m:1 ISO2 using ${isomapping}, nogen keep(3) keepusing(ISO3)
drop ISO2

* Reshape
greshape wide BIS_, i(ISO3 year) j(id)

* Destring
destring year, replace 

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

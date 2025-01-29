* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN IMF MFS Data
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-07-04
*
* Description: 
* This Stata script opens and cleans IMF MFS Data
* 
* Data Source: International Monetary Fund
* ==============================================================================

* ==============================================================================
* 	Set up 
* ==============================================================================
clear 

* Define globals 
global input "${data_raw}/aggregators/IMF/IMF_MFS.dta"
global output "${data_clean}/aggregators/IMF/IMF_MFS.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open
use "$input", clear

* Keep 
keep period value indicator ref_area 

* Reshape
greshape wide value, i(ref_area period) j(indicator)

* Rename
ren (ref_area period value14____XDC value34____XDC value35L___XDC valueFIGB_PA  valueFITB_PA valueFPOLM_PA valueFMB_XDC valueFMA_XDC valueFMBCC_XDC ) (ISO2 year historical_M0 historical_M1 historical_M2 ltrate strate cbrate modern_M2 modern_M0  modern_M1)

* Convert ISO2 into ISO3 codes.
merge m:1 ISO2 using ${isomapping}, nogen keep(3) keepusing(ISO3)

* Set 0 to missing
qui ds historical* modern*
foreach var in `r(varlist)'{
	replace `var' = . if `var' == 0
}

* Manually chainlink data for Iraq M2
qui su historical_M2 if year == 2008 & ISO3 == "IRQ"
local first_mean = r(mean)
qui su modern_M2 if year == 2008 & ISO3 == "IRQ"
local second_mean = r(mean)
local ratio = `second_mean' / `first_mean'
replace historical_M2 = historical_M2 * `ratio' if year <= 2008 & ISO3 == "IRQ"
replace historical_M2 = modern_M2 if historical_M2 == . & ISO3 == "IRQ"
replace modern_M2 = . if ISO3 == "IRQ"

* Alternate M* has more data than the first one, thus we will be chainlinking the two
splice, priority(modern historical) generate(M0) varname(M0) method("chainlink") base_year(2016) save("NO") 
splice, priority(modern historical) generate(M1) varname(M1) method("chainlink") base_year(2016) save("NO")
splice, priority(modern historical) generate(M2) varname(M2) method("chainlink") base_year(2016) save("NO") 

* Drop
drop ISO2 historical* modern*

* Add variable identifiers
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	ren `var' IMF_MFS_`var'
}

* Fix units
replace IMF_MFS_M1 = IMF_MFS_M1 / 2750    if year <= 1993 & ISO3 == "BRA"
replace IMF_MFS_M2 = IMF_MFS_M2 / 2750    if year <= 1993 & ISO3 == "BRA"

replace IMF_MFS_M1 = IMF_MFS_M1 / 10      if ISO3 == "MRT"
replace IMF_MFS_M2 = IMF_MFS_M2 / 10      if ISO3 == "MRT"

replace IMF_MFS_M1 = IMF_MFS_M1 / 1000    if ISO3 == "STP"
replace IMF_MFS_M2 = IMF_MFS_M2 / 1000    if ISO3 == "STP"

replace IMF_MFS_M0 = IMF_MFS_M0 / (10^14) if ISO3 == "VEN"
replace IMF_MFS_M1 = IMF_MFS_M1 / (10^14) if ISO3 == "VEN"
replace IMF_MFS_M2 = IMF_MFS_M2 / (10^14) if ISO3 == "VEN"

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

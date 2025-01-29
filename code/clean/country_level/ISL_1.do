* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CLEAN HISTORICAL MACROECONOMIC DATA FOR ICELAND
* 
* Description: 
* This Stata script reads in and cleans data from the Icelandic Historical 
* Statistics, published by Statistics Iceland.
*
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-04-21
*
* ==============================================================================

* ==============================================================================
* SET UP 
* ==============================================================================

* Clear data 
clear 

* Define input and output files 
global input "${data_raw}/country_level/ISL_1.xlsx"
global output "${data_clean}/country_level/ISL_1"

* ==============================================================================
* CLEAN DATA 
* ==============================================================================

* Open 
import excel using "${input}", clear 

* Drop unnecessary rows 
drop in 1/3 

* Make variables names
gen varname = "CS1_nGDP" in 2
replace varname = "CS1_rGDP_pc_index" in 3
replace varname = "CS1_pop" in 9
keep if varname != ""

* Rename year rows 
ds A B varname, not 
loc start = 1870
foreach var in `r(varlist)' {
	loc newname = "val"+"`start'"
	ren `var' `newname'
	loc start = `start' + 1
}

* Reshape 
drop A B 
gen ISO3 = "ISL"
greshape long val, i(varname) j(year)
greshape wide val, i(ISO3 year) j(varname)
ren val* *
destring *, replace 

* Rename
ren CS1_rGDP_pc_index CS1_deflator

* Convert pop to million
replace CS1_pop = CS1_pop / 1000000

* ===============================================================================
* 	OUTPUT
* ===============================================================================
* Sort
sort year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace

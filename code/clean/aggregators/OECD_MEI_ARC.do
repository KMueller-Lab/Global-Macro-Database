* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-10-30
*
* Description: 
* This Stata script opens and cleans KEI (Main Economic Indicators) data that 
* was newly digitized from the OECD archives.
* 
* Data Source: https://archive.org/details/pub_oecd-main-economic-indicators-historical-statistics
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================
* Clear data 
clear

* Define input and output files
global input "${data_raw}/aggregators/OECD/OECD_MEI_ARC.xlsx"
global output "${data_clean}/aggregators/OECD/OECD_MEI_ARC.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open
import excel using "${input}", sheet(Sheet1) firstrow clear

* Save
tempfile temp_master
save `temp_master', replace 

* Open
import excel using "${input}", sheet(Sheet2) firstrow clear


* Save and merge
tempfile temp_c
save `temp_c', replace 
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* Open
import excel using "${input}", sheet(Sheet3) firstrow clear

* Save and merge
tempfile temp_c
save `temp_c', replace 
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	ren `var' OECD_MEI_ARC_`var'
}

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

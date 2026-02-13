* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD MONETARY AGGREGATES FROM BANQUE DE FRANCE
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-23
*
* Description: 
* This stata script downloads data from Banque de France using DBnomics API
* 
* Data source:
* DBnomics API
* 
* Last downloaded:
* 2024-07-23
* ==============================================================================

* Run the master file
do "code/0_master.do"

cap {


* Define output file name 
global output "${data_raw}/country_level/FRA_1"

* Create temporary file
clear
tempfile temp_master
save `temp_master', replace emptyok


* Download 
local aggregates M10 M20 M30
foreach aggregate of local aggregates {
	* Import
	cap dbnomics import, pr(BDF) dataset(BSI1) BS_ITEM(`aggregate') DATA_TYPE(1) REF_AREA(FR) clear
	
	* Recast
	qui ds, has(type string)
	foreach var in `r(varlist)' {
		qui replace `var' = strtrim(`var')
		qui gen length = strlen(`var')
		qui su length
		qui recast str`r(max)' `var', force
		qui drop length
	}
	
	* Append and save
	append using `temp_master'
	save `temp_master', replace
}

* Save download date 
gmdsavedate, source(FRA_1)

* Save
savedelta ${output}, id(period REF_AREA series_code)



}

* Create the log
clear
set obs 1
gen variable = "FRA_1"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save
save "$data_temp/download_log/FRA_1_log.dta", replace

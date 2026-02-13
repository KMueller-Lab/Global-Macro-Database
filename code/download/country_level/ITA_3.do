* ==============================================================================
* GLOBAL CREDIT DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD MONETARY AGGREGATES FROM ISTAT (ITALY STATISTICAL OFFICE)
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-11-06
*
* ==============================================================================

* Run the master file
do "code/0_master.do"

cap {

clear 
* Define output file name 
global output "${data_raw}/country_level/ITA_3"

* Create temporary file
clear
tempfile temp_master
save `temp_master', replace emptyok

* NATIONAL ACCOUNTS
dbnomics import, pr(ISTAT) d(92_506_DF_DCCN_PILN_1) EDITION(2024M9)  clear
append using `temp_master', force
save `temp_master', replace 

* Save download date 
gmdsavedate, source(ITA_3)

* Save
savedelta ${output}, id(period dataset_code series_code)



}

* Create the log
clear
set obs 1
gen variable = "ITA_3"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save
save "$data_temp/download_log/ITA_3_log.dta", replace

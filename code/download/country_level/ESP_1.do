* ==============================================================================
* GLOBAL CREDIT DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD MONETARY AGGREGATES FROM INE (SPAIN STATISTICAL OFFICE)
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
global output "${data_raw}/country_level/ESP_1"

* Create temporary file
clear
tempfile temp_master
save `temp_master', replace emptyok

* GDP mp Demand (Current prices)
dbnomics import, pr(INE-SPAIN) d(30680) units(euros) clear
append using `temp_master', force
save `temp_master', replace 

* Save download date 
gmdsavedate, source(ESP_1)

* Save
savedelta ${output}, id(period dataset_code series_code)



}

* Create the log
clear
set obs 1
gen variable = "ESP_1"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save
save "$data_temp/download_log/ESP_1_log.dta", replace

* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD UN DATA
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-05-14
*
* Description: 
* This Stata script downloads UN DATA
* 
* Data source:
* UN DATA
*
* To get the list of all file names: curl -X 'GET' \ 'https://unstats.un.org/unsd/amaapi/api/File' \ -H 'accept: */*'
* 
* ==============================================================================

* Run the master file
do "code/0_master.do"

cap {

  
* Define output file name 
global output "${data_raw}/aggregators/UN"

* GDP in current prices
import excel using "https://unstats.un.org/unsd/amaapi/api/File/1", clear 
save "$output/nGDP", replace

* GDP in 2015 real prices in local currency
import excel using "https://unstats.un.org/unsd/amaapi/api/File/5", clear
save "$output/rGDP", replace

* GDP in 2015 real prices in USD
import excel using "https://unstats.un.org/unsd/amaapi/api/File/6", clear
save "$output/rGDP_USD", replace

* Population
import excel using "https://unstats.un.org/unsd/amaapi/api/File/30", clear
save "$output/USDfx", replace

* Save download date 
gmdsavedate, source(UN)
}

* Create the log
clear
set obs 1
gen variable = "UN"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save
save "$data_temp/download_log/UN_log.dta", replace




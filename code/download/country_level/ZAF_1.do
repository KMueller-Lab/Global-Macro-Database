* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD Statistics For South Africa
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-11-06
* ==============================================================================

* Run the master file
do "code/0_master.do"

cap {

clear 
* Define output file name 
global output "${data_raw}/country_level/ZAF_1"

* Create temporary file
clear
tempfile temp_master
save `temp_master', replace emptyok

* Money and Banking
dbnomics import, pr(SARB) d(QB) topic(MB)  freq(A) clear
append using `temp_master', force
save `temp_master', replace 

* National Accounts
dbnomics import, pr(SARB) d(QB) topic(NA)  freq(A) clear
append using `temp_master', force
save `temp_master', replace 

* Public Finance
dbnomics import, pr(SARB) d(QB) topic(PF)  freq(A) clear
append using `temp_master', force
save `temp_master', replace 

* Capital Markets
dbnomics import, pr(SARB) d(QB) topic(FM)  freq(A) clear
append using `temp_master', force
save `temp_master', replace 

* Save download date 
gmdsavedate, source(ZAF_1)

* Save
save "$output", replace
savedelta ${output}, id(period dataset_code series_code)



}

* Create the log
clear
set obs 1
gen variable = "ZAF_1"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save
save "$data_temp/download_log/ZAF_1_log.dta", replace

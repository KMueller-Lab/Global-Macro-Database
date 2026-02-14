* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD CPI DATA FROM BIS
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-04-14
*
* Description: 
* This Stata script downloads CPI data from BIS.
* 
* Data Source: Bank of International Settlements.
*
* ==============================================================================

* Run the master file
do "code/0_master.do"

cap {


global output "${data_raw}/aggregators/BIS/BIS_CPI/BIS_CPI"

local url "https://stats.bis.org/api/v1/data/WS_LONG_CPI/A?format=csv&detail=dataonly"

* Download the data 
copy "`url'" "bis_cpi.csv", replace

* Import the downloaded CSV file
import delimited "bis_cpi.csv", clear varnames(1)

* Save date 
gmdsavedate, source(BIS_CPI)

* Save
save "$output", replace 


}

* Create the log
clear
set obs 1
gen variable = "BIS_CPI"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save
save "$data_temp/download_log/BIS_CPI_log.dta", replace

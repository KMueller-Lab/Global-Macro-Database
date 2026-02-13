* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD US DOLLAR EXCHANGE RATES FROM BIS
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-04-05
*
* Description: 
* This Stata script downloads US dollar exchange rates from BIS.
* 
* Data source: Bank for International Settlements.
*
* =========================================================

* Run the master file
do "code/0_master.do"

cap {


* Define output file name 
global output "${data_raw}/aggregators/BIS/BIS_USDfx/BIS_USDfx"

local url "https://stats.bis.org/api/v1/data/WS_XRU/A?format=csv&detail=dataonly"

* Download the data 
copy "`url'" "bis_usd.csv", replace

* Import the downloaded CSV file
import delimited "bis_usd.csv", clear varnames(1)

save "$output", replace

* Save download date 
gmdsavedate, source(BIS_USDfx)



}

* Create the log
clear
set obs 1
gen variable = "BIS_USDfx"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save
save "$data_temp/download_log/BIS_USDfx_log.dta", replace

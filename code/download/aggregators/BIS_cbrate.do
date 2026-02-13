* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD CENTRAL BANK POLICY RATES FROM BIS
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-04-05
*
* Description: 
* This Stata script downloads Central Bank Policy Rates from BIS
* 
* Data source: Bank of International Settlements
*
* ==============================================================================

* Run the master file
do "code/0_master.do"

cap {


* Define output file name 
global output "${data_raw}/aggregators/BIS/BIS_cbrate/BIS_cbrate"

local url "https://stats.bis.org/api/v1/data/WS_CBPOL/M?format=csv&detail=dataonly"

* Download the data
copy "`url'" "bis_cbrate.csv", replace


* Import the downloaded CSV file
import delimited "bis_cbrate.csv", clear varnames(1)
save "$output", replace

gmdsavedate, source(BIS_cbrate)
}

* Create the log
clear
set obs 1
gen variable = "BIS_cbrate"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save
save "$data_temp/download_log/BIS_cbrate_log.dta", replace

* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD REAL EFFECTIVE EXCHANGE RATES FROM BIS
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-04-09
* 
* Description: 
* This Stata script downloads effective exchange rate from BIS
*
* Source: Bank for International Settlements.
*
* ==============================================================================

* Run the master file
do "code/0_master.do"

cap {


* Define output file name 
global output "${data_raw}/aggregators/BIS/BIS_REER/BIS_REER"

local url "https://stats.bis.org/api/v1/data/WS_EER/M?format=csv&detail=dataonly"
		   
* Download the data
copy "`url'" "bis_reer.csv", replace

* Import the downloaded CSV file
import delimited "bis_reer.csv", clear varnames(1)

save "$output", replace

* Save download date 
gmdsavedate, source(BIS_REER)

}

* Create the log
clear
set obs 1
gen variable = "BIS_reer"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save
save "$data_temp/download_log/BIS_reer_log.dta", replace

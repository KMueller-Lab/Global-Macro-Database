* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD HOUSING PRICES FROM BIS
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-04-05
*
* Description: 
* This Stata script downloads housing prices from BIS
* 
* Data Source: Bank of International Settlements.
*
* =========================================================

* Run the master file
do "code/0_master.do"

cap {


* Define output file name 
global output "${data_raw}/aggregators/BIS/BIS_HPI/BIS_HPI"

local url "https://stats.bis.org/api/v1/data/WS_SPP/all/all?format=csv&detail=dataonly"

* Download the data 
copy "`url'" "bis_hpi.csv", replace

* Import the downloaded CSV file
import delimited "bis_hpi.csv", clear varnames(1)

* Save download date 
gmdsavedate, source(BIS_HPI)

* Save
save "${output}", replace

}

* Create the log
clear
set obs 1
gen variable = "BIS_HPI"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save
save "$data_temp/download_log/BIS_HPI_log.dta", replace

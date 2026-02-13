* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD OECD HOUSE PRICE INDICATORS
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2025-09-28
*
* Description: 
* This Stata script downloads key economic indicators data from OECD
* 
* Data source:
* DBnomics API
* 
* ==============================================================================

* Run the master file
do "code/0_master.do"




clear

* Define output file name 
global output "${data_raw}/aggregators/OECD/OECD_HPI/OECD_HPI"

* Download
local url "https://sdmx.oecd.org/public/rest/data/OECD.ECO.MPD,DSD_AN_HOUSE_PRICES@DF_HOUSE_PRICES,1.0/..RHP.?dimensionAtObservation=AllDimensions&format=csvfilewithlabels"
cap copy "`url'" "OECD_HPI.csv", replace
qui import delimited "OECD_HPI.csv", clear
rm "OECD_HPI.csv"

* Save download date 
gmdsavedate, source(OECD_HPI)

* Save
save "$output", replace 



* Create the log
clear
set obs 1
gen variable = "OECD_HPI"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save
save "$data_temp/download_log/OECD_HPI_log.dta", replace

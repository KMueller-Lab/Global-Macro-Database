* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD OECD MEI
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-07-04
*
* Description: 
* This Stata script downloads OECD MEI (main economic indicators) Data using DBnomics API
* 
* Data source:
* DBnomics API OECD MEI Data
* 
* ==============================================================================

* Run the master file
do "code/0_master.do"

cap {


clear

* Define output file name 
global output "${data_raw}/aggregators/OECD/OECD_MEI/OECD_MEI"

* Download
local url "https://sdmx.oecd.org/public/rest/data/OECD.SDD.STES,DSD_STES@DF_MONAGG,4.0/.A.......?dimensionAtObservation=AllDimensions&format=csvfilewithlabels"
cap copy "`url'" "OECD.csv", replace
qui import delimited "OECD.csv", clear
rm "OECD.csv"

* Save download date 
gmdsavedate, source(OECD_MEI)

* Save
save "$output", replace 

}

* Create the log
clear
set obs 1
gen variable = "OECD_MEI"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save
save "$data_temp/download_log/OECD_MEI_log.dta", replace

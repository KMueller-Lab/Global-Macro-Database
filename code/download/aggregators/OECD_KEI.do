* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD OECD KEY ECONOMIC INDICATORS DATA
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-10
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
global output "${data_raw}/aggregators/OECD/OECD_KEI/OECD_KEI"

* Download
local url "https://sdmx.oecd.org/public/rest/data/OECD.SDD.STES,DSD_KEI@DF_KEI,4.0/.A.......?dimensionAtObservation=AllDimensions&format=csvfilewithlabels"
cap copy "`url'" "OECD_1.csv", replace
qui import delimited "OECD_1.csv", clear
rm "OECD_1.csv"

* Save download date 
gmdsavedate, source(OECD_KEI)

* Save
save "$output", replace 



* Create the log
clear
set obs 1
gen variable = "OECD_KEI"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save
save "$data_temp/download_log/OECD_KEI_log.dta", replace

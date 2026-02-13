* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Last Editor:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-05-14
* Last updated: 2024-06-05
*
* Description: 
* This Stata script downloads relevant variable from the OECD Economic outlook publication using DBnomics API
* 
* Input: NA 
*
* Output: A structured dataset containing relevant economic variables from the OECD, organized by country and time period.
*
* Data source:
* Organisation for Economic Co-operation and Development
* 
* Last downloaded:
* 2024-06-05
*
* ==============================================================================

* Run the master file
do "code/0_master.do"

cap {


clear

* Define output file name 
global output "${data_raw}/aggregators/OECD/OECD_EO/OECD_EO"

* Download
local url "https://sdmx.oecd.org/public/rest/data/OECD.ECO.MAD,DSD_EO@DF_EO,1.2/..A?dimensionAtObservation=AllDimensions&format=csvfilewithlabels"
cap copy "`url'" "OECD_EO_A.csv", replace
qui import delimited "OECD_EO_A.csv", clear

* Delete the temporary OECD file
rm "OECD_EO_A.csv"

* Save download date 
gmdsavedate, source(OECD_EO)

* Drop observations with no time periods
drop if time_period == .

* Save
save "$output", replace 

}

* Create the log
clear
set obs 1
gen variable = "OECD_EO"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save
save "$data_temp/download_log/OECD_EO_log.dta", replace

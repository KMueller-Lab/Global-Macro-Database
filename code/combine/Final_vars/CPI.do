* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
*
* Constructing CPI Index
* 
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-10-17
*
* ==============================================================================
* Run the master file
do "code/0_master.do"
cap {
	
* Open the data
use "$data_final/clean_data_wide", clear

* Set up the priority list
splice, priority(BIS EUS OECD_EO OECD_KEI WDI WDI_ARC BCEAO ADB AMECO WB_infl IMF_IFS IMF_WEO CS1 CS2 CS3 Moxlad IHD JST ECLAC MW AHSTAT HFS NBS FZ Mitchell IMF_WEO_forecast) generate(CPI) varname(CPI) base_year($base_year) method("chainlink")

* Assert CPI equal to 100 in 2015
levelsof ISO3 if CPI != . & year == 2015, local(countries) clean
foreach country of local countries {
	assert round(CPI,0.1) == 100 if year == 2015
}

}



* Create the log  
clear 
set obs 1 
gen variable = "CPI"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/CPI_log.dta", replace

cap {
* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_CPI", clear
	replace source = "BIS_CPI" if source == "BIS"
	gmdmakedoc CPI, ylabel("Consumer price index, 2010 = 100") transformation("ratio")
	gen variable = "CPI"
	gen variable_definition = "Consumer price index"
	save "$data_final/documentation_CPI", replace
}
}

if _rc != 0 {
	use "$data_temp/combine_log/CPI_log.dta", clear 
	replace status = "Error"
	save "$data_temp/combine_log/CPI_log.dta", replace
}









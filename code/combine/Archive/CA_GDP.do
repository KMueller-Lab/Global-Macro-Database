* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCTING CURRENT ACCOUNT TO GDP RATIO
* 
* Created: 
* 2024-06-28
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 	
* ==============================================================================
* Run the master file
do "code/0_master.do"
cap {
* Clear the panel
clear

use "$data_final/clean_data_wide", clear

* Calculate current account balance in GDP after deriving the current account balance values in local currency using our own constructed exchange rate
merge 1:1 ISO3 year using "${data_final}/chainlinked_USDfx.dta", keepusing(USDfx) keep(1 3) nogen
merge 1:1 ISO3 year using "${data_final}/chainlinked_nGDP.dta", keepusing(nGDP) keep(1 3) nogen

* Derive Mitchell values in LCU
replace Mitchell_CA = Mitchell_CA_USD * USDfx if Mitchell_CA == .

* Derive current account balance in terms of GDP
gen Mitchell_CA_GDP = (Mitchell_CA / Mitchell_nGDP) * 100
drop USDfx nGDP Mitchell_CA_USD Mitchell_CA

* Fix values for Sierra Leone
replace Mitchell_CA_GDP = Mitchell_CA_GDP * 1000 if ISO3 == "SLE"
replace Mitchell_CA_GDP = Mitchell_CA_GDP / 1000 if ISO3 == "IDN" & year <= 1939

* Drop outlier values for Ghana
replace Mitchell_CA_GDP = . if inrange(year, 1955, 1956) & ISO3 == "GHA"


* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================
* Set up the priority list
splice, priority(AMF BCEAO OECD_EO WDI WDI_ARC OECD_KEI IMF_IFS ADB IMF_WEO CS1 JST JO Mitchell IMF_WEO_forecast) generate(CA_GDP) varname(CA_GDP) base_year(2018) method("none")
}

* Create the log
clear 
set obs 1 
gen variable = "CA_GDP"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/CA_GDP_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_CA_GDP", clear
	gmdmakedoc CA_GDP, ylabel("Current account balance, % of GDP") transformation("ratio")
	gen variable = "CA_GDP"
	gen variable_definition = "Current account balance"
	save "$data_final/documentation_CA_GDP", replace
}

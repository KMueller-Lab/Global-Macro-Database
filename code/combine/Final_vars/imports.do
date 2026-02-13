* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCING IMPORTS
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



* Open the data
use "$data_final/clean_data_wide", clear

* Merge chainlinked USD exchange rate
merge 1:1 ISO3 year using "$data_final/chainlinked_USDfx", nogen keepus(USDfx)

* Derive trade values from UN_trade
gen UN_trade_imports = (UN_trade_imports_USD * USDfx)
gen UN_trade_exports = (UN_trade_exports_USD * USDfx)

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================
* Set up the priority list
splice, priority(OECD_EO EUS AMECO UN BCEAO AMF ADB IMF_WEO IMF_IFS CS1 CS2 CS3 WDI WDI_ARC JST UN_trade Tena AHSTAT Mitchell NBS HFS IHD TH_ID IMF_WEO_forecast) generate(imports) varname(imports) base_year(2019) method("chainlink")


* Create the log
clear 
set obs 1 
gen variable = "imports"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/imports_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_imports", clear
	gmdmakedoc imports, log ylabel("Imports, millions of LCU (Log scale)")	
	gen variable = "imports"
	gen variable_definition = "Imports"
	save "$data_final/documentation_imports", replace
}

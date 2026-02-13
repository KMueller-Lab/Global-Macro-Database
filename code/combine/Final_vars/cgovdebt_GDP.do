* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing government debt
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

	* Open the data
	use "$data_final/clean_data_wide", clear

	* ==============================================================================
	* Specify country specific priority ordering.
	* ==============================================================================

	* Set up the priority list except for Australia, Germany, Switzerland, and USA 
	drop if inlist(ISO3, "USA", "AUS", "DEU", "CHE")
	splice, priority(IMF_GDD AFRISTAT CS1 CS2 FZ RR NBS WDI WDI_ARC HFS) generate(cgovdebt_GDP) varname(cgovdebt_GDP) base_year(2018) method("none")

	* Splice Australia and USA 
	use "$data_final/clean_data_wide", clear
	keep if inlist(ISO3, "USA", "AUS")
	splice, priority(IMF_GDD AFRISTAT RR CS1 CS2 FZ NBS WDI WDI_ARC HFS) generate(cgovdebt_GDP) varname(cgovdebt_GDP) base_year(2018) method("none") save("CS")

	* Splice Germany and Switzerland
	use "$data_final/clean_data_wide", clear
	keep if inlist(ISO3, "DEU", "CHE")
	splice, priority(IMF_GDD AFRISTAT RR CS1 CS2 FZ NBS WDI WDI_ARC HFS) generate(cgovdebt_GDP) varname(cgovdebt_GDP) base_year(2018) method("chainlink") save("CS")

}


* Create the log
clear 
set obs 1 
gen variable = "cgovdebt_GDP"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/cgovdebt_GDP_log.dta", replace

cap {
	* Generate documentation if requested
	if $document == 1 {
		use "$data_final/chainlinked_cgovdebt_GDP", clear
		gmdmakedoc cgovdebt_GDP, ylabel("Central government debt, % of GDP") transformation("rate")
		gen variable = "cgovdebt_GDP"
		gen variable_definition = "Central government debt to GDP ratio"
		save "$data_final/documentation_cgovdebt_GDP", replace
	}
}

if _rc != 0 {
	use "$data_temp/combine_log/cgovdebt_GDP_log.dta", clear 
	replace status = "Error"
	save "$data_temp/combine_log/cgovdebt_GDP_log.dta", replace
}



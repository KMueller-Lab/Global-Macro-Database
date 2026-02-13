* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing central government taxes
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

* ==============================================================================
* Open the data
use "$data_final/clean_data_wide", clear

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================

* Set up the priority list
drop if inlist(ISO3, "AUS", "BEL", "DNK", "FIN", "FRA", "DEU", "IRN", "NZL", "NLD") | inlist(ISO3, "NOR", "POL", "SLV", "GBR", "SWE", "CHE", "CHL", "GRC", "JPN") | inlist(ISO3, "IND", "PAK", "USA")
splice, priority(EUS BCEAO IMF_GFS AFRISTAT AHSTAT CS1 CS2 Mitchell NBS) generate(cgovtax_GDP) varname(cgovtax_GDP) method("none") base_year(2017)


* Splice other countries 
use "$data_final/clean_data_wide", clear
keep if inlist(ISO3, "AUS", "BEL", "DNK", "FIN", "FRA", "DEU", "IRN", "NZL", "NLD") | inlist(ISO3, "NOR", "POL", "SLV", "GBR", "SWE", "CHE", "CHL", "GRC", "JPN") | inlist(ISO3, "IND", "PAK", "USA")
splice, priority(EUS BCEAO AFRISTAT AHSTAT CS1 CS2 Mitchell IMF_GFS NBS) generate(cgovtax_GDP) varname(cgovtax_GDP) method("chainlink") base_year(2017) save("CS")

}


* Create the log
clear 
set obs 1 
gen variable = "cgovtax_GDP"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/cgovtax_GDP_log.dta", replace

cap {
	* Generate documentation if requested
	if $document == 1 {
		use "$data_final/chainlinked_cgovtax_GDP", clear
		gmdmakedoc cgovtax_GDP, ylabel("Central government tax revenue, % of GDP") transformation("rate")
		gen variable = "cgovtax_GDP"
		gen variable_definition = "Central government tax revenue to GDP ratio"
		save "$data_final/documentation_cgovtax_GDP", replace
	}
}

* Log the error 
if _rc != 0 {
	use "$data_temp/combine_log/cgovtax_GDP_log.dta", clear
	replace status = "Error"
	save "$data_temp/combine_log/cgovtax_GDP_log.dta", replace
}





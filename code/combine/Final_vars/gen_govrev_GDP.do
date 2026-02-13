* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing general government revenue series (in % to GDP)
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

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================
cap {
	
* Set up the priority list
drop if inlist(ISO3, "ARG", "AUS", "BEL", "COL", "CRI", "DNK", "FIN", "FRA", "DEU") ///
	 |  inlist(ISO3, "GRC", "IRL", "ITA", "NLD", "NZL", "NIR", "SIN", "ZAF", "KOR") ///
	 |  inlist(ISO3, "ESP", "SWE", "CHE", "TUR", "USA", "AUT") ///
	 |  inlist(ISO3, "BHR", "IND", "IRN", "JOR")
splice, priority(EUS AMF OECD_EO AMECO IMF_WEO CS1 CS2 ECLAC ADB IMF_FPP IMF_WEO_forecast IMF_GFS) generate(gen_govrev_GDP) varname(gen_govrev_GDP) method("none") base_year(2018)

* Chainlink countries with same priority ordering 
use "$data_final/clean_data_wide", clear
keep if inlist(ISO3, "ARG", "AUS", "BEL", "COL", "CRI", "DNK", "FIN", "FRA", "DEU") ///
	 |  inlist(ISO3, "GRC", "IRL", "ITA", "NLD", "NZL", "NIR", "SIN", "ZAF", "KOR") ///
	 |  inlist(ISO3, "ESP", "SWE", "CHE", "TUR", "USA", "AUT")
splice, priority(EUS AMF OECD_EO AMECO IMF_WEO IMF_GFS CS1 CS2 ECLAC ADB IMF_FPP IMF_WEO_forecast) generate(gen_govrev_GDP) varname(gen_govrev_GDP) method("chainlink") base_year(2018) save("CS")	 

* Splice the rest with a different ordering 
use "$data_final/clean_data_wide", clear
keep if inlist(ISO3, "BHR", "IND", "IRN", "JOR")
splice, priority(IMF_WEO IMF_WEO_forecast IMF_GFS CS1 CS2 OECD_EO EUS IMF_FPP AMF  AMECO  ECLAC ADB) generate(gen_govrev_GDP) varname(gen_govrev_GDP) method("none") base_year(2018) save("CS")	 

}



* Create the log
clear 
set obs 1 
gen variable = "gen_govrev_GDP"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/gen_govrev_GDP_log.dta", replace

* Generate documentation if requested
cap {
	if $document == 1 {
		use "$data_final/chainlinked_gen_govrev_GDP", clear
		gmdmakedoc gen_govrev_GDP, ylabel("General government revenue, % of GDP") transformation("rate")
		gen variable = "gen_govrev_GDP"
		gen variable_definition = "General government revenue to GDP ratio"
		save "$data_final/documentation_gen_govrev_GDP", replace
	}
}

if _rc != 0 {
	* Use the log 
	use "$data_temp/combine_log/gen_govrev_GDP_log.dta", clear 
	replace status = "Error"
	save "$data_temp/combine_log/gen_govrev_GDP_log.dta", replace	
}





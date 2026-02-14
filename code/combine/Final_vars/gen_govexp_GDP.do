* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing general government expenditures (in % GDP)
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

* We use the general priority ordering for all countries except those that require a specific ordering 
* Drop countries that require a specific ordering 
drop if inlist(ISO3, "ARG", "DZA", "ARM", "AUS", "AUT", "BHR", "BEL", "COL", "CRI") ///
      | inlist(ISO3, "FIN", "FRA", "DEU", "ISL", "IND", "ITA", "NLD", "NZL", "NOR") ///
      | inlist(ISO3, "PRT", "ZAF", "KOR", "ESP", "SWE", "UGA", "ARE", "USA") ///
	  | inlist(ISO3, "DNK", "OMN", "ALB")
splice, priority(EUS AMF OECD_EO AMECO IMF_WEO IMF_GFS CS1 CS2 ECLAC ADB IMF_FPP FLORA IMF_WEO_forecast) generate(gen_govexp_GDP) varname(gen_govexp_GDP) method("none") base_year(2018)

* Chainlinking and assigning to AMF a lower priority
use "$data_final/clean_data_wide", clear
keep if inlist(ISO3, "DZA", "BHR", "ARE", "OMN")
splice, priority(EUS OECD_EO AMECO IMF_WEO IMF_GFS CS1 CS2 ECLAC ADB IMF_FPP FLORA AMF IMF_WEO_forecast) generate(gen_govexp_GDP) varname(gen_govexp_GDP) method("chainlink") base_year(2018) save("CS")

* Chainlinking with a modified ordering where EUS is assigned a lower probability to avoid many source changes 
use "$data_final/clean_data_wide", clear
keep if inlist(ISO3, "ARG", "AUT", "BEL", "COL", "DNK", "FIN", "FRA", "PRT", "USA") ///
	 |	inlist(ISO3, "ITA", "NLD", "KOR", "AUS", "ZAF", "DEU", "NOR", "SWE", "ESP")
splice, priority(OECD_EO AMECO IMF_WEO EUS IMF_GFS CS1 CS2 ECLAC ADB IMF_FPP FLORA AMF IMF_WEO_forecast) generate(gen_govexp_GDP) varname(gen_govexp_GDP) method("chainlink") base_year(2018) save("CS")

* Chainlinking and assinging a higher priority to the IMF WEO forecast 
use "$data_final/clean_data_wide", clear
keep if inlist(ISO3, "ARM", "IND", "CRI", "ISL", "NZL", "UGA", "ALB")
splice, priority(EUS OECD_EO AMECO IMF_WEO IMF_WEO_forecast CS1 CS2 IMF_GFS ECLAC ADB IMF_FPP FLORA AMF) generate(gen_govexp_GDP) varname(gen_govexp_GDP) method("none") base_year(2018) save("CS")

}

* Create the log
clear 
set obs 1 
gen variable = "gen_govexp_GDP"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/gen_govexp_GDP_log.dta", replace

cap {
* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_gen_govexp_GDP", clear
	gmdmakedoc gen_govexp, ylabel("General government expenditure, % of GDP") transformation("rate")
	gen variable = "gen_govexp_GDP"
	gen variable_definition = "General government expenditure to GDP ratio"
	save "$data_final/documentation_gen_govexp_GDP", replace
}
}

* Log if there is an error 
if _rc != 0 {
	use "$data_temp/combine_log/gen_govexp_GDP_log.dta", clear 
	replace status = "Error"
	save "$data_temp/combine_log/gen_govexp_GDP_log.dta", replace
}


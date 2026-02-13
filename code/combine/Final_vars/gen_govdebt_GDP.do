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


* Set up the priority list for all countries and drop those that need not to be chainlinked 
drop if inlist(ISO3, "BEL", "CHL", "CHE", "DNK", "FIN", "FRA", "GBN", "GRC", "GTM") | inlist(ISO3, "ISL", "MRT", "NOR", "ESP", "SWE", "THA") 
splice, priority(AMECO IMF_WEO IMF_FPP IMF_GDD IMF_HDD OECD_EO CS1 CS2 JST RR BORDO IMF_WEO_forecast) generate(gen_govdebt_GDP) varname(gen_govdebt_GDP) base_year(2018) method("chainlink")

* Continue with other countries 
use "$data_final/clean_data_wide", clear
keep if inlist(ISO3, "BEL", "CHL", "CHE", "DNK", "FIN", "FRA", "GBN", "GRC", "GTM") | inlist(ISO3, "ISL", "MRT", "NOR", "ESP", "SWE", "THA") 
splice, priority(AMECO IMF_WEO IMF_FPP IMF_GDD IMF_HDD OECD_EO CS1 CS2 JST RR BORDO IMF_WEO_forecast) generate(gen_govdebt_GDP) varname(gen_govdebt_GDP) base_year(2018) method("none") save("CS")


* Create the log
clear 
set obs 1 
gen variable = "gen_govdebt_GDP"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/gen_govdebt_GDP_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_gen_govdebt_GDP", clear
	gmdmakedoc gen_govdebt_GDP, ylabel("General government debt, % of GDP") transformation("ratio")
	gen variable = "gen_govdebt_GDP"
	gen variable_definition = "General government debt to GDP ratio"
	save "$data_final/documentation_gen_govdebt_GDP", replace
}

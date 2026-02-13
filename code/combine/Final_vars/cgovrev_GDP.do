* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing central government revenue series (in % to GDP)
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
* Set up the priority list
drop if inlist(ISO3, "COM", "GAB", "USA", "KOR", "ESP", "PRT", "NZL", "NLD", "MUS") | inlist(ISO3, "MRT", "MDG", "JPN")
splice, priority(EUS BCEAO IMF_GFS AFRISTAT CS1 CS2 JST AHSTAT AFDB Mitchell MD NBS FZ HFS) generate(cgovrev_GDP) varname(cgovrev_GDP) base_year(2018) method("none")

* Splice for countries with a different ordering 
use "$data_final/clean_data_wide", clear
keep if inlist(ISO3, "COM", "GAB", "USA", "NZL", "MDG", "JPN")
splice, priority(EUS BCEAO AFRISTAT AFDB CS1 JST Mitchell CS2 AHSTAT IMF_GFS MD NBS FZ HFS) generate(cgovrev_GDP) varname(cgovrev_GDP) base_year(2018) method("none") save("CS")

* Splice Korea, Spain, and Portugal  separately 
use "$data_final/clean_data_wide", clear
keep if inlist(ISO3, "KOR", "ESP", "PRT", "NLD", "MUS", "MRT")
splice, priority(CS2 EUS JST BCEAO AFRISTAT AFDB CS1 Mitchell AHSTAT MD IMF_GFS NBS FZ HFS) generate(cgovrev_GDP) varname(cgovrev_GDP) base_year(2018) method("chainlink") save("CS")

}
	 
* Create the log
clear 
set obs 1 
gen variable = "cgovrev_GDP"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/cgovrev_GDP_log.dta", replace

cap {
	* Generate documentation if requested
	if $document == 1 {
		use "$data_final/chainlinked_cgovrev_GDP", clear
		gmdmakedoc cgovrev_GDP, ylabel("Central government revenue, % of GDP") transformation("rate")
		gen variable = "cgovrev_GDP"
		gen variable_definition = "Central government revenue to GDP ratio"
		save "$data_final/documentation_cgovrev_GDP", replace
	}
}

* Log if there is an error 
if _rc != 0 {
	use "$data_temp/combine_log/cgovrev_GDP_log.dta", clear 
	replace status = "Error"
	save "$data_temp/combine_log/cgovrev_GDP_log.dta", replace
}



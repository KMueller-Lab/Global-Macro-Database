* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing central government expenditures (in % GDP)
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
splice, priority(EUS BCEAO IMF_GFS AFRISTAT CS1 CS2 JST ECLAC AFDB Mitchell FLORA AHSTAT MD NBS HFS) generate(cgovexp_GDP) varname(cgovexp_GDP) method("none") base_year(2018)

}

* Create the log
clear 
set obs 1 
gen variable = "cgovexp_GDP"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/cgovexp_GDP_log.dta", replace

cap {
	* Generate documentation if requested
	if $document == 1 {
		use "$data_final/chainlinked_cgovexp_GDP", clear
		gmdmakedoc cgovexp, ylabel("Central government expenditure, % of GDP") transformation("rate")
		gen variable = "cgovexp_GDP"
		gen variable_definition = "Central overnment expenditure to GDP ratio"
		save "$data_final/documentation_cgovexp_GDP", replace
	}
}


* Log if there is an error 
if _rc != 0 {
	use "$data_temp/combine_log/cgovexp_GDP_log.dta", clear 
	replace status = "Error"
	save "$data_temp/combine_log/cgovexp_GDP_log.dta", replace
}



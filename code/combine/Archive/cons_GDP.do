* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
*
* Construct consumption series (in % of GDP)
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

* Clear the panel
clear

* Create temporary file to store the data
tempfile temp_master
save `temp_master', replace emptyok

* Open the data
use "$data_final/clean_data_wide", clear

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================

* Set up the priority list
splice, priority(OECD_EO EUS AMECO UN BCEAO AMF IMF_IFS ECLAC CS1 CS2 CS3 WDI WDI_ARC AHSTAT) generate(cons_GDP) varname(cons_GDP) method("none") base_year(2018)

* Create the log
clear 
set obs 1 
gen variable = "cons_GDP"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/cons_GDP_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_cons_GDP", clear
	gmdmakedoc cons_GDP, ylabel("Total consumption, % of GDP") transformation("ratio")
	gen variable = "cons_GDP"
	gen variable_definition = "Total consumption to GDP ratio"
	save "$data_final/documentation_cons_GDP", replace
}

 
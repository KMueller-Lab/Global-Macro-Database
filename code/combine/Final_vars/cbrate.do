* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
*
* CONSTRUCING CENTRAL BANK POLICY RATE
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

* Open the data
use "$data_final/clean_data_wide", clear

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================

* Set up the priority list
splice, priority(BIS OECD_MEI_ARC OECD_EO IMF_IFS BCEAO CS1 CS2 FZ CS2 NBS Homer_Sylla IHD ECLAC Grimm) generate(cbrate) varname(cbrate) base_year(2017) method("none")

* Create the log
clear 
set obs 1 
gen variable = "cbrate"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/cbrate_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_cbrate", clear
	replace source = "BIS_cbrate" if source == "BIS"
	gmdmakedoc cbrate, ylabel("Central bank policy rate (%)") transformation("rate")
	gen variable = "cbrate"
	gen variable_definition = "Central bank policy rate"
	save "$data_final/documentation_cbrate", replace
}

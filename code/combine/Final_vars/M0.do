* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing M0 data
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

cap {
* Set up the priority list
drop if ISO3 == "SLB"
splice, priority(AFRISTAT BCEAO IMF_IFS ADB CS1 CS2 CS3 AHSTAT JST NBS Mitchell ECLAC BORDO HFS FZ IHD) generate(M0) varname(M0) base_year(2018) method("chainlink")

* Chainlink SLB separately with a different anchor year 
use "$data_final/clean_data_wide", clear
keep if ISO3 == "SLB"
splice, priority(ADB IMF_IFS) generate(M0) varname(M0) base_year(2023) method("chainlink") save("CS")

}


* Create the log
clear 
set obs 1 
gen variable = "M0"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/M0_log.dta", replace

cap {
* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_M0", clear
	gmdmakedoc M0, log ylabel("Money supply (M0), millions of LCU (Log scale)")	
	gen variable = "M0"
	gen variable_definition = "Money supply (M0)"
	save "$data_final/documentation_M0", replace
}
}

if _rc != 0 {
	use "$data_temp/combine_log/M0_log.dta", clear 
	replace status = "Error"
	save "$data_temp/combine_log/M0_log.dta", replace
}

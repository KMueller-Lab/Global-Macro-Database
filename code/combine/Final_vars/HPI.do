* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCT HOUSE PRICE INDEX SERIES
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

* Set up the priority list
cap {
splice, priority(BIS OECD EUS DallasFED CS1 CS2 JST) generate(HPI) varname(HPI) base_year(2018) method("chainlink")

* Assert HPI equal to 100 in 2015
levelsof ISO3 if HPI != . & year == 2015, local(countries) clean
foreach country of local countries {
	assert round(HPI,0.1) == 100 if year == 2015
}
}

* Create the log
clear 
set obs 1 
gen variable = "HPI"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/HPI_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_HPI", clear
	replace source = "BIS_HPI" if source == "BIS"
	gmdmakedoc HPI, ylabel("House price index, 2010 = 100") transformation("ratio")
	gen variable = "HPI"
	gen variable_definition = "House price index"
	save "$data_final/documentation_HPI", replace
}

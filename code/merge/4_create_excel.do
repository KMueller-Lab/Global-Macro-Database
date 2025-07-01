* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* MERGE FINAL DATASETS
*

* ==============================================================================
* MERGE IN ALL DATASETS WHILE CHECKING CONSISTENCY 
* ==============================================================================

* Preserve 
preserve 

* Get files 
filelist, directory($data_final) pat(*.dta) 

* Keep only individual files we need
drop if strpos(filename,"clean_data_wide.dta")
drop if strpos(filename,"data_final.dta")
drop if strpos(filename,"documentation.dta")
drop if strpos(filename,"documentation")
drop if strpos(filename,"GMD.xlsx")

* Extract varnames from filenames
gen identifier = regexs(1) if regexm(filename, "chainlinked_(.+)\.dta")
levelsof identifier, local(varnames) clean

* Restore 
restore 

* Increase stata memory for this task
clear
set max_memory 3g
set segmentsize 64m

* Derive the version 
local version = "$current_version"
di "`version'"

* Export into excel the data final 
use "$data_final/data_final.dta", clear
export excel using "$data_final/GMD.xlsx", sheet("data_final", modify) nolabel firstrow(vari)

* Loop 
foreach var of loc varnames {

	* Print name of file that is being merged
	di "Merging file `var'"
	
	* Import the data
	qui use "$data_final/chainlinked_`var'.dta", clear 
	
	* Add countryname
	merge m:1 ISO3 using $isomapping, keepus(countryname) nogen assert(2 3) keep(3) 
	order countryname
	
	* Sort
	sort ISO3 year 
	
	* Merge 
	export excel using "$data_distr/GMD_`version'.xlsx", sheet("`var'", modify) nolabel firstrow(vari)
	
}









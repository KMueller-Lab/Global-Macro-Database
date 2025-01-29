* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* MERGE CLEANED DATASETS
* 
* Description: 
* This Stata program merges all cleaned input files together so that they can be
* processed further and used to construct harmonized long-run time series.
*
* Requirements:
* Input data from folder ../..data/clean
* List of variables from 
*
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 
* 2024-04-21
*
* ==============================================================================
* OPEN BLANK COUNTRY-YEAR PANEL 
* ==============================================================================

* Open master list of countries 
use "$data_temp/blank_panel", clear 

* ==============================================================================
* MERGE IN ALL DATASETS WHILE CHECKING CONSISTENCY 
* ==============================================================================

* Preserve 
preserve 

* Get files 
filelist, directory($data_clean) pat(*.dta) 

* Drop Mitchell individual files
drop if regexm(dirname,"MITCHELL/individual_files")
* Make list of actual files 
replace filename = dirname+"/"+filename
levelsof filename, loc(files)

* Restore 
restore 

* Loop 
foreach file of loc files {

	* Print name of file that is being merged
	loc printname = subinstr("`file'","${data_clean}/","",.)
	di "Merging file `printname'"

	* Merge 
	qui merge 1:1 ISO3 year using "`file'", update
	
	* Check that countries are in master panel 
	qui levelsof ISO3 if _merge == 2, loc(errorcountries) clean 
	if "`errorcountries'"!="" {
		di as err "Cannot merge because the following countries are not in the master list:"
		di as err "`errorcountries'"
		exit 198
	}
	
	* Check that years are in master panel 
	qui levelsof year if _merge == 2, loc(erroryears)
	if "`erroryears'"!="" {
		di as err "Cannot merge because the following years are not in the master list:"
		di as err "`erroryears'"
		exit 198
	}
	
	* Drop merge 
	drop _merge
}
 

* ==============================================================================
* CLEAN UP AND SAVE 
* ==============================================================================

* Clean up data by dropping rows with all missing observations 
qui ds ISO3 year, not
egen anydata = rownonmiss(`r(varlist)')

* Keep only years from first non-missing observation onwards for each country
bysort ISO3 (year): egen minyear = min(cond(anydata > 0, year, .))
qui keep if year >= minyear

* Drop temporary variables
qui drop anydata minyear

* Drop IDCM 
drop IDCM*

* Nominal variables should not have zeros which is sometimes caused by periods of hyperinflation.
qui ds ISO3 year BVX* RR* LV* *ltrate *strate *cbrate *infl, not
foreach var in `r(varlist)'{
	qui replace `var' = . if `var' == 0
}

* Save 
save "$data_final/clean_data_wide", replace 

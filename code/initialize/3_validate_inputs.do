* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* VALIDITY CHECKS ON DATABASE INTEGRITY
* 
* Description: 
* This Stata program checks the integrity of the overall database structure.
*
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 
* 2024-04-21
*
* ==============================================================================

* ==============================================================================
* CHECK CONSISTENCY OF RAW AND CLEANED DATA FILES
* ==============================================================================

* Make file list in clean data 
filelist, directory($data_clean) 
replace dirname = subinstr(dirname,"${data_clean}/","",.)
drop if dirname == "country_level"
keep dirname
duplicates drop dirname, force
gen clean = 1
tempfile clean 
save `clean', replace 

* Make file list in raw data 
filelist, directory($data_raw) 
replace dirname = subinstr(dirname,"${data_raw}/","",.)
drop if dirname == "country_level"
drop if strpos(dirname, "Versions") > 0
keep dirname
duplicates drop dirname, force
merge 1:1 dirname using `clean'

* Drop aggregate folders 
drop if dirname == "${data_clean}"
drop if dirname == "${data_raw}"

* Report 
count if dirname != "country_level" & _merge == 2
if r(N) > 0 {
    di as error "The following folders are only in the clean data:"
    list dirname if dirname != "country_level" & _merge == 2, noobs compress
	exit 198
}

di as error "The following folders are only in the raw data:"
list dirname if _merge == 1, noobs compress

* ==============================================================================
* FOR CLEANED FILES, CHECK A FEW CONDITIONS
* - Documentation of sources is complete
* - Columns are either identifiers, sources, or known variables 
* - Values are numeric
* - Variables are present in the sources file
* ==============================================================================

***** Make list of cleaned files to be checked, open loop

* Get files 
filelist, directory($data_clean) pat(*.dta)

* Make list of actual files 
replace filename = dirname+"/"+filename
keep if filename != "${data_clean}/clean_data_wide.dta"
qui glevelsof filename , loc(files)

* Loop
foreach file of loc files {

	* Open file 
	qui use "`file'", clear 

	***** Assert that ISO3 code and year uniquely identify data 
	
	cap isid ISO3 year 
	if _rc!=0 {
		di as err "ISO3 and year are not unique in the `file'"
		exit 198
	}

	***** Assert that only ISO3 code is a string 
	* Get all string variables 
	qui ds, has(type string)
	
	* Check that the variable list only contains ISO3 
	cap assert "`r(varlist)'" == "ISO3"
	if _rc!=0 {
		di as err "List of strings contains variables except ISO3:"
		di as err "`r(varlist)'"
		exit 198
	}	
	
	
	
	***** Assert that all ISO3 codes are mentioned in country list
	
	* Get unique countries in clean dataset 
	qui levelsof ISO3, loc(ISO_using) clean 
	
	* Get unique countries in country list 
	preserve 
	qui use "$data_helper/countrylist", clear
	qui glevelsof ISO3, loc(ISO_list) clean 
	 
	
	* Check whether countries are in country list; if not, break
	foreach c of local ISO_using { 
		if `: list c in ISO_list' { 
		} 
		
		else {
			di as error "`c', located in `file', is not in the master country list" 
			exit 198
		}
	} 
	restore

	
	
	***** Assert that all variables from the clean data are mentioned in sources file
	di as result "Variables in file: `file'"
    qui use "`file'", clear
    qui ds ISO3 year, not
    local dataset_vars "`r(varlist)'"
    di "`r(varlist)'"
    preserve
    qui import delimited "$data_helper/sources.csv", varnames(1) clear
    qui glevelsof src_specific_var_name, local(possible_sources) clean
	qui glevelsof varabbr, local(varabbr_codes) clean
    
    
    * Check if the variables in the current dataset (`file') are in the src_specific_var_name column of the sources.csv file
    foreach var of local dataset_vars {
        if !`: list var in possible_sources' {
            di as err "Variable `var' in file `file' is not in the src_specific_var_name column of the sources.csv file."
            
        }
    }
	restore
	
	****** Assert that only needed variables are downloaded
    preserve
    qui import delimited "$data_helper/docvars.csv", varnames(1) clear
    qui glevelsof codes, local(code) clean
    
	
	* Check if the variables in the current dataset (`file') are in the src_specific_var_name column of the sources.csv file
    foreach var of local varabbr_codes {
        if !`: list var in code' {
            di as err "Variable `var' in file `file' is not in the varabbr column of the sources.csv file."
            
        }
    }
	restore
	
}	


/* ==============================================================================
* Two-way Check of sources.csv and cleaned data
* ==============================================================================

import delimited "$data_helper/sources.csv", varnames(1) clear

* Record all distinct inputs (file paths) in a local macro
levelsof data_clean, local(data_clean)


* Loop over each unique .dta file path recorded in the sources.csv
foreach i of local data_clean {
    preserve
    
	* Keep only the current .dta records (to avoid conflicting variable names from other datasets)
	keep if data_clean == "`i'"

	* Store all variables in src_specific_var_name into a local macro
	levelsof src_specific_var_name, local(src_vars) clean
	di "`src_vars'"

	* Open the current .dta file using the file path
	* local file_path = "${data_clean}/`i'"
	use "${data_clean}`i'", clear
	drop ISO year

	* Get all the variables in the .dta file
	ds
	local dta_vars `r(varlist)'
	di "`dta_vars'"

	* Two-way check using assert
	* 1. Assert that all recorded variables in src_specific_var_name exist in the .dta file
	foreach var of local src_vars {
		
		* Check if each src_specific_var_name is in the .dta variables
		if !`: list var in dta_vars' {
		
			di "`var' does not appear in list of .dta files"
			exit 198
		} 
	}

	* 2. Assert that all variables in the .dta file are recorded in src_specific_var_name
	foreach var of local dta_vars {
		
		* Checks if each variable in .dta is recorded in src_specific_var_name
		if !`: list var in src_vars' {

			di "`var' does not appear in sources.csv"
			exit 198
		
		} 
	}



    restore
}



* Produce this for all the variables and save somewhere else 
use "$data_final/data_final.dta", clear 

* Merge the blanck panel to have all the year up until 2025 
merge 1:1 ISO3 year using "$data_temp/blank_panel.dta", nogen

* Drop the countryname and id (we need to set the id again, countryname is needed to be filled again)
drop id countryname
encode ISO3, gen(id)
xtset id year
drop if ISO3 == "UMI"
* Add countryname 
merge m:1 ISO3 using $isomapping, nogen keepus(countryname) keep(3) assert(2 3) 

* Make the version specific gap folder 
cd "$data_temp/gaps"

* Create the folder 
cap mkdir "gap_$current_version"
if _rc != 0 {
	di "Folder already exist"
	cd "gap_$current_version"
}
else {
	cd "gap_$current_version"
}


* Get all variables 
ds id year ISO3 countryname, not

* For each variable, identify all gaps
foreach v in `r(varlist)' {
	preserve
    gen str30 `v'_gap = ""
    
    * Check if country has any data for this variable
    bysort id: gen has_data = 1 if `v' != . 

    
    * Find first non-missing year for each country
    bysort id: egen first_year = min(year) if !missing(`v')
	bysort id (year): egen first_year_1 = max(first_year)
    
    * Mark gaps (missing after first observation, up to 2025)
    gen byte is_gap = missing(`v') & year >= first_year_1 & year <= 2025
    
    * Create gap segment identifier
    bysort id (year): gen gap_id = sum(is_gap != is_gap[_n-1])
    replace gap_id = . if is_gap == 0
    
    * Get start and end of each gap segment
    bysort id gap_id (year): egen seg_start = min(year) if !missing(gap_id)
    bysort id gap_id (year): egen seg_end = max(year) if !missing(gap_id)
    
    * Create gap segment strings
    bysort id gap_id (year): gen seg_str = string(seg_start) + "-" + string(seg_end) if _n == 1 & !missing(gap_id)
    
    * Concatenate segments
    replace seg_str = "" if missing(seg_str)
    gen temp = ""
    bysort id (year): replace temp = cond(_n == 1, seg_str, temp[_n-1] + cond(seg_str != "" & temp[_n-1] != "", ", ", "") + seg_str)
    bysort id (year): replace temp = temp[_N]
    replace `v'_gap = temp
    
    * Label appropriately based on data availability
    replace `v'_gap = "No data" if has_data == 0
    replace `v'_gap = "No gap" if `v'_gap == "" & has_data == 1
    
    * Clean up
    drop has_data first_year first_year_1 is_gap gap_id seg_start seg_end seg_str temp
	drop if `v'_gap == ""
    bys ISO3: keep if _n == 1
	keep countryname ISO3 `v'_gap
	
	
	* Save 
	export delimited using "`v'.csv", replace
	
	* Restore
	restore
}



/* Output the gaps by country 
clear 

* Create a temporary file 
tempfile temp_master 
save `temp_master', emptyok 

* Loop over the files and append them
filelist, pat("*csv")
qui levelsof filename, clean local(files)
foreach file of local files {
	import delimited using "`file'", clear varnames(1) case(preserve)
	
	* Add the variable column 
	qui ds ISO3 countryname, not 
	ren `r(varlist)' gap 
	gen variable = "`r(varlist)'"
	
	* Clean the variable name 
	replace variable = subinstr(variable, "_gap", "", .)
	
	* Append 
	append using `temp_master'
	save `temp_master', replace
	
}


* Save the master 
use `temp_master', clear 
export delimited using "gaps_master.csv", replace 


* Output a csv file by country 
import delimited using "gaps_master.csv", clear varnames(1) case(preserve)
qui levelsof ISO3, clean local(countries)
foreach country of local countries {
	* Preserve
	preserve 
	
	* Keep only one country
	keep if ISO3 == "`country'"
	sort variable gap 
	
	* Export 
	export delimited using "`country'.csv", replace 
	
	* Restore 
	restore 
	
}

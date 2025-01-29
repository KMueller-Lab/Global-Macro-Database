* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* A SET OF PROGRAMS FOR CLEANING THE MITCHELL INTERNATIONAL HISTORICAL STATISTICS
* 
* Created: 
* 2024-06-28
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 	
* ==============================================================================

cap program drop import_columns
program import_columns
    args file_path sheet_name
    
    import excel using "`file_path'", clear sheet("Sheet`sheet_name'") allstring first
	ren A year
end

cap program drop import_columns_first
program import_columns_first
    args file_path sheet_name
    
    import excel using "`file_path'", clear sheet("Sheet`sheet_name'") allstring
	ren A year
end

cap program drop import_breaks
program import_breaks
    args file_path
    
    import excel using "`file_path'", clear sheet("Breaks") allstring first
	qui destring year, replace
end

cap program drop rename_columns
program rename_columns
    args j_col
	qui ds year, not
    foreach var in `r(varlist)'{
		cap rename `var' `j_col'`var'
	}
end

cap program drop destring_check
program destring_check 
	args variable
	qui ds
	foreach var in `r(varlist)' {
		qui replace `var' = "" if inlist(`var', "...", "…" , "—", "··· ", "… ", " - -", "... ", "- -", "....")
	}
	qui destring *, replace
	* Assert that all columns are numeric now
	qui ds, has(type string)
	cap `r(varlist)'
	if _rc != 0 {
		di as error "Not all variables in the `variable' sheet are numeric. Check these values:"
		qui gen x = `variable'
		qui destring x, force replace
		list if x == . & `variable' != ""
		drop x
		exit 198
	}
	else {
		di as txt "All variables are numeric."
	}

end

cap program drop reshape_data
program reshape_data
	args j_col
	qui ds year, not
    foreach var in `r(varlist)'{
		cap rename `var' `j_col'`var'
	}
	qui greshape long `j_col', i(year) j(countryname) string
	qui sort countryname `j_col'
end

cap program drop convert_units
program convert_units
	args country year_start year_end scale
	if "`scale'" == "Th" {
		qui replace `country' = `country' / 1000 if year <= `year_end' & year >= `year_start'
		di "Converted to millions by dividing value between `year_start' and `year_end' by 1,000"
	}
	
	if "`scale'" == "B" {
		qui replace `country' = `country' * 1000 if year <= `year_end' & year >= `year_start'
		di "Converted to millions by multiplying value between `year_start' and `year_end' by 1,000"
	}
	
	if "`scale'" == "Tri" {
		qui replace `country' = `country' * 1000000 if year <= `year_end' & year >= `year_start'
		di "Converted to millions by multiplying value between `year_start' and `year_end' by 1,000,000"
	}
end

cap program drop convert_currency
program convert_currency
	args country year_end scale
	qui replace `country' = `country' * `scale' if year <= `year_end'
	di "Converted using the exchange rate of `scale'"
end

cap program drop save_merge
program save_merge 
	args temp_c
	tempfile temp_master
	qui save `temp_master', emptyok replace
	qui append using `temp_c'
	qui save `temp_c', replace
	order countryname year
	sort countryname year
end


capture program drop adjust_breaks
program define adjust_breaks
	
	import excel using "${input}", clear first sheet("Base_years rGDP")
	qui ds
	foreach var in `r(varlist)'{
		local ln = strlen("`var'")
		if `ln' > 2 {
			local prev = "`var'"
		}
		else {
			ren `var' `prev'notes
		}
	}
	* Step 1: Generate id variable
	qui gen id = _n

	* Step 2: Reshape the data long
	qui reshape long @notes, i(id) j(countryname) string

	qui ds id countryname notes, not
	foreach var in `r(varlist)'{
		ren `var' year`var'
	}

	qui greshape long year, i(id countryname notes) j(value) string

	qui keep if countryname == value
	qui drop if year == .

	sort countryname year

	qui keep countryname year notes


	qui merge 1:1 countryname year using "$output"
	qui sort countryname year
	qui encode countryname, gen(id)
	qui xtset id year
	qui levelsof countryname, local(countries)
	foreach country of local countries {
		qui levelsof year if _merge == 3 & countryname == "`country'" & rGDP_LCU != ., local(years)
		foreach y of local years {
			* Check if there is overlapping values 
			qui su notes if year == `y' & countryname == "`country'", meanonly
			if r(mean) != . {
				local overlapping_value = r(mean)
				qui su rGDP_LCU if year == `y' & countryname == "`country'", meanonly
				local current_value = r(mean)
				local ratio = `overlapping_value' / `current_value'
				qui replace rGDP_LCU = rGDP_LCU * `ratio' if year <= `y' & countryname == "`country'" &	`ratio' != .
			}
			* Otherwise, use Stock-Waston
			else {
				qui gen growth_series1 = (rGDP_LCU - L1.rGDP_LCU)/L1.rGDP_LCU if inrange(year, `y'-3, `y'+3) & countryname == "`country'"
				qui su rGDP_LCU if year == `y' + 1 & countryname == "`country'", meanonly 
				local first_value = r(mean)
				qui su growth_series1 if year != `y'+1 & growth_series1 != . & countryname == "`country'", deta
				local prev_value = `first_value' / (1 + r(p50))
				qui su rGDP_LCU if year == `y' & countryname == "`country'", meanonly
				local current_value = r(mean)
				local ratio = `prev_value' / `current_value'
				qui replace rGDP_LCU = rGDP_LCU * `ratio' if year <= `y' & countryname == "`country'" &	`ratio' != .
				qui drop growth_series1
			}
		}
	}

	qui keep countryname rGDP_LCU year
	
	* Conclude
	di "Breaks adjusted using Stock-Watson if there is no overlapping data"

end


capture program drop adjust_breaks_CPI
program define adjust_breaks_CPI
	
	import excel using "${input}", clear first sheet("Base_years CPI")
	qui ds
	foreach var in `r(varlist)'{
		local ln = strlen("`var'")
		if `ln' > 2 {
			local prev = "`var'"
		}
		else {
			ren `var' `prev'notes
		}
	}
	* Step 1: Generate id variable
	qui gen id = _n

	* Step 2: Reshape the data long
	qui reshape long @notes, i(id) j(countryname) string

	qui ds id countryname notes, not
	foreach var in `r(varlist)'{
		ren `var' year`var'
	}

	qui greshape long year, i(id countryname notes) j(value) string

	qui keep if countryname == value
	qui drop if year == .

	sort countryname year

	qui keep countryname year notes
	


	qui merge 1:1 countryname year using "$output"
	qui sort countryname year
	qui encode countryname, gen(id)
	qui xtset id year
	qui levelsof countryname, local(countries)
	foreach country of local countries {
		qui levelsof year if _merge == 3 & countryname == "`country'" & CPI != ., local(years)
		foreach y of local years {
			* Check if there is overlapping values 
			qui su notes if year == `y' & countryname == "`country'", meanonly
			if r(mean) != . {
				local overlapping_value = r(mean)
				qui su CPI if year == `y' & countryname == "`country'", meanonly
				local current_value = r(mean)
				local ratio = `overlapping_value' / `current_value'
				qui replace CPI = CPI * `ratio' if year <= `y' & countryname == "`country'" &	`ratio' != .
			}
			* Otherwise, use Stock-Waston
			else {
				qui gen growth_series1 = (CPI - L1.CPI)/L1.CPI if inrange(year, `y'-3, `y'+3) & countryname == "`country'"
				qui su CPI if year == `y' + 1 & countryname == "`country'", meanonly 
				local first_value = r(mean)
				qui su growth_series1 if year != `y'+1 & growth_series1 != . & countryname == "`country'", deta
				local prev_value = `first_value' / (1 + r(p50))
				qui su CPI if year == `y' & countryname == "`country'", meanonly
				local current_value = r(mean)
				local ratio = `prev_value' / `current_value'
				qui replace CPI = CPI * `ratio' if year <= `y' & countryname == "`country'" &	`ratio' != .
				qui drop growth_series1
			}
		}
	}

	qui keep countryname CPI year infl
	
	* Conclude
	di "Breaks adjusted using Stock-Watson if there is no overlapping data"

end

capture program drop use_overlapping_data
program define use_overlapping_data

	* Delete strings rows that do not have numbers
	qui ds year, not 
	foreach country in `r(varlist)'{
		qui replace `country' = "" if regexm(`country', "[a-zA-Z]")
	}

	qui missings dropobs, force
	destring_check
	tempvar n
	gen `n' = _n
	levelsof `n' if year == ., clean local(ranks)

	qui ds year, not 
	foreach var in `r(varlist)' {
		foreach rank in `ranks' {
			local location = `rank'-1
			qui replace `var' = `var'[`rank'] if `var'[`rank'] != . in `location'
		}	
	}

end

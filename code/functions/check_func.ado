cap program drop check_func
program define check_func
	syntax, [name(string) country(string) time(string) posratios(string) othratios(string) rates(string) levels(string) indices(string)]
	
	* ==============================================================================
	* Set up and initializing
	* ==============================================================================

	* Create placeholders for potentially dubious values 
	foreach var in check reason reason_outlier reason_corr reason_discrep reason_implaus {
		cap drop `var'
	}
	
	foreach var in check reason_outlier reason_corr reason_discrep reason_implaus {
		qui gen `var' = 0
	}
	
	qui gen strL reason = ""
	
	* Specify locals to include in checking procedure 
	local exclude "`country' `time' countryname reason reason_outlier reason_corr reason_discrep reason_implaus chainlinking_ratio source source_change source_change_count check `name' note"
	unab allvars : *
	local rawvars : list allvars - exclude
	
	* Houskeeping (sort and order)
	sort `country' `time'
	order `time' `country' source `name' check
	
	* Make a panel 
	qui tempvar temp_ID
	qui encode `country', gen(`temp_ID')
	qui xtset `temp_ID' `time'
	
	* ==============================================================================
	* Always tag the very largest values (top and bottom 0.5%)
	* Note that we do this by variable type for this to make sense 
	* ==============================================================================
	
	* Ratios and rates: Can be checked directly 
	loc checkvars `posratios' `othratios' `rates'
	local is_present : list name in checkvars
	if `is_present' {
		qui _pctile `name', percentiles(0.5 99.5)
		qui replace check = 1 if `name'!=. & (`name' < r(r1) | `name' > r(r2))
		qui replace reason = reason + "; Data is in top or bottom 0.5%, flagged out of caution" if `name'!=. & (`name' < r(r1) | `name' > r(r2))
		qui replace reason_outlier = 1 if `name'!=. & (`name' < r(r1) | `name' > r(r2))
	}
	
	* Levels and indices: Check in growth rates 
	loc checkvars `levels' `indices'
	local is_present : list name in checkvars
	if `is_present' {
		qui tempvar growth 
		qui gen `growth' = (`name' - L.`name') / L.`name'
		qui _pctile `growth', percentiles(0.5 99.5)
		qui replace check = 1 if `growth'!=. & (`growth' < r(r1) | `growth' > r(r2))
		qui replace reason = reason + "; Growth rate is in top or bottom 0.5%, flagged out of caution" if `growth'!=. & (`growth' < r(r1) | `growth' > r(r2))
		qui replace reason_outlier = 1 if `name'!=. & (`name' < r(r1) | `name' > r(r2))
	}
	
	* ==============================================================================
	* Check whether GMD values show very large deviations from raw data 
	* ==============================================================================

	* Ratios, rates, and levels can be checked; makes less sense for indices
	loc checkvars `posratios' `othratios' `rates' `levels'
	local is_present : list name in checkvars
	if `is_present' {
	
	* Generate ratio of each raw data source relative to GMD spliced value 
		foreach var of local rawvars {
			qui gen `var'_ratio = `var' / `name'
		}

		* Tag values with implausible discrepancy across sources
		foreach var of local rawvars {
		
			* Get source name 
			loc comp = subinstr("`var'","_`name'","",.)
			
			* Set check flag to 1 in case of very large discrepancy 
			qui replace check = 1 if (abs(`var'_ratio) > 5 | abs(`var'_ratio) < 0.1) & `var'_ratio != .
			
			* Record reason and source with discrepancy 
			qui replace reason = reason + "; +500%/-90% discrepancy between GMD and `comp'" if (abs(`var'_ratio) > 5 | abs(`var'_ratio) < 0.1) & `var'_ratio != .
			qui replace reason_discrep = 1 if (abs(`var'_ratio) > 5 | abs(`var'_ratio) < 0.1) & `var'_ratio != .
		}
	}
	
	* Drop ratios 
	qui drop *_ratio
	
	* ==============================================================================
	* Check whether GMD values show negative correlation with raw data 
	* ==============================================================================
		
	* Loop over all raw data sources 
	foreach var of local rawvars {
		
		* Get source name 
		loc comp = subinstr("`var'","_`name'","",.)

		* Compute country-specific correlation
		qui bysort `temp_ID': egen corr = corr(`name' `var') 
			
		* Set check flag to 1 in case of a low correlation 
		qui replace check = 1 if corr < 0.3 
			
		* Record reason and source with discrepancy 
		qui replace reason = reason + "; <.3 correlation between GMD and `comp'" if corr < 0.3
		qui replace reason_corr = 1 if corr < 0.3
		
		* Drop correlation variable 
		qui drop corr 
	}

	* ==============================================================================
	* Check for implausible values in ratios
	* ==============================================================================
	
	* Only apply to positive ratios 
	local is_present : list name in posratios 
	if `is_present' {

		* Set check flag to 1 if the ratio has close-to-impossible values 
		qui replace check = 1 if `name' !=. & (`name' > 300 | `name' < 0.1)
	
		* Record reason and source with discrepancy 
		qui replace reason = reason + "; Ratio is above 300% or below 0.1%" if `name' !=. & (`name' > 300 | `name' < 0.1)
		qui replace reason_implaus = 1 if `name' !=. & (`name' > 300 | `name' < 0.1)
	}
	
	* Loop over all other ratios (can be negative)
	local is_present : list name in othratios 
	if `is_present' {
	
		* Set check flag to 1 if the ratio has close-to-impossible values 
		qui replace check = 1 if `name' !=. & (`name' > 50 | `name' < -50)
	
		* Record reason and source with discrepancy 
		qui replace reason = reason + "; Ratio is above 50% or below -50%" if `name' !=. & (`name' > 50 | `name' < -50)
		qui replace reason_implaus = 1 if `name' !=. & (`name' > 50 | `name' < -50)
	}
	
	* Reformat
	qui gen strL variables = "`name'"
	qui rename `name' value

	* Trim reason string 
	qui replace reason = substr(reason,3,strlen(reason)) if substr(reason,1,1) == ";"

end
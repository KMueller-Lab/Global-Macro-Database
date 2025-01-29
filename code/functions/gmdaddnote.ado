* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* A PROGRAM TO SAVE NOTES
* 
* Created: 
* 2024-10-13
* 
* Author:
* Karsten Müller
* National University of Singapore
* 	
* ==============================================================================

cap program drop gmdaddnote
program define gmdaddnote
syntax anything [if]

	* Parse if command 
	marksample touse

	* Parse anything such that first mention is variable, second string
	tokenize `anything'
	loc var     `1'
	loc newnote `2'
	
	* Check that ISO3 and year are in dataset 
	cap confirm var ISO3 year 
	if _rc!=0 {
		di "ISO3 and year required."
		exit 198
	}
	
	* Preserve 
	preserve 

	* Write anything into temporary note 
	tempvar note 
	qui gen `note' = "`newnote'" 

	* Only keep relevant variables 
	qui keep ISO3 year `note' `touse'
	
	* Merge based on ISO and year 
	qui merge 1:1 ISO3 year using "$data_temp/notes" , update
	
	* Check that ISO3 year combinations are all in notes file 
	cap assert _merge!=1
	if _rc!=0 {
		di as err "Dataset contains ISO3-year combinations not in notes file."
		exit 198
	}
	
	* Drop merge variable 
	qui drop _merge 

	* Check that variable exists in notes file 
	cap confirm var `var' 
	
	* If not, create variable 
	if _rc!=0 {
		qui gen `var' = ""
	}

	* Add anything note to existing note 
	qui replace `var' = strtrim(`var' + " " + `note') if `touse'
	
	* Drop temporary variable 
	qui drop `note' `touse'
	
	* Save notes file 
	qui save "$data_temp/notes", replace 
	
	* Note added 
	di "Added note to `var'."
	
	* Restore 
	restore 

end






	/*



	OLD APPROACH
	
	
	* Merge 
	use "$data_helper/notes", clear		
	
	
	* Assert that country exists 
	qui gmdisolist 
	if regexm("$gmdisolist","`iso'") == 0 {
		di as error "`iso' is not a gmd country."
		exit 198
	}
	
	* Assert that variable exists 
	qui gmdvarlist
	if regexm("$gmdvarlist","`variable'") == 0 {
		di as error "`variable' is not a gmd variable."
		exit 198
	}	

	* Assert that source exists, if specified 
	qui gmdsourcelist
	if regexm("$gmdsourcelist","`source'") == 0 & "`source'" != "" {
		di as error "`source' is not a gmd source."
		exit 198
	}	
	
	* Get start and end years 
	tokenize `years'
	loc first `1'
	loc last  `2'

	* Preserve dataset 
	preserve 

	* Open notes dataset 
	use "$data_helper/notes", clear		
		
	* Replace notes if only ISO and variable specified 
	if "`years'" == "" & "`source'" == "" {
		
		makerow, iso(string) variable(string) 
		replace notes = notes + "`anything'" if iso3 == "`iso'" & variable == "`variable'" 
		
	}
	
	* Replace notes if years but not source is specified
	if "`years'" != "" & "`source'" == "" {
	
		replace notes = notes + "`anything'" if iso3 == "`iso'" & variable == "`variable'" & year>=`first' & year<=`last'
		
	}
	
	* Replace notes if source but not years is specified
	if "`years'" != "" & "`source'" != "" {
	
		replace notes = notes + "`anything'" if iso3 == "`iso'" & variable == "`variable'" & source == "`source'"
		
	}

	* Replace notes if both source and years are specified 
	if "`years'" != "" & "`source'" != "" {
	
		replace notes = notes + "`anything'" if iso3 == "`iso'" & variable == "`variable'" & year>=`first' & year<=`last' & source == "`source'"
		
	}	
	
	* Save 
	save "$data_helper/notes", replace 
	
	* Restore 
	restore 
}
end

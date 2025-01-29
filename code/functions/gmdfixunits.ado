* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* A PROGRAM TO CONVERT UNITS AND SAVE THIS INFORMATION
* 
* Created: 
* 2024-10-24
* 
* Author:
* Karsten Müller
* National University of Singapore
* 	
* ==============================================================================

cap program drop gmdfixunits
program define gmdfixunits
syntax varlist (max=1) [if] [, divide(string) multiply(string) absolute missing replace(string)]

	* Check if any option is specified 
	if "`divide'" == "" & "`multiply'" == "" & "`absolute'" == "" & "`missing'" == "" & "`replace'" == ""{
		di as err "No option specified for converting units."
		exit 198
	}

	* Check that only divide or multiply is specified
	if "`divide'" != "" & "`multiply'" != "" {
		di as err "Only multiply or divide option can be specified."
		exit 198
	}
	
	* Check that ISO3 and year are in dataset 
	cap confirm var ISO3 year 
	if _rc!=0 {
		di "ISO3 and year required to store in notes."
		exit 198
	}
	
	* If absolute is specified, take absolute values 
	if "`absolute'" != "" {
		replace `varlist' = abs(`varlist')
		gmdaddnote `varlist' "Doubtful units in raw data fixed by using absolute value of `absolute'." `if'
	}
	
	* Divide units, record it in the documentation
	if "`divide'" != "" {
		replace `varlist' = `varlist' / `divide' `if'
		gmdaddnote `varlist' "Doubtful units in raw data fixed by dividing by `divide'." `if'
	}

	* Multiply units, record it in the documentation
	if "`multiply'" != "" {
		replace `varlist' = `varlist' * `multiply' `if'
		gmdaddnote `varlist' "Doubtful units in raw data fixed by multiplying with `multiply'." `if'
	}

	* Replace with missing, record it in the documentation
	if "`missing'" != "" {
		replace `varlist' = . `if'
		gmdaddnote `varlist' "Doubtful value in raw data dropped." `if'
	}
	
	* Replace with value, record it in the documentation
	if "`replace'" != "" {
		replace `varlist' = `replace' `if'
		gmdaddnote `varlist' "Doubtful value in raw data fixed by replacing with `replace'. See code for details." `if'
	}

	
end

* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* MAXIMIZE AVAILABILITY ACROSS SOURCES
* 
* Author:
* Karsten Müller
* National University of Singapore
*
* Description: 
* This Stata program combines different to derive data for a new variable.
*
* Created: 
* 2024-10-15
* ==============================================================================


capture program drop gmdcalculate
program define gmdcalculate
    syntax varlist, [Multiply Divide Replace SPLice]
	
	* Check if one condition is specified 
	if "`multiply'" == "" & "`divide'" == "" {
		di as err "At least one option (divide or multiply) must be specified."
		exit 198
	}

	* Make sure only one condition is specified 
	if "`multiply'" != "" & "`divide'" != "" {
		di as err "Only one option (divide or multiply) can be specified."
		exit 198
	}
	
	* Get variables 
	tokenize `varlist'
	loc result 		`1'
	loc numerator 	`2'
	loc denominator `3'
    
	* Get labels
	
	* Save original variable values so we can calculate the difference later 
	tempvar original 
	qui gen `original' = `result'
	
	* Display 
	di ""
	
	* Specify whether to replace non-missing data or not
	if "`replace'" == "" loc end "if `result' == ."
	if "`replace'" != "" di "Note: Non-missing values will be replaced."

	
	* If not using any splicing, derive variable of interest
	if "`splice'" == "" {
		if "`multiply'" == "multiply" {
		
			di "Calculating `result' by multiplying `numerator' with `denominator'."
			di ""
			
			* Calculate 
			noisily replace `result' = `numerator' * `denominator' `end'
			di "" 
			
			* Save number of changed observations 
			qui count if `result' != `original'
			if `r(N)' > 0 gmdaddnote `result' "Derived by multiplying `labnum' with `labden'." if `result' != `original'
		
		}
		
		if "`divide'" 	== "divide"  {
			
			di "Calculating `result' by dividing `numerator' by `denominator'."
			di ""
			
			* Calculate 
			noisily replace `result' = `numerator' / `denominator' `end'
			di "" 
			
			* Save number of changed observations 
			qui count if `result' != `original'
			if `r(N)' > 0 gmdaddnote `result' "Derived by dividing `labnum' by `labden'." if `result' != `original'

		}
	}
	
	* If using splicing, derive variable of interest using chain-linking 
	*if "`splice'" == "`splice'" {
	*	di as err "Splicing functionality not yet implemented."
	*}	

end

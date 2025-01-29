* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* A PROGRAM TO SAVE DOWNLOAD DATES 
* 
* Created: 
* 2024-10-13
* 
* Author:
* Karsten Müller
* National University of Singapore
* 	
* ==============================================================================

cap program drop gmdsavedate
program define gmdsavedate
syntax, Sourceabbr(string)

	* Make date 
	loc ddate = string(date(c(current_date), "DMY"), "%tdCCYY-NN-DD")


	* Get gmd source list 
	qui gmdsourcelist

	* If variable not in gmd source list, throw error
	if regexm("$gmdsourcelist","`sourceabbr'") == 0 {
		di as error "`sourceabbr' is not a gmd source."
	}
	
	* If variable is in gmd variable list, save download date 
	if regexm("$gmdsourcelist","`sourceabbr'") == 1 {	
		
		* Preserve dataset 
		preserve 

		* Open download dates dataset 
		qui use "$data_temp/download_dates", clear		
		
		* Check if source is already recorded 
		qui count if source_abbr == "`sourceabbr'"
		loc count = r(N)
		
		* If yes, replace download date 
		if `count' > 0 {
			qui replace download_date = "`ddate'" if source_abbr == "`sourceabbr'"
		}
		* If not, extend dataset by one row 
		if `count' == 0 {
			loc obs = _N + 1
			qui set obs `obs'
				
			qui replace download_date = "`ddate'" in `obs'
			qui replace source_abbr = "`sourceabbr'" in `obs'
		}
		
		* Save 
		qui save "$data_temp/download_dates", replace 
		
		* Restore 
		restore 
	}
end

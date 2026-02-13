qui {
	* ==============================================================================
	* GLOBAL MACRO DATABASE
	* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
	* ==============================================================================
	*
	* VALIDITY CHECKS FOR COMBINE FILES
	* 
	* Description: 
	* This Stata program checks that all variables have combine files
	*
	* Author:
	* Mohamed Lehbib
	* National University of Singapore
	*
	* Created: 
	* 2025-08-05
	*
	* ==============================================================================
	import delimited using "$docvars", clear varnames(1)

	* Keep the files that are supposed to be combined
	keep if derived != "Yes" & notelabel == "" & finalvarlist == "Yes"

	* Keep final column 
	keep codes

	* Save temporarily
	tempfile temp
	save `temp', replace

	* Import the list of combined files 
	filelist, dir($code_combine)

	* Extract the variable name 
	gen codes = subinstr(filename, ".do", "", .)

	* Drop archives 
	drop if strpos(dirname, "Archive")

	* Merge with the codes list 
	merge 1:1 codes using `temp'

	* Assert that the only not matched file in the run_input_variables which contains nGDP, pop, and USDfx combine code 
	cap assert _merge == 3 if codes !=  "A_run_input_variables" & codes != "A_run_input_variables_2" & codes != "CA_GDP" & codes != "CA_USD" & codes != "Heatmaps_by_country"
	

	* Print outcome message 
	if _rc == 0 {
		noi di "All variables have files"
	}
	else {
		count if _merge == 1 & codes != "run_input_variables"
		if r(N) > 0 {
			qui levelsof codes if _merge == 1, clean local(missing_sources)
			noi di "These variables `missing_sources' don't have combine files"
			exit 498
		}
		count if _merge == 2 
		if r(N) > 0 {
			qui levelsof codes if _merge == 2, clean local(missing_sources)
			noi di "These files `missing_sources' are for variables that are not supposed to be combined"
			exit 498
		}
		
	}
}


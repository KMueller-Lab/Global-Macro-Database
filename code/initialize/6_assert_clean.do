qui {
	* ==============================================================================
	* GLOBAL MACRO DATABASE
	* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
	* ==============================================================================
	*
	* VALIDITY CHECKS FOR RAW DATA 
	* 
	* Description: 
	* This Stata program checks that all raw data has clean code
	*
	* Author:
	* Mohamed Lehbib
	* National University of Singapore
	*
	* Created: 
	* 2025-08-05
	*
	* ==============================================================================

	* Assert each dataset has a clean file 
	filelist, dir($data_raw) 
	
	* Delete all stswp files
	if "`c(os)'" == "Windows" {
			shell del "*.stswp" /q /s
		}
	else {
		shell find . -name "*.stswp" -type f -delete
		shell find . -name ".DS_Store" -type f -delete
		
	}


	* Drop versions folder 
	drop if strpos(dirname, "Versions")

	* For aggregators, check the final dataset is processed. For example, UN has multiple raw files however we output one file for the UN. 
	gen source_abbr = substr(dirname, strrpos(dirname, "/")+1, .) if strpos(dirname, "aggregators")

	* Harmonize the name for GNA 
	replace source_abbr = "GNA" if strpos(dirname, "GNA")

	* For country level, take the unique file names
	replace source_abbr = substr(filename, 1, 5) if !strpos(dirname, "aggregators")

	* Keep one observation per dataset 
	keep source_abbr
	qui duplicates drop 
	
	* For Mitchell, we should have only one final variable, the check for the individual Mitchell files is performed later
	drop if strpos(source_abbr, "MITCHELL") 
	drop if strpos(source_abbr, "Mitchell") 

	* Save 
	tempfile temp 
	save `temp', replace 

	* Get the list of all the clean files 
	filelist, dir($code_clean)

	* Extract source name 
	gen source_abbr = substr(filename, 1, strlen(filename)-3)

	* For Mitchell, we should have only one final variable, the check for the individual Mitchell files is performed later
	drop if strpos(dirname, "MITCHELL") 
	drop if strpos(dirname, "Mitchell") 
	drop if strpos(source_abbr, "MITCHELL") 
	drop if strpos(source_abbr, "Mitchell") 

	* Drop duplicates and keep the final column 
	keep source_abbr
	qui duplicates drop

	* Merge and assert 
	cap merge 1:1 source_abbr using `temp', assert(3)

	count if _merge == 1 & source_abbr != "Mitchell" & source_abbr != "MITCHELL"
	if r(N) > 0 {
		qui levelsof source_abbr if _merge == 1, clean local(missing_sources)
		noi di "These datasets `missing_sources' don't have processing files"
		exit 498
	}
	count if _merge == 2 & source_abbr != "Mitchell" & source_abbr != "MITCHELL"  & source_abbr != "WB"
	if r(N) > 0 {
		qui levelsof source_abbr if _merge == 2, clean local(missing_sources)
		noi di "These files `missing_sources' don't have datasets, likely the dataset is not correctly named"
		exit 498
	}
}

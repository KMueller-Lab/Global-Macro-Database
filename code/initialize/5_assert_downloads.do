qui {
	* ==============================================================================
	* GLOBAL MACRO DATABASE
	* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
	* ==============================================================================
	*
	* VALIDITY CHECKS ON DOWNLOAD FILES
	* 
	* Description: 
	* This Stata program checks that all automated sources have download files
	*
	* Author:
	* Mohamed Lehbib
	* National University of Singapore
	*
	* Created: 
	* 2025-08-05
	*
	* ==============================================================================
	* Import the sources list 
	import delimited using "${data_helper}/sources.csv", clear varnames(1) stringc(_all) bindquote(strict)

	* Keep the relevant columns
	keep source_abbr download_method

	* Keep unique rows
	qui duplicates drop

	* Keep the files whose download is automatic
	keep if download_method != "Manual"


	* Save temporarily
	tempfile temp
	save `temp', replace

	* Assert that all the remaining files have a download file
	filelist, dir($code_download) 

	* Keep relevant column and rename 
	keep filename
	ren filename source_abbr

	* Remove the suffix .do from the name
	replace source_abbr = subinstr(source_abbr, ".do", "", .)

	* Merge
	cap merge 1:1 source_abbr using `temp', assert(3)

	* Print outcome message 
	if _rc == 0 {
		noi di "All automated datasets have download files"
	}
	else {
		count if _merge == 2
		if r(N) > 0 {
			qui levelsof source_abbr if _merge == 2, clean local(missing_sources)
			noi di "These sources `missing_sources' don't have download files"
			exit 498
		}
		count if _merge == 1 
		if r(N) > 0 {
			qui levelsof source_abbr if _merge == 1, clean local(missing_sources)
			noi di "These sources `missing_sources' have download files but are not tagged as automated"
			exit 498
		}
		
	}
}

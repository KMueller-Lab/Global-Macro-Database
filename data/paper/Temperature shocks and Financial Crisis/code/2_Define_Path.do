
* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* DEFINE PATH IN SECTION 4
* 
* Author:
* Chenzi Xu
* University of California, Berkeley
*
* Last Editor:
* Yachi Tu
* University of California, Berkeley
*
* Created: 2025-01-15
* Last updated: 2025-01-15
*
* ==============================================================================





* Define the path

	** Project address
	cd ..
	global GMP "`c(pwd)'"	// the parent folder of THIS file

	** Data sources	
	global data "$GMP/data"
	global TemperatureData "$data/Berkeley Earth/country-by-country-DTA"
	global GlobalTempData "$data/Berkeley Earth/global-DTA"
	global BK "data/Reference/bk_micc_replication"	// BK Replication package
	
	** store the intermediate results
	global temp "$GMP/temp" 
	cap mkdir "$temp"

	** Output address
	global Result "$GMP/result"
	cap mkdir "$Result"
	
	global ArchiveResult "$Result/Archive"
	cap mkdir "$ArchiveResult"
	
	cd "$GMP" 

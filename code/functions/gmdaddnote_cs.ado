* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* A PROGRAM TO SAVE NOTES
* 
* Created: 
* 2025-01-24
* 
* Author:
* Karsten Müller
* National University of Singapore
* 	
* ==============================================================================

cap program drop gmdaddnote_source
program define gmdaddnote_source
syntax anything

    * Parse arguments
    tokenize `anything'
    loc source   `1'
    loc newnote  `2'
	loc variable `3'
    
    * Preserve 
    preserve 
    
    * Create new one-row dataset with source and note
    clear
    set obs 1
    qui gen source = "`source'"
    qui gen note = "`newnote'"
	qui gen variable = "`variable'"
	
	* Add citation to source
	qui replace source = "\cite{" + source + "}"
	
    * Append to existing notes file
    qui append using "$data_temp/notes_sources"
	* Drop duplicates 
	qui duplicates drop source note variable, force
	
	* Save
    qui save "$data_temp/notes_sources", replace 
    
    * Restore 
    restore 
end
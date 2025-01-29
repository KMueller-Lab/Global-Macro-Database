* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* A SIMPLE PROGRAM THAT GETS THE MASTER LIST OF VARIABLES
* 
* Description: 
* This Stata program writes the list of variables into a global.
*
* Created: 
* 2024-04-18
*
* Author:
* Karsten Müller
* National University of Singapore
*
* ==============================================================================

* ==============================================================================
* DEFINE PROGRAM SYNTAX 
* ==============================================================================

cap program drop gmdvarlist
program define gmdvarlist

* ==============================================================================
* GET VARIABLES LIST
* ==============================================================================

* Preserve 
preserve 

* Open country list file 
qui import delimited "$data_helper/sources.csv", varnames(1) clear

* Get list of ISO3 codes 
qui levelsof varabbr, loc(gmdvarlist) clean 
glo gmdvarlist "`gmdvarlist '"

* Message 
di "Stored unique variable abbreviations in master list in global 'gmdvarlist'."

* Restore 
restore 

end

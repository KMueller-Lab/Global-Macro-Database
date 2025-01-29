* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* A SIMPLE PROGRAM THAT GETS THE MASTER LIST OF SOURCES
* 
* Description: 
* This Stata program writes the list of sources into a global.
*
* Created: 
* 2024-10-13
*
* Author:
* Karsten Müller
* National University of Singapore
*
* ==============================================================================

* ==============================================================================
* DEFINE PROGRAM SYNTAX 
* ==============================================================================

cap program drop gmdsourcelist
program define gmdsourcelist

* ==============================================================================
* GET VARIABLES LIST
* ==============================================================================

* Preserve 
preserve 

* Open country list file 
qui import delimited "$data_helper/sources.csv", varnames(1) clear

* Get list of ISO3 codes 
qui levelsof source_abbr, loc(gmdsourcelist) clean 
glo gmdsourcelist "`gmdsourcelist '"

* Message 
di "Stored unique source abbreviations in global 'gmdsourcelist'."

* Restore 
restore 

end

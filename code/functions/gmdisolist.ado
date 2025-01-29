* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* A SIMPLE PROGRAM THAT GETS THE MASTER LIST OF COUNTRIES
* 
* Description: 
* This Stata program writes the list of countries into a global.
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

cap program drop gmdisolist
program define gmdisolist

* ==============================================================================
* GET COUNTRY LIST 
* ==============================================================================

* Preserve 
preserve 

* Open country list file 
qui use "$data_helper/countrylist", clear 

* Get list of ISO3 codes 
qui levelsof ISO3, loc(gmdisolist) clean 
glo gmdisolist "`gmdisolist'"

* Message 
di "Stored unique ISO codes in master list in global 'gmdisolist'."

* Restore 
restore 

end

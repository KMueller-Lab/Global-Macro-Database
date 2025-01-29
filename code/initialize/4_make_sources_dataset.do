* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CREATE SOURCE NOTES LOG
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 
* 2025-01-24
*
* ==============================================================================
* CREATE BLANK SOURCE TRACKING DATASET
* ==============================================================================

* Create empty dataset with required columns
clear
set obs 1
gen source  = ""
gen note = ""
gen variable = ""

* Add labels
label var source  "Source name"
label var note "Note"
label var variable "Variable"

* Save in temp folder
save "$data_temp/notes_sources", replace
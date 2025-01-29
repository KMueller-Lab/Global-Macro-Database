* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* A PROGRAM TO SPLICE TOGETHER DIFFERENT SOURCES TO CREATE A HARMONIZED TIME SERIES
* 
* Created: 
* 2024-06-28
* 
* Author:
* Karsten Müller
* National University of Singapore
* 	
* ==============================================================================

*************************************************
***** Define program
*************************************************
cap program drop data_export
program define data_export
syntax anything, Name(string) [Round(string)] [whole]

*************************************************
***** Add comma for values in thousands
*************************************************
if "`whole'"!="" {
	loc anything = string(`anything',"%9.0gc")
}

else {
	loc anything = string(`anything',"%9.0f")
}

*************************************************
***** Set rounding to 2 decimals, unless specified
*************************************************
if "`round'" != "" & "`round'" != "1" {
    loc anything = string(`anything', "%9`round'f")
}

if "`round'" == "" & "`whole'" == "" & "`round'" != "1" {
    loc anything = string(`anything', "%9.1f")
}

if "`round'" == "1" {
	loc anything = string(`anything', "%9.0f")
}


*************************************************
***** Set up file write
*************************************************

* If first letter is ".", add leading zero 
if substr("`anything'",1,1) == "." {
	loc anything = "0"+"`anything'"
}

* Add % sign for LaTeX 
loc anything = "`anything'"+"%"
di "Exporting: `anything'"

* Output 
tempname `name'
file open `name' using "$numbers/`name'.tex", write text replace
file write `name' "`anything'"
file close `name'

end
*

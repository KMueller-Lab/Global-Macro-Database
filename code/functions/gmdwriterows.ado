* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* A PROGRAM TO OUTPUT THE DATASET IN THE CURRENT DATAFRAME 
* 
* Created: 
* 2024-10-13
* 
* Author:
* Karsten Müller
* National University of Singapore
* 	
* ==============================================================================

cap program drop gmdwriterows
program define gmdwriterows
syntax varlist (min=1), path(string)

	* Preserve dataset 
	preserve 

	* Only keep varlist 
	keep `varlist'
	
	* From here on, be quiet
	qui {

	* Make temporary name for output file at specified path
	tempname export
	file open `export' using "`path'", write text replace

	* Turn columns into one seperated by "&"
	gen writecolumn = ""
	ds writecolumn, not 
	
	foreach c in `r(varlist)' {
		replace writecolumn = writecolumn + `c' + " & " if `c' != "[0.5em]"
	
	}
	
	* Make last "&" "\\" for next line 
	replace writecolumn = substr(writecolumn,1,strlen(writecolumn)-3)
	replace writecolumn = writecolumn + " \\" if _n != _N | writecolumn == "[0.5em]" 
	
	* Only keep write column 
	keep writecolumn
	
	* Loop over rows, write into file 
	loc obs = _N

	}
	forval n = 1/`obs' {
		loc value = writecolumn[`n']
		file write `export' "`value'" _n
	}
	
	file close `export'
		
	* Restore dataset 
	restore 
	
end

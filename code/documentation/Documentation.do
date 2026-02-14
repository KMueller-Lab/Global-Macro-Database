* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCT THE DOCUMENTATION FOR ALL VARIABLES
* 
* Created: 
* 2024-06-28
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 	
* ==============================================================================


* Create the final documentation dataset
clear
tempfile documentation
save `documentation', replace emptyok

local vars nGDP rGDP inv finv cons exports /// 
		    imports CA_GDP  gen_govexp_GDP cgovexp_GDP gen_govrev_GDP ///
			cgovrev_GDP gen_govtax_GDP cgovtax_GDP gen_govdef_GDP ///
			cgovdef_GDP gen_govdebt_GDP cgovdebt_GDP CPI HPI infl ///
		   pop unemp USDfx REER strate ltrate cbrate M0 M1 M2 M3 M4
foreach var of local vars {
	use "$data_final/documentation_`var'", clear
	
	* Append to documentation
	append using `documentation'
	
	* Save
	save `documentation', replace
}

* Save the documentation
save "$data_final/documentation", replace

* Merge in the notes
merge m:1 source variable using  ///
"$data_temp/notes_sources.dta", nogen
replace notes = notes + " " + note
drop note

* Save the documentation  
save "$data_final/documentation", replace


* ==============================================================================
* 	CREATE THE MASTER DOCUMENTATION
* ==============================================================================

gmdcombinedocs nGDP rGDP inv finv cons exports ///
			   imports CA_GDP gen_govexp_GDP cgovexp_GDP  /// 
			   gen_govrev_GDP cgovrev_GDP gen_govtax_GDP ///
			    cgovtax_GDP gen_govdef_GDP cgovdef_GDP gen_govdebt_GDP ///
				 cgovdebt_GDP CPI HPI infl ///
			   pop unemp USDfx REER strate ltrate cbrate M0 M1 M2 M3 M4

* ==============================================================================
* 	CREATE THE COUNTRY SPECIFIC DOCUMENTATION
* ==============================================================================
use "$data_final/documentation", clear
gmdmakedoc_cs


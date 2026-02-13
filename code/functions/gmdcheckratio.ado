* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* VALIDITY CHECKS FOR DERIVED RATIOS
* 
* Description: 
* This Stata program checks that all cases where we have levels and GDP were 
* used to derive ratios
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 
* 2025-12-25
*
* ==============================================================================


cap program drop check_gdp_ratios
program define check_gdp_ratios 
	args source
    
    * Define variables to check
    local varlist cgovdebt cgovexp cgovtax cgovdef cgovrev gen_govdebt gen_govexp gen_govtax gen_govdef gen_govrev cons inv finv exports imports
    
    * Check if nGDP exists
    cap confirm variable `source'_nGDP
    if _rc {
        di as err "`source'_nGDP not found - cannot verify GDP ratios"
        error 111
    }
    
    * Check each variable for corresponding _GDP ratio
    foreach var of local varlist {
        cap confirm variable `source'_`var'
        if _rc == 0 {
            * Variable exists - check for ratio
            cap confirm variable `source'_`var'_GDP
            if _rc {
                di as err "`var' exists but `var'_GDP missing"
                error 111
            }
        }
    }
	
	* Check each ratio for corresponding level 
    foreach var of local varlist {
        cap confirm variable `source'_`var'_GDP
        if _rc == 0 {
            * Variable exists - check for level
            cap confirm variable `source'_`var'
            if _rc {
                di as err "`var'_GDP exists but `var' missing"
                error 111
            }
        }
    }
    
    di as text "All GDP ratios verified successfully"
	di as text "All level variables verified successfully"
end

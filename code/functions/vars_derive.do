* ==============================================================================
* CREATE DERIVED VARIABLES 
* ==============================================================================

* ==============================================================================
* CENTRAL GOVERNMENT FINANCES 
* ==============================================================================
* Central government revenue 
use "$data_final/chainlinked_cgovrev_GDP", clear 
keep ISO3 year cgovrev_GDP source 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen cgovrev = (cgovrev_GDP * nGDP) / 100
replace source = "Derived using data on central government revenue to GDP from " + source + " and the spliced GDP"
save "$data_final/chainlinked_cgovrev", replace

* Central government expenditure 
use "$data_final/chainlinked_cgovexp_GDP", clear 
keep ISO3 year cgovexp_GDP source 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen cgovexp = (cgovexp_GDP * nGDP) / 100
replace source = "Derived using data on central government expenditure to GDP from " + source + " and the spliced GDP"
save "$data_final/chainlinked_cgovexp", replace

* Central government tax revenue 
use "$data_final/chainlinked_cgovtax_GDP", clear 
keep ISO3 year cgovtax_GDP source 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
replace source = "Derived using data on central government tax revenue to GDP from " + source + " and the spliced GDP"
save "$data_final/chainlinked_cgovtax", replace

* Central government debt  
use "$data_final/chainlinked_cgovdebt", clear 
keep ISO3 year cgovdebt_GDP source 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
replace source = "Derived using data on central government debt to GDP from " + source + " and the spliced GDP"
save "$data_final/chainlinked_cgovdebt", replace

* Central government deficit
use "$data_final/chainlinked_cgovdef_GDP", clear 
keep ISO3 year cgovdef_GDP source 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
replace source = "Derived using data on central government deficit to GDP from " + source + " and the spliced GDP"
save "$data_final/chainlinked_cgovdef_GDP", replace



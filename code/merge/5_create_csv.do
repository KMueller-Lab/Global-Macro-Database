* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* EXPORT VARIABLE SPECIFIC DATA INTO CSV 
*
* ==============================================================================
* OPEN BLANK COUNTRY-YEAR PANEL 
* ==============================================================================

* Open master list of countries 
use "$data_temp/blank_panel", clear 

* ==============================================================================
* MERGE IN ALL DATASETS WHILE CHECKING CONSISTENCY 
* ==============================================================================

* Preserve 
preserve 

* Get files 
filelist, directory($data_final) pat(*.dta) 

* Keep only individual files we need
drop if strpos(filename,"clean_data_wide.dta")
drop if strpos(filename,"data_final.dta")
drop if strpos(filename,"documentation.dta")
drop if strpos(filename,"documentation")
drop if strpos(filename,"GMD.xlsx")
drop if strpos(filename,"chainlinked_rGDP_USD.dta")

* Extract varnames from filenames
gen identifier = regexs(1) if regexm(filename, "chainlinked_(.+)\.dta")
levelsof identifier, local(varnames) clean

* Restore 
restore 

* Derive the version 
local version = "$current_version"
di "`version'"

* Loop and export into csv
foreach var of loc varnames {

	* Print name of file that is being merged
	di "Exporting the file `var'"
	
	* Import the data
	qui use "$data_final/chainlinked_`var'.dta", clear 
	
	* Add countryname
	qui merge m:1 ISO3 using $isomapping, keepus(countryname) nogen assert(2 3) keep(3) 
	order countryname
	
	* Order 
	order ISO3 countryname year `var'
	
	* Minimal processing
	qui ren *_`var' *
	
	* Delete all columns labels
	foreach lab_var of varlist _all {
		label variable `lab_var' ""
	}
		
	* Export 
	qui export delimited using "$data_distr/`var'_`version'.csv", replace
	
}



* Derive the version 
local version = "$current_version"
di "`version'"


* Output the other variables
use "$data_final/data_final", clear
keep countryname ISO3 year nGDP rGDP deflator
gen source = "derived"
drop if deflator == .
gen note = "This variable is derived from the spliced values of nGDP and rGDP."
export delimited using "$data_distr/deflator_`version'.csv", replace


use "$data_final/data_final", clear
keep countryname ISO3 year CA CA_GDP nGDP
drop if CA == .
gen source = "derived"
gen note = "This variable is derived from the spliced values of nGDP and CA_GDP."
export delimited using "$data_distr/CA_`version'.csv", replace


use "$data_final/data_final", clear
keep countryname ISO3 year pop rGDP_pc rGDP
drop if rGDP_pc == .
gen source = "derived"
gen note = "This variable is derived from the spliced values of real GDP and pop."
export delimited using "$data_distr/rGDP_pc_`version'.csv", replace


use "$data_final/data_final", clear
keep countryname ISO3 year rGDP rGDP_USD USDfx nGDP
bys ISO3: gen x = USDfx if year == 2015
bys ISO3: egen USDfx_2015 = max(x)
drop USDfx x
gen source = "derived"
drop if rGDP_USD == .
gen note = "This variable is derived from the spliced values of real GDP and the exchange rate at the base year."
export delimited using "$data_distr/rGDP_USD_`version'.csv", replace


use "$data_final/data_final", clear
keep countryname ISO3 year SovDebtCrisis
gen source = "Derived"
gen note = "This variable combines two measures of debt crises prioritizing the measure from Laeven and Valencia and using data from Reinhart and Rogoff where their data is not available."
export delimited using "$data_distr/SovDebtCrisis_`version'.csv", replace


use "$data_final/data_final", clear
keep countryname ISO3 year CurrencyCrisis
gen source = "Derived"
gen note = "This variable combines two measures of currency crises prioritizing the measure from Laeven and Valencia and using data from Reinhart and Rogoff where their data is not available."
export delimited using "$data_distr/CurrencyCrisis_`version'.csv", replace


use "$data_final/data_final", clear
keep countryname ISO3 year BankingCrisis
gen source = "Derived"
gen note = "This variable is a harmonized measure of banking crises using Baron, Verner, and Xiong (2019); Laeven and Valencia (2020); Jordà, Schularick, and Taylor (2017); and Reinhart and Rogoff (2019)."
export delimited using "$data_distr/BankingCrisis_`version'.csv", replace


* Output the GMD as csv
use "$data_final/data_final", clear
export delimited using "$data_distr/GMD_`version'.csv", replace

* Output the GMD as dta
use "$data_final/data_final", clear
save "$data_distr/GMD_`version'", replace





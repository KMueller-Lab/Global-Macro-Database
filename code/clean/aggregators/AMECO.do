* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
* CLEAN AMECO DATA
* 
* Author:
* Ziliang Chen
* National University of Singapore
* 
* Created: 2024-07-20
*
* Description: 
* Script to process and output a final dataset.
*  
* ==============================================================================

* ==============================================================================
*			SET UP
* ==============================================================================

clear
global input "${data_raw}/aggregators/AMECO/AMECO"
global output "${data_clean}/aggregators/AMECO/AMECO"

* Open
use "${input}", clear

* Keep only relevant columns
keep period geo dataset_code series_code value frequency dataset_name unit

* Destring variables
drop if value == "NA"
destring period value, replace

* Drop unused regions
drop if inlist(geo, "ca12", "da12", "du15", "ea12", "ea19")
drop if inlist(geo, "ea20", "eu15", "eu27", "cu15", "d-w")
gen unit_nGDP = "mrd-" + geo

* Extract indicator
gen indicator = ""
replace indicator = "cons" if dataset_code == "UCNT" & !inlist(unit, "mrd-pps", "mrd-ecu-eur")
replace indicator = "pop" if dataset_code == "NPTD"
replace indicator = "rGDP" if dataset_code == "OVGD" 
replace indicator = "finv" if dataset_code == "UIGT" &  !inlist(unit, "mrd-pps", "mrd-ecu-eur")
replace indicator = "inv" if dataset_code == "UITT" &  !inlist(unit, "mrd-pps", "mrd-ecu-eur")
replace indicator = "nGDP" if dataset_code == "UVGD" & !inlist(unit, "mrd-pps", "mrd-ecu-eur", "pps-eu-15-100", "eur-eu-15-100", "pps-eu-27-100", "eur-eu-27-100")
replace indicator = "unemp" if dataset_code == "NUTN"
replace indicator = "imports" if dataset_code == "UMGS" &  !inlist(unit, "mrd-pps", "mrd-ecu-eur")
replace indicator = "REER" if dataset_code == "XUNRQ-1"
replace indicator = "exports" if dataset_code == "UXGS" &  !inlist(unit, "mrd-pps", "mrd-ecu-eur")
replace indicator = "ltrate" if dataset_code == "ILN" & unit == "-"
replace indicator = "strate" if dataset_code == "ISN" & unit == "-"
replace indicator = "CPI" if dataset_code == "ZCPIN"
drop if indicator == ""

* Keep
keep geo value period indicator

* Reshape
greshape wide value, i(geo period) j(indicator)

* Rename
ren value* *
replace geo = upper(geo)
ren geo ISO3
ren period year

* Convert unit
replace unemp = unemp / 1000
replace pop = pop / 1000
foreach var in cons exports finv imports nGDP rGDP inv {
    replace `var' = `var' * 1000
}

* Calculate the unemployment rate 
replace unemp = (unemp / pop) * 100

* Fix Romania's ISO3 code
replace ISO3 = "ROU" if ISO3 == "ROM"

* Add ratios to gdp variables
gen cons_GDP    = (cons / nGDP) * 100
gen imports_GDP = (imports / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100
gen finv_GDP    = (finv / nGDP) * 100
gen inv_GDP     = (inv / nGDP) * 100

* Add the deflator
gen deflator = (nGDP / rGDP) * 100

* Rebase the GDP to 2010
* Loop over all countries
qui levelsof ISO3, local(countries) clean
foreach country of local countries {
	
	* Rebase to 2010
	qui gen  temp = deflator if year == 2010 & ISO3 == "`country'"
	qui egen defl_2010 = max(temp) if ISO3 == "`country'"
	qui replace rGDP = (rGDP * defl_2010) / 100 if ISO3 == "`country'"
	qui drop temp defl_2010	
}

* Update the deflator
replace deflator = (nGDP / rGDP) * 100

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)' {
	ren `var' AMECO_`var'
}


* ==============================================================================
* 				Output
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplciates
isid ISO3 year

* Save
save "${output}", replace

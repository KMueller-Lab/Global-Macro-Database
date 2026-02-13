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

* Destring variables
destring year value, replace

* Drop regional aggregat
drop if regexm(Country, "[0-9]") // Euro area (19 countries)
drop if inlist(Country, "Euro area", "European Union")

* Extract indicator
gen indicator = ""

* Consumption
replace indicator = "cons"           if code == "UCNT"

* GDP 
replace indicator = "nGDP"           if code == "UVGD" 
replace indicator = "rGDP"           if code == "OVGD" 

* Investment
replace indicator = "inv"            if code == "UITT"
replace indicator = "finv"           if code == "UIGT" 

* Population and labor
replace indicator = "pop"            if code == "NPTN"
replace indicator = "unemp"          if code == "ZUTN"

* Trade variables 
replace indicator = "exports"        if code == "UXGS" 
replace indicator = "imports"        if code == "UMGS"
 
* Interest rates
replace indicator = "ltrate"         if code == "ILN"
replace indicator = "strate"         if code == "ISN" 

* Prices
replace indicator = "CPI"           if code == "ZCPIH"
replace indicator = "CPI_C"           if code == "ZCPIX"

* Government finances
replace indicator = "gen_govexp"         if code == "UUTG"
replace indicator = "gen_govtax"         if code == "UTTT"
replace indicator = "gen_govrev"         if code == "URTG"
replace indicator = "gen_govdebt"        if code == "UDGGL"

* Drop unused indicator 
keep if indicator != ""

* Add unit
replace Unit = strlower(Unit)
generat unit = "Index"   if strpos(Unit, "2015 = 100")
replace unit = "Billion" if substr(Unit, 1, 3) == "mrd" & unit == ""
replace unit = "Rate" 	 if strpos(Unit, "%") & unit == ""
replace unit = "Thd" 	 if Unit == "1000 persons"

* Keep 
keep Country value year indicator unit

* Convert to millions 
replace value = value * 1000 if unit == "Billion"
drop unit

* Reshape
greshape wide value, i(Country year) j(indicator)
ren (value* Country year) (* countryname year)

* Add the deflator
gen deflator = (nGDP / rGDP) * 100

* Convert units 
replace gen_govexp = (gen_govexp * 1000)

* Derive variables in ratios 
ds gen_gov* exports imports cons inv finv 
foreach var in `r(varlist)'{
	gen `var'_GDP = (`var' / nGDP) * 100
}

* Convert units
replace pop = pop / 1000

* Add ISO3
drop if countryname == "Czechia" 
merge m:1 countryname using "$isomapping", assert(2 3) keep(3) keepus(ISO3) nogen
drop countryname

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)' {
	ren `var' AMECO_`var'
}

* Rebase variables to $base_year
gmd_rebase AMECO

* Check for ratios and levels 
check_gdp_ratios AMECO

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

* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN US MACROECONOMIC DATA FROM FRED
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-05-15
*
* Description: 
* This Stata script opens and cleans macroeconomic variables on the US economy.
* 
* Data Source:
* Fred API in Stata
* ==============================================================================

* ==============================================================================
*  SET UP
* ==============================================================================

* Define input and output files
clear
global input "${data_raw}/country_level/USA_1"
global output "${data_clean}/country_level/USA_1"

* ==============================================================================
*  PROCESS
* ==============================================================================
use "$input", clear

* Extract the year
gen year = substr(datestr, 1, 4)
destring year, replace

* Keep start-of-year value for monthly and quarterly variables
keep if strpos(datestr, "-01-01") > 0

* Drop date variables other than year
drop datestr daten

* Rename
ren (GDPA GDPCA A939RX0Q048SBEA FPCPITOTLZGUSA B230RC0A052NBEA A929RC1A027NBEA W006RC1Q027SBEA W068RCQ027SBEA EXPGSA IMPGSA A124RC1A027NBEA GFDEGDQ188S RIFSPFFNA FYFSGDA188S AFRECPT BOGMBASE M1SL M2SL UNRATE USSTHPI BOGZ1FL073161113Q RIFSGFSM03NA) (nGDP rGDP rGDP_pc infl pop sav govtax govexp exports imports CA govdebt_GDP cbrate govdef_GDP govrev M0 M1 M2 unemp HPI ltrate strate)

* Convert variables to million
qui ds nGDP rGDP sav govtax govexp imports exports CA govrev M0 M1 M2 
foreach var in `r(varlist)'{
	qui replace `var' = `var' * 1000
}

* Convert population to million
qui replace pop = pop / 1000

* Fix interest rates units
replace ltrate = ltrate / 1000

* Generate country code
gen ISO3 = "USA"

* Add ratios to gdp variables
gen imports_GDP = (imports / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100
gen govrev_GDP = (govrev / nGDP) * 100
gen govexp_GDP = (govexp / nGDP) * 100
gen govtax_GDP = (govtax / nGDP) * 100


* Add source identifier
qui ds year ISO3, not
foreach var in `r(varlist)'{
	qui ren `var' CS1_`var'
}

*===============================================================================
* OUTPUT
*===============================================================================
* Sort
sort year

* Order 
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace

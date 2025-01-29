* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-05-14
* 
* Source: Organisation for Economic Co-operation and Development
*
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================

* Define globals 
global input "${data_raw}/aggregators/OECD/OECD_EO.dta"
global output "${data_clean}/aggregators/OECD/OECD_EO.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open
use "$input", clear

* Drop regional aggregates
drop if inlist(location, "EA17", "DAE", "OIL", "OTO", "NMEC", "OOP") | inlist(location, "RWD", "EMU", "EUU", "WLD", "ROW")

* Keep relevant variables
keep period value location indicator

* Reshape
greshape wide value, i(period location) j(indicator)

* Rename
ren value* *
ren (period location B9S13S CPIH D2D5D91RS13S EXCHER GGFLQ IRS ITISK TES13S UNR CBGDPR CPIH_YTYPCT EXCH GDP GDPV IRCB IT MGS MGSD POP TRS13S XGS XGSD CP CG) (year ISO3 govdef_GDP CPI govtax_GDP REER govdebt_GDP strate inv govexp_GDP unemp CA_GDP infl USDfx nGDP rGDP cbrate finv imports imports_USD pop govrev_GDP exports exports_USD cons_HH cons_gov)

* Convert units to millions
qui ds nGDP rGDP pop finv exports imports inv imports_USD exports_USD cons_HH cons_gov
foreach var in `r(varlist)'{
	replace `var' = `var' / 1000000
}

* Fix exchange rate, REER and CPI values
replace USDfx = 1 / USDfx
replace CPI = CPI * 100
replace REER = REER * 100

* Derive total consumption as the sum of government and household consumptions
gen cons = cons_HH + cons_gov
drop cons_HH cons_gov

* Derive nominal values of government finances
gen govdebt =  govdebt_GDP * nGDP / 100
gen govtax  =  govtax_GDP  * nGDP / 100
gen govrev  =  govrev_GDP  * nGDP / 100
gen govexp  =  govexp_GDP  * nGDP / 100
gen govdef  =  govdef_GDP  * nGDP / 100

* Add ratios to gdp variables
gen cons_GDP = (cons / nGDP) * 100
gen imports_GDP = (imports / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100
gen finv_GDP    = (finv / nGDP) * 100
gen inv_GDP     = (inv / nGDP) * 100

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	ren `var' OECD_EO_`var'
}


* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
save "${output}", replace

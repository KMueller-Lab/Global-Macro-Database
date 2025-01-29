* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and clean interest rates for Portugal
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-10-08
*
* URL:  http://www.ipeadata.gov.br/Default.aspx 
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
* Clear
clear
global input "${data_raw}/country_level/PRT_1"
global output "${data_clean}/country_level/PRT_1"

* ==============================================================================
*	POP
* ==============================================================================

* Open
import excel using "${input}", clear sheet("pop") first

* Remove spaces
replace pop = subinstr(pop, " ", "", .)

* Destring
destring *, replace

* Convert
replace pop = pop / 1000000

* Save
tempfile temp_master
save `temp_master', replace emptyok

* Open
import excel using "${input}", clear sheet("GDP") first

* Remove spaces
replace nGDP = subinstr(nGDP, " ", "", .)
replace nGDP = subinstr(nGDP, "?", "", .)

* Destring
destring *, replace

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year using `temp_master', nogen
save `temp_master', replace	

* Open
import excel using "${input}", clear sheet("money_supply") first

* Remove spaces
replace M0 = subinstr(M0, " ", "", .)
replace M1 = subinstr(M1, " ", "", .)
replace M2 = subinstr(M2, " ", "", .)

* Destring
destring *, replace

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year using `temp_master', nogen
save `temp_master', replace	

* Open
import excel using "${input}", clear sheet("cbrate") first allstring

* Extract year
gen year = substr(date, -4, .)
drop date

* Destring
destring *, replace

* Keep only end-of-year values
sort year
by year: keep if _n == _N

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year using `temp_master', nogen
save `temp_master', replace	

* Open
import excel using "${input}", clear sheet("CPI") first

* Remove spaces
replace CPI = subinstr(CPI, " ", "", .)
replace CPI = subinstr(CPI, "?", "", .)

* Destring
destring *, replace

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year using `temp_master', nogen
save `temp_master', replace	

* Open
import excel using "${input}", clear sheet("govdebt") first

* Remove spaces
replace govdebt = subinstr(govdebt, " ", "", .)

* Destring
destring *, replace

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year using `temp_master', nogen
save `temp_master', replace	

* Open
import excel using "${input}", clear sheet("govtax") first

* Extract year
gen year = substr(date, -4, .)
drop date
drop if year == ""

* Remove spaces
replace govtax = subinstr(govtax, " ", "", .)

* Destring
destring *, replace

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year using `temp_master', nogen
save `temp_master', replace	

* Open
import excel using "${input}", clear sheet("trade") first

* Remove spaces
replace exports = subinstr(exports, " ", "", .)
replace exports = subinstr(exports, "-", "", .)
replace imports = subinstr(imports, " ", "", .)
replace imports = subinstr(imports, "-", "", .)
replace year    = subinstr(year   , "…", "", .)

* Destring
destring *, replace
drop if year == .

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year using `temp_master', nogen
save `temp_master', replace	

* Open
import excel using "${input}", clear sheet("USDfx") first

* Destring
destring *, replace

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year using `temp_master', nogen
save `temp_master', replace	

* Add country's ISO3
gen ISO3 = "PRT"

* Convert values to Euro
merge m:1 ISO3 using $eur_fx, keep(1 3)
qui ds USDfx exports imports govtax govdebt M0 M1 M2 nGDP
foreach var in `r(varlist)'{
	replace `var' = `var'/EUR_irrevocable_FX if _merge == 3
}
drop EUR_irrevocable_FX _merge

* Derive inflation rate
sort ISO3 year
encode ISO3, gen(id)
xtset id year
by id: gen infl = (CPI - L.CPI) / L.CPI * 100 if L.CPI != .
drop id

* Add ratios to gdp variables
gen imports_GDP = (imports / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100
gen govdebt_GDP = (govdebt / nGDP) * 100
gen govtax_GDP = (govtax / nGDP) * 100



* Add source identifier
qui ds year ISO3, not
foreach var in `r(varlist)'{
	ren `var' CS1_`var'
}

* ==============================================================================
* 	Output
* ==============================================================================

* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace

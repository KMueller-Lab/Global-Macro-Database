* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and clean historical economic statistics
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-06-24
*
* URL: http://piketty.pse.ens.fr/files/FlandreauZummer2004.pdf (Transcribed from the appendix)
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
clear
global input "${data_raw}/aggregators/FZ/Flandreau_Zumer.xlsx"
global output "${data_clean}/aggregators/FZ/FZ.dta"

* ===============================================================================
* 	PROCESS
* ===============================================================================

* Open
import excel using "${input}", clear firstrow sheet(exports)

* Rename countries
ren Year year
ren UnitedKingdom GBR
ren Sweden SWE
ren Switzerland CHE
ren Spain ESP
ren Russia RUS
ren Portugal PRT
ren Norway NOR
ren Netherlands NLD
ren Italy ITA
ren Greece GRC
ren Germany DEU
ren France FRA
ren Denmark DNK
ren Brazil BRA
ren Belgium BEL
ren Argentina ARG

* Destring
ds, has(type string)
foreach var in `r(varlist)' { 
	quietly replace `var' = "" if `var' == "-"
}
destring *, replace 

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
}
else {
    di as txt "All variables are numeric."
}

* Reshape
qui ds year, not
foreach var in `r(varlist)' {
	ren `var' exports`var'
}
greshape long exports, i(year) j(ISO3) string

* Order 
order ISO3 year

* Sort
sort ISO3 year

* Create empty file to store the data
tempfile temp_master
save `temp_master', replace emptyok

* Loop over the next sheets and merge
local variable_list REVENUE DEFICITS govdebt cb_reserves cb_notes nGDP CPI  pop ltrate cbrate
foreach variable of local variable_list {
	
	* Open
	
	import excel using "${input}", clear firstrow sheet(`variable')
	
	* Rename countries
	ren Year year
	ren UnitedKingdom GBR
	ren Sweden SWE
	ren Switzerland CHE
	ren Spain ESP
	ren Russia RUS
	ren Portugal PRT
	ren Norway NOR
	ren Netherlands NLD
	ren Italy ITA
	ren Greece GRC
	ren Germany DEU
	ren France FRA
	ren Denmark DNK
	ren Brazil BRA
	ren Belgium BEL
	ren Argentina ARG
	
	* Destring
	ds, has(type string)
	foreach var in `r(varlist)' { 
		quietly replace `var' = "" if `var' == "n.a."
		quietly replace `var' = "" if `var' == "-"
		quietly replace `var' = "" if `var' == "."
	}
	qui destring *, replace 

	* Assert that all columns are numeric now
	ds, has(type string) 
	cap `r(varlist)'
	if _rc != 0 {
		di as error "Not all variables in the `variable' sheet are numeric."
		exit 198
	}
	else {
		di as txt "All variables are numeric."
	}

	* Reshape
	qui ds year, not
	foreach var in `r(varlist)' {
		ren `var' `variable'`var'
	}
	qui greshape long `variable', i(year) j(ISO3) string
	
	* Order 
	order ISO3 year
	
	* Sort
	sort ISO3 year	
	
	* Save and merge
	tempfile temp_`variable'
	save `temp_`variable'', replace emptyok
	merge 1:1 ISO3 year using `temp_master', nogen
	save `temp_master', replace	
}

* Create M0
gen M0 = cb_notes + cb_reserves

* Drop
drop cb_notes cb_reserves

* Calculate the share of debt, DEFICITS and REVENUE in GDP
gen govrev_GDP = (REVENUE/nGDP) * 100
gen govdef_GDP = (DEFICITS/nGDP) * 100
gen govdebt_GDP = (govdebt/nGDP) * 100

* Rename
ren REVENUE govrev
ren DEFICITS govdef

* Convert French Franks to new French Franks
qui ds nGDP govdebt govdef govrev exports M0 
foreach var in `r(varlist)'{
	replace `var' = `var' / 100 if ISO3 == "FRA"
}

* Convert population into millions
replace pop = pop/1000

* Convert currency for Argentina
qui ds nGDP govdebt govdef govrev govdebt exports M0 
foreach var in `r(varlist)'{
	replace `var' = `var' * (10^-13) if ISO3 == "ARG"
}

* Convert currency for Brazil
qui ds nGDP govdebt govdef govrev govdebt exports M0 
foreach var in `r(varlist)'{
	replace `var' = `var' * (10^-12) if ISO3 == "BRA"
}

* Convert currency for Brazil
qui ds nGDP govdebt govdef govrev govdebt exports M0 
foreach var in `r(varlist)'{
	replace `var' = `var' / 2750 if ISO3 == "BRA"
}

* Convert currency for Germany
qui ds nGDP govdebt govdef govrev govdebt exports M0 
foreach var in `r(varlist)'{
	replace `var' = `var' * (10^-12) if ISO3 == "DEU"
}

* Convert currency for Greece
qui ds nGDP govdebt govdef govrev govdebt exports M0 
foreach var in `r(varlist)'{
	replace `var' = `var' * (10^-3) if ISO3 == "GRC"
	replace `var' = `var' /   4     if ISO3 == "GRC"
}




* Convert to Euro
merge m:1 ISO3 using "$eur_fx", keep(1 3) nogen 

* Convert national currency numbers to Euro 
foreach var in nGDP govdebt govdef govrev govdebt exports M0  {
	replace `var' = `var'/EUR_irrevocable_FX if EUR_irrevocable_FX!=.
}
drop EUR_irrevocable_FX

* Derive inflation rate
sort ISO3 year
encode ISO3, gen(id)
xtset id year
by id: gen infl = (CPI - L.CPI) / L.CPI * 100 if L.CPI != .
drop id

* Add source identifier
qui ds ISO3 year, not
foreach var  in `r(varlist)'{
	ren `var' FZ_`var'
}


* ===============================================================================
* 	OUTPUT
* ===============================================================================

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplciates
isid ISO3 year

* Save
save "${output}", replace

* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* MAKE HEATMAP FOR COUNTRIES
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-11-05
*
* ==============================================================================
* ==============================================================================
* START
* ==============================================================================
use "$data_final/clean_data_wide", clear 

drop *rHPI BVX* LV* RR_crisis* *_rcons
keep ISO3 year *nGDP *rGDP  *cons *inv *finv *pop *exports *imports *CA_GDP *REER *USDfx *govrev *govexp *govtax *govdef_GDP *govdebt_GDP *M0 *M1 *M2 *M3 *M4 *cbrate *ltrate *strate *CPI *HPI *infl *unemp

* Add IMF WEO forecast value to the IMF_WEO and then drop it 
qui ds IMF_WEO_forecast* 
foreach var in `r(varlist)'{
	local short_name = substr("`var'", 18, .)
	replace IMF_WEO_`short_name' = `var' if IMF_WEO_`short_name' == .
}

drop IMF_WEO_forecast*

* Reshape in a more robust way instead of writing down all the sources which is not a good practice
preserve
* Save the list of variables in a local
import delimited "$data_helper/sources.csv", clear bindquotes(strict)
keep src_specific_var_name varabbr
qui replace src_specific_var_name = strtrim(src_specific_var_name)
qui replace varabbr = strtrim(varabbr)
gen source_len = strlen(varabbr)
gen source = substr(src_specific_var_name, 1, strlen(src_specific_var_name)-source_len-1)
keep source

* Drop sources that are no longer used 
drop if inlist(source, "LV", "BVX")
gduplicates drop 
qui levelsof source, local(sources) clean
restore 

* Reshape the data
reshape long `sources', i(ISO3 year) j(variable) string
replace variable = substr(variable, 2, .)

* Set graphs off
set graphics off

* Use Stata's built-in parallel processing capabilities
* Set number of processors for Stata/MP
set processors 2

cap program drop do_one_country 
program do_one_country
	args country
 
	preserve 
	qui keep if ISO3 == "`country'"
	di "Heatmap for `country'"

		qui missings dropvars, force

		* Reshape into long
		qui ds ISO3 year variable, not
		foreach var in `r(varlist)'{
			ren `var' GMD`var'
		}

		qui greshape long GMD, i(ISO3 year variable) j(source) string

		drop if GMD == .
		replace GMD = 1

		bysort year variable: egen source_count = total(GMD)

		* Order variables by category and logical flow
		gen order = .
		* Monetary Policy & Interest Rates
		replace order = 1 if var == "cbrate"      // Central Bank Rate
		replace order = 2 if var == "strate"      // Short-term Interest Rate
		replace order = 3 if var == "ltrate"      // Long-term Interest Rate

		* Money Supply Measures
		replace order = 4 if var == "M0"          // Money Supply (M0)
		replace order = 5 if var == "M1"          // Money Supply (M1)
		replace order = 6 if var == "M2"          // Money Supply (M2)
		replace order = 7 if var == "M3"          // Money Supply (M3)

		* GDP and Output
		replace order = 8 if var == "rGDP"        // Real GDP
		replace order = 9 if var == "nGDP"        // Nominal GDP
		replace order = 10 if var == "cons"       // Consumption
		replace order = 11 if var == "inv"        // Investment
		replace order = 12 if var == "finv"       // Fixed Investment

		* External Sector
		replace order = 13 if var == "CA_GDP"     // Current Account
		replace order = 14 if var == "exports"    // Exports
		replace order = 15 if var == "imports"    // Imports
		replace order = 16 if var == "REER"       // Real Effective Exchange Rate
		replace order = 17 if var == "USDfx"      // US Dollar Exchange Rate

		* General government Finances
		replace order = 18 if var == "gen_govrev"     // Government Revenue
		replace order = 19 if var == "gen_govtax"     // Government Tax
		replace order = 20 if var == "gen_govexp"     // Government Expenditure
		replace order = 21 if var == "gen_govdebt_GDP" // Government Debt to GDP
		replace order = 22 if var == "gen_govdef_GDP"     // Government Deficit to GDP
		
		* Central government Finances
		replace order = 23 if var == "cgovrev"     // Government Revenue
		replace order = 24 if var == "cgovtax"     // Government Tax
		replace order = 25 if var == "cgovexp"     // Government Expenditure
		replace order = 26 if var == "cgovdebt_GDP" // Government Debt to GDP
		replace order = 27 if var == "cgovdef_GDP"     // Government Deficit to GDP

		* Other Economic Indicators
		replace order = 28 if var == "unemp"      // Unemployment Rate
		replace order = 29 if var == "infl"       // Inflation Rate
		replace order = 30 if var == "HPI"        // House Price Index
		replace order = 31 if var == "pop"		  // Population


		replace variable = "Nominal GDP" if variable == "nGDP"
		replace variable = "Real GDP" if variable == "rGDP"
		replace variable = "Consumption" if variable == "cons"
		replace variable = "Gross capital formation" if variable == "inv"
		replace variable = "Gross fixed capital formation" if variable == "finv"
		replace variable = "Population" if variable == "pop"
		replace variable = "Exports" if variable == "exports"
		replace variable = "Imports" if variable == "imports"
		replace variable = "Current account" if variable == "CA_GDP"
		replace variable = "USD exchange rate" if variable == "USDfx"
		replace variable = "Real effective exchange rate" if variable == "REER"
		replace variable = "Central overnment tax revenue" if variable == "cgovtax"
		replace variable = "Central government expenditure" if variable == "cgovexp"
		replace variable = "Central government deficit" if variable == "cgovdef_GDP"
		replace variable = "Central government debt" if variable == "cgovdebt_GDP"
		replace variable = "Central government revenue" if variable == "cgovrev"
		replace variable = "General government tax revenue" if variable == "gen_govtax"
		replace variable = "General government expenditure" if variable == "gen_govexp"
		replace variable = "General government deficit" if variable == "gen_govdef_GDP"
		replace variable = "General government debt" if variable == "gen_govdebt_GDP"
		replace variable = "General government revenue" if variable == "gen_govrev"
		replace variable = "Money Supply (M0)" if variable == "M0"
		replace variable = "Money Supply (M1)" if variable == "M1"
		replace variable = "Money Supply (M2)" if variable == "M2"
		replace variable = "Money Supply (M3)" if variable == "M3"
		replace variable = "Central bank policy rate" if variable == "cbrate"
		replace variable = "Short-term interest rate" if variable == "strate"
		replace variable = "Long-term interest rate" if variable == "ltrate"
		replace variable = "Consumer price index" if variable == "CPI"
		replace variable = "House price index" if variable == "HPI"
		replace variable = "Inflation" if variable == "infl"
		replace variable = "Unemployment rate" if variable == "unemp"

		* encode variable, gen(id) // Removed to prevent alphabetical ordering
		sort year order

		* Create value labels based on the variable names
		label define id_label 1 "Central Bank Rate" 2 "Short-term Interest Rate" 3 "Long-term Interest Rate" ///
			4 "Money Supply (M0)" 5 "Money Supply (M1)" 6 "Money Supply (M2)" 7 "Money Supply (M3)" ///
			8 "Real GDP" 9 "Nominal GDP" 10 "Consumption" 11 "Investment" 12 "Fixed Investment" ///
			13 "Current Account" 14 "Exports" 15 "Imports" 16 "Real Effective Exchange Rate" ///
			17 "US Dollar Exchange Rate" 18 "General government Revenue" 19 "General government Tax" ///
			20 "General government Expenditure" 21 "General government Debt" 22 "General government Deficit" ///
			23 "Central government Revenue" 24 "Central government Tax" ///
			25 "Central government Expenditure" 26 "Central government Debt" 27 "Central government Deficit" ///
			28 "Unemployment Rate" 29 "Inflation Rate" 30 "House Price Index" 31 "Population"


		qui su year
		local ymin = r(min)
		local ymax = r(max)
		if r(N) <= 100 {
			local increment = 10
		}
		if r(N) > 100 & r(N) <= 200 {
			local increment = 20
		}
		if r(N) > 200 {
			local increment = 30
		}

		* Apply the value label to id variable
		gen id = order
		label values id id_label
		sort order 
		heatplot source_count i.id year, ///
			 keylabels(, format(%2.0f)) ///
			color(gold*0.2 gold*0.6 gold*0.8 orange*0.6 orange*0.8 red*0.8) ///
			p(lcolor(gray%15) lalign(center)) ///
			xtitle("") ytitle("") ///
			yscale(noline) ///
			xlabel(`ymin'(`increment')`ymax', nogrid labsize(3) angle(90)) ///
			ylabel(, notick labsize(3) grid glcolor(gs15) glpattern(solid)) ///
			graphregion(color(white)) plotregion(margin(small)) ///
			legend(title("") subtitle("") position(right) size(small) cols(1)) ///
			xsize(12) ysize(8) 
			graph export "${doc}/graphs/`country'_heatmap.pdf", replace
		
	restore
	
end

* Get list of countries to process
qui levelsof ISO3, local(countries) clean

* Sort data by ISO3 for parallel processing
sort ISO3

* Process countries using Stata's built-in parallel capabilities
* Since we're using Stata/MP, we can process countries in parallel using a simple loop
* Stata/MP will automatically parallelize many operations

foreach country of local countries {
	do_one_country `country'
}

* Set graphs on
set graphics on



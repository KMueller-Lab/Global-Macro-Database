* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* MAKE HEATMAP FOR CHILE
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

ren OECD_HPI OECD_EO_HPI
ren WDI_ARC_* WDIARC_*
drop *rcons
drop *rHPI BVX* LV* RR_crisis* 
keep ISO3 year *nGDP *rGDP  *cons *inv *finv *pop *exports *imports *CA_GDP *REER *USDfx *govrev *govexp *govtax *govdef_GDP *govdebt_GDP *M0 *M1 *M2 *M3 *cbrate *ltrate *strate *CPI *HPI *infl *unemp

* Add IMF WEO forecast value to the IMF_WEO and then drop it 
qui ds IMF_WEO_forecast* 
foreach var in `r(varlist)'{
	local short_name = substr("`var'", 18, .)
	replace IMF_WEO_`short_name' = `var' if IMF_WEO_`short_name' == .
}

drop IMF_WEO_forecast*

* Reshape
reshape long BIS_ BORDO_ CEPAC_ BRUEGEL_ Davis_ Grimm_ Gapminder_ HFS_ Homer_Sylla_  IHD_ IMF_FPP_ IMF_GDD_ IMF_HDD_ IMF_IFS_ IMF_GFS_ IMF_WEO_ IMF_WEO_forecast MAD_ MD_ MOXLAD_ MW_ Mitchell_ OECD_EO_ OECD_HPI_ OECD_KEI_ OECD_MEI_ OECD_QNA_ OECD_REV_ OECD_MEI_ARC_ FLORA_ PWT_ RR_debt_ TH_ID_ Tena_ UN_ WB_CC_ WDI_ WDIARC_ IMF_MFS_ GNA_ CS1_ CS2_ CS3_ JO_ JST_ FZ_ EUS_ BARRO_ FAO_ AMECO_ ILO_ LUND_ CLIO_ ADB_ AFDB_ AFRISTAT_ AHSTAT_ AMF_ BCEAO_ BG_ BIT_ DallasFED_ FRANC_ZONE_ JERVEN_ NBS_ Schmelzing_ UN_trade_, i(ISO3 year) j(variable) string


* Set graphs off
set graphics off

qui levelsof ISO3, local(countries)
foreach country of local countries{
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

	* Government Finances
	replace order = 18 if var == "govrev"     // Government Revenue
	replace order = 19 if var == "govtax"     // Government Tax
	replace order = 20 if var == "govexp"     // Government Expenditure
	replace order = 21 if var == "govdebt" // Government Debt to GDP
	replace order = 22 if var == "govdef_GDP"     // Government Deficit to GDP

	* Other Economic Indicators
	replace order = 23 if var == "unemp"      // Unemployment Rate
	replace order = 24 if var == "infl"       // Inflation Rate
	replace order = 25 if var == "HPI"        // House Price Index
	replace order = 26 if var == "pop"


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
	replace variable = "Government tax revenue" if variable == "govtax"
	replace variable = "Government expenditure" if variable == "govexp"
	replace variable = "Government deficit" if variable == "govdef_GDP"
	replace variable = "Government debt" if variable == "govdebt_GDP"
	replace variable = "Government revenue" if variable == "govrev"
	replace variable = "Money Supply (M0)" if variable == "M0"
	replace variable = "Money Supply (M1)" if variable == "M1"
	replace variable = "Money Supply (M2)" if variable == "M2"
	replace variable = "Money Supply (M3)" if variable == "M3"
	replace variable = "Central bank policy rate" if variable == "cbrate"
	replace variable = "Short-term interest rate" if variable == "strate"
	replace variable = "Long-term interest rate" if variable == "ltrate"
	replace variable = "Consumer price index" if variable == "CPI"
	replace variable = "House prices index" if variable == "HPI"
	replace variable = "Inflation" if variable == "infl"
	replace variable = "Unemployment" if variable == "unemp"

	encode variable, gen(id)
	sort year order

	* Create value labels based on the variable names
	label define id_label 1 "Central Bank Rate" 2 "Short-term Interest Rate" 3 "Long-term Interest Rate" ///
		4 "Money Supply (M0)" 5 "Money Supply (M1)" 6 "Money Supply (M2)" 7 "Money Supply (M3)" ///
		8 "Real GDP" 9 "Nominal GDP" 10 "Consumption" 11 "Investment" 12 "Fixed Investment" ///
		13 "Current Account" 14 "Exports" 15 "Imports" 16 "Real Effective Exchange Rate" ///
		17 "US Dollar Exchange Rate" 18 "Government Revenue" 19 "Government Tax" ///
		20 "Government Expenditure" 21 "Government Debt" 22 "Government Deficit" ///
		23 "Unemployment Rate" 24 "Inflation Rate" 25 "House Price Index" 26 "Population"


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
	label variable id id_label
	sort order 
	heatplot source_count i.id year, ///
		 keylabels(, format(%2.0f)) ///
		color(gold*0.2 gold*0.6 gold*0.8 orange*0.6 orange*0.8 red*0.8) ///
		p(lcolor(gray%15) lalign(center)) ///
		xtitle("") ytitle("") ///
		yscale(noline) ///
		xlabel(`ymin'(`increment')`ymax', nogrid labsize(3.5) angle(90)) ///
		ylabel(, notick labsize(3.5) grid glcolor(gs15) glpattern(solid)) ///
		graphregion(color(white)) plotregion(margin(small)) ///
		legend(title("") subtitle("") position(right) size(small) cols(1)) ///
		xsize(12) ysize(8) 
		graph export "${doc}/graphs/`country'_heatmap.pdf", replace
	
	restore
}

* Set graphs on
set graphics on

* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* MAKE FIGURES COMPARING ACROSS VARIABLES
* 
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-10-09
*
* ==============================================================================

* ==============================================================================
* PREPARE THE DATA
* ==============================================================================
*==============================================================================
* Global Macro Project
* MAKE TABLE COMPARING THE RAW NUMBER OF OBSERVATIONS WITH OTHER DATA SOURCES
*==============================================================================
* Set up the font for the graphs
graph set window fontface "Times New Roman"

* Find GMD dataset statistic summary
use "$data_final/data_final", clear
drop countryname
isid ISO3 year
drop rGDP_pc rGDP_USD
ren * data_*
ren data_ISO3 ISO3
ren data_year year
greshape long data_, i(ISO3 year) j(variable) string
ren data GMD

* Count non-missing observations
replace GMD = 1 if GMD != .
drop if GMD == .

* Calculate number of observations 
gcollapse (sum) GMD, by(variable)
tempfile temp_GMD_summary
save `temp_GMD_summary', replace

* Open cleaned file
use "$data_final/clean_data_wide", clear
drop WDI_ARC*
keep ISO3 year IMF_IFS_* IMF_WEO_* WDI_* OECD_EO_* UN_* JST_* Mitchell*
drop *pop
greshape long IMF_IFS_ IMF_WEO_ WDI_ OECD_EO_ UN_ JST_ Mitchell_, i(ISO3 year) j(variable) string
ren IMF_IFS_ 	data_IMF_IFS
ren IMF_WEO_	data_IMF_WEO
ren WDI_ 	data_WDI
ren OECD_EO_	data_OECD_EO
ren UN_			data_UN
ren JST_		data_JST
ren Mitchell_ 	data_Mitchell
greshape long data, i(ISO3 year variable) j(source) string

* Count non-missing observations for each source-variable combination
replace data = 1 if data != .
drop if data == .
gcollapse (sum) data, by(source variable)

* Reshape the data such that sources are columns
greshape wide data, i(variable) j(source)

* Merge with GMD Data
merge 1:1 variable using `temp_GMD_summary', keep(3) nogen
order variable GMD

* Calculate the ratio
ds variable GMD, not
foreach var in `r(varlist)'{
	gen `var'_share = round((`var'/GMD) * 100, 1)	
}

* Add GMD share column
gen GMD_share = 100

* Create more readable labels for all variables
replace variable = "Short-term interest rate" if var == "strate"
replace variable = "Long-term interest rate" if var == "ltrate"
replace variable = "Central bank rate" if var == "cbrate"
replace variable = "Money supply (M0)" if var == "M0"
replace variable = "Money supply (M1)" if var == "M1"
replace variable = "Money supply (M2)" if var == "M2"
replace variable = "Money supply (M3)" if var == "M3"
replace variable = "Money supply (M4)" if var == "M4"
replace variable = "Real GDP" if var == "rGDP"
replace variable = "Nominal GDP" if var == "nGDP"
replace variable = "Current account" if var == "CA_GDP"
replace variable = "Exports" if var == "exports"
replace variable = "Imports" if var == "imports"
replace variable = "Government revenue" if var == "govrev"
replace variable = "Government tax" if var == "govtax"
replace variable = "Government expenditure" if var == "govexp"
replace variable = "Government debt" if var == "govdebt_GDP"
replace variable = "Government deficit" if var == "govdef_GDP"
replace variable = "Consumer price index" if var == "CPI"
replace variable = "House price index" if var == "HPI"
replace variable = "Fixed investment" if var == "finv"
replace variable = "Investment" if var == "inv"
replace variable = "Unemployment rate" if var == "unemp"
replace variable = "Inflation rate" if var == "infl"
replace variable = "Real consumption" if var == "rcons"
replace variable = "Consumption" if var == "cons"
replace variable = "Real effective exchange rate" if var == "REER"
replace variable = "US dollar exchange rate" if var == "USDfx"
replace variable = "Consumer price index" if var == "CPI"

drop if var == "rGDP_USD"
drop if var == "rGDP_pc"


* Drop some derived variables 
drop if substr(variable, -4, .) == "_GDP"
drop if inlist(variable,"govdebt","govdef","CA")

* Rename
ren data_* *

* ==============================================================================
* RESHAPE THE GRAPHS
* ==============================================================================
* Remove the thousand separator from GMD column
qui ds variable *share, not
foreach var in `r(varlist)'{
	ren `var' d`var'
}

qui ds variable d*, not
foreach var in `r(varlist)'{
	ren `var' c`var'
}

ren *_share *
greshape long d c, i(variable) j(varname) string

drop if c == .
gsort variable -c

by variable: keep if _n <= 2
replace varname = "next" if c < 100
greshape wide d c, i(variable) j(varname) 
ren c* share_*
ren d* count_*


preserve

* Sort by count_GMD in descending order
gsort -count_GMD
gen order = _n

* Create horizontal bar graph
graph hbar (sum) count_GMD count_next, ///
    over(variable, sort(order) label(angle(0) labsize(small)) gap(200)) bargap(80) ///
    bar(1, color("51 122 183")) ///
    bar(2, color("217 83 79")) ///
    legend(order(1 "Global Macro Database" 2 "Next best source") pos(5) size(small) region(style(none)) cols(1)) ///
    ylabel(, angle(45) labsize(small)) ///
	ytitle("Number of country-year observations") ///
    graphregion(color(white) margin(r=5 t=2 b=2 l=5)) ///
    blabel(bar, format(%9.0gc) size(vsmall) color(gs0)) ///
    plotregion(style(none)) /// 
    ysize(5) xsize(3.5) ///

* Export the graph
graph export "${graphs}/sources_comparison_total.eps", replace
restore

* ==============================================================================
* Global Macro Project
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* FIGURE SHOWING SHARE OF COUNTRIES COVERED BY EACH VARIABLE 
* 
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-10-11
*
* ==============================================================================

* ==============================================================================
* CALCULATE STATISTICS BY VARIABLE FROM FINAL DATASET 
* ==============================================================================

* Set up the font for the graphs
graph set window fontface "Times New Roman"

* Open cleaned file
use "$data_final/clean_data_wide", clear
ren OECD_HPI OECD_EO_HPI
drop *rHPI
keep ISO3 year *nGDP *rGDP *imports *exports *govdebt_GDP *M0 *strate *govexp *govrev *govtax *govdef_GDP *cbrate *ltrate *CA_GDP *M1 *M2 *M3 *infl *rcons *cons *inv *finv *REER *USDfx *unemp *HPI *strate *M4 *CPI

keep if inlist(year, 1900, 1980, 2008)

* Create a temporary variable to store all variable names
qui ds

* Create a local macro to store the result
local varlist `r(varlist)'

* Create an empty local to store unique prefixes
local prefixes

* Loop through each variable
foreach var of local varlist {

    * Extract everything before the specified suffixes
    if regexm("`var'", "^(.+?)(nGDP|rGDP|imports|exports|govdebt_GDP|M0|strate|govexp|govrev|govtax|govdef_GDP|cbrate|ltrate|HPI|infl|rcons|cons|inv|finv|CA_GDP|REER|USDfx|unemp}CPI|M1|M2|M3|M4)$") {
        local prefix = regexs(1)

        * Remove trailing underscore if present
        local prefix = rtrim("`prefix'")
        if substr("`prefix'", -1, 1) == "_" {
            local prefix = substr("`prefix'", 1, length("`prefix'")-1)
        }
        
		* Add to prefixes if not already there
        if !regexm("`prefixes'", "\b`prefix'\b") {
            local prefixes "`prefixes' `prefix'"
        }
    }
}

* Create the reshape command dynamically
local reshape_list ""
foreach prefix of local prefixes {
    
	* Check if any variables with this prefix exist in the dataset
    cap ds `prefix'_*
    if !_rc {
        local reshape_list "`reshape_list' `prefix'_"
    }
}

* Display the prefixes being used
display "Reshaping using the following prefixes:"
foreach prefix of local prefixes {
    cap ds `prefix'_*
    if !_rc {
        display "`prefix'"
    }
}

* Execute the reshape command
greshape long `reshape_list', i(ISO3 year) j(variable) string

* Rename
qui ds ISO3 year variable, not
foreach var in `r(varlist)'{
	ren `var' data`var'
}

* Reshape 
greshape long data, i(ISO3 year variable) j(source) string

* Delete the trailing underscore
replace source = substr(source, 1, length(source) - 1) if substr(source, -1, 1) == "_"

* Collapse on country-year variable level 
drop if data == .
replace data = 1
encode ISO3 , gen(d)

duplicates drop ISO3 year variable, force
gcollapse (count) d, by(variable year)
gen country_share = d
drop d

* Reshape 
greshape wide country_share, i(variable) j(year)

* Create helper variables for shortened arrows
gen cs1900_short  = country_share1900 + 4
gen cs1980_short  = country_share1980 - 4
gen cs1980_short2 = country_share1980 + 4
gen cs2008_short  = country_share2008 - 4


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
replace order = 10 if var == "rcons"       // Real Consumption
replace order = 11 if var == "cons"        // Consumption
replace order = 12 if var == "inv"         // Investment
replace order = 13 if var == "finv"        // Fixed Investment
* External Sector
replace order = 14 if var == "CA_GDP"      // Current Account
replace order = 15 if var == "exports"     // Exports
replace order = 16 if var == "imports"     // Imports
replace order = 17 if var == "REER"        // Real Effective Exchange Rate
replace order = 18 if var == "USDfx"       // US Dollar Exchange Rate
* Government Finances
replace order = 19 if var == "govrev"      // Government Revenue
replace order = 20 if var == "govtax"      // Government Tax
replace order = 21 if var == "govexp"      // Government Expenditure
replace order = 22 if var == "govdebt_GDP" // Government Debt to GDP
replace order = 23 if var == "govdef_GDP"  // Government Deficit
* Other Economic Indicators
replace order = 24 if var == "unemp"       // Unemployment Rate
replace order = 25 if var == "infl"        // Inflation Rate
replace order = 26 if var == "CPI"         // Consumer price index
replace order = 27 if var == "HPI"         // House Price Index

* Create more readable labels for all variables
replace variable = "Short-term interest rate" if var == "strate"
replace variable = "Long-term interest rate" if var == "ltrate"
replace variable = "Central bank policy rate" if var == "cbrate"
replace variable = "Money supply (M3)" if var == "M3"
replace variable = "Money supply (M2)" if var == "M2"
replace variable = "Money supply (M1)" if var == "M1"
replace variable = "Money supply (M0)" if var == "M0"
replace variable = "Real GDP" if var == "rGDP"
replace variable = "Nominal GDP" if var == "nGDP"
replace variable = "Current account" if var == "CA_GDP"
replace variable = "Exports" if var == "exports"
replace variable = "Imports" if var == "imports"
replace variable = "Government revenue" if var == "govrev"
replace variable = "Government tax revenue" if var == "govtax"
replace variable = "Government expenditure" if var == "govexp"
replace variable = "Government debt" if var == "govdebt_GDP"
replace variable = "Government deficit" if var == "govdef_GDP"
replace variable = "House price index" if var == "HPI"
replace variable = "Gross fixed capital formation" if var == "finv"
replace variable = "Gross capital formation" if var == "inv"
replace variable = "Unemployment rate" if var == "unemp"
replace variable = "Inflation rate" if var == "infl"
replace variable = "Real consumption" if var == "rcons"
replace variable = "Consumption" if var == "cons"
replace variable = "Real effective exchange rate" if var == "REER"
replace variable = "US dollar exchange rate" if var == "USDfx"
replace variable = "Consumer price index" if var == "CPI"

* Sort by the order variable
ren order n
sort n
replace n = abs(n - 26)

* Graph
sum country_share1900
loc min = `r(min)'
gen min = `r(min)' - 5

sum country_share2008
loc max = `r(max)'

twoway ///
    (pcarrow n cs1900_short n cs1980_short, msize(medium) lcolor(dashed) lwidth(thin) mcolor(black)) ///
    (pcarrow n cs1980_short2 n cs2008_short, msize(medium) lcolor(dashed) lwidth(thin) mcolor(black)) ///
    (scatter n country_share1900, mcolor(navy)) ///
    (scatter n country_share1980, mcolor(maroon)) ///
    (scatter n country_share2008, mcolor(magenta)) ///
    (scatter n min, mlabpos(9) m(none) ml(variable) mlabc(black)) ///
    , ///
    yscale(off range(1 25)) ///  // Increase vertical range for more spacing
    ysize(16) xsize(20) ///      // Large numbers for both dimensions
    legend(off) ///
    xlabel(20(30)230, labsize(4) nogrid tlength(0.5cm)) ///
    ylabel(, labsize(large) nogrid) ///
    xtit("Number of countries covered") ///
    graphregion(margin(l=39) color(white)) ///
    xscale(range(`min' `max')) ///
    legend(on size(small) order(3 "1900" 4 "1980" 5 "2008") ring(0) pos(1) c(1))
	graph export "${graphs}/source_per_var.eps", replace 
drop min

* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* MAKE TABLE WITH A FULL LIST OF SOURCES 
* 
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-10-09
*
* ==============================================================================

* ==============================================================================
* GET RELEVANT INFORMATION FROM SOURCES.CSV
* ==============================================================================

* Open docvars.csv sheet
insheet using "${data_helper}/docvars.csv", clear

* Keep only variables used in the appendix
keep if finalvarlist !="" 
drop if derived == "Yes" & strpos(codes, "gov") != 1 & codes != "deflator"
drop if inlist(codes, "govrev", "govtax", "govdef", "govexp", "govdebt")

* Keep needed columns only
keep codes units label derivations

* ==============================================================================
* FORMAT TABLE
* ==============================================================================
order label codes units

* Make "_" and "." Latex compatible 
foreach var of varlist _all {
    * Replace "_"" with "\_"
    replace `var' = subinstr(`var', "_", "\_", .)

	* Replace % with "\%"
    replace `var' = subinstr(`var', "%", "\%", .)
}


* Format the table correctly so it's ready for publication
replace units = subinstr(units, "millions", "Millions", .)
replace units = "\%" if units == "in \%" 
replace units = "Index, $base_year = 100" if units == "index, $base_year = 100" 
replace units = "LC" if label == "Real GDP Per Capita"
replace units = "1 USD in LC" if label == "USD Exchange Rate"

ren label varname 
ren codes abbr

tempfile master
save `master', emptyok


* ==============================================================================
* Use data_final to calculate the variable coverages
* ==============================================================================
use "${data_final}/data_final", clear

* Drop unnecessary variables, but keep ISO3 and year
drop countryname

preserve

* Step 1: Create a list of variables (excluding ISO3 and year)
ds ISO3 year, not
local vars `r(varlist)'

* Step 2: Create an empty dataset with variable names and placeholders
clear
set obs `: word count `vars''
gen str32 varname = ""
gen int from = .
gen int to = .
gen int forecasts = .
gen int countries = .

* Populate variable names
local i = 1
foreach var of local vars {
    replace varname = "`var'" in `i'
    local ++i
}

* Step 3: Loop over variables to calculate metrics and fill placeholders
restore
tempname results
postfile `results' str32(varname) int(from) int(to) int(forecasts) int(countries) using summary_table.dta, replace

foreach var of local vars {
    * First year without missing values
    quietly summarize year if !missing(`var')
    local first_year = r(min)

    * Last year without missing values
    quietly summarize year if !missing(`var')
    local last_year = r(max)

    * Number of forecasted years (beyond current year, 2024)
    local forecasts = `last_year' - $current_year
    if `forecasts' < 0 {
        local forecasts = 0
    }

    * Number of countries with data for this variable
    quietly distinct ISO3 if !missing(`var')
    local num_countries = r(ndistinct)

    * Post the results
    post `results' ("`var'") (`first_year') (`last_year') (`forecasts') (`num_countries')
}

postclose `results'

* Step 4: Create the summary table
use summary_table.dta, clear
list

ren varname abbr

* Replace "_"" with "\_"
replace abbr = subinstr(abbr, "_", "\_", .)
* Replace % with "\%"
replace abbr = subinstr(abbr, "%", "\%", .)

* Merge with varname created using docvars.csv
merge 1:1 abbr using `master', nogen

order varname abbr units
sort abbr

* Identify variables excluding varname, abbr, and units
ds varname abbr units, not
local varlist `r(varlist)'

* Loop over each variable and make them strings
foreach var of local varlist {
    tostring `var', replace
}

* Make correct order for the table
gen order = .

* Keep only final variables 

replace order = 1 if varname == "Nominal GDP"
replace order = 2 if varname == "Real GDP"
replace order = 3 if varname == "Real GDP in USD"
replace order = 4 if varname == "GDP deflator"
replace order = 5 if varname == "Final consumption"
replace order = 6 if varname == "Gross capital formation"
replace order = 7 if varname == "Gross fixed capital formation"

// C. External sectors
replace order = 9  if varname == "Current account in percent of GDP"
replace order = 10 if varname == "Exports"
replace order = 11 if varname == "Imports"
replace order = 12 if varname == "Real effective exchange rate"
replace order = 13 if varname == "USD exchange rate"

// D. government finances
replace order = 14 if varname == "Combined government debt in percent of GDP"
replace order = 15 if varname == "Combined government deficit in percent of GDP"
replace order = 16 if varname == "Combined government expenditure in percent of GDP"
replace order = 17 if varname == "Combined government revenue in percent of GDP"
replace order = 18 if varname == "Combined government tax revenue in percent of GDP"

replace order = 19 if varname == "General government debt in percent of GDP"
replace order = 20 if varname == "General government deficit in percent of GDP"
replace order = 21 if varname == "General government expenditure in percent of GDP"
replace order = 22 if varname == "General government revenue in percent of GDP"
replace order = 23 if varname == "General government tax revenue in percent of GDP"

replace order = 24 if varname == "Central government debt in percent of GDP"
replace order = 25 if varname == "Central government deficit in percent of GDP"
replace order = 26 if varname == "Central government expenditure in percent of GDP"
replace order = 27 if varname == "Central government revenue in percent of GDP"
replace order = 28 if varname == "Central government tax revenue in percent of GDP"

// E. Money and interests
replace order = 29 if varname == "M0"
replace order = 30 if varname == "M1"
replace order = 31 if varname == "M2"
replace order = 32 if varname == "M3"
replace order = 33 if varname == "M4"
replace order = 34 if varname == "Central bank policy rate"
replace order = 35 if varname == "Short-term interest rate"
replace order = 36 if varname == "Long-term interest rate"

// F. Prices and labor market
replace order = 37 if varname == "Consumer price index"
replace order = 38 if varname == "House price index"
replace order = 39 if varname == "Inflation"
replace order = 40 if varname == "Unemployment rate"
replace order = 41 if varname == "Population"

// G. Financial crisis variables 
replace order = 42 if varname == "Banking crisis"
replace order = 43 if varname == "Sovereign debt crisis"
replace order = 44 if varname == "Currency crisis"

sort order
drop if order == . 
* Drop helper column "order"
drop order

* Set forecasts to "---" if none 
replace forecasts = "---" if forecasts == "0"

* Print variable abbreviations as variable code
replace abbr = "\texttt{"+abbr+"}"

* Make the varname shorter 
replace varname = subinstr(varname, "in percent of GDP", ", \% GDP", .)
replace varname = subinstr(varname, "Combined government", "Gov.", .)
replace varname = subinstr(varname, "Central government", "Gov.", .)
replace varname = subinstr(varname, "General government", "Gov.", .)
replace units = subinstr(units, "Index, ", "", .)
replace units = subinstr(units, "Millions of LC", "Mill. LC", .)
replace units = subinstr(units, " = ", "=", .)
replace units = "Mill. USD" if units == "Millions of USD"
replace units = "1 USD" if units == "1 USD in LC"
replace units = "Units" if units == "LCU per capita"

* Add time frame
gen range = from + "-" + to
drop from to 
order varname abbr derivations range
drop unit 


* Export into LaTeX (seperate panels)
preserve 
keep if _n>=1 & _n<=7
gmdwriterows *, path("${tables}/tab_variable_descriptions_A.tex")
restore 

preserve 
keep if _n>=8 & _n<=12
gmdwriterows *, path("${tables}/tab_variable_descriptions_B.tex")
restore 

preserve 
keep if _n>=13 & _n<=17
gmdwriterows *, path("${tables}/tab_variable_descriptions_C.tex")
restore 

preserve 
keep if _n>=18 & _n<=22
gmdwriterows *, path("${tables}/tab_variable_descriptions_D.tex")
restore 

preserve 
keep if _n>=23 & _n<=27
gmdwriterows *, path("${tables}/tab_variable_descriptions_E.tex")
restore 

preserve 
keep if _n>=28 & _n<=35
gmdwriterows *, path("${tables}/tab_variable_descriptions_F.tex")
restore 

preserve 
keep if _n>=36 & _n<=40
gmdwriterows *, path("${tables}/tab_variable_descriptions_G.tex")
restore 

preserve 
keep if _n>=41 & _n<=43
gmdwriterows *, path("${tables}/tab_variable_descriptions_H.tex")
restore 

* Drop temporary file 
rm "summary_table.dta"

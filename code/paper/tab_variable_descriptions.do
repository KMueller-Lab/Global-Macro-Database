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

* Keep needed columns only
keep codes units label

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
replace units = "Index, 2010 = 100" if units == "index, 2010 = 100" 
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
    local forecasts = `last_year' - 2024
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

* Loop over each variable and destring
foreach var of local varlist {
    tostring `var', replace
}

* Make correct order for the table
gen order = .

replace order = 1 if varname == "Nominal GDP"
replace order = 2 if varname == "Real GDP"
replace order = 3 if varname == "Real GDP in USD"
replace order = 4 if varname == "Real GDP per capita"
replace order = 5 if varname == "GDP deflator"
replace order = 6 if varname == "Population"

// B. Consumption and investments
replace order = 7 if varname == "Real final consumption"
replace order = 8 if varname == "Final consumption"
replace order = 9 if varname == "Final consumption in percent of GDP"
replace order = 10 if varname == "Gross capital formation"
replace order = 11 if varname == "Gross capital formation in percent of GDP"
replace order = 12 if varname == "Gross fixed capital formation"
replace order = 13 if varname == "Gross fixed capital formation in percent of GDP"
// C. External sectors
replace order = 14 if varname == "Current account"
replace order = 15 if varname == "Current account in percent of GDP"
replace order = 16 if varname == "Exports"
replace order = 17 if varname == "Exports in percent of GDP"
replace order = 18 if varname == "Imports"
replace order = 19 if varname == "Imports in percent of GDP"
replace order = 20 if varname == "Real effective exchange rate"
replace order = 21 if varname == "USD exchange rate"
// D. Government finances
replace order = 22 if varname == "Government debt"
replace order = 23 if varname == "Government debt in percent of GDP"
replace order = 24 if varname == "Government deficit"
replace order = 25 if varname == "Government deficit in percent of GDP"
replace order = 26 if varname == "Government expenditure"
replace order = 27 if varname == "Government expenditure in percent of GDP"
replace order = 28 if varname == "Government revenue"
replace order = 29 if varname == "Government revenue in percent of GDP"
replace order = 30 if varname == "Government tax revenue"
replace order = 31 if varname == "Government tax revenue in percent of GDP"
// E. Money and interests
replace order = 32 if varname == "M0"
replace order = 33 if varname == "M1"
replace order = 34 if varname == "M2"
replace order = 35 if varname == "M3"
replace order = 36 if varname == "M4"
replace order = 37 if varname == "Central bank policy rate"
replace order = 38 if varname == "Short-term interest rate"
replace order = 39 if varname == "Long-term interest rate"
// F. Prices and labor market
replace order = 40 if varname == "Consumer price index"
replace order = 41 if varname == "House price index"
replace order = 42 if varname == "Inflation"
replace order = 43 if varname == "Unemployment rate"
// G. Financial crisis variables 
replace order = 44 if varname == "Banking crisis dummy"
replace order = 45 if varname == "Sovereign debt crisis dummy"
replace order = 46 if varname == "Currency crisis dummy"

sort order

* Drop helper column "order"
drop order

* Set forecasts to "---" if none 
replace forecasts = "---" if forecasts == "0"

* Print variable abbreviations as variable code
replace abbr = "\texttt{"+abbr+"}"

* Export into LaTeX (seperate panels)
preserve 
keep if _n>=1 & _n<=6
gmdwriterows *, path("${tables}/tab_variable_descriptions_A.tex")
restore 

preserve 
keep if _n>=7 & _n<=13
gmdwriterows *, path("${tables}/tab_variable_descriptions_B.tex")
restore 

preserve 
keep if _n>=14 & _n<=21
gmdwriterows *, path("${tables}/tab_variable_descriptions_C.tex")
restore 

preserve 
keep if _n>=22 & _n<=31
gmdwriterows *, path("${tables}/tab_variable_descriptions_D.tex")
restore 

preserve 
keep if _n>=32 & _n<=39
gmdwriterows *, path("${tables}/tab_variable_descriptions_E.tex")
restore 

preserve 
keep if _n>=40 & _n<=43
gmdwriterows *, path("${tables}/tab_variable_descriptions_F.tex")
restore 

preserve 
keep if _n>=44 & _n<=46
gmdwriterows *, path("${tables}/tab_variable_descriptions_G.tex")
restore 

* Drop temporary file 
rm "summary_table.dta"

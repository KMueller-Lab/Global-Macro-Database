* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN HISTORICAL FINANCIAL STATISTICS
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-06-28
*
* Description: 
* This Stata script opens and cleans historical financial statistics data from the center for financial stability
* 
* Url: https://centerforfinancialstability.org/hfs.php
*
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
* Clear data 
clear

* Define globals 
global input "${data_raw}/aggregators/HFS/General_tables.xlsx"
global input1 "${data_raw}/aggregators/HFS/input1.dta"
global output "${data_clean}/aggregators/HFS/HFS.dta"

* ==============================================================================
* 	PREPARE THE INPUT DATA
* ==============================================================================

* Open
import excel using "${input}", clear sheet(Annual data 1800 onward) allstring 

* Drop rows with missing observation
missings dropvars, force
drop in 1/2

* Rename columns
ren A 		countryname
ren B 		category
ren C 		series
ren D 		unit
ren E		scale
ren F		time
ren G 		source
ren H 		start
ren I		end
ren J		notes
qui ds countryname category series unit scale time source start end notes, not
foreach var in `r(varlist)' {
    local newname = `var'[1]
    capture ren `var' y_`newname'
}
drop in 1

* Save the input
save "$input1", replace



********************************************************************************
* Nunes, Bastien, Valério, de Sousa, and Costa
********************************************************************************

* Keep only one source
preserve
keep if strpos(source , "Nunes, Bastien, Valério, de Sousa, and Costa") > 0

* Keep only series needed
keep if series == "Monetary base (M0)"

* Drop Goa and fix names
drop if countryname == "Goa"
replace countryname = "Timor-Leste" if countryname == "Timor-Leste (East Timor)"
replace country = "Macau" if countryname == "Macao"

* Keep relevant columns
keep countryname y_*

* Reshape
greshape long y_, i(countryname) j(year) string

* Generate countries' ISO3 code
merge m:1 countryname using $isomapping, keep(1 3) nogen

* Keep
keep ISO3 year y_

* Destring
destring year y_, replace

* Assert that all columns are numeric now
ds year y_, has(type string)
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Rename
ren y_ M0

* Convert units
replace M0 = M0 / 1000



* Order
order ISO3 year

* Sort
sort ISO3 year

* Save in a temporary file
tempfile temp_master
save `temp_master', replace emptyok

* Restore
restore

********************************************************************************
* 						Valério and Tjipilica (2006: 16-19)
********************************************************************************
* Keep only one source
preserve
keep if strpos(source , "Tjipilica") > 0


* Rename the series
replace series = "CPI" if series == "Price index"
replace series = "imports" if strpos(series , "Imports") > 0
replace series = "exports" if strpos(series , "Exports") > 0
replace series = "govexp" if series == "Government spending"
replace series = "govrev" if series == "Government revenue"
replace series = "nGDP_index_LCU" if series == "Nominal GDP"
replace series = "rGDP_index_LCU" if series == "Real GDP"
replace series = "rGDP_pc_index_LCU" if series == "Real GDP per person"
replace series = "rGDP_pc_index_LCU" if series == "GDP per person"
replace series = "pop" if series == "Population"
replace series = "M0" if series == "Monetary base (M0)"

* Drop Goa and fix names
drop if countryname == "Goa"
replace countryname = "Timor-Leste" if countryname == "Timor-Leste (East Timor)"
replace country = "Macau" if countryname == "Macao"

* Keep relevant columns
keep countryname series y_*

* Reshape
greshape long y_, i(countryname series) j(year) string

* Drop missing values for Angola
replace y_ = "" if y_ == "?" 

* Destring
destring year y_, replace

* Reshape into wide
greshape wide y_, i(countryname year) j(series) string

* Generate countries' ISO3 code
merge m:1 countryname using $isomapping, keep(1 3) nogen

* Keep
keep ISO3 year y_*

* Assert that all columns are numeric now
ds year y_*, has(type string)
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Rename
ren y_* *

* Convert units
replace pop = pop / 1000
replace govexp = govexp / 1000 
replace exports = exports / 1000 if ISO3 != "MAC"
replace imports = imports / 1000 if ISO3 != "MAC"
replace govrev = govrev / 1000 
replace M0 = M0 / 1000 
replace M2 = M2 / 1000 if ISO3 == "AGO"

* Deflate the Angolan currency
qui ds govexp imports exports govrev M0 M2
foreach var in `r(varlist)' {
	replace `var' = `var' / 1000000 if ISO3 == "AGO"
}

* Convert Macau currency
qui ds govexp imports exports govrev M0 M2
foreach var in `r(varlist)' {
	replace `var' = `var' / 5 if ISO3 == "MAC"
}

* Order
order ISO3 year

* Sort
sort ISO3 year

* Save in a temporary file and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************
* IFS
********************************************************************************

* Keep only one source
preserve
keep if strpos(source , "IFS") > 0

* Drop Egypt (There is a typo in the name and it will be processed later)
drop if strpos(countryname, "Egypt")


* Rename the series
replace series = "c_exports" if series == "Exports" & source == "IFS (April 1948)" // LCU
replace series = "c_imports" if series == "Imports" & source == "IFS (April 1948)" // LCU

* Keep only relevant rows
keep if strpos(series, "c_")

* Identify countries with units equal to billions in order to convert later
levelsof countryname if scale == "Billions", clean local(to_convert)

* Keep relevant columns
keep countryname series y_*

* Reshape
greshape long y_, i(countryname series) j(year) string

* Destring
replace y_ = "" if y_ == "n.a." | y_ == "0"
destring year y_, replace

* Reshape into wide
greshape wide y_, i(countryname year) j(series) string

* Rename columns
ren y_c_* *

* Convert units
foreach country of local to_convert{
	replace imports = imports * 1000 if countryname == "`country'"
	replace exports = exports * 1000 if countryname == "`country'"
}

* Convert the rest of the countries
replace imports = imports * 1000 if inlist(countryname, "Czech Republic", "Iran ", "Belgium")
replace exports = exports * 1000 if inlist(countryname, "Czech Republic", "Iran ", "Belgium")

* Convert Uruguay currency
replace imports = imports / 1000000 if countryname == "Uruguay"
replace exports = exports / 1000000 if countryname == "Uruguay"

* Convert Peru currency
replace imports = imports * (10^-9) if countryname == "Peru"
replace exports = exports * (10^-9) if countryname == "Peru"

* Convert Brazil currency
replace imports = imports * (10^-15) / 2750 if countryname == "Brazil" 
replace exports = exports * (10^-15) / 2750 if countryname == "Brazil" 

* Convert Bolivia currency
replace imports = imports * (10^-9) if countryname == "Bolivia"
replace exports = exports * (10^-9) if countryname == "Bolivia"

* Convert Venezuela currency
replace imports = imports * (10^-14) if countryname == "Venezuela"
replace exports = exports * (10^-14) if countryname == "Venezuela"

* Generate countries' ISO3 code
replace countryname = strtrim(countryname)
merge m:1 countryname using $isomapping, keep(1 3) nogen

* Keep
keep ISO3 year exports imports

* Assert that all columns are numeric now
ds year exports imports, has(type string)
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Drop rows with missing data
qui ds ISO3 year, not
qui missings dropobs `r(varlist)', force

* Order
order ISO3 year

* Sort
sort ISO3 year

* Convert currency for european countries
merge m:1 ISO3 using $eur_fx, keep(1 3)
qui ds imports exports
foreach var in `r(varlist)'{
	replace `var' = `var'/EUR_irrevocable_FX if _merge == 3
}
drop EUR_irrevocable_FX _merge

* Save in a temporary file and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************
* 						INEGI
********************************************************************************
* Keep only one source
preserve
keep if strpos(source , "INEGI") > 0 // Is only for Mexico



* Rename the series
replace series = "c_USDfx" if series == "Market exchange rate, US dollar"
replace series = "c_M1" if series == "M1: old methodology"
replace series = "c_M2" if series == "M2: old methodology"
replace series = "c_M3" if series == "M3: old methodology"
replace series = "c_M4" if series == "M4: old methodology"
replace series = "c_imports_USD" if series == "Imports" // USD
replace series = "c_exports_USD" if series == "Exports" // USD
replace series = "c_cgov_debt" if series == "Federal debt: total" & scale == "Thousands"
replace series = "c_govrev" if series == "Federal revenue" & scale == "Millions"
replace series = "c_govexp" if series == "Federal spending" & scale == "Millions"
replace series = "c_rGDP_LCU" if series == "Gross domestic product" & unit == "Constant 1970 Mexican pesos"
replace series = "c_M0" if series == "Monetary base (M0)"
replace series = "c_CPI" if series == "Wholesale prices, Mexico City" & source == "INEGI (1999: Cuadro 19.6)"

* Keep only relevant rows
keep if strpos(series, "c_")

* Keep relevant columns
keep countryname series y_*

* Reshape
greshape long y_, i(countryname series) j(year) string

* Destring
destring year y_, replace

* Reshape into wide
greshape wide y_, i(countryname year) j(series) string

* Add country's ISO3 code
gen ISO3 = "MEX"
drop countryname

* Assert that all columns are numeric now
ds year y_*, has(type string)
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Rename
ren y_c_* *

* Add imports and exports in LCU
gen imports = imports_USD * USDfx
gen exports = exports_USD * USDfx

* Change to new denomination
ds imports exports cgov_debt govrev govexp  
foreach var in `r(varlist)'{
	replace `var' = `var' / 1000 if year < 1993
}


* Fix exchange rate units
replace USDfx = USDfx / 1000 if year <= 1992 & ISO3 == "MEX"

* Convert units
replace cgov_debt = cgov_debt / 1000

* Order
order ISO3 year

* Sort
sort ISO3 year

* Drop 
replace rGDP_LCU = . if year < 1895

* Save in a temporary file and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************
* 						SARBI
********************************************************************************
* Keep only one source
preserve
keep if strpos(source , "SARBI") > 0 // Is only for India



* Rename the series
replace series = "c_GBPfx" if series == "Market exchange rate: rate obtained by British Secretary of State for India for transfers on India"
replace series = "c_REVENUE1" if series == "Revenue, Indian government--series 1" // Units LCU
replace series = "c_REVENUE2" if series == "Revenue, Indian government--series 2" // Units LCU
replace series = "c_govexp1" if series == "Spending, Indian government--series 1" // Units LCU
replace series = "c_govexp2" if series == "Spending, Indian government--series 2" // Units LCU
replace series = "c_cgov_debt" if series == "Indian government debt: total" //  Units LCU


* Keep only relevant rows
keep if strpos(series, "c_")

* Keep relevant columns
keep countryname series y_*

* Reshape
greshape long y_, i(countryname series) j(year) string

* Destring
destring year y_, replace

* Reshape into wide
greshape wide y_, i(countryname year) j(series) string

* Add country's ISO3 code
gen ISO3 = "IND"
drop countryname

* Assert that all columns are numeric now
ds year y_*, has(type string)
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Rename
ren y_c_* *

* Aggregate two government revenue and spending series together (There is no break)
replace REVENUE1 = REVENUE2 if REVENUE1 == .
replace govexp1 = govexp2 if govexp1 == .

* Rename
ren govexp1 govexp
ren REVENUE1 REVENUE

* Drop
drop govexp2 REVENUE2

* Convert units
replace cgov_debt = cgov_debt / 1000000
replace REVENUE   = REVENUE   / 1000000
replace govexp    = govexp    / 1000000
ren REVENUE govrev 

* Order
order ISO3 year

* Sort
sort ISO3 year

* Save in a temporary file and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************
* 						COLOMBIA
********************************************************************************
* Keep only one source
preserve
keep if countryname == "Colombia"

* Rename the series
replace series = "c_DEFICIT" if series == "Central government deficit" 
replace series = "c_cons" if series == "Final consumption" 
replace series = "c_govrev" if series == "Government revenue" 
replace series = "c_govexp" if series == "Government spending: total" 
replace series = "c_inv" if series == "Gross domestic capital formation: total" & start == "1925"
replace series = "c_finv" if series == "Gross domestic capital formation: gross fixed domestic capital formation"
replace series = "c_sav" if series == "Saving: total, series 1" 


* Keep only relevant rows
keep if strpos(series, "c_")

* Keep relevant columns
keep countryname series y_*

* Reshape
greshape long y_, i(countryname series) j(year)

* Destring
destring year y_, replace

* Reshape into wide
greshape wide y_, i(countryname year) j(series) string

* Add country's ISO3 code
gen ISO3 = "COL"
drop countryname

* Assert that all columns are numeric now
ds year y_*, has(type string)
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Rename
ren y_c_* *


* Order
order ISO3 year

* Sort
sort ISO3 year

* Save in a temporary file and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************
* 						CHILE
********************************************************************************
* Keep only one source
preserve
keep if countryname == "Chile"

* Rename the series
replace series = "c_CPI" if series == "Consumer prices" // Index, 1996 =100
replace series = "c_deflator" if series == "GDP deflator" // Index, 1996 =100
replace series = "c_govrev" if series == "Government revenue, nominal"  // Chilean (post 1975) pesos
replace series = "c_govexp" if series == "Government spending, nominal" // Chilean (post 1975) pesos
replace series = "c_rGDP_LCU" if series == "Gross domestic product (GDP), real" //  1996 Chilean pesos
replace series = "c_M1" if series == "M1 (Estimate A: coins valued at face value)" // Chilean (post 1975) pesos
replace series = "c_M2" if series == "M2 (Estimate A: coins valued at face value)" // Chilean (post 1975) pesos
replace series = "c_M0" if series == "Monetary base (M0) (Estimate A: coins valued at face value)" // Chilean (post 1975) pesos
replace series = "c_strate" if series == "Short-run interest rate" // 

* Keep only relevant rows
keep if strpos(series, "c_")

* Keep relevant columns
keep countryname series y_*

* Reshape
greshape long y_, i(countryname series) j(year) string

* Destring
destring year y_, replace

* Reshape into wide
greshape wide y_, i(countryname year) j(series) string

* Add country's ISO3 code
gen ISO3 = "CHL"
drop countryname

* Assert that all columns are numeric now
ds year y_*, has(type string)
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Rename
ren y_c_* *

* Convert units
qui ds govrev govexp rGDP_LCU 
foreach var in `r(varlist)'{
	qui replace `var' = `var' * (10^-6)
}

* Order
order ISO3 year

* Sort
sort ISO3 year

* Save in a temporary file and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************
* 						BRAZIL
********************************************************************************
* Keep only one source
preserve
keep if countryname == "Brazil"

* Rename the series
replace series = "c_M1" if series == "M1: total" // Millions
replace series = "c_M2" if series == "M2: total" // Millions


* Keep only relevant rows
keep if strpos(series, "c_")

* Keep relevant columns
keep countryname series y_*

* Reshape
greshape long y_, i(countryname series) j(year) string

* Destring
destring year y_, replace

* Reshape into wide
greshape wide y_, i(countryname year) j(series) string

* Add country's ISO3 code
gen ISO3 = "BRA"
drop countryname

* Assert that all columns are numeric now
ds year y_*, has(type string)
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Rename
ren y_c_* *

* Convert units
replace M1 = M1 * (10^-15) / 2750 if ISO3 == "BRA"
replace M2 = M2 * (10^-15) / 2750 if ISO3 == "BRA"
replace M1 = M1  / 2750 if ISO3 == "BRA"
replace M2 = M2  / 2750 if ISO3 == "BRA"
replace year = year + 1 // Fixing the year values


* Order
order ISO3 year

* Sort
sort ISO3 year

* Save in a temporary file and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************
* 						CUBA
********************************************************************************
* Keep only one source
preserve
keep if countryname == "Cuba"

* Rename the series
replace series = "c_DEFICIT" if series == "Balance" // Units
replace series = "c_govrev" if series == "Revenue" // Units
replace series = "c_govexp" if series == "Spending" // Units



* Keep only relevant rows
keep if strpos(series, "c_")

* Keep relevant columns
keep countryname series y_*

* Reshape
greshape long y_, i(countryname series) j(year) string

* Destring
destring year y_, replace

* Reshape into wide
greshape wide y_, i(countryname year) j(series) string

* Add country's ISO3 code
gen ISO3 = "CUB"
drop countryname

* Assert that all columns are numeric now
ds year y_*, has(type string)
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Rename
ren y_c_* *

* Convert to millions
replace DEFICIT = DEFICIT/1000000
replace govrev = govrev/1000000
replace govexp  = govexp /1000000


* Drop rows with missing data
qui ds ISO3 year, not
qui missings dropobs `r(varlist)', force

* Order
order ISO3 year

* Sort
sort ISO3 year

* Save in a temporary file and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************
* 						Egypt
********************************************************************************
* Keep only one source
preserve
keep if strpos(countryname, "Egypt")

* Rename the series
replace series = "c_exports" if series == "Exports" & source == "IFS (April 1948)" // LCU Millions
replace series = "c_imports" if series == "Imports" & source == "IFS (April 1948)" // LCU Millions

* Keep only relevant rows
keep if strpos(series, "c_")

* Fix country's name
replace countryname = strtrim(countryname)

* Keep relevant columns
keep countryname series y_*

* Reshape
greshape long y_, i(countryname series) j(year) string

* Destring
destring year y_, replace

* Reshape into wide
greshape wide y_, i(countryname year) j(series) string

* Add country's ISO3 code
gen ISO3 = "EGY"
drop countryname

* Assert that all columns are numeric now
ds year y_*, has(type string)
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Rename
ren y_c_* *

* Drop rows with missing data
qui ds ISO3 year, not
qui missings dropobs `r(varlist)', force

* Order
order ISO3 year

* Sort
sort ISO3 year

* Save in a temporary file and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************
* 						Indonesia
********************************************************************************
* Keep only one source
preserve
use $input1, clear
keep if countryname == "Indonesia"

* Rename the series
replace series = "c_govrev" if series == "Government revenue, according to Civil Statements" // Netherlands East Indies guilders
replace series = "c_govexp" if series == "Government spending, according to Civil Statements" // Netherlands East Indies guilders
replace series = "c_rGDP_LCU" if series == "GDP"  // Billions LCU

* Keep only relevant rows
keep if strpos(series, "c_")

* Keep relevant columns
keep countryname series y_*

* Reshape
greshape long y_, i(countryname series) j(year) string

* Destring
destring year y_, replace

* Reshape into wide
greshape wide y_, i(countryname year) j(series) string

* Add country's ISO3 code
gen ISO3 = "IDN"
drop countryname

* Assert that all columns are numeric now
ds year y_*, has(type string)
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Rename
ren y_c_* *

* Drop rows with missing data
qui ds ISO3 year, not
qui missings dropobs `r(varlist)', force

* Convert units
replace rGDP_LCU = rGDP_LCU * 1000
replace govexp = govexp / 100000
replace govrev = govrev / 100000

* Order
order ISO3 year

* Sort
sort ISO3 year

* Save in a temporary file and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************
* 						Spain
********************************************************************************
* Keep only one source
preserve
keep if strpos(countryname, "Spain")

* Rename the series
replace series = "c_M0" if series == "Monetary base" // LCU Millions
replace series = "c_M1" if series == "M1" // LCU Millions
replace series = "c_M2" if series == "M2" // LCU Millions
replace series = "c_M3" if series == "M3" // LCU Millions
replace series = "c_GBPfx" if series == "Main official exchange rate, pound sterling" & start == "1821"

* Keep only relevant rows
keep if strpos(series, "c_")

* Keep relevant columns
keep countryname series y_*

* Reshape
greshape long y_, i(countryname series) j(year) string

* Destring
destring year y_, replace

* Reshape into wide
greshape wide y_, i(countryname year) j(series) string

* Add country's ISO3 code
gen ISO3 = "ESP"
drop countryname

* Assert that all columns are numeric now
ds year y_*, has(type string)
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Rename
ren y_c_* *

* Convert currency to Euro
merge m:1 ISO3 using $eur_fx, keep(1 3)
qui ds M1 M2 M3
foreach var in `r(varlist)'{
	replace `var' = `var'/EUR_irrevocable_FX if _merge == 3
}
drop EUR_irrevocable_FX _merge

* Drop rows with missing data
qui ds ISO3 year, not
qui missings dropobs `r(varlist)', force

* Order
order ISO3 year

* Sort
sort ISO3 year

* Save in a temporary file and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************
* 						Japan 
********************************************************************************
* Keep only one source
preserve
keep if strpos(countryname, "Japan")

* Rename the series
replace series = "c_cgov_debt1" if series == "National government debt" & start == "1805" // LCU Millions
replace series = "c_cgov_debt2" if series == "National government debt" & start == "1846" // LCU Millions
replace series = "c_govrev" if series == "National government revenue, net"  // LCU Millions
replace series = "c_govexp" if series == "National government spending, net"  // LCU Millions
replace series = "c_unemp" if series == "Unemployment rate"

* Keep only relevant rows
keep if strpos(series, "c_")

* Keep relevant columns
keep countryname series y_*

* Reshape
greshape long y_, i(countryname series) j(year) string

* Destring
replace y_ = "" if y_ == "..."
destring year y_, replace

* Reshape into wide
greshape wide y_, i(countryname year) j(series) string

* Add country's ISO3 code
gen ISO3 = "JPN"
drop countryname



* Assert that all columns are numeric now
ds year y_*, has(type string)
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Rename
ren y_c_* *

* Aggregate two series (no break)
replace cgov_debt1 = cgov_debt2 if cgov_debt1 == .
ren cgov_debt1 cgov_debt
drop cgov_debt2

* Convert units
replace govrev = govrev / (10^5)
replace govexp = govexp / (10^5)

* Drop rows with missing data
qui ds ISO3 year, not
qui missings dropobs `r(varlist)', force

* Order
order ISO3 year

* Sort
sort ISO3 year

* Save in a temporary file and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace


* Restore
restore

********************************************************************************
* 						IRELAND 
********************************************************************************
* Keep only one source
preserve
keep if strpos(countryname, "Ireland") 

* Rename the columns
keep if series == "Nominal GDP: Republic of Ireland" // "Nominal GDP: Republic of Ireland": Millions Pounds sterling

* Keep relevant columns
keep countryname y_*

* Reshape
greshape long y_, i(countryname) j(year) string

* Destring
destring year y_, replace

* Add country's ISO3 code
gen ISO3 = "IRL"
drop countryname

* Assert that all columns are numeric now
ds year y_, has(type string)
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Rename
ren y_ nGDP_LCU

* Drop rows with missing data
drop if nGDP_LCU == .

* Order
order ISO3 year

* Sort
sort ISO3 year

* Save in a temporary file and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace


* Restore
restore

********************************************************************************
* 						LEAGUE OF NATIONS 
********************************************************************************
* Keep only one source
keep if strpos(source, "League")

* Rename the series
replace series = "c_CPI_1929" if strpos(series, "Retail prices") & unit == "Index, 1929 = 100"
replace series = "c_CPI_n1929" if strpos(series, "Retail prices") & unit != "Index, 1929 = 100"

* Keep only relevant rows
keep if strpos(series, "c_")

* Drop duplicated series
duplicates tag countryname, gen(dup)
keep if dup == 0

* Keep relevant columns
keep countryname series y_*

* Reshape
greshape long y_, i(countryname series) j(year) string

* Destring
destring year y_, replace

* Reshape into wide
greshape wide y_, i(countryname year) j(series) string

* Generate countries' ISO3 code
replace countryname = "Myanmar" if countryname == "Myanmar (Burma)"
merge m:1 countryname using $isomapping, keep(3) nogen // Dataset includes some historical territories that no longer exist

* Keep ISO3
keep ISO3 year y_c_*

* Assert that all columns are numeric now
ds year y_*, has(type string)
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Rename
ren y_c_* *
ren CPI_1929 CPI
drop CPI_n1929


* Drop rows with missing data
qui ds ISO3 year, not
qui missings dropobs `r(varlist)', force

* Order
order ISO3 year

* Sort
sort ISO3 year

* Save in a temporary file and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* Fix units
replace imports = imports * 10 if ISO3 == "FIN"
replace exports = exports * 10  if ISO3 == "FIN"

replace imports = imports / 100 if ISO3 == "FRA"
replace exports = exports / 100 if ISO3 == "FRA"

replace imports = imports / 1000 if ISO3 == "POL"
replace exports = exports / 1000 if ISO3 == "POL"

replace imports = imports * 650 if ISO3 == "GNB"
replace exports = exports * 650 if ISO3 == "GNB"

replace imports = imports / (5e8) if ISO3 == "NIC"
replace exports = exports / (5e8) if ISO3 == "NIC"

replace imports = imports * 2 if ISO3 == "ZAF"
replace exports = exports * 2 if ISO3 == "ZAF"

* Fix values that deviates from other sources for Poland and Serbia
replace imports = . if inlist(ISO3, "POL", "SRB")
replace exports = . if inlist(ISO3, "POL", "SRB")

* ==============================================================================
* 	SET UP 
* ==============================================================================

* Derive inflation rate
sort ISO3 year
encode ISO3, gen(id)
xtset id year
by id: gen infl = (CPI - L.CPI) / L.CPI * 100  if L.CPI != .
drop id

* Add source identifier
ds ISO3 year, not
foreach var in `r(varlist)' {
	ren `var' HFS_`var'
}

* Drop rows with no data
qui ds ISO3 year, not
missings dropobs `r(varlist)', force

* Rename
ren *_LCU *
* ren HFS_CPI_1929 HFS_CPI
ren HFS_cgov_debt HFS_govdebt
ren HFS_DEFICIT HFS_govdef

* Drop unused variables
drop HFS_GBPfx

* Check for duplicates
isid ISO3 year

* Sort
sort ISO3 year

* Order
order ISO3 year

* Save
save "${output}", replace

* Remove input1 file
rm "$input1"

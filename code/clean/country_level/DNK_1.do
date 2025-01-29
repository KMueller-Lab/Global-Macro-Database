* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CLEAN DATA FOR DENMARK
* 
* Description: 
* This Stata script reads in and cleans data from 
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024/06/24
* Link: https://sites.google.com/view/kim-abildgren/historical-statistics
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================

global input "${data_raw}/country_level/DNK_1.xls"
global output "${data_clean}/country_level/DNK_1"

* ==============================================================================
* 	POPULATION
* ==============================================================================
clear
* Open
import excel using "${input}", clear sheet(S036A)

* Keep only columns with needed data
qui keep A B

* Rename columns
ren A year
ren B pop

* Drop documentation and empty rows
qui drop in 1/11
qui missings dropobs, force

* Destring 
qui destring *, replace

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Sort
sort year

* Convert units from thousands to million
replace pop = pop/1000

* Save
tempfile temp_master
qui save `temp_master', replace emptyok

* ==============================================================================
* 	Gross Domestic Product at market prices, current prices
* ==============================================================================

* Open
import excel using "${input}", clear sheet(S006A)

* Keep only columns with needed data
qui keep A B

* Rename columns
ren A year
ren B nGDP

* Drop documentation and empty rows
qui drop in 1/11
qui missings dropobs, force

* Destring 
qui destring *, replace

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Sort
sort year

* Save and merge
tempfile temp_nGDP
qui save `temp_nGDP', replace emptyok
qui merge 1:1 year using `temp_master', nogen
qui save `temp_master', replace

* ==============================================================================
* 	Gross Domestic Product at market prices, constant prices (Million 2010-kroner)
* ==============================================================================

* Open
import excel using "${input}", clear sheet(S042A)

* Keep only columns with needed data
qui keep A B

* Rename columns
ren A year
ren B rGDP

* Drop documentation and empty rows
qui drop in 1/11
qui missings dropobs, force

* Destring 
qui destring *, replace

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Sort
sort year

* Save and merge
tempfile temp_rGDP
qui save `temp_rGDP', replace emptyok
qui merge 1:1 year using `temp_master', nogen
qui save `temp_master', replace

* ==============================================================================
* 	Total consumption, current prices
* ==============================================================================

* Open
import excel using "${input}", clear sheet(S045A)

* Keep only columns with needed data
qui keep A B

* Rename columns
ren A year
ren B cons

* Drop documentation and empty rows
qui drop in 1/11
qui missings dropobs, force

* Destring 
qui destring *, replace

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Sort
sort year

* Save and merge
tempfile temp_cons
qui save `temp_cons', replace emptyok
qui merge 1:1 year using `temp_master', nogen
qui save `temp_master', replace

* ==============================================================================
* 	Gross investments, current prices
* ==============================================================================

* Open
import excel using "${input}", clear sheet(S046A)

* Keep only columns with needed data
qui keep A B

* Rename columns
ren A year
ren B inv

* Drop documentation and empty rows
qui drop in 1/11
qui missings dropobs, force

* Destring 
qui destring *, replace

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Sort
sort year

* Save and merge
tempfile temp_inv
qui save `temp_inv', replace emptyok
qui merge 1:1 year using `temp_master', nogen
qui save `temp_master', replace

* ==============================================================================
* 	Danmark Nationalbank's discount rate
* ==============================================================================

* Open
import excel using "${input}", clear sheet(S184A)

* Keep only columns with needed data
qui keep A B

* Rename columns
ren A year
ren B cbrate

* Drop documentation and empty rows
qui drop in 1/11
qui missings dropobs, force

* Destring 
qui destring *, replace

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Sort
sort year

* Save and merge
tempfile temp_cbrate
qui save `temp_cbrate', replace emptyok
qui merge 1:1 year using `temp_master', nogen
qui save `temp_master', replace

* ==============================================================================
* 	Yield on long-term government bonds
* ==============================================================================

* Open
import excel using "${input}", clear sheet(S001A)

* Keep only columns with needed data
qui keep A B

* Rename columns
ren A year
ren B ltrate

* Drop documentation and empty rows
qui drop in 1/11
qui missings dropobs, force

* Destring 
qui destring *, replace

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Sort
sort year

* Save and merge
tempfile temp_lgrate
qui save `temp_lgrate', replace emptyok
qui merge 1:1 year using `temp_master', nogen
qui save `temp_master', replace

* ==============================================================================
* 	House price index, nationwide (2022=100)
* ==============================================================================

* Open
import excel using "${input}", clear sheet(S030A)

* Keep only columns with needed data
qui keep A B

* Rename columns
ren A year
ren B HPI

* Drop documentation and empty rows
qui drop in 1/11
qui missings dropobs, force

* Destring 
qui destring *, replace

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Sort
sort year

* Save and merge
tempfile temp_HPI
qui save `temp_HPI', replace emptyok
qui merge 1:1 year using `temp_master', nogen
qui save `temp_master', replace

* ==============================================================================
* 	Bilateral exchange rate vis-á-vis United States (DKK per 100 USD)
* ==============================================================================

* Open
import excel using "${input}", clear sheet(S127A)

* Keep only columns with needed data
qui keep A B

* Rename columns
ren A year
ren B USDfx

* Drop documentation and empty rows
qui drop in 1/11
qui missings dropobs, force

* Destring 
qui destring *, replace

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Convert units
replace USDfx = USDfx/100

* Sort
sort year

* Save and merge
tempfile temp_USDfx
qui save `temp_USDfx', replace emptyok
qui merge 1:1 year using `temp_master', nogen
qui save `temp_master', replace

* ==============================================================================
* 	Real effective exchange-rate index (1980=100)
* ==============================================================================

* Open
import excel using "${input}", clear sheet(S093A)

* Keep only columns with needed data
qui keep A B

* Rename columns
ren A year
ren B REER

* Drop documentation and empty rows
qui drop in 1/11
qui missings dropobs, force

* Destring 
qui destring *, replace

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Sort
sort year

* Save and merge
tempfile temp_reer
qui save `temp_reer', replace emptyok
qui merge 1:1 year using `temp_master', nogen
qui save `temp_master', replace

* ==============================================================================
* 	Consumer price index, total (1980=100)
* ==============================================================================

* Open
import excel using "${input}", clear sheet(S032A)

* Keep only columns with needed data
qui keep A B

* Rename columns
ren A year
ren B CPI

* Drop documentation and empty rows
qui drop in 1/11
qui missings dropobs, force

* Destring 
qui destring *, replace

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Sort
sort year

* Save and merge
tempfile temp_CPI
qui save `temp_CPI', replace emptyok
qui merge 1:1 year using `temp_master', nogen
qui save `temp_master', replace

* ==============================================================================
* 	Unemployment rate
* ==============================================================================

* Open
import excel using "${input}", clear sheet(S041A)

* Keep only columns with needed data
qui keep A B

* Rename columns
ren A year
ren B unemp

* Drop documentation and empty rows
qui drop in 1/11
qui missings dropobs, force

* Destring 
qui destring *, replace

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Sort
sort year

* Save and merge
tempfile temp_unemp
qui save `temp_unemp', replace emptyok
qui merge 1:1 year using `temp_master', nogen
qui save `temp_master', replace

* ==============================================================================
* 	IMPORTS OF GOODS
* ==============================================================================

* Open
import excel using "${input}", clear sheet(S056A)

* Keep only columns with needed data
qui keep A B

* Rename columns
ren A year
ren B imports_goods

* Drop documentation and empty rows
qui drop in 1/11
qui missings dropobs, force

* Destring 
qui destring *, replace

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Sort
sort year

* Save and merge
tempfile temp_imports_goods
qui save `temp_imports_goods', replace emptyok
qui merge 1:1 year using `temp_master', nogen
qui save `temp_master', replace

* ==============================================================================
* 	IMPORTS OF SERVICES
* ==============================================================================

* Open
import excel using "${input}", clear sheet(S057A)

* Keep only columns with needed data
qui keep A B

* Rename columns
ren A year
ren B imports_services

* Drop documentation and empty rows
qui drop in 1/11
qui missings dropobs, force

* Destring 
qui destring *, replace

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Sort
sort year

* Save and merge
tempfile temp_imports_services
qui save `temp_imports_services', replace emptyok
qui merge 1:1 year using `temp_master', nogen
qui save `temp_master', replace

* ==============================================================================
* 	IMPORTS
* ==============================================================================

* Sort
sort year

* Derive imports as the sum of imports of goods and services after 1948
gen imports = imports_goods
replace imports = imports_goods + imports_services if year >= 1948

* Drop 
drop imports_goods imports_services

* Sort
sort year

* Save
qui save `temp_master', replace

* ==============================================================================
* 	EXPORTS OF GOODS
* ==============================================================================

* Open
import excel using "${input}", clear sheet(S054A)

* Keep only columns with needed data
qui keep A B

* Rename columns
ren A year
ren B exports_goods

* Drop documentation and empty rows
qui drop in 1/11
qui missings dropobs, force

* Destring 
qui destring *, replace

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Sort
sort year

* Save and merge
tempfile temp_exports_goods
qui save `temp_exports_goods', replace emptyok
qui merge 1:1 year using `temp_master', nogen
qui save `temp_master', replace

* ==============================================================================
* 	EXPORTS OF SERVICES
* ==============================================================================

* Open
import excel using "${input}", clear sheet(S055A)

* Keep only columns with needed data
qui keep A B

* Rename columns
ren A year
ren B exports_services

* Drop documentation and empty rows
qui drop in 1/11
qui missings dropobs, force

* Destring 
qui destring *, replace

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Sort
sort year

* Save and merge
tempfile temp_exports_services
qui save `temp_exports_services', replace emptyok
qui merge 1:1 year using `temp_master', nogen

* ==============================================================================
* 	EXPORTS
* ==============================================================================

* Sort
sort year

* Derive imports as the sum of imports of goods and services after 1948
gen exports = exports_goods
replace exports = exports_goods + exports_services if year >= 1948

* Drop 
drop exports_goods exports_services

* Add country's ISO3 code
gen ISO3 = "DNK"

* Derive inflation rate
sort ISO3 year
encode ISO3, gen(id)
xtset id year
by id: gen infl = (CPI - L.CPI) / L.CPI * 100 if L.CPI != .
drop id

* Add ratios to gdp variables
gen cons_GDP    = (cons / nGDP) * 100
gen imports_GDP = (imports / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100
gen inv_GDP     = (inv / nGDP) * 100


* Add source identifier
qui ds year ISO3, not
foreach var in `r(varlist)'{
	ren `var' CS1_`var'
}

* ==============================================================================
* 	SAVE
* ==============================================================================
* Order
order ISO3 year

* Sort
sort year

* Check for duplicates
isid year ISO3 

* Save
save "${output}", replace

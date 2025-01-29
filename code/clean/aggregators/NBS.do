* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
*
* Description: 
* This Stata script reads in and cleans data from National Bank of Serbia (NBS)
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-06-24
*
* URL: https://www.nbs.rs/en/drugi-nivo-navigacije/publikacije-i-istrazivanja/seemhn/seemhn-dctf/
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
* Clear
clear

* Set up
global input  "${data_raw}/aggregators/NBS/NBS.xlsx"
global output "${data_clean}/aggregators/NBS/NBS.dta"

* ==============================================================================
*  	GREECE
* ==============================================================================


* Open
import excel using "$input", clear sheet(GR data tables A)

* Preserve and save in a temporary file
preserve

* Keep only columns that have the same year range
keep DK DL DM DN DO DP DQ DR

* Rename columns
ren DK year
ren DL nGDP
ren DM rGDP
ren DN deflator
ren DO rGDP_pc
ren DP imports
ren DQ exports
ren DR pop

* Drop rows with missing data
drop in 1/4
missings dropobs, force

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
}
destring *, replace

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

* Add the country columns
gen ISO3 = "GRC"

* Order
order ISO3 year

* Sort
sort year

* Convert units
replace nGDP = nGDP / 1000
replace rGDP = rGDP / 1000
replace imports = imports / 1000
replace exports = exports / 1000

* Save
tempfile temp_master
save `temp_master', replace emptyok

* Restore
restore

********************************************************************************

* Preserve
preserve

* Keep only columns with needed data
keep L M N BE BF BG 

* Rename columns
ren L year
ren M M3 
ren N M0
ren BE cbrate
ren BF cbrate_bis
ren BG strate

* Drop rows with documentation
drop in 1/4
drop in 99/l

* Replace cbrate by cbrate after 1929
replace cbrate = cbrate_bis if cbrate == ""
drop cbrate_bis
replace cbrate = "9" if cbrate == "9*"
replace strate = "" if strate == ".."

* Destring
destring *, replace

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

* Add the country columns
gen ISO3 = "GRC"

* Order
order ISO3 year

* Sort
sort year

* Convert units
replace M3 = M3 / 1000
replace M0 = M0 / 1000

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************

* Preserve
preserve

* Keep only columns with needed data
keep CG CJ CH CI

* Drop rows with missing data
drop in 1/42
drop in 28/l

* Rename columns
ren CG year
ren CJ USDfx
ren CH GBPfx
ren CI FRFfx

* Destring
destring *, replace

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

* Add the country columns
gen ISO3 = "GRC"

* Order
order ISO3 year

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************

* Preserve
preserve

* Keep columns with needed data 
keep CM CN CO CR

* Rename columns
ren CM year
ren CN govrev
ren CO govtax
ren CR govexp

* Drop empty rows
drop in 1/4
drop if strpos(year, "Note")
missings dropobs, force

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
	replace `var'  = "" if `var' == "."
}
destring *, replace

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
replace govrev = govrev / 1000
replace govtax = govtax / 1000
replace govexp = govexp / 1000

* Add ISO3 code
gen ISO3 = "GRC"

* Order
order ISO3 year

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************

* Preserve
preserve

* Keep only columns with needed data
keep CX CY

* Rename columns
ren CX year
ren CY CPI

* Drop empty rows
drop in 1/4
missings dropobs, force

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
	replace `var'  = "" if `var' == "."
}
destring *, replace

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

* Add country's ISO3 code
gen ISO3 = "GRC"

*Order
order ISO3 year

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore
restore

* ==============================================================================
*  ROMANIA
* ==============================================================================
* Clear

import excel using "${input}", clear sheet(RO data tables A)

* Preserve
preserve

* Rename columns
ren BG year
ren BH nGDP
ren BI imports
ren BK exports
ren BM pop
ren AQ govrev
ren AR govtax
ren AS govtax_bis
ren AT govrev_bis
ren AU govexp
ren AV govexp_bis
ren AX govdebt
ren AK USDfx
ren AF FRFfx
ren AH GBPfx

* Keep only columns with needed data
ds
foreach var of varlist _all { 
    if length("`var'") < 3 {
        drop `var'
    }
}

* Drop empty rows
drop in 1/6
missings dropobs, force

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
	replace `var'  = "" if `var' == "."
}
destring *, replace

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

* Add country's ISO3 code
gen ISO3 = "ROU"

*Order
order ISO3 year

* Sort
sort year

* Create variables as the sum of their components
replace govexp = govexp + govexp_bis if govexp_bis != .
replace govrev = govrev + govrev_bis if govrev_bis != .
replace govtax = govtax + govtax_bis if govtax_bis != .

* Drop
drop *_bis

* Convert units
replace nGDP    = nGDP
replace imports = imports /  1000
replace exports = exports /  1000
replace govrev  = govrev  /  1000
replace govtax  = govtax  /  1000
replace govdebt = govdebt /  1000
replace govexp  = govexp  /  1000

* Create variable share per GDP
gen govrev_GDP  = (govrev/nGDP)  * 100 if nGDP != .
gen govtax_GDP  = (govtax/nGDP)  * 100 if nGDP != .
gen govdebt_GDP = (govdebt/nGDP) * 100 if nGDP != .

* Drop
drop govdebt govrev govtax

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************

* Preserve
preserve

* Keep only columns with needed data
keep L Q R

* Rename
ren L year
ren Q M0
ren R M3

* Drop empty columns
drop in 1/6
missings dropobs, force

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
	replace `var'  = "" if `var' == "."
}
destring *, replace
missings dropobs `r(varlist)', force

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

* Add country's ISO3 code
gen ISO3 = "ROU"

* Convert units
replace M0 = M0 / 1000
replace M3 = M3 / 1000

* Order
order ISO3 year

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore 
restore 

********************************************************************************

* Preserve
preserve

* Keep only columns with needed data
keep BB BC

* Rename
ren BB year
ren BC CPI

* Drop empty columns
drop in 1/6
missings dropobs, force

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
	replace `var'  = "" if `var' == "."
}
destring *, replace

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

* Add country's ISO3 code
gen ISO3 = "ROU"


* Order
order ISO3 year

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************

* Preserve
preserve

* Keep only columns with needed data
keep T U W

* Rename
ren T year
ren U month
ren W cbrate

* Drop empty columns
drop in 1/6
missings dropobs, force

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
	replace `var'  = "" if `var' == "."
}
destring *, replace

* Keep end of year observation
bysort year: keep if _n == _N
drop month

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

* Add country's ISO3 code
gen ISO3 = "ROU"

* Order
order ISO3 year

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************

* Preserve
preserve

* Keep only columns with needed data
keep Y Z AB

* Rename
ren Y year
ren Z month
ren AB strate

* Drop empty columns
drop in 1/6
missings dropobs, force

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
	replace `var'  = "" if `var' == "."
}
destring *, replace

* Keep end of year observation
bysort year: keep if _n == _N
drop month 

* Drop duplicated years
drop in 21
drop in 6

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

* Add country's ISO3 code
gen ISO3 = "ROU"

* Order
order ISO3 year

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore
restore

* ==============================================================================
*  ALBANIA
* ==============================================================================

* Open
import excel using "${input}", clear sheet(AL data tables A)

* Preserve
preserve

* Keep only columns with needed data
keep AX AY AZ BA

* Rename
ren AX year
ren AY exports
ren AZ imports
ren BA pop

* Drop empty columns
drop in 1/4
missings dropobs, force

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
	replace `var'  = "" if `var' == "."
}
destring *, replace

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

* Add country's ISO3 code
gen ISO3 = "ALB"

* Convert units
replace imports = imports / 1000
replace exports = exports / 1000

* Order
order ISO3 year

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************

* Preserve
preserve

* Keep only columns with needed data
keep AJ AK AL AM

* Rename
ren AJ year
ren AK govrev
ren AL govexp
ren AM govtax

* Drop empty columns
drop in 1/4
missings dropobs, force

* Fix the year column
replace year = substr(year, -4, 4)
replace year = "1923" if year == "1922"
replace year = "1922" if year == "1921"

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
	replace `var'  = "" if `var' == "."
}
destring *, replace

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

* Add country's ISO3 code
gen ISO3 = "ALB"

* Order
order ISO3 year

* Convert units
replace govrev = govrev / 1000
replace govtax = govtax / 1000
replace govexp = govexp / 1000

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************

* Preserve
preserve

* Keep only columns with needed data
keep L T U
ren L year
ren T M0
ren U M3

* Drop empty columns
drop in 1/4
missings dropobs, force
drop in 13

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
	replace `var'  = "" if `var' == "."
}
destring *, replace

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

* Add country's ISO3 code
gen ISO3 = "ALB"

* Order
order ISO3 year

* Sort
sort year

* Convert units
replace M0 = M0 / 1000
replace M3 = M3 / 1000

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************

* Preserve
preserve

* Keep only columns with needed data
keep W Y 
ren W year
ren Y cbrate

* Drop empty columns
drop in 1/4
missings dropobs, force

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
	replace `var'  = "" if `var' == "."
}
destring *, replace

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

* Add country's ISO3 code
gen ISO3 = "ALB"

* Order
order ISO3 year

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore
restore

* ==============================================================================
*  	BULGARIA
* ==============================================================================

* Clear
import excel using "${input}", clear sheet(BG data tables A)

* Preserve
preserve

* Rename columns
ren BI year
ren BJ nGDP
ren BK rGDP
ren BM imports
ren BL exports
ren BN pop
ren AW govrev
ren AX govexp
ren AZ govdebt
ren BA govdebt_d

* Keep only columns with needed data
ds
foreach var of varlist _all { 
    if length("`var'") < 3 {
        drop `var'
    }
}

* Drop empty columns
drop in 1/5
missings dropobs, force

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
	replace `var'  = "" if `var' == "."
}
destring *, replace

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

* Add country's ISO3 code
gen ISO3 = "BGR"

* Add government debt as the sum of domestic and foreign government debt
replace govdebt = govdebt + govdebt_d if govdebt_d != .

* Convert units
replace nGDP = nGDP / 1000
replace rGDP = rGDP / 1000
replace imports = imports / 1000
replace exports = exports / 1000
replace govrev = govrev / 1000
replace govdebt = govdebt / 1000
replace govexp = govexp / 1000

* Create the ratio per GDP
gen govdebt_GDP = govdebt/nGDP * 100
gen govrev_GDP = govrev/nGDP * 100

* Drop 
drop govrev govdebt govdebt_d

* Order
order ISO3 year

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************

* Preserve
preserve

* Keep only columns with needed data
keep AO AS AP AQ

* Rename columns
ren AO year
ren AS USDfx
ren AP GBPfx
ren AQ FRFfx

* Drop empty columns
drop in 1/5
missings dropobs, force

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
	replace `var'  = "" if `var' == "."
}
destring *, replace

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

* Add country's ISO3 code
gen ISO3 = "BGR"

* Order
order ISO3 year

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************

* Preserve
preserve

* Keep only columns with needed data
keep BC BD BE BF BG
ren BC year
ren BD CPI

* Rename columns
ren BE wholesale_price_index
ren BF retail_price_index
ren BG gen_market_price_index

* Drop empty columns
drop in 1/5
missings dropobs, force

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
	replace `var'  = "" if `var' == "."
}
destring *, replace

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

* Add country's ISO3 code
gen ISO3 = "BGR"

* Set CPI as the available CPI
replace CPI = retail_price_index 	  if  CPI == .
replace CPI = gen_market_price_index  if  CPI == .
replace CPI = wholesale_price_index   if  CPI == .

* Keep
keep ISO3 year CPI

* Order
order ISO3 year

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************

* Preserve
preserve

* Keep only columns with needed data
keep X Z AA

* Rename columns
ren X year
ren Z month
ren AA cbrate

* Drop empty columns
drop in 1/5
missings dropobs, force

* Use end of period observation
destring year cbrate, replace
bysort year: keep if _n == _N
drop month 

* Destring
destring *, replace

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

* Add country's ISO3 code
gen ISO3 = "BGR"

* Order
order ISO3 year

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************

* Preserve
preserve

* Keep only columns with needed data
keep Q R V

* Rename columns
ren Q year
ren R M0
ren V M3

* Drop empty columns
drop in 1/5
missings dropobs, force

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
	replace `var'  = "" if `var' == "."
}
destring *, replace

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

* Add country's ISO3 code
gen ISO3 = "BGR"

* Convert Units
replace M0 = M0/1000
replace M3 = M3/1000

* Order
order ISO3 year

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore
restore

* ==============================================================================
* 	 TURKEY
* ==============================================================================

* Clear
import excel using "${input}", clear sheet(TR data tables A)

* Preserve
preserve

* Rename columns
keep AN AO AP AQ AR AS AI AC AD AE AF Z G M N O
ren AN year
ren AO nGDP
ren AP rGDP
ren AQ exports
ren AR imports
ren AS pop
ren AI CPI
ren AC govtax
ren AD govrev
ren AE govdebt
ren AF govdebt_d
ren Z USDfx
ren G M0
ren M M1
ren N M2
ren O M3


* Drop empty columns
drop in 1/6
missings dropobs, force

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
	replace `var'  = "" if `var' == "."
}
destring *, replace

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

* Add country's ISO3 code
gen ISO3 = "TUR"

* Add foreign debt to domestic debt 
replace govdebt = govdebt + govdebt_d if govdebt_d != .
drop govdebt_d

* Convert units
replace nGDP = nGDP / 1000
replace rGDP = rGDP / 1000

replace imports = imports / 1000
replace exports = exports / 1000

replace govrev = govrev / 1000
replace govtax = govtax / 1000
replace govdebt = govdebt / 1000

replace M0 = M0 / 1000
replace M1 = M1 / 1000
replace M2 = M2 / 1000
replace M3 = M3 / 1000

* Create the ratio per GDP
gen govdebt_GDP = govdebt/nGDP * 100
gen govrev_GDP  = govrev/nGDP  * 100
gen govtax_GDP  = govtax/nGDP  * 100

* Drop 
drop govrev govdebt govtax

* Order
order ISO3 year

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************

* Preserve
preserve

* Rename columns
keep Q R S T
ren Q year
ren R cbrate
ren S strate
ren T ltrate

* Drop empty columns
drop in 1/6
missings dropobs, force

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
	replace `var'  = "" if `var' == "."
}
destring *, replace

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

* Add country's ISO3 code
gen ISO3 = "TUR"

* Order
order ISO3 year

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore
restore

* ==============================================================================
*  	SERBIA
* ==============================================================================

* Clear
import excel using "${input}", clear sheet(SE data tables A)

* Preserve
preserve

* Rename columns
keep BY CC
ren BY year
ren CC pop

* Drop empty columns
drop in 1/4
missings dropobs, force

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
	replace `var'  = "" if `var' == "."
}
destring *, replace

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

* Add country's ISO3 code
gen ISO3 = "SRB"

* Convert units
replace pop     = pop     / 1000

* Order
order ISO3 year

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore
restore

********************************************************************************

* Preserve
preserve

* Rename columns
keep A AI AK I
ren A year
ren AI cbrate
ren AK strate
ren I M0


* Drop empty columns
drop in 1/4
missings dropobs, force

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
	replace `var'  = "" if `var' == "."
}
destring *, replace

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

* Add country's ISO3 code
gen ISO3 = "SRB"

* Order
order ISO3 year

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* Restore
restore

* ==============================================================================
*  	AUSTRIA
* ==============================================================================

* Clear
import excel using "${input}", clear sheet(AH data tables A)

* Rename
keep BV Z AA BR BW BY CA CG
ren BV year
ren Z cbrate
ren AA strate
ren BR CPI
ren BW nGDP
ren BY rGDP
ren CA rGDP_pc
ren CG pop

* Drop empty columns
drop in 1/4
missings dropobs, force

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
	replace `var'  = "" if `var' == "."
}
destring *, replace

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
replace pop = pop/10

* Add country's ISO3 code
gen ISO3 = "AUT"

* Order
order ISO3 year

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
*  	HUNGARY
* ==============================================================================

* Open
import excel using "${input}", clear sheet(AH data tables A)

* Rename columns
keep BV Z AA BX BZ CB CH
ren BV year
ren Z cbrate
ren AA strate
ren BX nGDP
ren BZ rGDP
ren CB rGDP_pc
ren CH pop

* Drop empty columns
drop in 1/4
missings dropobs, force

* Destring
ds year, not
foreach var in `r(varlist)'{
	replace `var'  = "" if `var' == ".."
	replace `var'  = "" if `var' == "."
}
destring *, replace

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
replace pop = pop/10

* Add country's ISO3 code
gen ISO3 = "HUN"

* Order
order ISO3 year

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
* 	Create the ratio per GDP for GRC
* ==============================================================================
replace govdebt_GDP = govdebt / nGDP * 100 if ISO3 == "GRC"
replace govrev_GDP = govrev   / nGDP * 100 if ISO3 == "GRC"

* ==============================================================================
* 	Convert currencies
* ==============================================================================

* Add ratios to gdp variables
gen imports_GDP = (imports / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100
gen govexp_GDP  = (govexp / nGDP) * 100
replace govrev_GDP  = (govrev / nGDP) * 100
replace govtax_GDP  = (govtax / nGDP) * 100


* Rename variables to include NBS_
ds ISO3 year, not
foreach var in `r(varlist)'{
	ren `var' NBS_`var'
}
merge m:1 ISO3 using "$eur_fx", keep(1 3) nogen 
qui ds NBS_nGDP NBS_rGDP NBS_M0 NBS_M1 NBS_M2 NBS_M3 NBS_govexp NBS_govrev NBS_govtax
foreach var in `r(varlist)'{
	replace `var' = `var' / EUR_irrevocable_FX if EUR_irrevocable_FX  != .
}
drop EUR_irrevocable_FX


* Convert Turkey currency
replace NBS_USDfx   = NBS_USDfx   / 100000 if ISO3 == "TUR"

* Convert Turkey's currency 
qui ds NBS_nGDP NBS_rGDP NBS_M0 NBS_M1 NBS_M2 NBS_M3 NBS_govexp NBS_govrev NBS_govtax NBS_exports NBS_imports
foreach var in `r(varlist)'{
	replace `var' = `var' / 1000000 if ISO3 == "TUR"
}

* Convert Romania's currency 
ds NBS_nGDP NBS_rGDP NBS_M0 NBS_M1 NBS_M2 NBS_M3 NBS_govexp NBS_govrev NBS_govtax NBS_exports NBS_imports NBS_USDfx
foreach var in `r(varlist)'{
	replace `var' = `var' * (10^-8) if ISO3 == "ROU"
}

* Convert Greece's currency 
qui ds NBS_rGDP NBS_M0 NBS_M1 NBS_M2 NBS_M3 NBS_govexp NBS_govrev NBS_govtax NBS_exports NBS_imports
foreach var in `r(varlist)'{
	replace `var' = `var' * (10^-6)   if ISO3 == "GRC"
	replace `var' = `var' / 5  if ISO3 == "GRC"
}

* Convert Bulgaria's currency 
qui ds NBS_nGDP NBS_USDfx NBS_rGDP NBS_M0 NBS_M1 NBS_M2 NBS_M3 NBS_govexp NBS_govrev NBS_govtax NBS_exports NBS_imports
foreach var in `r(varlist)'{
	replace `var' = `var' / 1000000 if ISO3 == "BGR"
}

* Convert Greece's exchange rate again
replace NBS_USDfx = NBS_USDfx / 500 if ISO3 == "GRC" 

* Derive inflation rate
sort ISO3 year
encode ISO3, gen(id)
xtset id year
by id: gen NBS_infl = (NBS_CPI - L.NBS_CPI) / L.NBS_CPI * 100 if L.NBS_CPI != .
drop id

* Drop
drop NBS_GBPfx NBS_FRFfx

* Austria Hungary population wrong when cross-checking with official Census data

* ==============================================================================
*  OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Check for duplicates
isid year ISO3

* Order
order ISO3 year

* Save
save "${output}", replace

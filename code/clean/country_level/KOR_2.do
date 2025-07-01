* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN KOREAN HISTORICAL ECONOMIC DATA
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2025-06-20
*
* URL:
* https://link.springer.com/book/10.1007/978-981-15-3874-2
* 
* ==============================================================================

* ==============================================================================
* SET UP
* ==============================================================================
clear
global trade  "${data_raw}/country_level/KOR_2a.xlsx"
global CPI    "${data_raw}/country_level/KOR_2b.xlsx"
global NA 	  "${data_raw}/country_level/KOR_2c.xlsx"
global gov 	  "${data_raw}/country_level/KOR_2d.xlsx"
global fin    "${data_raw}/country_level/KOR_2e.xlsx"
global output "${data_clean}/country_level/KOR_2.dta"

* Add temporary variable 
tempfile temp_master
save `temp_master', replace emptyok

* ==============================================================================
*			NATIONAL ACCOUNTS (CONSTAT PRICES)
* ==============================================================================

* Open
qui import excel using "${NA}", sheet("N11-16") clear

* Rename
keep A B C D E
ren(A B C D E) (year rGDPKOR rGDPPRK popKOR popPRK)

* Drop unused rows
keep in 6/110 

* Destring the variables 
destring *, replace

* Reshape 
greshape long rGDP pop, i(year) j(ISO3) string

* Convert units 
qui replace rGDP = rGDP * 1000 
qui replace pop  = pop  / 1000

* Sort 
sort ISO3 year

* Save 
save `temp_master', replace

* ==============================================================================
*			NATIONAL ACCOUNTS (CURRENT PRICES)
* ==============================================================================

* Open
qui import excel using "${NA}", sheet("N17-32") clear

* Rename
keep A B I J K L M N
ren(A B I J K L M N) (year nGDP cons_h cons_g finv stock exports imports)

* Drop unused rows
keep in 5/98
drop in 31

* Destring the variables 
destring *, replace

* Create variables 
gen cons = cons_g + cons_h 
gen inv  = finv + stock
drop cons_* stock

* Convert units 
qui ds year, not 

* Add ISO3 code 
gen ISO3 = "KOR"

* Sort
sort year

* Order
order ISO3 year

* Merge 
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
*			TRADE
* ==============================================================================

* Open
qui import excel using "${trade}", sheet("V1-13") clear

* Rename
keep A B C N
ren(A B C N) (year exports imports CA)

* Drop rows 
keep in 6/101
drop if year == ""

* Destring
destring *, replace

* Create variables 
qui ds year, not
foreach var in `r(varlist)'{
	qui gen `var'_USD = `var' if year >= 1950
	qui replace `var' = . if year >= 1950
}

* Add ISO3 code 
gen ISO3 = "KOR"

* Merge 
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
*			Consumer Price index (1945-2009)
* ==============================================================================

* Open
qui import excel using "${CPI}", sheet("O4-8") clear

* Drop unused columns and rows
keep in 5/69
keep F G

* Rename
ren(F G) (year CPI)

* Destring 
destring *, replace

* Sort
sort year

* Add ISO3 code 
gen ISO3 = "KOR"

* Order
order ISO3 year

* Merge 
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
*			MONETARY AGGREGATES (1)
* ==============================================================================

* Open
qui import excel using "${fin}", sheet("S44-49") clear

* Drop unused columns and rows
keep in 6/49
keep A C E F

* Rename
ren(A C E F) (year M1 M2 M0)

* Destring 
destring *, replace

* Sort
sort year

* Add ISO3
gen ISO3 = "KOR"

* Order
order ISO3 year

* drop
drop if year == .

* Convert units 
ds M* 
foreach var in `r(varlist)'{
	qui replace `var' = `var'/1000
}

* Merge 
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
*			MONETARY AGGREGATES (2)
* ==============================================================================

* Open
qui import excel using "${fin}", sheet("S50-61") clear

* Drop unused columns and rows
keep in 5/75
keep A B C D H J

* Rename
ren(A B C D H J) (year M0 old_M1 old_M2 new_M1 new_M2)

* Destring 
destring *, replace

* Sort
sort year

* Add ISO3
gen ISO3 = "KOR"

* Order
order ISO3 year

* drop
drop if year == .

* Convert units 
ds *M*
foreach var in `r(varlist)'{
	qui replace `var' = `var'*1000
}

* Chainlink old and new variabels 
splice, priority(new old) generate(M1) varname(M1) base_year(2014)  method("chainlink") save("NO")
splice, priority(new old) generate(M2) varname(M2) base_year(2014)  method("chainlink") save("NO")

* Keep final variables 
drop old* new*

* Merge 
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
*			GOVERNMENT EXPENDITURE 
* ==============================================================================


* Open
qui import excel using "${gov}", sheet("T1-15") clear

* Drop unused columns and rows
keep in 6/104
keep A C

* Rename
ren(A C) (year govexp)

* Destring 
destring *, replace

* Sort
sort year
drop if year == .

* Add ISO3 code 
gen ISO3 = "KOR"

* Order
order ISO3 year

* Convert units
replace govexp = govexp * 1000 if year >= 1951

* Merge 
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
*			GOVERNMENT REVENUE 
* ==============================================================================

* Open
qui import excel using "${gov}", sheet("T203-219") clear

* Drop unused columns and rows
keep in 6/123
keep A C B

* Rename
ren(A B C) (year govrev govtax)

* Destring 
drop if year == ""
destring *, replace

* Sort
sort year

* Add ISO3 code 
gen ISO3 = "KOR"

* Order
order ISO3 year

* Convert units
replace govrev = govrev * 1000 if year >= 1946
replace govtax = govtax * 1000 if year >= 1946

* Merge 
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
*			GOVERNMENT DEFICIT 
* ==============================================================================

* Open
qui import excel using "${gov}", sheet("T236-251") clear

* Drop unused columns and rows
keep in 6/38
keep A K

* Rename
ren(A K) (year govdef)

* Destring 
destring *, replace

* Sort
sort year

* Add ISO3 code 
gen ISO3 = "KOR"

* Order
order ISO3 year

* Merge 
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
*			GOVERNMENT DEFICIT 
* ==============================================================================

* Open
qui import excel using "${gov}", sheet("T252-272") clear

* Drop unused columns and rows
keep in 7/68
keep A D

* Rename
ren(A D) (year govdef)

* Destring 
destring *, replace

* Sort
sort year

* Add ISO3 code 
gen ISO3 = "KOR"

* Order
order ISO3 year

* Merge 
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
*			GOVERNMENT DEBT 
* ==============================================================================

* Open
qui import excel using "${gov}", sheet("T273-291") clear

* Drop unused columns and rows
keep in 12/41
keep A T

* Rename
ren(A T) (year govdebt_GDP)

* Destring 
destring *, replace

* Sort
sort year

* Add ISO3 code 
gen ISO3 = "KOR"

* Order
order ISO3 year

* Merge 
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
*			GOVERNMENT DEBT 
* ==============================================================================

* Open
qui import excel using "${gov}", sheet("T292-301") clear

* Drop unused columns and rows
keep in 12/73
keep A K

* Rename
ren(A K) (year govdebt_GDP)

* Destring 
destring *, replace

* Sort
sort year

* Add ISO3 code 
gen ISO3 = "KOR"

* Order
order ISO3 year

* Merge 
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Add data identifier
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	qui ren `var' CS2_`var'
}

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplciates
isid ISO3 year

* Save
save "${output}", replace






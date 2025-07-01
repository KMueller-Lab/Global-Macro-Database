* ==============================================================================
* GLOBAL CREDIT DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and clean historical economic data for Spain Central Bank
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-12-29
*
* URL: https://repositorio.bde.es/handle/123456789/23358?locale=en
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
* Clear
clear
global input1 "${data_raw}/country_level/ESP_2a.xlsx"
global input2 "${data_raw}/country_level/ESP_2b.xlsx"
global input3 "${data_raw}/country_level/ESP_2c.xlsx"
global input4 "${data_raw}/country_level/ESP_2d.xlsx"
global input5 "${data_raw}/country_level/ESP_2e.xlsx"
global output "${data_clean}/country_level/ESP_2"

* ==============================================================================
*	Import inflation data
* ==============================================================================

* Open
import excel using "$input1", clear sheet("1500-2010_A") allstring cellrange(N3:TC4) 

* Rename the columns
qui ds
foreach var in `r(varlist)'{
	local newname = `var'[1]
	ren `var' infl`newname'
}
drop in 1

* Add ISO3 
gen ISO3 = "ESP"

* Reshape
greshape long infl, i(ISO3) j(year)

* Destring 
destring infl, force replace

* Save 
tempfile temp_master
save `temp_master', replace

* ==============================================================================
*	Import Population data between 1277 and 1849
* ==============================================================================

* Open
import excel using "$input2", clear sheet("Cuadro_3") allstring cellrange(M3:VM4) 

* Rename the columns
qui ds
foreach var in `r(varlist)'{
	local newname = `var'[1]
	ren `var' pop`newname'
}
drop in 1

* Add ISO3 
gen ISO3 = "ESP"

* Reshape
greshape long pop, i(ISO3) j(year)

* Destring 
destring pop, force replace

* Save
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
*	Import Population data after 1850
* ==============================================================================

* Open
import excel using "$input2", clear sheet("Cuadro_2") allstring cellrange(M3:GA5) 
drop in 2 // empty row

* Rename the columns
qui ds
foreach var in `r(varlist)'{
	local newname = `var'[1]
	ren `var' pop`newname'
}
drop in 1

* Add ISO3 
gen ISO3 = "ESP"

* Reshape
greshape long pop, i(ISO3) j(year)

* Destring 
destring pop, force replace

* Save
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
*	Import national accounts data
* ==============================================================================

* Open
import excel using "$input3", clear sheet("Prados-Escosura_A") allstring cellrange(B3:GA19)

* Keep needed rows
replace I = "var" in 1
replace I = "nGDP" in 4
replace I = "cons" in 5
replace I = "inv" in 8
replace I = "finv" in 9
replace I = "exports" in 16
replace I = "imports" in 17
drop if I == ""
drop B C D E F G H J K L

* Rename the columns
qui ds I, not
foreach var in `r(varlist)'{
	local newname = `var'[1]
	ren `var' CS2_`newname'
}
drop in 1

* Add ISO3 
gen ISO3 = "ESP"

* Reshape
greshape long CS2_, i(ISO3 I) j(year)
greshape wide CS2_, i(ISO3 year) j(I) string

* Destring 
destring CS2*, replace

* Save
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
*	Import real GDP data
* ==============================================================================

* Open
import excel using "$input3", clear sheet("PIB_A_1850-2020") allstring cellrange(M3:FU23)
drop in 2/8 // keep only year and real gdp rows
drop in 3/13

* Add column id
gen I = "var" in 1 
replace I = "rGDP" in 2
replace I = "rGDP_pc" in 3

* Rename the columns
qui ds I, not
foreach var in `r(varlist)'{
	local newname = `var'[1]
	ren `var' CS2_`newname'
}
drop in 1

* Add ISO3 
gen ISO3 = "ESP"

* Reshape
greshape long CS2_, i(ISO3 I) j(year)
greshape wide CS2_, i(ISO3 year) j(I) string

* Destring 
destring CS2*, replace
* Save
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
*	Import real GDP per capita index data
* ==============================================================================

* Open
import excel using "$input3", clear sheet("PIB_A_1277-1850") allstring cellrange(M3:VN4)

* Rename the columns
qui ds
foreach var in `r(varlist)'{
	local newname = `var'[1]
	ren `var' rGDP_pc_index`newname'
}
drop in 1

* Add ISO3 
gen ISO3 = "ESP"

* Reshape
greshape long rGDP_pc_index, i(ISO3) j(year)

* Destring 
destring rGDP_pc_index, force replace

* Save
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* Chainlink rGDP pc 
ren rGDP_pc_index index_rGDP_pc
splice, priority(CS2 index) generate(rGDP_pc) varname(rGDP_pc) method("chainlink") base_year(2010) save("NO") 
drop CS2_rGDP_pc index_rGDP_pc

* Save
save `temp_master', replace

* ==============================================================================
*	Import exchange rate data
* ==============================================================================

* Open
import excel using "$input5", clear sheet("Cuadro_1b") allstring cellrange(M4:ACP6)

* Add column id
gen I = "var" in 1 
replace I = "cbrate_1" in 2
replace I = "cbrate_2" in 3

* Rename the columns
qui ds I, not
foreach var in `r(varlist)'{
	replace `var' = subinstr(`var', ":", "", .)
	local newname = `var'[1]
	ren `var' CS2_`newname'
}
drop in 1

* Add ISO3 
gen ISO3 = "ESP"

* Reshape
greshape long CS2_, i(ISO3 I) j(date) string
greshape wide CS2_, i(ISO3 date) j(I) string

* Destring 
destring CS2*, replace

* Extract the year and month
gen year = substr(date, 1, 4)
gen month = substr(date, 5, 2)
destring year month, replace

* Keep end-of-year observations 
sort year month
by year: keep if _n == _N

* Add the final column
gen CS2_cbrate = CS2_cbrate_1
replace CS2_cbrate = CS2_cbrate_2 if CS2_cbrate == .

* Keep only final variables
keep ISO3 year CS2_cbrate

* Save
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* Maximize real GDP availability
replace CS2_rGDP = (rGDP_pc * pop) if CS2_rGDP == .

* Add ratios to gdp variables
ren CS2_* *
gen cons_GDP    = (cons / nGDP) * 100
gen imports_GDP = (imports / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100
gen finv_GDP    = (finv / nGDP) * 100
gen inv_GDP     = (inv / nGDP) * 100

* Add the deflator
gen deflator = (nGDP / rGDP) * 100

* Rebase the GDP to 2010
qui gen  temp = deflator if year == 2010 
qui egen defl_2010 = max(temp) 
qui replace rGDP = (rGDP * defl_2010) / 100 
qui drop temp defl_2010	

* Update the deflator
replace deflator = (nGDP / rGDP) * 100


* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	ren `var' CS2_`var'
}

* Convert population units
replace CS2_pop = CS2_pop / 1000000

* ==============================================================================
* 	Output
* ==============================================================================

* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace

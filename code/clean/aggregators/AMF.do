* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN ECONOMIC DATA FROM AMF
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Description: 
* This stata script cleans economic data from Arab Monetary Fund (AMF)
*
* Created: 2024-07-10
*
* URL: https://www.amf.org.ae/ (Archived on: 2024-09-25)
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================

* Clear data 
clear

* Define input and output files 
global input1 "${data_raw}/aggregators/AMF/AMF_national_accounts.xlsx"
global input2 "${data_raw}/aggregators/AMF/AMF_USDfx.xlsx"
global input3 "${data_raw}/aggregators/AMF/AMF_CA_balance.xlsx"
global input4 "${data_raw}/aggregators/AMF/AMF_gov_finance.xlsx"
global output "${data_clean}/aggregators/AMF/AMF.dta"

* ==============================================================================
* 	NATIONAL ACCOUNTS
* ==============================================================================

* Open
qui import excel using "${input1}", clear

* Keep only relevant rows
qui ds A B C, not
missings dropobs `r(varlist)', force
replace A = "nGDP" if A == "|==>GDP"
replace A = "cons"     if A == "|==>Total Consumption"
replace A = "exports"  if A == "|===>Exports of Goods and Services"
replace A = "imports"  if A == "|===>Imports of Goods and Services"
replace A = "inv"	   if A == "|==>Total Investment"
replace A = "rGDP" if strpos(A, "|==>GDP at base price")
replace A = "infl"	   if A == "|==>First: the percentage change in the consumer price index"
drop if strpos(A, "=") > 0
drop C

* Rename
ren A series
ren B countryname
ds series countryname, not
foreach var in `r(varlist)'{
		local newname = `var'[1]
		qui ren `var' AMF_`newname'
}
drop in 1

* Reshape
qui greshape long AMF_, i(countryname series) j(year) string

* Destring
destring year AMF_, replace

* Reshape into wide
reshape wide AMF_, i(countryname year) j(series) string

* Generate countries' ISO3 code
merge m:1 countryname using $isomapping, keep(1 3) keepusing(ISO3) nogen
replace ISO3 = "ARE" if countryname == "Emirates"
drop countryname

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
tempfile temp_na
save `temp_na', replace


* ==============================================================================
* 	USD exchange rate
* ==============================================================================

* Open
qui import excel using "${input2}", clear

* Keep only relevant rows
qui ds A B C, not
missings dropobs `r(varlist)', force
drop if A == "|=>Domestic Currency Per U.S. Dollar(Period Average)"

* Drop unused columns
drop A C D

* Rename
ren B countryname
ds countryname, not
foreach var in `r(varlist)'{
		local newname = `var'[1]
		qui ren `var' AMF_`newname'
}
drop in 1

* Reshape
qui greshape long AMF_, i(countryname) j(year) string

* Destring
destring year AMF_, replace

* Rename
ren AMF_ AMF_USDfx

* Generate countries' ISO3 code
merge m:1 countryname using $isomapping, keep(1 3) keepusing(ISO3) nogen
replace ISO3 = "ARE" if countryname == "Emirates"
drop countryname

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
tempfile temp_USDfx
save `temp_USDfx', replace
merge 1:1 ISO3 year using `temp_na', nogen
save `temp_na', replace


* ==============================================================================
* 	Current account balance
* ==============================================================================

* Open
qui import excel using "${input3}", clear

* Keep only relevant rows
qui ds A B C, not
missings dropobs `r(varlist)', force
keep if A == "|=>Current Account Balance" | A == "Item"

* Drop unused columns
drop A C D

* Rename
ren B countryname
ds countryname, not
foreach var in `r(varlist)'{
		local newname = `var'[1]
		qui ren `var' AMF_`newname'
}
drop in 1

* Reshape
qui greshape long AMF_, i(countryname) j(year) string

* Destring
destring year AMF_, replace

* Rename
ren AMF_ AMF_CA

* Generate countries' ISO3 code
merge m:1 countryname using $isomapping, keep(1 3) keepusing(ISO3) nogen
replace ISO3 = "ARE" if countryname == "Emirates"
drop countryname

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
tempfile temp_CA
save `temp_CA', replace
merge 1:1 ISO3 year using `temp_na', nogen
save `temp_na', replace

* ==============================================================================
* 	Government finance
* ==============================================================================

* Open
qui import excel using "${input4}", clear

* Keep only relevant rows
qui ds A B C, not
missings dropobs `r(varlist)', force
replace A = "govrev" if A == "|=>Total Public Revenues"
replace A = "govtax"     if A == "|===> Taxes Revenue"
replace A = "govexp"  if A == "|=>Total Public Expenditure"
replace A = "govdef"  if A == "|>Overall  Surplus (+) / Deficit (-)"
drop if strpos(A, "|") > 0
drop C

* Rename
ren A series
ren B countryname
ds series countryname, not
foreach var in `r(varlist)'{
		local newname = `var'[1]
		qui ren `var' AMF_`newname'
}
drop in 1

* Reshape
qui greshape long AMF_, i(countryname series) j(year) string

* Destring
destring year AMF_, replace

* Reshape into wide
reshape wide AMF_, i(countryname year) j(series) string

* Generate countries' ISO3 code
merge m:1 countryname using $isomapping, keep(1 3) keepusing(ISO3) nogen
replace ISO3 = "ARE" if countryname == "Emirates"
drop countryname

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
tempfile temp_CA
save `temp_CA', replace
merge 1:1 ISO3 year using `temp_na', nogen
save `temp_na', replace

* ==============================================================================
* 	Fixing unit issues
* ==============================================================================

* Mauritania's data is multiplied by 10 after 2012 for trade data and 2009 for exchange rate
gmdfixunits AMF_imports if ISO3 == "MRT" & year <= 2012, divide(10)
gmdfixunits AMF_exports if ISO3 == "MRT" & year <= 2012, divide(10)
gmdfixunits AMF_govexp if ISO3 == "MRT" & year <= 2012, divide(10)
gmdfixunits AMF_govrev if ISO3 == "MRT" & year <= 2012, divide(10)
gmdfixunits AMF_govdef if ISO3 == "MRT" & year <= 2012, divide(10)
gmdfixunits AMF_govtax if ISO3 == "MRT" & year <= 2012, divide(10)
gmdfixunits AMF_cons if ISO3 == "MRT" & year <= 2012, divide(10)


* Mauritania's data is multiplied by 10 before 2009 for exchange rate
gmdfixunits AMF_USDfx if ISO3 == "MRT" & year <= 2009, divide(10)

* Sudan's data is multiplied by 10 after 2012
gmdfixunits AMF_imports if ISO3 == "SDN" & year <= 1996, divide(100)
gmdfixunits AMF_exports if ISO3 == "SDN" & year <= 1996, divide(100)
gmdfixunits AMF_inv if ISO3 == "SDN" & year <= 1996, divide(100)

* Derive values in GDP
gen AMF_govexp_GDP = (AMF_govexp / AMF_nGDP) * 100
gen AMF_govdef_GDP = (AMF_govdef / AMF_nGDP) * 100
gen AMF_govrev_GDP = (AMF_govrev / AMF_nGDP) * 100
gen AMF_govtax_GDP = (AMF_govtax / AMF_nGDP) * 100
gen AMF_CA_GDP 	   = (AMF_CA     / AMF_nGDP) * 100
gen AMF_cons_GDP    = (AMF_cons / AMF_nGDP) * 100
gen AMF_imports_GDP = (AMF_imports / AMF_nGDP) * 100
gen AMF_exports_GDP = (AMF_exports / AMF_nGDP) * 100
gen AMF_inv_GDP     = (AMF_inv / AMF_nGDP) * 100


* ==============================================================================
* 	Output
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
save "${output}", replace

* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* 
* Description: 
* This Stata script reads in and cleans historical government expenditure data
* from the GPIH at UC Davis.
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-08-01
*
* URL: https://gpih.ucdavis.edu/Government.htm (Archived: 2024-09-05)
* ==============================================================================

* ==============================================================================
* SET UP 
* ==============================================================================
clear
global input "${data_raw}/aggregators/FLORA/Flora_expenditure_series_Europe.xlsx"
global output "${data_clean}/aggregators/FLORA/FLORA.dta"

* Save
tempfile temp_master
save `temp_master', replace emptyok

* ==============================================================================
* AUSTRIA
* ==============================================================================
* Open
qui import excel using "$input", clear sheet("Austria") allstring

* Keep relevant variables
keep A M Y AK

* Drop empty rows
drop in 1/5
drop in 54/l

* Destring
destring *, force replace

* Rename
ren A year
ren M cgovexp 
ren Y nGDP
ren AK cgovexp_GDP

* Turn all zeros into missing
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = . if `var' == 0
}

* Convert units 
replace cgovexp = cgovexp / 10


* Add country's ISO3 code
gen ISO3 = "AUT"

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* BELGIUM
* ==============================================================================
* Open
qui import excel using "$input", clear sheet("Belgium") allstring

* Keep relevant variables
keep A M Z AL 

* Drop empty rows
drop in 1/5
drop in 142/l

* Destring
destring *, force replace

* Rename
ren A year
ren M cgovexp 
ren Z nGDP 
ren AL cgovexp_GDP

* Turn all zeros into missing
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = . if `var' == 0
}

* Add country's ISO3 code
gen ISO3 = "BEL"

* Convert Belgium units
replace nGDP    = nGDP 	  * (10^3)  if year > 1913
replace cgovexp = cgovexp * (10^-3) if year < 1913

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Denmark
* ==============================================================================
* Open
qui import excel using "$input", clear sheet("Denmark") allstring

* Keep relevant variables
keep A M Y AK

* Drop empty rows
drop in 1/5

* Arrange the value correctly
gen AK1 = ""
gen AK2 = ""
forvalues i=1/47 {
    local j = `i' + 162
    replace AK1 = AK[`j'] in `i'
	replace AK2 = M[`j'] in `i'
}

drop in 159/l 

* Destring
destring *, force replace
replace AK = . if AK == 0

* Rename
ren A year
ren AK cgovexp_GDP
ren AK1 gen_govexp_GDP
ren M  cgovexp 
ren AK2 gen_govexp
ren Y nGDP

* Turn all zeros into missing
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = . if `var' == 0
}

* Add country's ISO3 code
gen ISO3 = "DNK"

* Convert units
qui replace cgovexp = cgovexp / 1000 if year <= 1901

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* FINLAND
* ==============================================================================
* Open
qui import excel using "$input", clear sheet("Finland") allstring

* Keep relevant variables
keep A M Z AL

* Drop empty rows
drop in 1/5

* Arrange the value correctly
gen N = ""
gen N1 = ""
forvalues i=1/28 {
    local j = `i' + 98
    replace N = AL[`j'] in `i'
    replace N1 = M[`j'] in `i'
}
drop in 95/l

* Destring
destring *, force replace


* Rename
ren A year
ren AL cgovexp_GDP
ren M  cgovexp
ren N gen_govexp_GDP
ren N1 gen_govexp
ren Z nGDP

* Convert units 
qui replace cgovexp = cgovexp / 1000
qui replace gen_govexp = gen_govexp / 100000

* Turn all zeros into missing
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = . if `var' == 0
}

* Add country's ISO3 code
gen ISO3 = "FIN"

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* FRANCE
* ==============================================================================
* Open
qui import excel using "$input", clear sheet("France") allstring

* Keep relevant variables
keep A M AA AM 

* Drop empty rows
drop in 1/5
drop in 155/l

* Destring
destring *, force replace

* Rename
ren A year
ren M cgovexp
ren AA nGDP
ren AM cgovexp_GDP

* Turn all zeros into missing
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = . if `var' == 0
}

* Add country's ISO3 code
gen ISO3 = "FRA"

* Convert units 
replace nGDP 	= nGDP 	  * 1000
replace nGDP 	= nGDP 	  * 10   if year >= 1957
replace cgovexp = cgovexp / 10   if year <= 1946

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* GERMANY
* ==============================================================================
* Open
qui import excel using "$input", clear sheet("Germany") allstring

* Keep relevant variables
keep A M Y AK

* Drop empty rows
drop in 1/5

* Arrange the value correctly in excel
gen N = ""
gen N1 = ""
forvalues i=1/104 {
    local j = `i' + 130
    replace N = AK[`j'] in `i'
    replace N1 = M[`j'] in `i'
}
drop in 127/l

* Destring
destring *, force replace


* Rename
ren A year
ren AK cgovexp_GDP
ren N gen_govexp_GDP
ren M cgovexp
ren N1 gen_govexp
ren Y nGDP

* Destring
destring *, force replace

* Turn all zeros into missing
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = . if `var' == 0
}

* Convert units
replace cgovexp    = cgovexp 	* (10^-12) if year <= 1913
replace nGDP       = nGDP 		* (10^-12) if year <= 1913
replace gen_govexp = gen_govexp * (10^-12) if year <= 1913

* Add country's ISO3 code
gen ISO3 = "DEU"

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* ITALY
* ==============================================================================
* Open
qui import excel using "$input", clear sheet(" Italy") allstring

* Keep relevant variables
keep A M Y AK

* Drop empty rows
drop in 1/5
drop in 115/l
qui replace A = "1974" if A == "1973" & AK == ""

* Destring
destring *, force replace

* Rename
ren A year
ren M cgovexp
ren Y nGDP
ren AK cgovexp_GDP

* Turn all zeros into missing
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = . if `var' == 0
}

* Convert units
qui replace nGDP = nGDP * 1000 if year >= 1952

* Add country's ISO3 code
gen ISO3 = "ITA"

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Netherlands
* ==============================================================================
* Open
qui import excel using "$input", clear sheet("Netherlands") allstring

* Keep relevant variables
keep A M Z AL

* Drop empty rows
drop in 1/5
drop in 127/l

* Destring
destring *, force replace

* Rename
ren A year
ren M cgovexp
ren Z nGDP
ren AL cgovexp_GDP

* Turn all zeros into missing
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = . if `var' == 0
}

* Add country's ISO3 code
gen ISO3 = "NLD"

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Norway
* ==============================================================================
* Open
qui import excel using "$input", clear sheet("Norway") allstring

* Keep relevant variables
keep A M Y AK

* Drop empty rows
drop in 1/6

* Arrange the value correctly
gen N = ""
gen N1 = ""
forvalues i=1/61 {
    local j = `i' + 130
    replace N = AK[`j'] in `i'
    replace N1 = M[`j'] in `i'
}
drop in 127/l 

* Rename
ren A year
ren M cgovexp
ren Y nGDP
ren AK cgovexp_GDP
ren N gen_govexp_GDP
ren N1 gen_govexp

* Destring
destring *, force replace

* Turn all zeros into missing
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = . if `var' == 0
}

* Add country's ISO3 code
gen ISO3 = "NOR"

* Convert units
replace cgovexp    = cgovexp    / 10
replace gen_govexp = gen_govexp / 10

replace cgovexp    = cgovexp    / 100 if year < 1913
replace gen_govexp = gen_govexp / 100 if year < 1913

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Sweden
* ==============================================================================
* Open
qui import excel using "$input", clear sheet("Sweden") allstring

* Keep relevant variables
keep A M Y AL

* Drop empty rows
drop in 1/6

* Arrange the value correctly
gen N = ""
gen N1 = ""
forvalues i=1/63 {
    local j = `i' + 130
    replace N = AL[`j'] in `i'
    replace N1 = M[`j'] in `i'
}
drop in 127/l 

* Rename
ren A year
ren M cgovexp
ren Y nGDP
ren AL cgovexp_GDP
ren N gen_govexp_GDP
ren N1 gen_govexp

* Destring
destring *, force replace

* Turn all zeros into missing
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = . if `var' == 0
}

* Add country's ISO3 code
gen ISO3 = "SWE"

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Switzerland
* ==============================================================================
* Open
qui import excel using "$input", clear sheet("Switzerland") allstring

* Keep relevant variables
keep A M Y AL

* Drop empty rows
drop in 1/5

* Arrange the value correctly
gen N = ""
gen N1 = ""
forvalues i=1/38 {
    local j = `i' + 130
    replace N = AL[`j'] in `i'
    replace N1 = M[`j'] in `i'
}
drop in 39/l 

* Rename
ren A year
ren M cgovexp
ren Y nGDP
ren AL cgovexp_GDP
ren N gen_govexp_GDP
ren N1 gen_govexp

* Destring
destring *, force replace

* Destring
destring *, force replace

* Turn all zeros into missing
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = . if `var' == 0
}

* Add country's ISO3 code
gen ISO3 = "CHE"

* Convert units
replace cgovexp = cgovexp / 1000
replace gen_govexp = gen_govexp / 1000

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* United Kingdom
* ==============================================================================
* Open
qui import excel using "$input", clear sheet(" UK") allstring

* Keep relevant variables
keep A M AA AL

* Drop empty rows
drop in 1/5

* Arrange the value correctly
gen N = ""
gen N1 = ""
forvalues i=1/186 {
    local j = `i' + 151
    replace N = AL[`j'] in `i'
    replace N1 = M[`j'] in `i'
}

gen year = .
destring A, replace
forvalues i=1/186 {
    local j = `i' + 151
    replace year = A[`j'] in `i'
}
drop in 187/l
drop A 

* Destring
destring *, force replace

* Turn all zeros into missing
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = . if `var' == 0
}

* Rename
ren M cgovexp
ren AA nGDP
ren AL cgovexp_GDP
ren N gen_govexp_GDP
ren N1 gen_govexp

* Add country's ISO3 code
gen ISO3 = "GBR"

* Convert units
replace cgovexp = cgovexp / 10 


* Save
append using `temp_master'
save `temp_master', replace

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)' {
	ren `var' FLORA_`var'
}

* Convert euros 
merge m:1 ISO3 using "$eur_fx", keep(1 3)
ds FLORA_cgovexp FLORA_gen_govexp FLORA_nGDP 
foreach var in `r(varlist)' {
	replace `var' = `var' / EUR if _merge == 3
} 
keep ISO3 year FLORA*

* Rebase variables to $base_year
gmd_rebase FLORA

* Check for ratios and levels 
check_gdp_ratios FLORA

* ==============================================================================
* OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid year ISO3 

* Save
save "${output}", replace


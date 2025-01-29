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
global output "${data_clean}/aggregators/FLORA/Flora.dta"

* Save
tempfile temp_master
save `temp_master', replace emptyok

* ==============================================================================
* AUSTRIA
* ==============================================================================
* Open
qui import excel using "$input", clear sheet("Austria") allstring

* Keep relevant variables
keep A AK

* Drop empty rows
drop in 1/5
drop in 54/l

* Rename
ren A year
ren AK centralgov_exp

* Add country's ISO3 code
gen ISO3 = "AUT"

* Destring
destring year centralgov_exp, replace
gen generalgov_exp = .

* Order
order ISO3 year centralgov_exp generalgov_exp

* Save
tempfile temp_AUT
save `temp_AUT', replace emptyok
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* BELGIUM
* ==============================================================================
* Open
qui import excel using "$input", clear sheet("Belgium") allstring

* Keep relevant variables
keep A AL

* Drop empty rows
drop in 1/5
drop in 142/l

* Rename
ren A year
ren AL centralgov_exp

* Add country's ISO3 code
gen ISO3 = "BEL"

* Destring
destring year centralgov_exp, replace
gen generalgov_exp = .

* Order
order ISO3 year centralgov_exp generalgov_exp

* Save
tempfile temp_BEL
save `temp_BEL', replace emptyok
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Denmark
* ==============================================================================
* Open
qui import excel using "$input", clear sheet("Denmark") allstring

* Keep relevant variables
keep A AK

* Drop empty rows
drop in 1/5

* Destring
destring AK, force replace

* Arrange the value correctly
gen N = .
forvalues i=1/47 {
    local j = `i' + 162
    replace N = AK[`j'] in `i'
}
drop in 108/l 

* Rename
ren A year
ren AK centralgov_exp
ren N generalgov_exp

* Add country's ISO3 code
gen ISO3 = "DNK"
destring year, replace

* Order
order ISO3 year centralgov_exp generalgov_exp

* Save
tempfile temp_DNK
save `temp_DNK', replace emptyok
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* FINLAND
* ==============================================================================
* Open
qui import excel using "$input", clear sheet("Finland") allstring

* Keep relevant variables
keep A AL

* Drop empty rows
drop in 1/5

* Destring
destring AL, force replace

* Arrange the value correctly
gen N = .
forvalues i=1/28 {
    local j = `i' + 98
    replace N = AL[`j'] in `i'
}
drop in 95/l

* Rename
ren A year
ren AL centralgov_exp
ren N generalgov_exp

* Add country's ISO3 code
gen ISO3 = "FIN"
destring *, replace

* Order
order ISO3 year centralgov_exp generalgov_exp

* Save
tempfile temp_FIN
save `temp_FIN', replace emptyok
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* FRANCE
* ==============================================================================
* Open
qui import excel using "$input", clear sheet("France") allstring

* Keep relevant variables
keep A AM

* Drop empty rows
drop in 1/5
drop in 155/l

* Rename
ren A year
ren AM centralgov_exp

* Add country's ISO3 code
gen ISO3 = "FRA"

* Destring
destring year centralgov_exp, replace
gen generalgov_exp = .

* Order
order ISO3 year centralgov_exp generalgov_exp

* Save
tempfile temp_FRA
save `temp_FRA', replace emptyok
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* GERMANY
* ==============================================================================
* Open
qui import excel using "$input", clear sheet("Germany") allstring

* Keep relevant variables
keep A AK

* Drop empty rows
drop in 1/5

* Destring
destring AK, force replace

* Arrange the value correctly in excel
gen N = .
forvalues i=1/104 {
    local j = `i' + 130
    replace N = AK[`j'] in `i'
}
drop in 127/l

* Rename
ren A year
ren AK centralgov_exp
ren N generalgov_exp

* Add country's ISO3 code
gen ISO3 = "DEU"
destring year, replace

* Order
order ISO3 year centralgov_exp generalgov_exp

* Save
tempfile temp_DEU
save `temp_DEU', replace emptyok
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* ITALY
* ==============================================================================
* Open
qui import excel using "$input", clear sheet(" Italy") allstring

* Keep relevant variables
keep A AK

* Drop empty rows
drop in 1/5
drop in 115/l
replace A = "1974" if A == "1973" & AK == ""

* Rename
ren A year
ren AK centralgov_exp

* Add country's ISO3 code
gen ISO3 = "ITA"
destring year centralgov_exp, replace
gen generalgov_exp = .

* Order
order ISO3 year centralgov_exp generalgov_exp

* Save
tempfile temp_ITA
save `temp_ITA', replace emptyok
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Netherlands
* ==============================================================================
* Open
qui import excel using "$input", clear sheet("Netherlands") allstring

* Keep relevant variables
keep A AL

* Drop empty rows
drop in 1/5
drop in 127/l

* Rename
ren A year
ren AL centralgov_exp

* Add country's ISO3 code
gen ISO3 = "NLD"
destring year centralgov_exp, replace
gen generalgov_exp = .

* Order
order ISO3 year centralgov_exp generalgov_exp

* Save
tempfile temp_NLD
save `temp_NLD', replace emptyok
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Norway
* ==============================================================================
* Open
qui import excel using "$input", clear sheet("Norway") allstring

* Keep relevant variables
keep A AK

* Drop empty rows
drop in 1/6

* Destring
destring AK, force replace

* Arrange the value correctly
gen N = .
forvalues i=1/61 {
    local j = `i' + 130
    replace N = AK[`j'] in `i'
}
drop in 127/l 

* Rename
ren A year
ren AK centralgov_exp
ren N generalgov_exp

* Add country's ISO3 code
gen ISO3 = "NOR"
destring year, replace

* Order
order ISO3 year centralgov_exp generalgov_exp

* Save
tempfile temp_NOR
save `temp_NOR', replace emptyok
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Sweden
* ==============================================================================
* Open
qui import excel using "$input", clear sheet("Sweden") allstring

* Keep relevant variables
keep A AL

* Drop empty rows
drop in 1/6

* Destring
destring AL, force replace

* Arrange the value correctly
gen N = .
forvalues i=1/63 {
    local j = `i' + 130
    replace N = AL[`j'] in `i'
}
drop in 127/l 

* Rename
ren A year
ren AL centralgov_exp
ren N generalgov_exp

* Add country's ISO3 code
gen ISO3 = "SWE"

* Destring
destring year, replace

* Order
order ISO3 year centralgov_exp generalgov_exp
replace centralgov_exp = . if centralgov_exp == 0

* Save
tempfile temp_SWE
save `temp_SWE', replace emptyok
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Switzerland
* ==============================================================================
* Open
qui import excel using "$input", clear sheet("Switzerland") allstring

* Keep relevant variables
keep A AL

* Drop empty rows
drop in 1/5

* Destring
destring AL, force replace

* Arrange the value correctly
gen N = .
forvalues i=1/38 {
    local j = `i' + 130
    replace N = AL[`j'] in `i'
}
drop in 39/l 

* Rename
ren A year
ren AL centralgov_exp
ren N generalgov_exp

* Add country's ISO3 code
gen ISO3 = "CHE"
destring year, replace

* Order
order ISO3 year centralgov_exp generalgov_exp

* Save
tempfile temp_CHE
save `temp_CHE', replace emptyok
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* United Kingdom
* ==============================================================================
* Open
qui import excel using "$input", clear sheet(" UK") allstring

* Keep relevant variables
keep A AL

* Drop empty rows
drop in 1/5

* Destring
destring AL, force replace

* Arrange the value correctly
gen N = .
forvalues i=1/186 {
    local j = `i' + 151
    replace N = AL[`j'] in `i'
}
gen year = .
destring A, replace
forvalues i=1/186 {
    local j = `i' + 151
    replace year = A[`j'] in `i'
}
drop in 187/l
drop A 

* Rename
ren AL centralgov_exp
ren N generalgov_exp

* Add country's ISO3 code
gen ISO3 = "GBR"

* Order
order ISO3 year centralgov_exp generalgov_exp

* Save
tempfile temp_GBR
save `temp_GBR', replace emptyok
append using `temp_master'
save `temp_master', replace

* Rename variables
ren centralgov_exp FLORA_govexp_GDP
keep ISO3 year FLORA_govexp_GDP

* Turn null values (0) to missing
replace FLORA_govexp_GDP	 = . if FLORA_govexp_GDP	 == 0

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


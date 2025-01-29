* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN POPULATION DATA FROM GAPMINDER
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-08-14
*
* Description: 
* This Stata script cleans population data from Gapminder.
*
* URL: https://www.gapminder.org/data/
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================
clear
global input "${data_raw}/aggregators/Gapminder/Gapminder.xlsx"
global output "${data_clean}/aggregators/Gapminder/Gapminder"

* ==============================================================================
* 	PROCESS
* ==============================================================================
* Open
import excel using "${input}", clear allstring

* Rename the columns
ren A countryname
qui ds countryname, not
foreach var in `r(varlist)' {
    local newname = `var'[1]
    rename `var' pop`newname'
}
drop in 1

* Reshape
qui greshape long pop, i(countryname) j(year) string

* Extract the units
tempvar factor pop_1
gen `factor' = substr(pop, -1, 1)
gen `pop_1' = substr(pop, 1, strlen(pop)-1) if inlist(`factor', "B", "M", "k")
replace `pop_1' = pop if !inlist(`factor', "B", "M", "k")
destring `pop_1', replace
drop pop

* Calculate the final variable and convert to millions
gen Gapminder_pop = .
replace Gapminder_pop = `pop_1' * 1000    if `factor' == "B"
replace Gapminder_pop = `pop_1'           if `factor' == "M"
replace Gapminder_pop = `pop_1' / 1000    if `factor' == "k"
replace Gapminder_pop = `pop_1' / 1000000 if !inlist(`factor', "B", "M", "k")

* Add ISO3 code
merge m:1 countryname using $isomapping, keep(1 3) keepusing(ISO3)

* Manually fix countries that didn't merge
replace ISO3 = "COD" if countryname == "Congo, Dem. Rep."
replace ISO3 = "COG" if countryname == "Congo, Rep."
replace ISO3 = "CIV" if countryname == "Cote d'Ivoire"
replace ISO3 = "HKG" if countryname == "Hong Kong, China"
replace ISO3 = "KGZ" if countryname == "Kyrgyz Republic"
replace ISO3 = "LAO" if countryname == "Lao"
replace ISO3 = "FSM" if countryname == "Micronesia, Fed. Sts."
replace ISO3 = "MKD" if countryname == "North Macedonia"
replace ISO3 = "RUS" if countryname == "Russia"
replace ISO3 = "SVK" if countryname == "Slovak Republic"
replace ISO3 = "KNA" if countryname == "St. Kitts and Nevis"
replace ISO3 = "LCA" if countryname == "St. Lucia"
replace ISO3 = "VCT" if countryname == "St. Vincent and the Grenadines"
replace ISO3 = "ARE" if countryname == "UAE"
replace ISO3 = "GBR" if countryname == "UK"
replace ISO3 = "USA" if countryname == "USA"

* Destring
destring year, replace

* Keep year until 2030
keep if year <= 2030

* Keep relevant variables 
keep ISO3 year Gapminder_pop

* ==============================================================================
* 	Output
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplciates
isid ISO3 year

* Save
save "${output}", replace

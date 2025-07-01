* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CLEAN KOREAN GDP DATA FROM ASIAN HISTORICAL STATISTICS VOLUME 4
* Description: 
* This stata script cleans historical macroeconomic data for Korea.
*
* Author:
* Karsten Müller
* National University of Singapore
* 
* Created: 2024-04-23
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================

* Clear 
clear

* Define input and output 
global input "${data_raw}/country_level/KOR_1.xlsx"
global output "${data_clean}/country_level/KOR_1"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open
import excel using "${input}", clear sheet("15.3.1 ")

* Drop unnecessary rows 
drop in 1/8
drop in 98 
drop if A == ""

* Destring 
destring *, replace 

* Convert data from colonial period in Yen to Won (exchanged at par but unit change)
foreach var in D G J {
	replace `var' = `var' / 1000 if A <= 1940
}

* Estimate nominal GDP in 1911 using growth rate of primary and secondary sector
* because data on tertiary sector is unavailable 
replace D = D[2] * ((G[1] + J[1]) / (G[2] + J[2])) in 1

* Only keep data on South Korea 
keep A D 

* Rename
ren (A D) (year CS1_nGDP)

* Save temporary file 
tempfile KOR_nGDP 
save `KOR_nGDP', replace 


* Open real GDP data 
import excel using "${input}", clear sheet("15.3.2  ")

* Drop unnecessary rows 
drop in 1/8
drop in 98/102
drop if A == ""

* Destring 
destring *, replace 

* Estimate nominal GDP in 1911 using growth rate of primary and secondary sector
* because data on tertiary sector is unavailable 
replace D = D[2] * ((G[1] + J[1]) / (G[2] + J[2])) in 1

* Only keep data on South Korea, rename 
keep A D 
ren A year 
ren D CS1_rGDP

* Save temporary file 
tempfile KOR_rGDP 
save `KOR_rGDP', replace 


* Open population data 
import excel using "${input}", clear sheet("15.3.3 ")

* Drop unnecessary rows 
drop in 1/8
drop if A == "" | D == ""

* Destring 
destring *, replace 

* Only keep data on South Korea, rename 
keep A D 
ren A year 
ren D CS1_pop


* Merge with other files 
merge 1:1 year using `KOR_nGDP', nogen
merge 1:1 year using `KOR_rGDP', nogen

* * Rescale units to million
replace CS1_rGDP = CS1_rGDP * 1000 if year >= 1953
replace CS1_nGDP = CS1_nGDP * 1000 if year >= 1953
replace CS1_pop = CS1_pop / 1000

* Make GDP per capita 
gen CS1_rGDP_pc = CS1_rGDP / CS1_pop

* Add country's ISO3
gen ISO3 = "KOR"

* Add the deflator
gen CS1_deflator = (CS1_nGDP / CS1_rGDP) * 100


* ===============================================================================
* 	OUTPUT
* ===============================================================================

* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace

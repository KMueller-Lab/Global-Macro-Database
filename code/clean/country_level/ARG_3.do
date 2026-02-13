* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Description: 
* This Stata script opens and cleans historical macroeconomic data on Argentina
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2025-03-01
*
* URL: https://dossiglos.fundacionnorteysur.org.ar/home
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================

* Clear 
clear

* Define input and output files
global input "${data_raw}/country_level/"
global output "${data_clean}/country_level/ARG_3.dta"

* ==============================================================================
* 	TRADE VARIABLES
* ==============================================================================
import excel using "$input/ARG_3c.xlsx", clear cellrange(A23:C231) 

* Rename
ren (A B C) (year exports_USD imports_USD)

* Destring
destring *, replace force

* Turn year into a string
tostring(year), force replace

* Save 
tempfile temp_master
save `temp_master', replace

* ==============================================================================
* 	MONETARY AGGREGATES
* ==============================================================================
* Import the data
import excel using "$input/ARG_3b.xlsx", clear sheet(Agregados M.) cellrange(A76:D231)

* Rename
ren (A B D) (year M1 M3)
drop C

* Destring
destring *, replace force

* Convert units
replace M1 = M1 / 10^6
replace M3 = M3 / 10^6

* Turn year into a string
tostring(year), force replace

* Merge and save
merge 1:1 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
* 	EXCHANGE RATE
* ==============================================================================
* Import the data
import excel using "$input/ARG_3b.xlsx", clear sheet(Tipo de Cambio) cellrange(A13:B221) 

* Rename
ren (A B) (year USDfx)

* Destring
destring *, replace force

* Turn year into a string
tostring(year), force replace

* Merge and save
merge 1:1 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
* 	MONETARY BASE
* ==============================================================================
* Import the data
import excel using "$input/ARG_3b.xlsx", clear sheet(Pasivos M.) cellrange(A76:F231)

* Keep 
keep A F

* Rename
ren(A F) (year M0)

* Destring
destring *, replace force

* Convert units
replace M0 = M0 / 10^6

* Turn year into a string
tostring(year), force replace

* Merge and save
merge 1:1 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
* 	CONSUMER PRICE INDEX
* ==============================================================================
* Import
import excel using "$input/ARG_3a.xlsx", clear cellrange(A20:C228)

* Rename
ren (A B C) (year CPI infl)

* Destring
destring *, replace force
replace infl = infl * 100

* Turn year into a string
tostring(year), force replace

* Merge and save
merge 1:1 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
* 	REAL NATIONAL ACCOUNTS VARIABLES
* ==============================================================================
* Import
import excel using "$input/ARG_3d.xlsx", clear cellrange(A17:K225)

* Keep
keep A B K

* Rename
ren(A B K) (year rGDP rcons)

* Destring
destring *, replace force

* Turn year into a string
tostring(year), force replace

* Merge and save
merge 1:1 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
* 	DEFLATOR
* ==============================================================================
* Import
import excel using "$input/ARG_3d.xlsx", clear cellrange(A17:B225) sheet(Precios impl. por sectores)

* Rename
ren(A B) (year deflator)

* Destring
destring *, replace force

* Turn year into a string
tostring(year), force replace

* Merge and save
merge 1:1 year using `temp_master', nogen
save `temp_master', replace

* Destring year
destring year, replace

* ==============================================================================
* 	Output
* ==============================================================================

* Use the deflator to derive nominal GDP
gen nGDP = (deflator * rGDP) / 100

* Add source identifier 
ren * CS3_*
ren CS3_year year

* Drive ratio variables
gen CS3_exports = CS3_exports_USD * CS3_USDfx
gen CS3_imports = CS3_imports_USD * CS3_USDfx
gen CS3_exports_GDP = (CS3_exports / CS3_nGDP) * 100
gen CS3_imports_GDP = (CS3_imports / CS3_nGDP) * 100

* Check for ratios and levels 
check_gdp_ratios CS3

* Add country ISO3 
gen ISO3 = "ARG"

* Rebase variables to $base_year
gmd_rebase CS3

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
save "${output}", replace

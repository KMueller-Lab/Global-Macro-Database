* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-10
*
* Description: 
* This Stata script opens and cleans key economic indicators data from OECD
* 
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================

* Clear data 
clear 

* Define globals 
global input "${data_raw}/aggregators/OECD/OECD_KEI.dta"
global output "${data_clean}/aggregators/OECD/OECD_KEI.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open
use "$input", clear

* Keep relevant columns 
keep period value frequency location subject measure series_name 

* Rename
ren period year
ren location ISO3
ren value OECD_KEI_

* Drop non-country regions
merge m:1 ISO3 using $isomapping, nogen keep(3) keepusing(ISO3)

* Create a new variable for type based on series_name
replace subject = "CA_GDP" 	if subject == "B6BLTT02"
replace subject = "infl" 	if subject == "CPALTT01" & measure == "GP" // Growth over the previous period
replace subject = "CPI"  	if subject == "CPALTT01" & measure == "ST" // Index 2015 = 100
replace subject = "strate"  if subject == "IR3TIB01"
replace subject = "ltrate"  if subject == "IRLTLT01"
replace subject = "unemp" 	if subject == "LRHUTTTT"

* One measure of CPI is dropped because it represents the GY (Growth over the same period in the previous year, but it's equal to GP when the frequency is annual)
drop if subject == "CPALTT01"
drop series_name frequency measure 

* Reshape wide
qui greshape wide OECD_KEI_, i(ISO3 year) j(subject) string

* Destring
destring year, replace

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
save "${output}", replace

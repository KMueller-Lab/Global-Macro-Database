* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN HOUSE PRICE DATA FROM THE DALLAS FED 
* 
* Description: 
* This Stata script opens and cleans house prices data from the Dallas Fed.
*
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-04-05
*
* ==============================================================================

* ==============================================================================
* SET UP 
* ==============================================================================

* Clear data 
clear 

* Define input and output files 
global input "${data_raw}/aggregators/DallasFed/hp2304.xlsx"
global output "${data_clean}/aggregators/DallasFed/DALLASFED_HPI.dta"

* ==============================================================================
* PROCESS DATA 
* ==============================================================================

* Open nominal prices 
import excel using "${input}", clear sheet(HPI) first
drop in 1

* Drop aggregates 
drop AB Aggregate* 

* Rename, reshape 
ren * v=
ren vA date
greshape long v, i(date) j(countryname) string

* Make country names 
replace countryname="New Zealand" if countryname=="NewZealand"
replace countryname="South Africa" if countryname=="SAfrica"
replace countryname="South Korea" if countryname=="SKorea"
replace countryname="United Kingdom" if countryname=="UK"
replace countryname="United States" if countryname=="US"

* Generate ISO3 codes
merge m:1 countryname using $isomapping, assert(2 3) keep(3) keepus(ISO3) nogen
drop countryname

* Rename
ren v DALLASFED_HPI

* Save temporary file
tempfile HPI
save `HPI', replace 

* Open real prices 
import excel using "${input}", clear sheet(RHPI) first
drop in 1

* Drop aggregates 
drop AB Aggregate* 
drop if A==""

* Rename, reshape 
ren * v=
ren vA date
greshape long v, i(date) j(countryname) string

* Make country names 
replace countryname="New Zealand" if countryname=="NewZealand"
replace countryname="South Africa" if countryname=="SAfrica"
replace countryname="South Korea" if countryname=="SKorea"
kountry countryname, from(other) stuck
ren _ISO3N_ stuck
kountry stuck, from(iso3n) to(iso3c)
ren _ISO3C_ ISO3
drop countryname stuck

* Rename variable, drop unnecessary stuff
ren v DALLASFED_rHPI

* Save temporary file
merge 1:1 ISO3 date using `HPI', nogen

* Make year and quarter variables 
gen year=substr(date,1,4)
gen quarter=substr(date,7,1)
keep if quarter=="4"
destring year, replace
drop quarter date 

* Rescale indices, 2010 = 100
foreach var in DALLASFED_HPI DALLASFED_rHPI {
	gen temp=`var' if year==2010
	bysort ISO3: egen scaler=max(temp)
	replace `var'=`var'*(100/scaler)
	drop temp scaler   
}

* Save 
order ISO3 year 
isid ISO3 year 
save "${output}", replace 

* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN REAL AND NOMINAL GDP FROM TAIWAN'S STATISTICAL BUREAU
* 
* Description: 
* This stata script cleans on Taiwanese GDP from Taiwan's Statistical Bureau.
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* ==============================================================================

* ==============================================================================
* SET UP 
* ==============================================================================

* Clear data 
clear 

* Define input and output files
global input "${data_raw}/country_level/TWN_1.xls"
global output "${data_clean}/country_level/TWN_1.dta"

* ==============================================================================
* CLEAN DATA 
* ==============================================================================

* Open 
import excel using ${input} , clear cellrange(A5:H321)

* Fix country name
gen ISO3 = "TWN"

* Fix variable names 
ren B CS1_pop
ren C CS1_USDfx
ren E CS1_nGDP
ren F CS1_nGDP_USD
ren G CS1_nGDP_pc 
ren H CS1_nGDP_pc_USD
ren A year

* Clean year variable 
replace year = substr(year,1,4)
keep if inlist(substr(year,1,2),"19","20")

* Destring, drop growth rate 
destring *, replace
drop D

* Rescale units to million
replace CS1_pop = CS1_pop / 1000000

* Reoder
order ISO3 year

* Drop unused variables
drop CS1_nGDP_pc CS1_nGDP_pc_USD

* Save 
isid ISO3 year
save ${output} , replace 

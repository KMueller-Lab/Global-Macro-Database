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
* This Stata script opens and cleans revenue statistics data from the OECD
* 
* Source: Organisation for Economic Cooperation and Development
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================
* Clear data 
clear

* Define input and output files
global input "${data_raw}/aggregators/OECD/OECD_REV.dta"
global output "${data_clean}/aggregators/OECD/OECD_REV.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================
* Open
use "$input", clear

* Keep relevant columns 
keep period value cou

* Rename
ren period year
ren cou ISO3
ren value OECD_REV_govtax

* Convert units
replace OECD_REV_govtax = OECD_REV_govtax * 1000

* Drop non-country regions
merge m:1 ISO3 using $isomapping, nogen keep(3) keepusing(ISO3)

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Output
save "${output}", replace

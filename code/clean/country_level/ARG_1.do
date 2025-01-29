* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN DATA FOR ARGENTINA 
* 
* Description: 
* This Stata script reads in and cleans data from BANKING AND FINANCE IN ARGENTINA IN THE PERIOD 1900-35
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-06-28 
*
* Url: https://www.dallasfed.org/~/media/documents/research/papers/2001/wp0108.pdf (Page 43, Table 6 transcibed)
* ==============================================================================

* ==============================================================================
* SET UP 
* ==============================================================================

* Clear data 
clear 

* Define input and output files
global input "${data_raw}/country_level/ARG_1.xlsx"
global output "${data_clean}/country_level/ARG_1.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================
* Open  
import excel using "${input}", clear first sheet(CS1_M3_GDP)

* Destring
replace CS1_M3_GDP = subinstr(CS1_M3_GDP,"%","",.)
destring *, replace 

* Save 
gen ISO3 = "ARG"

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

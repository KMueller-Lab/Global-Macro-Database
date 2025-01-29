* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* CLEAN GDP DATA FOR AUSTRIA FROM SCHULZE (2000)
* 
* Description: 
* This Stata script reads in and cleans data on Austrian GDP from the paper 
* "Patterns of growth and stagnation in the late nineteenth century Habsburg 
* economy" by Max-Stephan Schulze (2000).
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-09-25
*
* ==============================================================================

* ==============================================================================
* `SET UP 
* ==============================================================================
* Clear data 
clear 

* Define input and output files
global input "${data_raw}/country_level/AUT_1.xlsx"
global output "${data_clean}/country_level/AUT_1"

* ==============================================================================
* 	PROCESS
* ==============================================================================
* Open 
import excel using "${input}" , clear 

* Process 
drop in 1/3

* Rename
ren A year 
ren E CS1_rGDP
ren F CS1_rGDP_pc

* Drop unnecessary variables
drop B C D G

* Make country code 
gen ISO3 = "AUT"

* Correct an error in the decimal sign of one observation 
replace CS1_rGDP_pc = "433.3" if CS1_rGDP_pc == "433-3"
destring year CS1_rGDP CS1_rGDP_pc, replace  

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

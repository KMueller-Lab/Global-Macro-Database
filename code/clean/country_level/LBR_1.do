* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN DATA FROM ERIC MONNET
* 
* Description: 
* This Stata script reads in and cleans data on Liberia historical data
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-09-30
*
* Source: Leigh Gardner, Sovereignty without Power: Liberia in the Age of Empires, 1822-1980 (Cambridge University Press, 2022).

* ==============================================================================
* 	SET UP 
* ==============================================================================

* Clear the panel
clear

* Define input and output files 
global input "${data_raw}/country_level/LBR_1.xlsx"
global output "${data_clean}/country_level/LBR_1"

* ==============================================================================
* 	POPULATION
* ==============================================================================
* Open
import excel using "${input}", clear sheet("1. Population") firstrow

* Rename
ren (Year Population) (year pop)

* Convert to millions
replace pop = pop / 1000000

* Set up temporary files
tempfile temp_master
save `temp_master', replace 

* ==============================================================================
* 	Public Revenue
* ==============================================================================
* Open
import excel using "${input}", clear sheet("3. Public Revenue") firstrow

* Rename
ren (Year PublicrevenenominalUS) (year govrev)

* Convert to millions
replace govrev = govrev / 1000000

* Merge and save
tempfile temp_c
save `temp_c', replace
merge 1:1 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
* 	Public Spending
* ==============================================================================
* Open
import excel using "${input}", clear sheet("4. Public Spending") firstrow

* Rename
ren (Year PublicspendingnominalUS) (year govexp)

* Convert to millions
replace govexp = govexp / 1000000

* Merge and save
tempfile temp_c
save `temp_c', replace
merge 1:1 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
* 	Total exports
* ==============================================================================
* Open
import excel using "${input}", clear sheet("6. Total exports") firstrow

* Rename
ren (Year TotalexportvaluenominalUS) (year exports)

* Convert to millions
replace exports = exports / 1000000

* Merge and save
tempfile temp_c
save `temp_c', replace
merge 1:1 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
* 	Total imports
* ==============================================================================
* Open
import excel using "${input}", clear sheet("7. Total imports ") firstrow

* Rename
ren (Year TotalimportvaluenominalUS) (year imports)

* Convert to millions
replace imports = imports / 1000000

* Merge and save
tempfile temp_c
save `temp_c', replace
merge 1:1 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
* 	GDP per capita
* ==============================================================================
* Open
import excel using "${input}", clear sheet("11. GDP per capita") firstrow cellrange(A1:B136)

* Rename
ren (Year GDPpercapita1990internation) (year rGDP_pc_USD)

* Merge and save
tempfile temp_c
save `temp_c', replace
merge 1:1 year using `temp_master', nogen

* Derive real GDP 
gen rGDP_USD = rGDP_pc_USD * pop

* Add ISO3 code
gen ISO3 = "LBR"

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	qui ren `var' CS1_`var'
}

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

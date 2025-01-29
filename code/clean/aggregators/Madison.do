* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Description: 
* This Stata script reads in and cleans data from the Maddison project.
*
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-06-28
*
* URL: https://dataverse.nl/api/access/datafile/421303
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
* Clear data 
clear 

* Define input and output files
global input "${data_raw}/aggregators/MAD/maddison2023.dta"
global output "${data_clean}/aggregators/MAD/Madisson.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open 
use "$input", clear

* Rename variables 
ren (countrycode gdppc pop) (ISO3 MAD_rGDP_pc_USD MAD_pop)
keep ISO3 year MAD_rGDP_pc_USD MAD_pop

* Convert units
replace MAD_pop = MAD_pop / 1000 

* Drop the first obvious sporadic years (before 1252) and Mexico before 1896
drop if year < 1252
replace MAD_rGDP_pc_USD = . if year <= 1895 & ISO3 == "MEX"

* Keep only continuous data 
sort ISO3 year
by ISO3: gen gap = year - year[_n-1] if _n > 1 & MAD_rGDP_pc_USD[_n-1] != . & MAD_rGDP_pc_USD[_n] != .
replace MAD_pop = . if gap != 1
drop gap

by ISO3: gen gap = year - year[_n-1] if _n > 1 & MAD_rGDP_pc_USD[_n-1] != . & MAD_rGDP_pc_USD[_n] != .
replace MAD_rGDP_pc_USD = . if gap != 1
drop gap

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


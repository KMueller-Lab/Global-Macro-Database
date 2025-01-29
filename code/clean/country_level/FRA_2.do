* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN DATA FROM ERIC MONNET
* 
* Description: 
* This Stata script reads in and cleans data on French interest rates
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-09-30
*
* Source: Levy-Garboua Vivien et Monnet Eric , 2016, « Les taux d'intérêt en France : une perspective historique », Revue d'économie financière, vol. 1 (n° 121), p. 35-58. 
* ==============================================================================
* 	SET UP 
* ==============================================================================

* Clear the panel
clear

* Define input and output files 
global input "${data_raw}/country_level/FRA_2.xlsx"
global output "${data_clean}/country_level/FRA_2"

* ==============================================================================
* 	PROCESS
* ==============================================================================
* Open
import excel using "${input}", clear sheet(annuel) cellrange(A3:E218)

* Keep relevant variables
keep A B D E

* Rename
ren (A B D E) (year cbrate strate ltrate)

* Destring
qui destring *, replace

* Add ISO3 code
gen ISO3 = "FRA"

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	qui ren `var' CS2_`var'
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

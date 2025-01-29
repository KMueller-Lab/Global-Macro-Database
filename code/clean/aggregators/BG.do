* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script cleans data from Stephen Broadberry and Leigh Gardner. 
* "Economic growth in Sub-Saharan Africa, 1885-2008: Evidence from eight countries," 
* Explorations in Economic History 83 (2022): Appendix 1. 
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-09-30
*
* URL: https://doi.org/10.1016/j.eeh.2021.101424
* ==============================================================================
* 	SET UP 
* ==============================================================================

* First run WDI because we will use later 
do "$code_clean/aggregators/WDI.do"
clear

* Clear the panel
clear  

* Define input and output files 
global input "${data_raw}/aggregators/BG/BG.xlsx"
global output "${data_clean}/aggregators/BG/BG.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================
import excel using "${input}", clear firstrow cellrange(A2:I126)

* Rename
ren (A SouthAfrica Zimbabwe Ghana Nigeria Kenya Uganda Zambia Malawi) (year ZAF ZWE GHA NGA KEN UGA ZMB MWI)
qui ds year, not
foreach var in `r(varlist)'{
	ren `var' rGDP_pc_USD`var'
}

* Reshape
greshape long rGDP_pc_USD, i(year) j(ISO3) string


* Merge in the WDI rGDP_pc_USD and derive their real GDP 
merge 1:1 ISO3 year using "${data_clean}/aggregators/WB/WDI", nogen keep(1 3) keepus(WDI_rGDP)
ren rGDP_pc_USD BG_rGDP 

* Splice
splice, priority(WDI BG) generate(rGDP) varname(rGDP)  method("chainlink") base_year(2000) save("NO") 
keep year BG_rGDP rGDP ISO3
ren BG_rGDP BG_rGDP_pc_USD
ren rGDP BG_rGDP 




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

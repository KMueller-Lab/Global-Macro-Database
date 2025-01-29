* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
*
* Construct time series on banking crises
* 
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-10-17
*
* ==============================================================================

* ==============================================================================
* Merge data files
* ==============================================================================

* Open blank panel 
use "${data_temp}/blank_panel", clear

* Make panel id 
egen id = group(ISO3)
xtset id year 

* Merge in data sources 
merge 1:1 ISO3 year using "${data_clean}/aggregators/RR/RR", nogen assert(1 3)
merge 1:1 ISO3 year using "${data_clean}/aggregators/LV/LV", nogen assert(1 3)
merge 1:1 ISO3 year using "${data_clean}/aggregators/JST/JST", nogen assert(1 3) keepus(JST_crisisB) 
merge 1:1 ISO3 year using "${data_clean}/aggregators/BVX/BVX", nogen assert(1 3)


* ==============================================================================
* Construct harmonized measure of banking crises
*
* Note: We combine four measures of banking crises. We take data from Baron,
*		Verner, and Xiong (2019); Laeven and Valencia (2020); Jordà, Schularick,
*		and Taylor (2017); and Reinhart and Rogoff (2019). 
* ==============================================================================

* Define ordering 
local priority BVX LV JST RR 

* Make composite crisis indicator based on above ordering 
gen BankingCrisis = .

foreach s of loc priority {
    replace BankingCrisis = `s'_crisisB if BankingCrisis == .
}

/* In some cases, the above consolidation leads to duplicate "crises" in 
	   consecutive years. The reason is that, in some cases, the data in BVX, LV, 
	   and/or JST might be missing but is not missing in RR. To remedy this issue, 
	   we only count new crises if there was no crisis in the previous three years.
*/

xtset id year
replace BankingCrisis = 0 if L1.BankingCrisis == 1 | L2.BankingCrisis == 1 | L3.BankingCrisis == 1 

* Only keep relevant variables 
keep ISO3 year BankingCrisis

* Save 
save "${data_final}/BankingCrisis", replace

* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
*
* Construct data series on currency crises 
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


* ==============================================================================
* Construct harmonized measure of currency crises
*
* Note: For this measure, we combine two measures of currency crises.
*		We prioritize the measure from Laeven and Valencia and use data from
*		Reinhart and Rogoff where their data is not available.
* ==============================================================================

* Define ordering 
local priority LV RR 

* Make composite crisis indicator based on above ordering 
gen CurrencyCrisis = .

foreach s of loc priority {
    replace CurrencyCrisis = `s'_crisisC if CurrencyCrisis == .
}

/* In some cases, the above consolidation leads to duplicate "crises" in 
	   consecutive years. To remedy this issue, we only count new crises if 
	   there was no crisis in the previous three years.
*/

xtset id year 
replace CurrencyCrisis = 0 if L1.CurrencyCrisis == 1 | L2.CurrencyCrisis == 1 | L3.CurrencyCrisis == 1 

* Only keep relevant variables 
keep ISO3 year CurrencyCrisis

* Save 
save "${data_final}/CurrencyCrisis", replace

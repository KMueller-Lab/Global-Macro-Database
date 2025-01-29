* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
*
* Constructing data on sovereign debt crises
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
* Construct harmonized measure of sovereign debt crises
*
* Note: For this measure, we combine two measures of sovereign debt crises.
*		We prioritize the measure from Laeven and Valencia and use data from
*		Reinhart and Rogoff where their data is not available.
* ==============================================================================

* Count as sovereign debt crisis any indicator from Laeven-Valencia
egen LV_SovDebtCrisis = rowmax(LV_crisisSD1 LV_crisisSD2)

* Count as sovereign debt crisis any sovereign debt issue from Reinhart-Rogoff
egen RR_SovDebtCrisis = rowmax(RR_crisisDD RR_crisisED1 RR_crisisED2)

* Define ordering 
local priority LV RR 

* Make composite crisis indicator based on above ordering 
gen SovDebtCrisis = .

foreach s of loc priority {
    replace SovDebtCrisis = `s'_SovDebtCrisis if SovDebtCrisis == .
}

/* In some cases, the above consolidation leads to duplicate "crises" in 
	   consecutive years. To remedy this issue, we only count new crises if 
	   there was no crisis in the previous three years.
*/

xtset id year 
replace SovDebtCrisis = 0 if L1.SovDebtCrisis == 1 | L2.SovDebtCrisis == 1 | L3.SovDebtCrisis == 1 

* Only keep relevant variables 
keep ISO3 year SovDebtCrisis

* Save 
save "${data_final}/SovDebtCrisis", replace

* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-10-17
*
* Description: 
* This Stata script cleans data on banking crises from Baron, Verner, and Xiong
* (BVX), published 2021 in the QJE.
*
* ==============================================================================
*
* ==============================================================================
*			SET UP
* ==============================================================================

clear
global input1 "${data_raw}/aggregators/BVX/bvx_crisis_final"
global input2 "${data_raw}/aggregators/BVX/bvx_annual_regdata_final"
global output "${data_clean}/aggregators/BVX/BVX"

* ==============================================================================
* Clean data 
* ==============================================================================

* Open full crisis list to grab a few crises dropped in regression sample 
use "$input1", clear 

* Drop missing years (countries not in sample)
drop if year == .

* Make indicators for crises and panics 
gen BVX_crisisB = cond(revised!=.,1,0)
ren panic BVX_panic

* Only keep relevant variables 
keep ISO3 year BVX_crisisB BVX_panic 

* Save temporary file 
tempfile BVX_add
save `BVX_add', replace 

* Open full panel file 
use "$input2", clear 

* Only keep relevant variables 
keep ISO3 year C_B30 C_N30 JC RC PANIC_ind PANIC_finer bankfailure_narrative

* Rename 
ren (ISO3 C_B30 C_N30 JC RC PANIC_ind PANIC_finer bankfailure_narrative) (ISO3 BVX_crash_bank BVX_crash_nonfin BVX_narr BVX_crisisB BVX_panic BVX_panic_finer BVX_bfail)

* Set historically correct ISO3 codes
replace ISO3 = "CSK" if ISO3 == "CZE" & year < 1992

* Merge additional crises from crisis list 
merge 1:1 ISO3 year using `BVX_add', update nogen 

* ==============================================================================
* 	Output
* ==============================================================================

* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace

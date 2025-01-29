* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-10
*
* Description: 
* This Stata script opens and cleans quarterly national accounts data from OECD
* 
* Data Source: Organisation for Economic Cooperation and Development
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================

* Clear data 
clear

* Define input and output files
global input "${data_raw}/aggregators/OECD/OECD_QNA.dta"
global output "${data_clean}/aggregators/OECD/OECD_QNA.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open
use "$input", clear

* Keep relevant columns 
keep period value location subject

* Rename 
ren (period location value) (year ISO3 OECD_QNA_)

* Rename subject names
replace subject = "nGDP" if subject == "B1_GS1"
replace subject = "sav"  if subject == "B8GS1"
replace subject = "cons" if subject == "P3"
replace subject = "inv"  if subject == "P5"
replace subject = "finv" if subject == "P51"

* Keep end-of-year observations
duplicates drop ISO3 year subject, force

* Drop non-country regions
merge m:1 ISO3 using $isomapping, nogen keep(3) keepusing(ISO3)

* Reshape wide
qui greshape wide OECD_QNA_, i(ISO3 year) j(subject)

* Convert units
replace OECD_QNA_finv = OECD_QNA_finv * 1000 if inlist(ISO3, "IND", "IDN")
replace OECD_QNA_inv  = OECD_QNA_inv  * 1000 if inlist(ISO3, "IND", "IDN")
replace OECD_QNA_cons  = OECD_QNA_cons  * 1000 if inlist(ISO3, "IND", "IDN")

* Destring
destring year, replace


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

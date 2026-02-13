* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Clean the MD_1 Data
* 
* Author:
* Zekai Shen
* National University of Singapore
* 
* Created: 2024-06-14
*
* Description: 
* This Stata script opens and cleans from the Cox & Dinececco and Beramendi et al. (2018).
*
* Original download link:
* https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/EVCSCQ
* ==============================================================================

* ==============================================================================
* 	SETUP
* ==============================================================================
* Clear
clear
 
* Set input and output files
global input "${data_raw}/aggregators/MD/MD_1.dta"
global output "${data_clean}/aggregators/MD/MD.dta"

* ==============================================================================
*  Process the data 
* ==============================================================================

* Open
use "$input", clear

* Keep relevant variable
keep countryname year pop logexppercap logrevpercap yield loggdppercap

* Keep Countries
keep if countryname == "france" | countryname == "netherlands" | countryname == "portugal" | countryname == "spain" | countryname == "sweden"

* Convert population units into millions
replace pop = pop / 1000000

* Transform log variables into ratio measured by GDP
gen exppercap	   = exp(logexppercap)
gen revercap	   = exp(logrevpercap)
gen gdppercap      = exp(loggdppercap)
gen expenditure    = (pop * exppercap) 
gen gdp 		   = pop * gdppercap 
gen revenue 	   = pop * revercap
gen expendituregdp = (expenditure/gdp) * 100
gen revenuegdp     = (revenue/gdp) * 100

* Transform the bond rate into percentages
gen bond_rate = yield/100

* Rename variables
rename revenuegdp MD_govrev_GDP
rename expendituregdp MD_govexp_GDP
rename pop MD_pop
rename gdp MD_rGDP 
rename bond_rate MD_ltrate
rename countryname ISO3

* Keep relevant variables
keep ISO3 year MD_*

* Add ISO3 codes
replace ISO3 = "FRA" if ISO3 == "france"
replace ISO3 = "NLD" if ISO3 == "netherlands"
replace ISO3 = "PRT" if ISO3 == "portugal"
replace ISO3 = "ESP" if ISO3 == "spain"
replace ISO3 = "SWE" if ISO3 == "sweden"

* Convert units 
replace MD_govrev_GDP = MD_govrev_GDP * 100
replace MD_govexp_GDP = MD_govexp_GDP * 100

* Assign all values to central government. Specified in the source.
ren MD_gov* MD_cgov*

* Drop Data for France because it's not correct 
drop if inlist(ISO3, "FRA", "NLD", "PRT")

* ==============================================================================
*  OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Check for duplicates
isid year ISO3

* Order
order ISO3 year

* Save
save "${output}", replace

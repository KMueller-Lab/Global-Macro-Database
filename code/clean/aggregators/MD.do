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
* 	SET-UP
* ==============================================================================
* Clear
clear

* Set input and output files
global input1 "${data_raw}/aggregators/MD/MD_1.dta"
global input2 "${data_raw}/aggregators/MD/MD_2.dta"
global output "${data_clean}/aggregators/MD/MD.dta"

* Create master tempfile to store all the datasets
tempfile temp_master
save `temp_master', replace emptyok

* ==============================================================================
*  Cox & Dinececco (The Budgetary Origins of Fiscal-Military Prowess)
* ==============================================================================

* Open
use "$input1", clear

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

* Save
tempfile temp_MD1
save `temp_MD1', replace emptyok
append using `temp_master'
save `temp_master', replace

* ==============================================================================
*  Beramendi et al. (2018)
* ==============================================================================

* Open
use "$input2", clear

* Keep needed variable
keep year ctycode taxgdp 

* Add ISO3 codes
gen ISO3 = ctycode
merge m:1 ISO3 using $isomapping
levelsof ISO3 if _merge == 1 //`"BUL"' `"DEN"' `"GER"' `"GRE"' `"JAP"' `"NET"' `"NZD"' `"POR"' `"ROM"' `"SPA"' `"SWI"' `"UK"' `"URU"'

* Keep relevant variables
keep year ctycode taxgdp  

* Drop empty rows
missings dropobs, force

* Rename the ISO3	
replace ctycode = "BGR" if ctycode == "BUL"
replace ctycode = "DNK" if ctycode == "DEN"
replace ctycode = "DEU" if ctycode == "GER"
replace ctycode = "GRC" if ctycode == "GRE"
replace ctycode = "JPN" if ctycode == "JAP"
replace ctycode = "NLD" if ctycode == "NET"
replace ctycode = "NZL" if ctycode == "NZD"
replace ctycode = "PRT" if ctycode == "POR"
replace ctycode = "ROU" if ctycode == "ROM"
replace ctycode = "ESP" if ctycode == "SPA"
replace ctycode = "CHE" if ctycode == "SWI"
replace ctycode = "GBR" if ctycode == "UK"
replace ctycode = "URY" if ctycode == "URU"

* Rename 
rename ctycode ISO3
rename taxgdp MD_govtax_GDP

* Save and merge
tempfile temp_MD2
save `temp_MD2', replace emptyok
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* Convert units
replace MD_govtax_GDP = MD_govtax_GDP * 100
replace MD_govrev_GDP = MD_govrev_GDP * 10
replace MD_govexp_GDP = MD_govexp_GDP * 10

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

* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and cleans data from the paper "Is the crisis 
* problem growing more severe?" by Michael BORDO, Barry Eichengreen, Daniela 
* Klingebiel, and Maria Soledad Martinez-Peria, which was published in Economic 
* Policy in 2001.
*
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-04-05
*
* URL: https://doi.org/10.1111/1468-0327.00070
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================

* Clear data 
clear

* Define input and output files 
global input "${data_raw}/aggregators/BORDO/GDP_BORDO.xls"
global output "${data_clean}/aggregators/BORDO/BORDO.dta"

* ==============================================================================
* 	PROCESS DATA
* ==============================================================================

import excel using "${input}", clear first sheet(updated)

* Keep relevant variables
keep country year nGDP pop infl rgdpNEW debtgdp stintr ltintr ncusdxr gdppc 

* Rename variables
ren (country nGDP pop infl rgdpNEW ncusdxr gdppc debtgdp stintr ltintr) (ISO3 nGDP pop infl rGDP USDfx rGDP_pc_USD govdebt_GDP strate ltrate)

* Destring
destring *, replace

* Drop rows with missing data
qui ds ISO3 year, not
missings dropobs `r(varlist)', force

* Convert units
replace nGDP = nGDP / 1000000
replace rGDP = rGDP / 1000000

* Convert currency
merge m:1 ISO3 using $eur_fx, keep(1 3)
replace nGDP = nGDP/EUR_irrevocable_FX if _merge == 3
replace rGDP = rGDP/EUR_irrevocable_FX if _merge == 3
replace USDfx    = USDfx   /EUR_irrevocable_FX if _merge == 3
drop EUR_irrevocable_FX _merge

* Fix wrong ISO codes
replace ISO3 = "CHN" if ISO3 == "CHI"

* Add source identifier
qui ds year ISO3, not
foreach var in `r(varlist)' {
	ren `var' BORDO_`var'
}

* Ecuador
replace BORDO_nGDP = BORDO_nGDP  * (10^-3) if ISO3 == "ECU"

* Germany 
replace BORDO_nGDP = BORDO_nGDP   / (10^12) if ISO3 == "DEU" & year <= 1923
replace BORDO_USDfx = BORDO_USDfx / (10^12) if ISO3 == "DEU" & year <= 1923

* Fix exchange rate units in teh year 1997 which differ a lot from other sources
replace BORDO_USDfx = . if year == 1997 

* Turkiye
replace BORDO_USDfx = BORDO_USDfx * (10^-6) if ISO3 == "TUR"
replace BORDO_nGDP  = BORDO_nGDP  * (10^-6) if ISO3 == "TUR"

* Ghana
replace BORDO_USDfx = BORDO_USDfx / 10000 if ISO3 == "GHA"
replace BORDO_nGDP = BORDO_nGDP * (10^-3) if ISO3 == "GHA"

* Zimbabwe
replace BORDO_USDfx = BORDO_USDfx / 1000 if ISO3 == "ZWE"

* Brazil
replace BORDO_USDfx = BORDO_USDfx /  2750	 if ISO3 == "BRA"
replace BORDO_USDfx = BORDO_USDfx * (10^-12) if ISO3 == "BRA"
replace BORDO_nGDP = BORDO_nGDP   * (10^-12) if ISO3 == "BRA"
replace BORDO_nGDP = BORDO_nGDP   /  2750	 if ISO3 == "BRA"

* Venezuela
replace BORDO_USDfx = BORDO_USDfx / 1000      if ISO3 == "VEN"
replace BORDO_nGDP  = BORDO_nGDP  * (10^-14)  if ISO3 == "VEN"

* Drop Argentina because the data differed significantly from data from other sources and convert the units
replace BORDO_USDfx = . if ISO3 == "ARG"
replace BORDO_nGDP = BORDO_nGDP * (10^-13) if ISO3 == "ARG"
replace BORDO_rGDP = BORDO_rGDP * (10^-11) if ISO3 == "ARG"

* Drop interpolated value in Bordo for Japan in 1945 and Germany in 1923 which are likely to be wrong
replace BORDO_nGDP = . if year == 1945 & ISO3 == "JPN"
replace BORDO_nGDP = . if year == 1923 & ISO3 == "DEU"

* Drop real GDP for Zimbabwe, one value in 1978
replace BORDO_rGDP = . if ISO3 == "ZWE"

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid year ISO3 

* Save
save "${output}", replace

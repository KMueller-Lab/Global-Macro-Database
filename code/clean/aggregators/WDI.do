* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CLEAN DATA FROM THE WORLD DEVELOPMENT INDICATORS
* 
* Description: 
* This Stata script reads in and cleans data from the World Bank's World 
* Development Indicators.
*
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 
* Last updated: 2024-09-26
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
* Define input and output files 
clear
global input "${data_raw}/aggregators/WB/WDI.dta"
global output "${data_clean}/aggregators/WB/WDI"

* ==============================================================================
* 	PROCESS
* ==============================================================================
* Open 
use "$input"

* Drops regional aggregates 
drop if incomelevel == "NA"
drop if region == "" 

* Rename countrycode as ISO3
ren countrycode ISO3

* Drop Channel Islands 
drop if ISO3 == "CHI"

* Drop unnecessary variables 
drop region adminregion adminregionname incomelevel lendingtype lendingtypename
drop countryname regionname incomelevelname indicatorname

* Reshape so that indicator codes are long 
greshape long yr, i(ISO3 indicatorcode) j(year) string
greshape wide yr, i(ISO3 year) j(indicatorcode)
ren yr* *

* Derive central government debt share of GDP
replace GC_DOD_TOTL_CN = (GC_DOD_TOTL_CN/NY_GDP_MKTP_CN) * 100

* Rename variables 
ren (SP_POP_TOTL NY_GDP_MKTP_CN NY_GDP_MKTP_KN NY_GDP_MKTP_CD NY_GDP_MKTP_KD NY_GDP_PCAP_KN FP_CPI_TOTL FP_CPI_TOTL_ZG NE_GDI_TOTL_CN NE_GDI_FTOT_CN NY_GNS_ICTR_CN NE_CON_TOTL_CN NE_CON_TOTL_KN NE_IMP_GNFS_CN NE_IMP_GNFS_CD NE_EXP_GNFS_CN NE_EXP_GNFS_CD PA_NUS_FCRF PX_REX_REER BN_CAB_XOKA_GD_ZS GC_TAX_TOTL_CN GC_DOD_TOTL_CN GC_XPN_TOTL_CN GC_REV_XGRT_GD_ZS GC_TAX_TOTL_GD_ZS) ///
    (pop nGDP rGDP nGDP_USD rGDP_USD rGDP_pc CPI infl inv finv sav cons rcons imports imports_USD exports exports_USD USDfx REER CA_GDP govtax govdebt_GDP govexp govrev_GDP govtax_GDP)

* Make variables into millions 
foreach var of varlist  nGDP rGDP rGDP_USD nGDP_USD inv finv sav cons rcons imports imports_USD exports exports_USD pop govexp govtax {
	replace `var'= `var' / 1000000
}

* Destring
destring year *, replace

* Replace zero values 
replace finv = . if finv == 0
replace inv = .  if inv  == 0
replace cons = . if cons == 0

* Fix Venezuela units 
foreach var of varlist  nGDP rGDP rGDP_USD nGDP_USD inv finv sav cons rcons imports imports_USD exports exports_USD govexp govtax {
	replace `var'= `var' / (10^5) if ISO3 == "VEN"
}

* Fix Sierra Leone units 
foreach var of varlist USDfx nGDP rGDP rGDP_USD nGDP_USD inv finv sav cons rcons imports imports_USD exports exports_USD govexp govtax {
	replace `var'= `var' * 1000 if ISO3 == "SLE"
}

* Fix Afghanistan units 
foreach var of varlist  nGDP rGDP rGDP_USD nGDP_USD inv finv sav cons rcons imports imports_USD exports exports_USD govexp govtax {
	replace `var'= `var' / 1000 if ISO3 == "AFG" & year <= 1978
}

* Fix Indonesia units 
foreach var of varlist  nGDP imports inv finv exports cons {
	replace `var'= `var' / 1000 if ISO3 == "IDN" & year <= 1965
}

* Sao-Tome & principe exchange rate issues
replace USDfx = USDfx * 1000 if ISO3 == "STP"


* Fix units for Spain's government debt 
replace govdebt_GDP = govdebt_GDP / 100 if ISO3 == "ESP" & inrange(year, 1970, 1971)

* Fix Oman units
replace rGDP = rGDP * (10^6) if ISO3 == "OMN" & year <= 1964

* Generate government revenue nominal values and capital account
gen govrev = (govrev_GDP * nGDP) / 100
gen CA = (CA_GDP * nGDP) / 100

* Convert currency for Eurozone countries
merge m:1 ISO3 using $eur_fx, keep(1 3)
replace USDfx  = USDfx / EUR_irrevocable_FX if _merge == 3 & year <= 1998
drop EUR_irrevocable_FX _merge

* Add real GDP per capita in USD
gen rGDP_pc_USD = rGDP_USD / pop

* Add ratios to gdp variables
gen cons_GDP    = (cons / nGDP) * 100
gen imports_GDP = (imports / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100
gen govexp_GDP  = (govexp / nGDP) * 100
gen finv_GDP    = (finv / nGDP) * 100
gen inv_GDP     = (inv / nGDP) * 100

* Investment to GDP ratio for the US is likely wrong
replace finv_GDP = . if year <= 1971 & ISO3 == "USA"

* Add the deflator
gen deflator = (nGDP / rGDP) * 100

* Rebase the GDP to 2010
* Loop over all countries
qui levelsof ISO3, local(countries) clean
foreach country of local countries {
	
	* Rebase to 2010
	qui gen  temp = deflator if year == 2010 & ISO3 == "`country'"
	qui egen defl_2010 = max(temp) if ISO3 == "`country'"
	qui replace rGDP = (rGDP * defl_2010) / 100 if ISO3 == "`country'"
	qui drop temp defl_2010	
}

* Update the deflator
replace deflator = (nGDP / rGDP) * 100


* Add source identifier
qui ds year ISO3, not
foreach var in `r(varlist)' {
	ren `var' WDI_`var'
}

* Drop 
drop WDI_FM_LBL_BMNY_CN  

* Add government debt levels 
gen WDI_govdebt = (WDI_govdebt_GDP * WDI_nGDP) / 100

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

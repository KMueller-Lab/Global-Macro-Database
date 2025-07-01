* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN INTERNATIONAL MONETARY FUND (IMF) INTERNATIONAL FINANCIAL STATISTICS (IFS) DATA
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Last Editor:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-04-22
* Last update: 2025-06-23
*
* Description: This Stata script processes the raw IMF IFS data.
*
* Data source: IMF International Financial Statistics
* 
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================
* Clear all
clear

* Define input and output files
global input "${data_raw}/aggregators/IMF/IMF_IFS"
global output "${data_clean}/aggregators/IMF/IMF_IFS.dta"

* ==============================================================================
* 	SET UP
* ==============================================================================
* Open.
use "${input}", clear

* Destring and convert units
destring unit_mult date value, replace
replace value = value / 1000 if unit_mult == 3
drop unit_mult

* Reshape into a wide dataset.
greshape wide value, i(date ISO3) j(indicator)

* Rename
ren value* *
ren (date NGDP_XDC NGDP_R_XDC ENDA_XDC_USD_RATE EREER_IX FPOLM_PA LP_PE_NUM LUR_PT BCAXF_BP6_USD NFI_XDC NI_XDC NM_XDC NX_XDC NC_XDC PCPI_IX PCPI_PC_CP_A_PT NC_R_XDC FITB_PA FIGB_PA ) (year nGDP rGDP USDfx REER cbrate pop unemp CA_USD finv inv imports exports cons CPI infl rcons strate ltrate)
drop BGS* EDNE*

* Use the exchange rate to derive the CA
gen CA = CA_USD * USDfx

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	ren `var' IMF_IFS_`var'
}


* Convert currency for european countries
merge m:1 ISO3 using $eur_fx, keep(1 3)
replace IMF_IFS_USDfx  = IMF_IFS_USDfx / EUR_irrevocable_FX if _merge == 3
drop EUR_irrevocable_FX _merge

* ==============================================================================
* The following code was used to clean the IMF IFS data we downloaded through 
* the dBnomics API. In these data, many units were misreported and thus had to be 
* manually adjusted. Our understanding is that dBnomics simply has a different 
* process of accessing these data, and that these issues in fact are present 
* in some versions of the IMF IFS data. We thus leave this code in here in case
* it becomes relevant again in the future.
*
* Convert units in case of undocumented inconsistencies in reporting units
* ==============================================================================

/* Fix the units for real GDP for various countries (Errors detected from the plots)
replace IMF_IFS_nGDP = IMF_IFS_nGDP / 100  if ISO3 == "LBR"
replace IMF_IFS_nGDP = IMF_IFS_nGDP * 1000 if ISO3 == "IND"
replace IMF_IFS_nGDP = IMF_IFS_nGDP * (10^3) if ISO3 == "IDN"
replace IMF_IFS_nGDP = IMF_IFS_nGDP * 1000 if ISO3 == "LBY" & year <= 1985 & year >= 1981
replace IMF_IFS_rGDP = IMF_IFS_rGDP * (10^9) if ISO3 == "BFA"
replace IMF_IFS_rGDP = IMF_IFS_rGDP * (10^6) if ISO3 == "IND"
replace IMF_IFS_rGDP = . if year <= 2004 & ISO3 == "SLV"

* Fix the units for India and Indonesia
replace IMF_IFS_imports = IMF_IFS_imports * 1000 if inlist(ISO3, "IND", "IDN")
replace IMF_IFS_exports = IMF_IFS_exports * 1000 if inlist(ISO3, "IND", "IDN")

* Burkina Faso data is 0 before 1998
replace IMF_IFS_imports = . if ISO3 == "BFA" & year <= 1998 // True
replace IMF_IFS_exports = . if ISO3 == "BFA" & year <= 1998 // True

* Bolivia exchange rate issues
replace IMF_IFS_USDfx = . if year == 1958 & ISO3 == "BOL"

* Sao-Tome & Principe and Sierra Leone exchange rate issues
replace IMF_IFS_USDfx = IMF_IFS_USDfx * 1000 if ISO3 == "STP"
replace IMF_IFS_USDfx = IMF_IFS_USDfx * 1000 if ISO3 == "SLE"

* Turkiye
replace IMF_IFS_USDfx = IMF_IFS_USDfx / 1000000 if ISO3 == "TUR" & year <= 1956
replace IMF_IFS_USDfx = IMF_IFS_USDfx / 100000 if ISO3 == "TUR"  & year == 1957

* Wrong value for Vietnam GDP in 2023
replace IMF_IFS_nGDP = 1.022e+10 if ISO3 == "VNM" & year == 2023 // Using values from IMF WEO
replace IMF_IFS_rGDP = 5.831e+09 if ISO3 == "VNM" & year == 2023 // Using values from IMF WEO

*/

* Derive CA_GDP
gen IMF_IFS_CA_GDP = (IMF_IFS_CA/IMF_IFS_nGDP) * 100

* Drop
drop  IMF_IFS_CA IMF_IFS_CA_USD  

* Add ratios to gdp variables
gen IMF_IFS_cons_GDP    = (IMF_IFS_cons / IMF_IFS_nGDP) * 100
gen IMF_IFS_imports_GDP = (IMF_IFS_imports / IMF_IFS_nGDP) * 100
gen IMF_IFS_exports_GDP = (IMF_IFS_exports / IMF_IFS_nGDP) * 100
gen IMF_IFS_finv_GDP    = (IMF_IFS_finv / IMF_IFS_nGDP) * 100
gen IMF_IFS_inv_GDP     = (IMF_IFS_inv / IMF_IFS_nGDP) * 100


* Add the deflator
gen IMF_IFS_deflator = (IMF_IFS_nGDP / IMF_IFS_rGDP) * 100

* Rebase the GDP to 2010
* Loop over all countries
qui levelsof ISO3, local(countries) clean
foreach country of local countries {
	
	* Rebase to 2010
	qui gen  temp = IMF_IFS_deflator if year == 2010 & ISO3 == "`country'"
	qui egen defl_2010 = max(temp) if ISO3 == "`country'"
	qui replace IMF_IFS_rGDP = (IMF_IFS_rGDP * defl_2010) / 100 if ISO3 == "`country'"
	qui drop temp defl_2010	
}

* Update the deflator
replace IMF_IFS_deflator = (IMF_IFS_nGDP / IMF_IFS_rGDP) * 100

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

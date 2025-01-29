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
* Last update: 2024-09-26
*
* Description: This Stata script processes the raw IMF IFS data.
*
* Data source: IMF International Financial Statistics
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

* Reshape into a wide dataset.
keep period ref_area indicator value
greshape wide value, i(ref_area period) j(indicator)

* Rename
ren value* *
ren (period ref_area NGDP_XDC NGDP_R_XDC ENDA_XDC_USD_RATE EREER_IX FPOLM_PA LP_PE_NUM LUR_PT BCAXF_BP6_USD NFI_XDC NI_XDC NM_XDC NX_XDC NC_XDC PCPI_IX PCPI_PC_CP_A_PT NC_R_XDC) (year ISO2 nGDP rGDP USDfx REER cbrate pop unemp CA_USD finv inv imports exports cons CPI infl rcons)

* Use the exchange rate to derive the CA
gen CA = CA_USD * USDfx


* Change German Federal Republic ISO code.
replace ISO2 = "DD" if ISO2 == "DE2"

* Change Socialist Federal Republic of Yugoslavia ISO code.
replace ISO2 = "YU" if ISO2 == "YUC"

* Change CzechoSlovakia ISO code.
replace ISO2 = "CS" if ISO2 == "CSH"

* Change U.S.S.R ISO code.
replace ISO2 = "SU" if ISO2 == "SUH"

* Drop regional aggregates 
drop if regexm(ISO2, "[0-9]")

* Convert ISO2 into ISO3 codes.
merge m:1 ISO2 using ${isomapping}, nogen keep(3) assert(2 3) keepusing(ISO3)
drop ISO2 

* Convert pop to million
replace pop = pop / 1000

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
* 	Convert units in case of undocumented inconsistencies in reporting units
* ==============================================================================

* Fix Ghana's imports and exports data (negative values detected)
replace IMF_IFS_exports = abs(IMF_IFS_exports) 
replace IMF_IFS_imports = abs(IMF_IFS_imports) 

* Fix wrong values
replace IMF_IFS_nGDP = . if IMF_IFS_nGDP == 4.657e-07 & ISO3 == "VNM"

* Fix the units for real GDP for various countries (Errors detected from the plots)
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
replace IMF_IFS_imports = . if ISO3 == "BFA" & year <= 1998
replace IMF_IFS_exports = . if ISO3 == "BFA" & year <= 1998

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

* Derive CA_GDP
gen IMF_IFS_CA_GDP = (IMF_IFS_CA/IMF_IFS_nGDP) * 100

* Drop
drop   IMF_IFS_BGS_BP6_USD IMF_IFS_CA IMF_IFS_CA_USD IMF_IFS_EDNE_USD_XDC_RATE 

* Add ratios to gdp variables
gen IMF_IFS_cons_GDP    = (IMF_IFS_cons / IMF_IFS_nGDP) * 100
gen IMF_IFS_imports_GDP = (IMF_IFS_imports / IMF_IFS_nGDP) * 100
gen IMF_IFS_exports_GDP = (IMF_IFS_exports / IMF_IFS_nGDP) * 100
gen IMF_IFS_finv_GDP    = (IMF_IFS_finv / IMF_IFS_nGDP) * 100
gen IMF_IFS_inv_GDP     = (IMF_IFS_inv / IMF_IFS_nGDP) * 100


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

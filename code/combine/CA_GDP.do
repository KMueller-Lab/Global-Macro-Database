* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCTING CURRENT ACCOUNT TO GDP RATIO
* 
* Created: 
* 2024-06-28
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 	
* ==============================================================================

* Clear the panel
clear

* Create temporary file to store the data
tempfile temp_master
save `temp_master', replace emptyok

* First run our chainlinked nominal GDP because we will use later 
do "$code_combine/nGDP.do"
clear

* Second run USDfx because we will use later 
do "$code_combine/USDfx.do"
clear

use "$data_final/clean_data_wide", clear

* Calculate current account balance in GDP after deriving the current account balance values in local currency using our own constructed exchange rate
merge 1:1 ISO3 year using "${data_final}/chainlinked_USDfx.dta", keepusing(USDfx) keep(1 3) nogen
merge 1:1 ISO3 year using "${data_final}/chainlinked_nGDP.dta", keepusing(nGDP) keep(1 3) nogen

* Derive Mitchell values in LCU
replace Mitchell_CA = Mitchell_CA_USD * USDfx if Mitchell_CA == .

* Derive current account balance in terms of GDP
gen Mitchell_CA_GDP = (Mitchell_CA / Mitchell_nGDP) * 100
drop USDfx nGDP Mitchell_CA_USD Mitchell_CA

* Fix values for Sierra Leone
replace Mitchell_CA_GDP = Mitchell_CA_GDP * 1000 if ISO3 == "SLE"
replace Mitchell_CA_GDP = Mitchell_CA_GDP / 1000 if ISO3 == "IDN" & year <= 1939

* Drop outlier values for Ghana
replace Mitchell_CA_GDP = . if inrange(year, 1955, 1956) & ISO3 == "GHA"


* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================
* Set up the priority list
splice, priority(IMF_WEO AMF BCEAO OECD_EO WDI WDI_ARC OECD_KEI IMF_IFS ADB CS1 JST JO Mitchell) generate(CA_GDP) varname(CA_GDP) base_year(2018) method("none")


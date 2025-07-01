* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN AFRICAN ECONOMIC DATA FROM AFRICAN DEVELOPMENT BANK
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-20
*
* Description: 
* Script to process and output data from the African Development Bank. 
*
* ==============================================================================

* ==============================================================================
*			SET UP
* ==============================================================================

clear
global input "${data_raw}/aggregators/AFDB/AFDB"
global output "${data_clean}/aggregators/AFDB/AFDB"

* Open
use "${input}", clear

* Keep only relevant columns
keep period country indicator value

* Set series's code
replace indicator = "M1" 		  if indicator == "FM.LBL.MONY.CN"
replace indicator = "M2" 		  if indicator == "FM.LBL.MQMY.CN"
replace indicator = "govdef_GDP"  if indicator == "GC.BAL.CASH.GD.ZS"
replace indicator = "govrev_GDP"  if indicator == "GC.REV.TOTL.GD.ZS"
replace indicator = "govexp_GDP"  if indicator == "GC.XPN.TOTL.GD.ZS"
replace indicator = "unemp"		  if indicator == "SL.TLF.15UP.UEM"
replace indicator = "emp"		  if indicator == "LM.POP.EPP.TOT"
replace indicator = "nGDP"		  if indicator == "NY.GDP.MKTP.CN"

* Reshape
greshape wide value, i(country period) j(indicator)

* Rename
ren value* *
ren country ISO3
ren period year

* Convert units
replace M1  = M1  /  1000000
replace M2  = M2  /  1000000
replace emp = emp /  1000

* Drop regional aggregates
merge m:1 ISO3 using $isomapping, keep(3) keepusing(ISO3) nogen

* Drop rows with no data
qui ds ISO3 year, not
missings dropobs `r(varlist)', force

* Fix units for Mauritania
replace M1  = M1  /  10 if ISO3 == "MRT"
replace M2  = M2  /  10 if ISO3 == "MRT"
replace nGDP  = nGDP  /  10 if ISO3 == "MRT"

* Fix units for Sao-Tome
replace M1  = M1  /  1000 if ISO3 == "STP"
replace M2  = M2  /  1000 if ISO3 == "STP"
replace nGDP  = nGDP  /  1000 if ISO3 == "STP"

* Fix units for Zambia
replace M1 = M1 * 100 if year > 2000 & ISO3 == "ZMB"
replace M2 = M2 * 100 if year > 2000 & ISO3 == "ZMB"
replace nGDP = nGDP / 1000 if ISO3 == "ZMB" & year <= 1999

* Fix units for Tunisia
replace nGDP = nGDP / 1000 if year <= 2005 & year >= 2000 & ISO3 == "TUN"
replace nGDP = nGDP * 10 if year == 2000 & ISO3 == "TUN"

* Fix units for Togo
replace nGDP = nGDP * 10 if year <= 2005 & year >= 2000 & ISO3 == "TGO"

* Fix units for Eswatini
replace nGDP = nGDP / 1000 if year <= 2005 & year >= 2000 & ISO3 == "SWZ"

* Fix units for Mozambique
replace nGDP = nGDP / 1000 if year >= 2004 & ISO3 == "MOZ"

* AFDB data on Congo and Liberia is likely mistaken. Deviates widely from all other sources
replace M1 = . if year < 1995 & ISO3 == "COG"
replace M2 = . if year < 1995 & ISO3 == "COG"

replace M1 = . if year > 2000 & ISO3 == "LBR"
replace M2 = . if year >= 2000 & ISO3 == "LBR"

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)' {
	ren `var' AFDB_`var'
}

* Derive government finances nominal values
replace AFDB_nGDP  = AFDB_nGDP  /  1000000
gen AFDB_govdef = (AFDB_govdef_GDP * AFDB_nGDP) / 100
gen AFDB_govrev = (AFDB_govrev_GDP * AFDB_nGDP) / 100
gen AFDB_govexp = (AFDB_govexp_GDP * AFDB_nGDP) / 100


* ==============================================================================
* 				Output
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplciates
isid ISO3 year

* Save
save "${output}", replace

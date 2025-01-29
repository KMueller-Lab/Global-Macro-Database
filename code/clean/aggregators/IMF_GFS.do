* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-12
* 
* Description: 
* This Stata script cleans Government Finance Statistics from the IMF
*
* Data source: International Monetary Fund
* 
* 
* ==============================================================================
*
* ==============================================================================
*	SET UP
* ==============================================================================
* Clear all
clear 

* Define input and output files
global input "${data_raw}/aggregators/IMF/IMF_GFS"
global output "${data_clean}/aggregators/IMF/IMF_GFS.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================
* Open.
use "${input}", clear

* Keep relevant columns
keep period value REF_AREA CLASSIFICATION REF_SECTOR UNIT_MEASURE

* Destring
replace value = "" if value == "NA"
destring period value, replace
replace CLASSIFICATION = CLASSIFICATION + "_" + REF_SECTOR + "_" + UNIT_MEASURE
drop REF_SECTOR UNIT_MEASURE

* Reshape
greshape wide value, i(REF_AREA period) j(CLASSIFICATION)

* Rename columns
ren value* *
ren REF_AREA ISO2
ren period year

* Use central government values and fill in with budgetary central government 
gen govtax =  G11__Z_S1311_XDC 
replace govtax =  G11__Z_S1311B_XDC if govtax == .

gen govrev =  G1__Z_S1311_XDC 
replace govrev =  G1__Z_S1311B_XDC if govrev == .

gen govexp =  G2M__Z_S1311_XDC 
replace govexp =  G2M__Z_S1311B_XDC if govexp == .

gen govdef_GDP =  GNLB__Z_S1311_XDC_R_B1GQ
replace govdef_GDP =  GNLB__Z_S1311B_XDC_R_B1GQ if govdef == .

* Keep only relevant columns
keep ISO2 year gov*


* Turn ISO2 to ISO3
merge m:1 ISO2 using $isomapping, assert(2 3) keep(3) keepusing(ISO3) nogen
drop ISO2

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)' {
	ren `var' IMF_GFS_`var'
}

* Convert units
local countries AGO ARM AUS BDI BEN BFA BGD BOL BRA CHL CHN CIV CAN CMR COD COG COL CRI CZE DEU DNK DOM DZA EGY ESP FRA GAB GBR GNQ HUN IND IDN IDN IRN IRN IRQ ISL ITA JAM JPN KAZ KEN KHM KOR LAO LBN LKA MDG MLI MMR MNG MWI NER NGA NOR PAK PHL PRY RUS RWA SAU SEN SLE SRB SWE TGO THA TUR TZA UGA USA UZB VNM YEM ZAF ZMB
foreach country of local countries {
	qui replace IMF_GFS_govexp = IMF_GFS_govexp * 1000 if ISO3 == "`country'"
	qui replace IMF_GFS_govrev = IMF_GFS_govrev * 1000 if ISO3 == "`country'"
	qui replace IMF_GFS_govtax = IMF_GFS_govtax * 1000 if ISO3 == "`country'"
}

local countries FSM KIR LBR MHL PLW WSM BOL AIA MSR
foreach country of local countries {
	qui replace IMF_GFS_govexp = IMF_GFS_govexp / 1000 if ISO3 == "`country'"
	qui replace IMF_GFS_govrev = IMF_GFS_govrev / 1000 if ISO3 == "`country'"
	qui replace IMF_GFS_govtax = IMF_GFS_govtax / 1000 if ISO3 == "`country'"
}

* Convert currency for El Salvador
qui replace IMF_GFS_govexp = IMF_GFS_govexp / 8.75 if ISO3 == "SLV" & year <= 2000
qui replace IMF_GFS_govrev = IMF_GFS_govrev / 8.75 if ISO3 == "SLV" & year <= 2000
qui replace IMF_GFS_govtax = IMF_GFS_govtax / 8.75 if ISO3 == "SLV" & year <= 2000

* Convert currency for Ecuador
qui replace IMF_GFS_govexp = IMF_GFS_govexp / 2500 if ISO3 == "ECU" & year <= 2000
qui replace IMF_GFS_govrev = IMF_GFS_govrev / 2500 if ISO3 == "ECU" & year <= 2000
qui replace IMF_GFS_govtax = IMF_GFS_govtax / 2500 if ISO3 == "ECU" & year <= 2000

* Fix two mistaken values in GFS
qui replace  IMF_GFS_govrev = IMF_GFS_govrev / 10 if ISO3 == "SDN" & inrange(year, 1998, 1999)

* Convert currency for Korea
qui replace  IMF_GFS_govrev = IMF_GFS_govrev * 1000 if ISO3 == "KOR" 
qui replace  IMF_GFS_govtax = IMF_GFS_govtax * 1000 if ISO3 == "KOR" 
qui replace  IMF_GFS_govexp = IMF_GFS_govexp * 1000 if ISO3 == "KOR" 

* Convert currency for Congo
qui replace  IMF_GFS_govrev = IMF_GFS_govrev / 100  if ISO3 == "COD" & year <= 1997
qui replace  IMF_GFS_govtax = IMF_GFS_govtax / 100  if ISO3 == "COD" & year <= 1997
qui replace  IMF_GFS_govexp = IMF_GFS_govexp / 100  if ISO3 == "COD" & year <= 1997

* Convert currency for Congo
qui replace  IMF_GFS_govrev = IMF_GFS_govrev / 1000  if ISO3 == "COD" & year <= 1993
qui replace  IMF_GFS_govtax = IMF_GFS_govtax / 1000  if ISO3 == "COD" & year <= 1993
qui replace  IMF_GFS_govexp = IMF_GFS_govexp / 1000  if ISO3 == "COD" & year <= 1993

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

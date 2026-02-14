* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN USD EXCHANGE RATE DATA FROM THE BIS
* 
* Author:
* Ziliang Chen
* National University of Singapore
* 
* Created: 2024-09-25
*
* Description: 
* This Stata script reads in and cleans exchange rate data from the BIS
*
* Data source: Bank for International Settlements
*
* ==============================================================================

* ==============================================================================
* SET UP
* ==============================================================================

* Define input and output files 
clear
global input "${data_raw}/aggregators/BIS/BIS_USDfx/BIS_USDfx.dta"
global output "${data_clean}/aggregators/BIS/BIS_USDfx/BIS_USDfx.dta"

* ==============================================================================
* PROCESSING
* ==============================================================================

* Open 
use "${input}", clear 

* Drop regional aggregates
drop if ref_area == "XM"

* Keep annual data and end of period
keep if collection == "A"

* Keep only relevant variables
keep time obs ref_area 

* Replace "NA" in value and destring it
destring obs time, replace ignore("NA")

* Convert ISO2 to ISO3
ren ref_area ISO2
merge m:1 ISO2 using ${isomapping}, nogen keep(3) keepusing(ISO3)
drop ISO2

* Rename
ren obs BIS_USDfx 
ren time year

* Fix exchange rate units
qui replace BIS_USDfx = BIS_USDfx / 10 if ISO3 == "MRT"
gmdaddnote_source BIS  "Values converted to current currency." BIS_USDfx

qui replace BIS_USDfx = BIS_USDfx / 1000 if ISO3 == "STP"
gmdaddnote_source BIS  "Values converted to current currency." BIS_USDfx

* ==============================================================================
* OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid year ISO3 

* Save
save "${output}", replace

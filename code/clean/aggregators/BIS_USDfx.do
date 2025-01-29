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
global input "${data_raw}/aggregators/BIS/BIS_USDfx.dta"
global output "${data_clean}/aggregators/BIS/BIS_USDfx.dta"

* ==============================================================================
* PROCESSING
* ==============================================================================

* Open 
use "${input}"

* Drop regional aggregates
drop if strpos(series_name, "Waemu") | strpos(series_name, "World") 
drop if ref_area == "XM"

* Keep only relevant variables
keep period value ref_area

* Replace "NA" in value and destring it
replace value = "" if value == "NA"
destring value, replace

* Convert ISO2 to ISO3
ren ref_area ISO2
merge m:1 ISO2 using ${isomapping}, nogen assert(2 3) keep(3) keepusing(ISO3)
drop ISO2

* Rename
ren value BIS_USDfx 
ren period year

* Fix exchange rate units
gmdfixunits BIS_USDfx if ISO3 == "MRT", divide(10)
gmdfixunits BIS_USDfx if ISO3 == "SLE", multiply(1000)

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

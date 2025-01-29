* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* Clean Exchange rate data from Bank of Italy
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2025-01-08
*
* URL: https://tassidicambio.bancaditalia.it/terzevalute-wf-ui-web/converter
* ==============================================================================
*
* ==============================================================================
*			SET UP
* ==============================================================================
* Set up global variables
clear
global input "${data_raw}/aggregators/BIT/BIT_USDfx"
global output "${data_clean}/aggregators/BIT/BIT_USDfx"

* ==============================================================================
* Clean data 
* ==============================================================================

* Open
import delimited using "${input}", clear

* Rename the indicator 
replace rateconvention = "USDfx_i" if rateconvention == "Dollars amount per 1 units of foreign currency"
replace rateconvention = "USDfx" if rateconvention == "Foreign currency amount for 1 Dollar"
replace rateconvention = "LIRfx" if rateconvention == "Liras amount per 1 units of foreign currency"

* Turn USDfx into 1 USD in LCU
replace rate = 1 / rate if rateconvention == "USDfx_i" 
replace rateconvention = "USDfx" if rateconvention == "USDfx_i"

* Drop 
drop isocode uiccode 

* Reshape
greshape wide rate, i(currency referencedatecet) j(rateconvention)
ren rate* BIT_*

* Extract country ISO3 codes 
gen ISO3 = "AUT" if currency == "Austrian Shilling"
replace ISO3 = "PYF" if currency == "CFP Franc"
replace ISO3 = "DDR" if currency == "DDR Mark"
replace ISO3 = "FLK" if currency == "Falkland Pound"
replace ISO3 = "GIB" if currency == "Gibraltar Pound"
replace ISO3 = "GRC" if currency == "Greek Drachma"
replace ISO3 = "ITA" if currency == "Italian Lira"
replace ISO3 = "ALB" if currency == "Lek"
replace ISO3 = "PRK" if currency == "North Korean Won"
replace ISO3 = "SUN" if currency == "Ruble"
replace ISO3 = "SHN" if currency == "St. Helena Pound"

* Drop
drop currency BIT_LIRfx

* Rename
ren referencedatecet year

* ==============================================================================
* 	Output
* ==============================================================================
* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace

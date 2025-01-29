* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-07-04
*
* Description: 
* This Stata script opens and cleans MEI (main economic indicators) data from OECD.
* 
* Data Source: OECD
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================
* Clear data 
clear

* Define input and output files
global input "${data_raw}/aggregators/OECD/OECD_MEI.dta"
global output "${data_clean}/aggregators/OECD/OECD_MEI.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open
use "$input", clear

* Keep relevant columns
keep period value subject location

* Reshape wide
greshape wide value, i(period location) j(subject)

* Rename
ren value* * 
ren (period location CCRETT01 IRLTLT01 IRSTCB01 MABMM301 MANMM101) (year ISO3 REER ltrate cbrate M3 M1)

* Drop non-country regions
drop if ISO3 == "EA19"

* Convert variables to million (Billion for Indonesia)
replace M1 = M1 * 1000 if !inlist(ISO3, "GBR", "ISR")
replace M3 = M3 * 1000 if !inlist(ISO3, "GBR", "ISR")

replace M1 = M1 * 1000 if ISO3 == "IDN"
replace M3 = M3 * 1000 if ISO3 == "IDN"

* Fix units for Japan
replace M1 = M1 / 10 if ISO3 == "JPN"
replace M3 = M3 / 10 if ISO3 == "JPN"

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	ren `var' OECD_MEI_`var'
}

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

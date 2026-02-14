* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* This folder runs intermediate files that are used as input for other variables.
*
* This is needed to speed up the cleaning and processing parts.
* 
* Created: 
* 2025-06-25
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 	
* ==============================================================================


* ==============================================================================
* Nominal GDP
* ==============================================================================

do "$code/0_master.do"

* Open the data
use "$data_final/clean_data_wide", clear

* Set up the priority list
cap splice, priority(OECD_EO EUS AMECO UN BCEAO FRANC_ZONE AMF ADB FAO AFDB IMF_WEO IMF_IFS ECLAC IMF_GDD MW CS1 CS2 CS3 JST WDI WDI_ARC AHSTAT Mitchell BORDO JO Moxlad NBS GNA HFS FZ Davis FLORA IMF_WEO_forecast) generate(nGDP) varname(nGDP) base_year(2019) method("chainlink")

* Create the log
clear 
set obs 1 
gen variable = "nGDP"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/nGDP_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_nGDP", clear
	gmdmakedoc nGDP, log ylabel("Nominal GDP, millions of LCU (Log scale)")	
	gen variable = "nGDP"
	gen variable_definition = "Nominal GDP"
	save "$data_final/documentation_nGDP", replace
}



* ==============================================================================
* USDfx file 
* ==============================================================================

* Open the data
use "$data_final/clean_data_wide", clear

* Drop Zimbabwe values that are unreliable
drop if year >= 2008 & ISO3 == "ZWE"

* Set up the priority list
cap {
	
splice, priority(BIS IMF_IFS OECD_EO OECD_KEI UN WDI ADB AMF CS1 CS2 CS3 BIT BORDO HFS JST Tena Moxlad MW NBS AHSTAT PWT IMF_WEO IMF_WEO_forecast) generate(USDfx) varname(USDfx) base_year(2018) method("none")


* To French colonies in Africa, we assign the exchange rate of the French Franc between 1903 and 1949
local colonies "SEN CIV BFA MLI NER TCD CAF CMR BEN TGO GIN GAB COG"

* Loop over every colony
foreach colony of local colonies {
    preserve
		qui drop *_USDfx
        qui keep if ISO3 == "FRA"  & inrange(year, 1903, 1949)
        qui replace ISO3 = "`colony'" 
		qui replace USDfx = USDfx * 0.85 if year <= 1947
		qui replace USDfx = USDfx * 200 if year <= 1949
        tempfile fra_early_`colony'
        qui save `fra_early_`colony''
    restore
    
    * Append the early FRA data
    append using `fra_early_`colony''
}

* Sort
sort ISO3 year

* Add the source
qui gen imputed = 0
foreach colony of local colonies {
    qui replace imputed = 1 if ISO3 == "`colony'" & inrange(year, 1903, 1949)
	qui replace source = "JST" if imputed == 1
}

* Drop 
drop imputed

* Assign France exchange rate to Monaco
local Monaco "MCO"

preserve
	qui drop *_USDfx
	qui keep if ISO3 == "FRA"  & inrange(year, 1925, 1959)
	qui replace ISO3 = "`Monaco'" 
	tempfile MCO
	qui save `MCO'
restore

* Append
append using `MCO'

* Sort
sort ISO3 year

* Add the source
qui gen imputed = 0
qui replace imputed = 1 if ISO3 == "MCO" & inrange(year, 1925, 1959)
qui replace source = "JST" if imputed == 1

* Drop 
drop imputed

* To US territories, we assign the USD exchange rate which is one
local colonies "PRI GUM VIR"

* Loop over every colony
foreach colony of local colonies {
    preserve
		qui drop *_USDfx
        qui keep if ISO3 == "USA"  & inrange(year, 1898, 1959)
        qui replace ISO3 = "`colony'" 
        tempfile usa_early_`colony'
        qui save `usa_early_`colony''
    restore
    
    * Append
    append using `usa_early_`colony''
}

* Sort
sort ISO3 year

* Add the source
qui gen imputed = 0
foreach colony of local colonies {
    qui replace imputed = 1 if ISO3 == "`colony'"
	qui replace source = "Tena" if imputed == 1
}

* Virgin Islands joined the US only in 1917, dropping observations before then
replace USDfx = . if ISO3 == "VIR" & year <= 1917

* Drop 
drop imputed

* Make Ecuador and El Salvador exchange rate equal to 1 
qui replace USDfx = 1 if inlist(ISO3, "ECU", "SLV")

* Save 
save "$data_final/chainlinked_USDfx", replace

}

* Create the log
clear 
set obs 1 
gen variable = "USDfx"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/USDfx_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_USDfx", clear
	replace source = "BIS_USDfx" if source == "BIS"
	gmdmakedoc USDfx, ylabel("USD exchange rate, 1 USD in LCU") transformation("ratio")	
	gen variable = "USDfx"
	gen variable_definition = "USD exchange rate"
	save "$data_final/documentation_USDfx", replace
}

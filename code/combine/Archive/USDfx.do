* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing USD exchange rates 
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

* Open the data
use "$data_final/clean_data_wide", clear

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================
* Drop Zimbabwe values that are unreliable
drop if year >= 2008 & ISO3 == "ZWE"
keep if ISO3 == "VEN"
* Set up the priority list
splice, priority(BIS IMF_IFS OECD_EO WDI ADB AMF CS1 CS2 CS3 BIT BORDO HFS JST Tena MOXLAD MW NBS AHSTAT PWT) generate(USDfx) varname(USDfx) base_year(2018) method("none")

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
local colonies "PRI GUM UMI VIR"

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

* Drop duplicated columns 

* Save 
save "$data_final/chainlinked_USDfx", replace

 
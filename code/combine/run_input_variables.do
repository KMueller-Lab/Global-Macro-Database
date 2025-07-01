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
* Open the data
use "$data_final/clean_data_wide", clear

* Set up the priority list
splice, priority(OECD_EO EUS AMECO WDI UN BCEAO FRANC_ZONE AMF ADB AFDB FAO WDI_ARC OECD_QNA IMF_WEO IMF_IFS CEPAC IMF_GDD CS1 CS2 CS3 MW JST AHSTAT Mitchell BORDO JO MOXLAD NBS GNA HFS FZ Davis IMF_WEO_forecast) generate(nGDP) varname(nGDP) base_year(2019) method("chainlink")


* ==============================================================================
* Population file
* ==============================================================================

* Open the data
use "$data_final/clean_data_wide", clear

* Set up the priority list
splice, priority(WDI OECD_EO ADB IMF_IFS WDI_ARC UN AMECO IMF_WEO CS1 CS2 AHSTAT Gapminder JERVEN MW Tena FZ BORDO JST MD MOXLAD NBS PWT HFS PWT MAD  IMF_WEO_forecast) generate(pop) varname(pop) base_year(2018) method("chainlink")


* ==============================================================================
* USDfx file 
* ==============================================================================

* Open the data
use "$data_final/clean_data_wide", clear

* Drop Zimbabwe values that are unreliable
drop if year >= 2008 & ISO3 == "ZWE"

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

* Save 
save "$data_final/chainlinked_USDfx", replace

 
 * ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
*
* CONSTRUCING USDfx file
* 
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-10-17
*
* ==============================================================================

* Run the master file
do "code/0_master.do"

clear 
 
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
	gmdmakedoc USDfx, ylabel("USD exchange rate, 1 USD in LCU") transformation("ratio")	
	gen variable = "USDfx"
	gen variable_definition = "USD exchange rate"
	save "$data_final/documentation_USDfx", replace
}


* ==============================================================================
* Real GDP in USD file
* ==============================================================================


cap {
	* Open the data
	use "$data_final/chainlinked_rGDP", clear
	keep ISO3 year rGDP

	* Merge with US dollar values
	merge 1:1 ISO3 year using "$data_final/chainlinked_USDfx", nogen keep(3) keepus(USDfx)

	* Merge with nominal GDP values
	merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", nogen keep(3) keepus(nGDP)


	* We derive real gdp in USD following the World Bank methodology
	* First calculate growth rates from constant LCU series
	sort ISO3 year
	by ISO3: gen rgdp_growth_forward = rGDP/rGDP[_n-1] - 1 if year > 2015
	by ISO3: gen rgdp_growth_back = rGDP[_n+1]/rGDP - 1 if year < 2015

	* Calculate nominal gdp in US dollar
	gen nGDP_USD = nGDP / USDfx

	* Get 2015 nominal GDP in USD for each country 
	gen base_2015 = nGDP_USD if year == 2015
	by ISO3: egen gdp_2015_usd = max(base_2015)
	drop base_2015

	* Generate our calculated real GDP series
	gen rGDP_USD = .
	replace rGDP_USD = gdp_2015_usd if year == 2015

	* Forward calculation (2011 onwards)
	sort ISO3 year
	local current_year = 2015
	while `current_year' < $current_year {
		by ISO3: replace rGDP_USD = rGDP_USD[_n-1] * (1 + rgdp_growth_forward) ///
			if year == `current_year' + 1
		local current_year = `current_year' + 1
	}

	* Backward calculation (2009 and earlier)
	local current_year = 2015
	while `current_year' > 1789 {
		by ISO3: replace rGDP_USD = rGDP_USD[_n+1] / (1 + rgdp_growth_back[_n]) ///
			if year == `current_year' - 1
		local current_year = `current_year' - 1
	}

	* Keep only relevant columns
	keep ISO3 year rGDP_USD

	* Save 
	save "$data_final/chainlinked_rGDP_USD", replace
}


* Create the log
clear 
set obs 1 
gen variable = "rGDP_USD"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/rGDP_USD_log.dta", replace

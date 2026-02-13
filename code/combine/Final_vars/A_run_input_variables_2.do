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
* ==============================================================================

* ==============================================================================
* Population file
* ==============================================================================

do "code/0_master.do"

* Open the data
use "$data_final/clean_data_wide", clear

* Set up the priority list
cap splice, priority(OECD_EO ADB WDI AMECO IMF_WEO UN CS1 CS2 AHSTAT Gapminder JERVEN MW Tena FZ BORDO JST WDI_ARC  MD Moxlad NBS PWT HFS PWT Maddison IMF_WEO_forecast) generate(pop) varname(pop) base_year(2018) method("chainlink")

* Create the log
clear 
set obs 1 
gen variable = "pop"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/pop_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_pop", clear
	gmdmakedoc pop, ylabel("Population, millions") transformation("ratio")	
	gen variable = "pop"
	gen variable_definition = "Population"
	save "$data_final/documentation_pop", replace
}

* ==============================================================================
* rGDP file
* ==============================================================================

* ==============================================================================
* 	Derive Real GDP from Maddison using our own population data
* ==============================================================================
* Open 
qui use "${data_clean}/aggregators/Maddison/Maddison.dta", clear

* Merge in the dataset
qui merge 1:1 ISO3 year using "$data_final/chainlinked_pop", nogen keep(1 3) keepus(pop source)
qui drop if source == "Maddison" // Maddison data has a lot of gaps in population, it is reported on a decade basis, thus if we keep if as is, we will have an unrealiable GDP series that has a lot of gaps. 
qui drop source
qui merge 1:1 ISO3 year using "${data_clean}/aggregators/WB/WDI/WDI", nogen keep(1 3) keepus(WDI_rGDP)

* Derive real GDP 
qui gen Maddison_rGDP = Maddison_rGDP_pc_USD * pop
keep ISO3 year Maddison_rGDP WDI_rGDP

* Splice real GDP using WDI, real GDP, and real GDP per capita
qui splice, priority(WDI Maddison) generate(rGDP) varname(rGDP) method("chainlink") base_year(2000) save("NO") 

* Keep only continuous data 
qui sort ISO3 year
qui by ISO3: gen gap = year - year[_n-1] if _n > 1 & rGDP != .
qui keep if gap == 1 & gap[_n+1] == 1 | year == 2022

* Keep
qui keep ISO3 rGDP year WDI_rGDP
qui ren rGDP Maddison_rGDP

* Merge with the clean data 
merge 1:1 ISO3 year using "$data_final/clean_data_wide", nogen 

* ==============================================================================
* 	SPLICE BARRO TOTAL GDP
* ==============================================================================

* Calculate real GDP in Barro based on our population data
qui merge 1:1 ISO3 year using "$data_final/chainlinked_pop", nogen keep(1 3) keepus(pop)
gen BARRO_rGDP = BARRO_rGDP_pc * pop 
drop pop 

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================
* Set up the priority list
qui splice, priority(OECD_EO EUS AMECO WDI UN BCEAO AMF ADB FAO WDI_ARC IMF_WEO IMF_IFS MW CS1 CS2 CS3 JST AHSTAT Mitchell BORDO NBS GNA HFS BG MD BARRO Maddison IMF_WEO_forecast) generate(rGDP) varname(rGDP) base_year(2015) method("chainlink")

* Create the log
clear 
set obs 1 
gen variable = "rGDP"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/rGDP_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_rGDP", clear
	gmdmakedoc rGDP, log ylabel("Real GDP, millions of LCU (Log scale)")	
	gen variable = "rGDP"
	gen variable_definition = "Real GDP"
	save "$data_final/documentation_rGDP", replace
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
	merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", nogen keep(1 3) keepus(nGDP)

	* We derive real gdp in USD following the World Bank methodology
	* First calculate growth rates from constant LCU series
	sort ISO3 year
	by ISO3: gen rgdp_growth_forward = rGDP/rGDP[_n-1] - 1 if year > $base_year
	by ISO3: gen rgdp_growth_back = rGDP[_n+1]/rGDP - 1 if year < $base_year

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

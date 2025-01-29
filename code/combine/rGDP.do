* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCING REAL GDP
* 
* Created: 
* 2024-06-28
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 	
* ==============================================================================


clear

* First run our chainlinked population because we will use later 
do "$code_combine/pop.do"
clear

* Second run WDI because we will use later 
do "$code_clean/aggregators/WDI.do"
clear



* ==============================================================================
* 	Derive Real GDP from Madisson using our own population data
* ==============================================================================
* Open 
use "${data_clean}/aggregators/MAD/Madisson.dta", clear
* Merge in the dataset
merge 1:1 ISO3 year using "$data_final/chainlinked_pop", nogen keep(1 3) keepus(pop source)
drop if source == "MAD"
drop source
merge 1:1 ISO3 year using "${data_clean}/aggregators/WB/WDI", nogen keep(1 3) keepus(WDI_rGDP)
* Derive real GDP 
gen MAD_rGDP = MAD_rGDP_pc_USD * pop

* Splice real GDP using WDI, real GDP, and real GDP per capita
splice, priority(WDI MAD) generate(rGDP) varname(rGDP) method("chainlink") base_year(2000) save("NO") 

* Keep only continuous data 
sort ISO3 year
by ISO3: gen gap = year - year[_n-1] if _n > 1 & rGDP != .
keep if gap == 1 & gap[_n+1] == 1 | year == 2022

* Keep
keep ISO3 rGDP year pop
ren rGDP MAD_rGDP

* Merge with the clean data 
merge 1:1 ISO3 year using "$data_final/clean_data_wide", nogen 

* ==============================================================================
* 	SPLICE BARRO TOTAL GDP
* ==============================================================================
* Merge in the dataset
gen BARRO_rGDP = BARRO_rGDP_pc * pop 
drop pop 


* Rabase all series to the IMF World Economic Outlook
keep ISO3 year *rGDP
recast str3 ISO3, force
qui levelsof ISO3, local(countries)
foreach country of local countries {
	qui ds IMF_WEO_rGDP ISO3 year, not
	foreach var in `r(varlist)'{
		qui su year if `var' != . & ISO3 == "`country'"
		if r(N) > 0 {
			qui su year if IMF_WEO_rGDP != . & `var' != .  & ISO3 == "`country'"
			if r(N) > 0 {
				local min_year = r(min)
				local max_year = r(max)
				qui su IMF_WEO_rGDP if inrange(year, `min_year', `max_year') & ISO3 == "`country'"
				local first_mean  = r(mean)
				qui su `var' if inrange(year, `min_year', `max_year') & ISO3 == "`country'"
				local base_mean = r(mean)
				local ratio = `first_mean' / `base_mean'
				qui replace `var' = `var' * `ratio' if ISO3 == "`country'"
			}
			else {
				di "No overlapping between `var' and WEO"
				* Try with BORDO
				qui su year if BORDO_rGDP != . & `var' != .  & ISO3 == "`country'"
				local min_year = r(min)
				local max_year = r(max)
				su BORDO_rGDP if inrange(year, `min_year', `max_year') & ISO3 == "`country'", meanonly
				local first_mean  = r(mean)
				qui su `var' if inrange(year, `min_year', `max_year') & ISO3 == "`country'", meanonly
				local base_mean = r(mean)
				local ratio = `first_mean' / `base_mean'
				qui replace `var' = `var' * `ratio' if ISO3 == "`country'"
			}
		}
		else {
				di ""
		}
		
	}
}

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================

* Set up the priority list
splice, priority(IMF_WEO BCEAO AMF EUS OECD_EO WDI IMF_IFS WDI_ARC ADB MW UN  FAO AMECO CS1 CS2 CS3 JST BORDO MD NBS GNA AHSTAT BARRO BG MAD Mitchell HFS) generate(rGDP) varname(rGDP) base_year(2018) method("chainlink")


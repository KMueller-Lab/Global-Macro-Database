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
* ==============================================================================
* Run the master file
do "code/0_master.do"

* ==============================================================================
* 	Derive Real GDP from Maddison using our own population data
* ==============================================================================
* Open 
use "${data_clean}/aggregators/Maddison/Maddison.dta", clear

* Merge in the dataset
merge 1:1 ISO3 year using "$data_final/chainlinked_pop", nogen keep(1 3) keepus(pop source)
*drop if source == "MAD" // Madisson data has a lot of gaps in population, it is reported on a decade basis, thus 
drop source
merge 1:1 ISO3 year using "${data_clean}/aggregators/WB/WDI/WDI", nogen keep(1 3) keepus(WDI_rGDP)

* Derive real GDP 
gen Maddison_rGDP = Maddison_rGDP_pc_USD * pop

* Splice real GDP using WDI, real GDP, and real GDP per capita
splice, priority(WDI Maddison) generate(rGDP) varname(rGDP) method("chainlink") base_year(2000) save("NO") 

* Keep only continuous data 
sort ISO3 year
by ISO3: gen gap = year - year[_n-1] if _n > 1 & rGDP != .
keep if gap == 1 & gap[_n+1] == 1 | year == 2022

* Keep
keep ISO3 rGDP year pop
ren rGDP Maddison_rGDP

* Merge with the clean data 
merge 1:1 ISO3 year using "$data_final/clean_data_wide", nogen 

* ==============================================================================
* 	SPLICE BARRO TOTAL GDP
* ==============================================================================

* Calculate real GDP in Barro based on our population data
gen BARRO_rGDP = BARRO_rGDP_pc * pop 
drop pop 

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================

* Set up the priority list
splice, priority(OECD_EO EUS AMECO WDI UN BCEAO AMF ADB FAO WDI_ARC IMF_WEO IMF_IFS MW CS1 CS2 CS3 JST AHSTAT Mitchell BORDO NBS GNA HFS BG MD BARRO Maddison IMF_WEO_forecast) generate(rGDP) varname(rGDP) base_year(2015) method("chainlink")

* Rebase GDP to 2015
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", nogen keep(1 3) keepus(nGDP) 

* Add the deflator
gen deflator = (nGDP / rGDP) * 100

* Loop over all countries
qui levelsof ISO3, local(countries) clean
foreach country of local countries {
	
	* Rebase to 2015
	qui gen  temp = deflator if year == 2015 & ISO3 == "`country'"
	qui egen defl_2015 = max(temp) if ISO3 == "`country'"
	qui replace rGDP = (rGDP * defl_2015) / 100 if ISO3 == "`country'"
	qui drop temp defl_2015	
	
}

* Save 
drop deflator nGDP 
save "$data_final/chainlinked_rGDP", replace


gmdslack, send("`c(username)': The combine file for real GDP has run successfully")

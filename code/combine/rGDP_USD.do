* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* DERIVE SERIES ON REAL GDP IN USD 
* 
* Created: 
* 2024-06-28
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 	
* ==============================================================================

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






* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Description: 
* This Stata script opens and cleans economic data from FAO
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-12-01
* ==============================================================================


* ==============================================================================
* SET UP 
* ==============================================================================
* Clear data 
clear

* Define input and output files
global input "${data_raw}/aggregators/FAO/FAO_macro.xls"
global output "${data_clean}/aggregators/FAO/FAO.dta"

* ==============================================================================
* PROCESS
* ==============================================================================
* Open
import excel using "${input}", clear first

* Keep
keep Area ElementCode Year Value AreaCodeM49 Item

* Rename
ren AreaCodeM49 ISOnum
ren Area countryname
ren Year year

* Destring
destring year ISOnum, replace

* Extract the indicators
gen indicator = ""
replace indicator = "nGDP" if ElementCode == "6224" & Item == "Gross Domestic Product"
replace indicator = "rGDP" if ElementCode == "6225" & Item == "Gross Domestic Product"
replace indicator = "finv"     if ElementCode == "6224" & Item == "Gross Fixed Capital Formation"
drop if indicator == ""
drop ElementCode

* Generate ISO3 codes
merge m:1 ISOnum using $isomapping, keep(1 3) nogen keepus(ISO3)
replace ISO3 = "YMD" if countryname == "Yemen Dem"
replace ISO3 = "YEM" if countryname == "Yemen Ar Rp"
replace ISO3 = "SDN" if countryname == "Sudan (former)" 
replace ISO3 = "ETH" if countryname == "Ethiopia PDR"

* Keep relevant variables
keep ISO3 year Value indicator

* Reshape
greshape wide Value, i(year indicator) j(ISO3)
ren Value* *

* Combine Yemen into modern Yemen
replace YMD = YMD * 26
replace YEM = YEM + YMD if YMD != .
drop YMD

* Rename
qui ds year indicator, not
foreach var in `r(varlist)'{
	ren `var' FAO_`var'
}

* Reshape again
greshape long FAO_, i(year indicator) j(ISO3) string
greshape wide FAO_, i(ISO3 year) j(indicator)


* Convert Venezuela to match UN units
qui ds *finv FAO_nGDP *rGDP
foreach var in `r(varlist)'{
	qui replace `var' = `var' * (10^6) if ISO3 == "VEN"
}

* Add ratios to gdp variables
gen FAO_finv_GDP    = (FAO_finv / FAO_nGDP) * 100

* Add the deflator
gen FAO_deflator = (FAO_nGDP / FAO_rGDP) * 100

* Rebase the GDP to 2010
* Loop over all countries
qui levelsof ISO3, local(countries) clean
foreach country of local countries {
	
	* Rebase to 2010
	qui gen  temp = FAO_deflator if year == 2010 & ISO3 == "`country'"
	qui egen defl_2010 = max(temp) if ISO3 == "`country'"
	qui replace FAO_rGDP = (FAO_rGDP * defl_2010) / 100 if ISO3 == "`country'"
	qui drop temp defl_2010	
}

* Update the deflator
replace FAO_deflator = (FAO_nGDP / FAO_rGDP) * 100



* ==============================================================================
* OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid year ISO3 

* Save
save "${output}", replace

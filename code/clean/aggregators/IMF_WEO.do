* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN INTERNATIONAL MONETARY FUND (IMF) WORLD ECONOMIC OUTLOOK
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-08-06
*
* Description: 
* This Stata script processes the raw IMF WEO data.
*
* Data source: IMF World Economic Outlook
* ==============================================================================

* ==============================================================================
* SET UP
* ==============================================================================
* Clear all
clear

* First run WDI because we will use later 
do "$code_clean/aggregators/WDI.do"
clear


* Define input and output files
global input "$data_raw/aggregators/IMF/WEO_2024Oct.xlsx"
global WDI  "${data_clean}/aggregators/WB/WDI"
global output "${data_clean}/aggregators/IMF/IMF_WEO" 

* ==============================================================================
* PROCESSING
* ==============================================================================
import excel using "$input", clear
drop A D E G H

qui ds B C F I BH, not
foreach var in `r(varlist)'{
	local newname = `var'[1]
	ren `var' IMF_WEO_`newname'
}

ren (B C F I BH) (ISO3 indicator notes country_notes forecast)
drop in 1


* Extract the base year
gen base_year = substr(country_notes, strpos(country_notes, "Base year:") + 11, 5) if indicator == "NGDP_R" & substr(country_notes, strpos(country_notes, "Base year:") + 11, 2) != "FY"
replace base_year = "20" + substr(country_notes, strpos(country_notes, "Base year: FY") + 18, 2) if base_year == "" & indicator == "NGDP_R"

* Drop 
drop notes country_notes

* Drop empty rows
qui ds ISO3 indicator, not
missings dropobs `r(varlist)', force

* Reshape 
greshape long IMF_WEO_, i(ISO3 indicator) j(year) string

* Destring
replace IMF_WEO_ = "" if inlist(IMF_WEO_, "n/a", "--")
destring forecast year base_year IMF_WEO_, replace

* keep relevant indicators
keep if inlist(indicator, "NGDP_R", "NGDPRPC", "NID_NGDP", "PCPI", "TM_RPCH", "TX_RPCH", "LUR", "LP", "GGR_NGDP") | inlist(indicator, "GGXCNL_NGDP", "GGXWDG_NGDP", "BCA_NGDPD", "GGX_NGDP", "NGDP", "NGDPD")


* Reshape wide
greshape wide IMF_WEO_ forecast base_year, i(ISO3 year) j(indicator)

* Rename
ren IMF_WEO_* *
ren (BCA_NGDPD GGXWDG_NGDP GGXCNL_NGDP GGX_NGDP GGR_NGDP LP PCPI LUR NID_NGDP NGDPRPC NGDP_R TM_RPCH TX_RPCH NGDP NGDPD) (CA_GDP govdebt_GDP govdef_GDP govexp_GDP govrev_GDP pop CPI unemp inv_GDP rGDP_pc rGDP imports_yoy exports_yoy nGDP nGDP_USD)
ren forecast* *
ren (BCA_NGDPD GGXWDG_NGDP GGXCNL_NGDP GGX_NGDP GGR_NGDP LP PCPI LUR NID_NGDP NGDPRPC NGDP_R TM_RPCH TX_RPCH NGDP NGDPD) (forecast_CA_GDP forecast_govdebt_GDP forecast_govdef_GDP forecast_govexp_GDP forecast_govrev_GDP forecast_pop forecast_CPI forecast_unemp forecast_inv_GDP forecast_rGDP_pc forecast_rGDP forecast_imports forecast_exports forecast_nGDP forecast_nGDP_USD)
ren base_yearNGDP_R rGDP_base_year

* Drop 
drop base*
ren rGDP_base_year base_year

* Fix countries with mistaken base year. (Assertion is not possible because some countries have the same nGDP and rGDP in different years)
replace base_year = 2022 if ISO3 == "AGO"
replace base_year = 2022 if ISO3 == "HKG"
replace base_year = 2011 if ISO3 == "IND"
replace base_year = 2018 if ISO3 == "LBR"

* Add the deflator
gen deflator = (nGDP / rGDP) * 100

* Rebase the GDP to 2010
* Loop over all countries
qui levelsof ISO3, local(countries) clean
foreach country of local countries {
	
	* Rebase to 2010
	qui gen  temp = deflator if year == 2010 & ISO3 == "`country'"
	qui egen defl_2010 = max(temp) if ISO3 == "`country'"
	qui replace rGDP = (rGDP * defl_2010) / 100 if ISO3 == "`country'"
	qui drop temp defl_2010	
}

* Update the deflator
replace deflator = (nGDP / rGDP) * 100

* Drop 
drop base_year

* Fix countries' ISO3 code
replace ISO3 = "PSE" if ISO3 == "WBG"
replace ISO3 = "XKX" if ISO3 == "UVK"

* Derive trade data using values from WDI (WDI has more trade data than the IMF IFS)
* Import WDI
merge 1:1 ISO3 year using $WDI, keepus(WDI_imports WDI_exports) nogen

* Extend the IMF IFS values using the growth rates of WEO
gen exports = WDI_exports
gen imports = WDI_imports

* Forward calculation
sort ISO3 year
by ISO3: replace exports = exports[_n-1] * (1 + exports_yoy[_n]/100) if missing(WDI_exports) & year > year[_n-1]
by ISO3: replace imports = imports[_n-1] * (1 + imports_yoy[_n]/100) if missing(WDI_imports) & year > year[_n-1]

* Drop columns with growth rates and WDI
drop *yoy WDI*

* Separate forecasts from actual values
qui ds forecast*
foreach var in `r(varlist)'{
	
	* Extract the variable name
	local name = subinstr("`var'", "forecast_", "", .)

	* Assign the values based on the forecast
	qui levelsof ISO3, local(countries) clean
	foreach country of local countries {
		qui su `var' if ISO3 == "`country'", meanonly
		qui replace `var' = `name' if year >= r(mean) & ISO3 == "`country'"
		qui replace `var' = . if year < r(mean) & ISO3 == "`country'"
		qui replace `name' = . if year >= r(mean) & ISO3 == "`country'"
	}
}

* Convert units
replace nGDP = nGDP * 1000
replace rGDP = rGDP * 1000
replace nGDP_USD = nGDP_USD * 1000
replace forecast_nGDP = forecast_nGDP * 1000
replace forecast_rGDP = forecast_rGDP * 1000
replace forecast_nGDP_USD = forecast_nGDP_USD * 1000

* Fix wrong government debt value for Senegal in 1971
gmdfixunits govdebt_GDP if govdebt_GDP == 0.71 & ISO3 == "SEN" & year == 1971, missing
gmdfixunits forecast_govdebt_GDP if forecast_govdebt_GDP == 0.71 & ISO3 == "SEN" & year == 1971, missing

* Fix wrong government debt value for Congo
qui gmdfixunits govdebt_GDP if govdebt_GDP == 0 & ISO3 == "COG", missing
qui gmdfixunits forecast_govdebt_GDP if forecast_govdebt_GDP == 0 & ISO3 == "COG", missing

* Convert units to match those of the UN
ds nGDP rGDP
foreach var in `r(varlist)'{
	replace `var' = `var' * 10^6 if ISO3 == "VEN"
}

* Calculate variable nominal values
gen govexp = (govexp_GDP * nGDP) / 100
gen CA 	   = (CA_GDP * nGDP)     / 100
gen inv    = (inv_GDP * nGDP)    / 100
gen govdef = (govdef_GDP * nGDP) / 100
gen govrev = (govrev_GDP * nGDP) / 100

* Calculate forecast variable nominal values
gen forecast_govexp = (forecast_govexp_GDP * forecast_nGDP) / 100
gen forecast_CA     = (forecast_CA_GDP * forecast_nGDP)     / 100
gen forecast_inv    = (forecast_inv_GDP * forecast_nGDP)    / 100
gen forecast_govdef = (forecast_govdef_GDP * forecast_nGDP) / 100
gen forecast_govrev = (forecast_govrev_GDP * forecast_nGDP) / 100

* Fix MAC government debt values
replace govdebt_GDP = . if ISO3 == "MAC" & govdebt_GDP == 0
replace forecast_govdebt_GDP = . if ISO3 == "MAC" & forecast_govdebt_GDP == 0

* Derive inflation rate
sort ISO3 year
encode ISO3, gen(id)
xtset id year
by id: gen infl = (CPI - L.CPI) / L.CPI * 100 if L.CPI != .
by id: gen forecast_infl = (forecast_CPI - L.forecast_CPI) / L.forecast_CPI * 100 if L.forecast_CPI != .
drop id

* Data for Somalia is in USD but nevertheless differs from other source even if we use the exchange rate to convert it to local currency, so we are keeping only the ratios
ds ISO3 year *_GDP *infl *pop *CPI *unemp forecast*, not
foreach var in `r(varlist)'{
	qui replace `var' = . if ISO3 == "SOM"
}

* Add ratios to gdp variables
gen imports_GDP = (imports / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100

* Add ratios to gdp variables forecasts
gen forecast_imports_GDP = (forecast_imports / forecast_nGDP) * 100
gen forecast_exports_GDP = (forecast_exports / forecast_nGDP) * 100

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	ren `var' IMF_WEO_`var'
}

* Data for Zimbabwe before 2009 is unreliable according to the notes
ds ISO3 year *infl* *CPI* *unemp* *pop *_GDP, not
foreach var in `r(varlist)'{
	replace `var' = . if ISO3 == "ZWE"
}

* Data for Djibouti investment is unreliable
replace IMF_WEO_inv = . if IMF_WEO_inv < 0 & ISO3 == "DJI"
replace IMF_WEO_inv_GDP = . if IMF_WEO_inv_GDP < 0 & ISO3 == "DJI"

replace IMF_WEO_forecast_inv = . if IMF_WEO_forecast_inv < 0 & ISO3 == "DJI"
replace IMF_WEO_forecast_inv_GDP = . if IMF_WEO_forecast_inv_GDP < 0 & ISO3 == "DJI"

* Derive Exchange rate from the data 
gen IMF_WEO_USDfx = IMF_WEO_nGDP / IMF_WEO_nGDP_USD
gen IMF_WEO_forecast_USDfx = IMF_WEO_forecast_nGDP / IMF_WEO_forecast_nGDP_USD

* Add government debt levels from WEO
gen IMF_WEO_govdebt = (IMF_WEO_govdebt_GDP * IMF_WEO_nGDP) / 100
gen IMF_WEO_forecast_govdebt = (IMF_WEO_forecast_govdebt_GDP * IMF_WEO_forecast_nGDP) / 100

* ==============================================================================
* OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace

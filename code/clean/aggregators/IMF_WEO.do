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
global input  "${data_raw}/aggregators/IMF/IMF_WEO"
global WDI  "${data_clean}/aggregators/WB/WDI"
global output "${data_clean}/aggregators/IMF/IMF_WEO" 

* ==============================================================================
* PROCESSING
* ==============================================================================

* Open
use "$input", clear

* Keep relevant columns
keep period value weo_country weo_subject dataset_code

* Drop missing values
drop if value == "NA"

* Keep latest edition of WEO
keep if dataset_code == "WEO:2024-10"
drop dataset_code

* Destring
destring value, replace

* Reshape
greshape wide value, i(period weo_country) j(weo_subject)

* Rename
ren value* *
ren (period weo_country BCA_NGDPD GGXWDG_NGDP GGXCNL_NGDP GGX_NGDP GGR_NGDP LP PCPI LUR NID_NGDP NGDPRPC NGDP_R NGDP TM_RPCH TX_RPCH) (year ISO3 CA_GDP govdebt_GDP govdef_GDP govexp_GDP govrev_GDP pop CPI unemp inv_GDP rGDP_pc rGDP nGDP imports_yoy exports_yoy)

* Drop
drop GGSB_NPGDP

* Fix countries' ISO3 code
replace ISO3 = "PSE" if ISO3 == "WBG"
replace ISO3 = "XKX" if ISO3 == "UVK"

* Convert units
replace nGDP = nGDP * 1000
replace rGDP = rGDP * 1000

* Fix wrong government debt value for Senegal in 1971
gmdfixunits govdebt_GDP if govdebt_GDP == 0.71 & ISO3 == "SEN" & year == 1971, missing

* Fix wrong government debt value for Congo
gmdfixunits govdebt_GDP if govdebt_GDP == 0 & ISO3 == "COG", missing

* Calculate variable nominal values
gen govexp = (govexp_GDP * nGDP) / 100
gen CA 	   = (CA_GDP * nGDP)     / 100
gen inv    = (inv_GDP * nGDP)    / 100
gen govdef = (govdef_GDP * nGDP) / 100
gen govrev = (govrev_GDP * nGDP) / 100

* Fix MAC government debt values
replace govdebt_GDP = . if ISO3 == "MAC" & govdebt_GDP == 0

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

* Derive inflation rate
sort ISO3 year
encode ISO3, gen(id)
xtset id year
by id: gen infl = (CPI - L.CPI) / L.CPI * 100 if L.CPI != .
drop id

* Data for Somalia is in USD but nevertheless differs from other source even if we use the exchange rate to convert it to local currency, so we are keeping only the ratios
ds ISO3 year *_GDP *infl *pop *CPI *unemp, not
foreach var in `r(varlist)'{
	qui gmdfixunits `var' if ISO3 == "SOM", missing
}

* Add ratios to gdp variables
gen imports_GDP = (imports / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	ren `var' IMF_WEO_`var'
}


* Data for Zimbabwe before 2009 is unreliable according to the notes
qui ds ISO3 year *infl *CPI *unemp, not
foreach var in`r(varlist)'{
	gmdfixunits `var' if ISO3 == "ZWE", missing
}

* Data for Djibouti investment is unreliable
replace IMF_WEO_inv = . if IMF_WEO_inv < 0 & ISO3 == "DJI"
replace IMF_WEO_inv_GDP = . if IMF_WEO_inv_GDP < 0 & ISO3 == "DJI"

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

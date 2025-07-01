* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* MAKE TABLE TO COMPARE GMR WITH MAJOR DATASETS: IMF_IFS WB_WDI PWT OECD IMF_WEO EUROSTAT UN GFD (GFD is not included in the current table)
* 
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-10-09
*
* ==============================================================================

* ==============================================================================
* GET RELEVANT INFORMATION ABOUT SOURCES
* ==============================================================================

* Open source sheet
insheet using "${data_helper}/sources.csv", clear names

* Make list of variables in each source 
gen varlist = ""

glevelsof source_abbr, loc(sources)

foreach s of loc sources {
    // Count the number of unique variable abbreviations for the current source
    levelsof varabbr if source_abbr == "`s'", clean 
    local num_vars = r(N) // Store the count of unique variables

    // Replace varlist with the count of variables for the current source
    replace varlist = "`num_vars'" if source_abbr == "`s'"
	* replace varlist = subinstr("`r(levels)'"," ",", ",.) if source_abbr == "`s'"
}

* Drop duplicate sources (in sources.csv, source-variable tuple is unique)
duplicates drop source_abbr, force 

* Only keep relevant columns 
keep source_abbr varlist

* Make placeholder variables for later
foreach var in from from_median to forecasts num_country num_obs{

	gen `var' = ""

}

* Keep only the major dataset
keep if inlist(source_abbr, "IMF_IFS", "WDI", "PWT", "OECD_EO", "IMF_WEO", "EUROSTAT", "UN", "JST", "MAD")

* Save processed data 
tempfile tab_comparison
save `tab_comparison', replace 

* ==============================================================================
* OPEN FULL DATASET, GET START AND END DATES FOR AGGREGATORS
* ==============================================================================

* Store source_abbr for later to loop over
glevelsof source_abbr, loc(sources)

* Use clean_data_wide to identify data availability of each source
qui use "$data_final/clean_data_wide", clear

* Reshape wide to long to get coverage
local allvars
foreach s of loc sources {
    ds `s'*
    local allvars `allvars' `r(varlist)'
}

* Loop through sources to get coverage dates from wide data
foreach s of loc sources {
    * Get all variables for this source
	
    * Drop population variables if they exist
    cap drop `s'_pop
	
    ds `s'*
    local vars `r(varlist)'
	
	preserve
	
	keep `s'* year ISO3

	egen rowmax = rowmax(`s'*)
	drop if rowmax == .


	* Calculate median start year across countries
	bysort ISO3 (year): egen temp_first = min(cond(rowmax!=., year, .))
	qui sum temp_first, detail
	loc from_median_`s' = r(p50)
	drop temp_first

	* Calculate min, max, forecast years
	qui sum year if rowmax!=.
	* find the start date of the entire dataset
	loc from_`s' = r(min)
	* Find the end date of the entire dataset
	loc to_`s' = r(max)
	* Find the forecast years
	loc forecast_`s' = r(max) - ($currdate - 1) // Minus 1 for the current year
	if `forecast_`s'' < 0 {
		loc forecast_`s' = 0
	}
	* Count unique countries for this source
	qui levelsof ISO3 if rowmax!=., local(iso3s)
	loc num_country_`s' = `: word count `iso3s''

	* Count country-year observations
	qui count if rowmax!=.
	loc num_obs_`s' = r(N)

	* Display
	di "Start year for source `s': " `from_`s''
	di "median start year for source `s': " `from_median_`s''
	di "Maximum year for source `s': " `to_`s''
	di "Forecast years for source `s': " `forecast_`s''
	di "Number of countries recorded in `s': " `num_country_`s''
	di "Number of country-year observations in `s': " `num_obs_`s''
	
	restore
}

* Now update the metadata file with the coverage dates
use `tab_comparison', clear
foreach s of loc sources {
    replace from = "`from_`s''" if source_abbr == "`s'"
	replace from_median = "`from_median_`s''" if source_abbr == "`s'"
    replace to = "`to_`s''" if source_abbr == "`s'"
    replace forecasts = "`forecast_`s''" if source_abbr == "`s'"
	replace num_country = "`num_country_`s''" if source_abbr == "`s'"
	replace num_obs = "`num_obs_`s''" if source_abbr == "`s'"
}
save `tab_comparison', replace

* ==============================================================================
* ADD GFD dataset into the table
* ==============================================================================
qui use "$data_helper/GFD_processed", clear
gen GFD_govdef = GFD_govdef_GDP * GFD_nGDP
gen GFD_govdebt = GFD_govdebt_GDP * GFD_nGDP
gen GFD_govexp_GDP = GFD_govexp / GFD_nGDP
gen GFD_govrev_GDP = GFD_govrev / GFD_nGDP
gen GFD_govtax_GDP = GFD_govtax / GFD_nGDP
gen GFD_imports_GDP = GFD_imports / GFD_nGDP
gen GFD_exports_GDP = GFD_exports / GFD_nGDP
gen GFD_CA = GFD_CA_GDP * GFD_nGDP
gen GFD_finv_GDP = GFD_finv / GFD_nGDP
gen GFD_inv_GDP = GFD_inv / GFD_nGDP
gen GFD_rGDP_pc = GFD_rGDP / GFD_pop

ds ISO3 year, not
loc varlist `r(varlist)'

egen rowmax = rowmax(`varlist')
drop if missing(rowmax)

* Calculate median start year across countries
bysort ISO3 (year): egen temp_first = min(cond(rowmax!=., year, .))
qui sum temp_first, detail
loc from_median_GFD = r(p50)
drop temp_first

* Calculate min, max, forecast years
qui sum year if rowmax!=.

* Find the start date of the entire dataset
loc from_GFD = r(min)

* Find the end date of the entire dataset
loc to_GFD = r(max)

* Find the forecast years
loc forecast_GFD = r(max) - ($currdate - 1) // Minus 1 for the current year
if `forecast_GFD' < 0 {
	loc forecast_GFD = 0
}

* Count unique countries for this source
qui levelsof ISO3 if rowmax!=., local(iso3s)
loc num_country_GFD = `: word count `iso3s''

* Count country-year observations
qui count if rowmax!=.
loc num_obs_GFD = r(N)

* Display
di "Start year for source GFD: " `from_GFD'
di "median start year for source GFD: " `from_median_GFD'
di "Maximum year for source GFD: " `to_GFD'
di "Forecast years for source GFD: " `forecast_GFD'
di "Number of countries recorded in GFD: " `num_country_GFD'
di "Number of country-year observations in GFD: " `num_obs_GFD'

* Count number of variables 
describe GFD*, simple
local num_vars_GFD = r(k) 
clear
set obs 1 

* Fill in GFD data
gen source_abbr = "GFD"
gen from = "`from_GFD'" 
gen from_median = "`from_median_GFD'" 
gen to = "`to_GFD'" 
gen forecasts = "`forecast_GFD'" 
gen num_country = "`num_country_GFD'" 
gen num_obs = "`num_obs_GFD'" 
gen varlist = "`num_vars_GFD'"
append using `tab_comparison'
save `tab_comparison', replace

* ==============================================================================
* ADD GMD dataset into the table
* ==============================================================================

* Identify data availability of each source
qui use "$data_final/data_final", clear
drop countryname id
ds ISO3 year, not
loc varlist `r(varlist)'
local num_vars_GMD: word count `r(varlist)'

egen rowmax = rowmax(`varlist')
drop if missing(rowmax)

* Calculate median start year across countries
bysort ISO3 (year): egen temp_first = min(cond(rowmax!=., year, .))
qui sum temp_first, detail
loc from_median_GMD = r(p50)
drop temp_first

* Calculate min, max, forecast years
qui sum year if rowmax!=.

* Find the start date of the entire dataset
loc from_GMD = r(min)

* Find the end date of the entire dataset
loc to_GMD = r(max)

* Find the forecast years
loc forecast_GMD = r(max) - ($currdate - 1) // Minus 1 for the current year
if `forecast_GMD' < 0 {
	loc forecast_GMD = 0
}

* Count unique countries for this source
qui levelsof ISO3 if rowmax!=., local(iso3s)
loc num_country_GMD = `: word count `iso3s''

* Count country-year observations
qui count if rowmax!=.
loc num_obs_GMD = r(N)

* Display
di "Start year for source GMD: " `from_GMD'
di "median start year for source GMD: " `from_median_GMD'
di "Maximum year for source GMD: " `to_GMD'
di "Forecast years for source GMD: " `forecast_GMD'
di "Number of countries recorded in GMD: " `num_country_GMD'
di "Number of country-year observations in GMD: " `num_obs_GMD'
di "Number of variables in GMD: " `num_vars_GMD'

use `tab_comparison', clear

* Create placeholder for GMD, and make GMD the first observation
gen temp_order = _n + 1
set obs `=_N + 1'
replace source_abbr = "GMD" in `=_N'
replace temp_order = 1 if source_abbr == "GMD"
sort temp_order
drop temp_order

* Fill in GMD data
replace from = "`from_GMD'" if source_abbr == "GMD"
replace from_median = "`from_median_GMD'" if source_abbr == "GMD"
replace to = "`to_GMD'" if source_abbr == "GMD"
replace forecasts = "`forecast_GMD'" if source_abbr == "GMD"
replace num_country = "`num_country_GMD'" if source_abbr == "GMD"
replace num_obs = "`num_obs_GMD'" if source_abbr == "GMD"
replace varlist = "`num_vars_GMD'" if source_abbr == "GMD"


* ==============================================================================
* CALCULATE ACTUAL YEAR
* ==============================================================================
destring to, replace
destring forecast, replace
gen to_actual = to - forecasts
ren to to_forecast
drop forecast

* Set forecast to missing if they don't exist
replace to_forecast = . if to_forecast <= 2024
tostring to_forecast, replace
replace to_forecast = "---" if to_forecast == "."

tostring to_actual, replace

* ==============================================================================
* MERGE TOGETHER RELEVANT INFORMATION, FORMAT TABLE 
* ==============================================================================
order source_abbr from from_median to_actual to_forecast num_country num_obs varlist

* Add citation style to the title
replace source_abbr = "\citetalias{" + source_abbr + "}" if source_abbr != "GMD"

* Add thousand separator
gen x = strlen(num_obs)
gen y = ""
replace y = substr(num_obs, 1, 1) + "," + substr(num_obs, 2, .) if x == 4
replace y = substr(num_obs, 1, 2) + "," + substr(num_obs, 3, .) if x == 5
drop num_obs x
ren y num_obs 
order source_abbr from from_median to_actual to_forecast num_country num_obs varlist

* Export into LaTeX
gmdwriterows *, path("${tables}/tab_comparison.tex")

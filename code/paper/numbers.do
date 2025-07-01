* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* PRODUCE NUMBERS FOR MANUSCRIPT
* 
* Description: 
* This Stata script produces various numbers reported in the manuscript.
*
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-10-04
*
* ==============================================================================

* ==============================================================================
* NUMBERS RELATING TO NUMBER OF SOURCES AND VARIABLES USED
* ==============================================================================

* Open source sheet
use "${data_final}/data_final.dta", clear

* Number of variables
ds ISO3 year countryname id, not
loc varlist `r(varlist)'
local num_vars_GMD: word count `r(varlist)'
data_export `num_vars_GMD', name(number_variables_final) whole


* Number of variables excluding ratios
drop *_GDP
ds ISO3 year countryname id, not
loc varlist `r(varlist)'
local num_vars_GMD: word count `r(varlist)'
data_export `num_vars_GMD', name(number_variables) whole


* ==============================================================================
* NUMBER OF AGGREGATORS AND COUNTRY-SPECIFIC SOURCES 
* ==============================================================================

* Get number of aggregators 
filelist, directory($code_clean/aggregators) 
drop if strpos(dirname, "aggregators/Mitchell")
unique filename 
loc number_aggregators `r(unique)'
data_export `number_aggregators', name(number_aggregators) whole

* Get number of country-specific sources
filelist, directory($code_clean/country_level) 
drop if strpos(dirname, "Versions")
unique filename
loc number_countryspecific `r(N)'
data_export `number_countryspecific', name(number_countryspecific) whole

* Calculate total number 
loc number_sources = `number_countryspecific' + `number_aggregators'
data_export `number_sources', name(number_sources) whole

* Get number of current and historical aggregators  
filelist, directory($code_download/aggregators) 
count 
local number_sources_current_aggr = `r(N)'
local number_sources_historical_aggr = `number_aggregators' - `number_sources_current_aggr'
data_export `number_sources_current_aggr', name(number_sources_current_aggr) whole
data_export `number_sources_historical_aggr', name(number_sources_historical_aggr) whole

* Get number of current and historical country-specific sources 
filelist, directory($code_download/country_level) 
drop if regexm(filename,".stswp")
replace filename = subinstr(filename,".do","",.)
count 
local number_current_countryspecific = `r(N)'
local number_historical_countryspec = `number_countryspecific' - `number_current_countryspecific'
data_export `number_current_countryspecific', name(number_current_countryspecific) whole
data_export `number_historical_countryspec', name(number_historical_countryspec) whole

* Calculate total number of current and historical sources 
local number_current = `number_current_countryspecific' + `number_sources_current_aggr'
data_export `number_current', name(number_current) whole

local number_historical = `number_historical_countryspec' + `number_sources_historical_aggr'
data_export `number_historical', name(number_historical) whole


* ==============================================================================
* NUMBERS RELATING TO COVERAGE OF FINAL DATASET 
* ==============================================================================

* Open cleaned file
use "$data_final/data_final", clear
qui ds ISO3 year countryname id, not
qui missings dropobs `r(varlist)', force

* First year in data 
sum year 
data_export `r(min)', name(year_start) round(1)

* Latest year in data 
sum year 
data_export `r(max)', name(year_end_forecasts) round(1)

* Latest year in data that is not a forecast
sum year if year<$currdate
data_export `r(max)', name(year_end) round(1)

* Number of countries 
unique ISO3
data_export `r(unique)', name(number_countries) whole


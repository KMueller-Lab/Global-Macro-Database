* ==============================================================================
* Global Macro DATABASE
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
*
* MAKE TABLE WITH A FULL LIST OF SOURCES 
* 
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-10-09
*
* ==============================================================================

* ==============================================================================
* GET RELEVANT INFORMATION FROM SOURCES.CSV
* ==============================================================================

* Open source sheet 
insheet using "${data_helper}/sources.csv", clear names


* Make list of variables in each source 
gen varlist = ""
drop if source_abbr == "IDCM"
glevelsof source_abbr, loc(sources)

foreach s of loc sources {

    // Count the number of unique variable abbreviations for the current source
    levelsof varabbr if source_abbr == "`s'", clean 
    local num_vars = r(N) // Store the count of unique variables

    // Replace varlist with the count of variables for the current source
    replace varlist = "`num_vars'" if source_abbr == "`s'"
}

* Drop duplicate sources (in sources.csv, source-variable tuple is unique)
duplicates drop source_abbr, force 

* Only keep relevant columns 
keep source_abbr download_date digitized varlist country_specific historical

* Make placeholder variables for later
foreach var in from to forecasts num_country source{

	gen `var' = ""

}

* Save processed data 
tempfile tab_no_sources_meta
save `tab_no_sources_meta', replace 

* ==============================================================================
* OPEN FULL DATASET, GET START AND END DATES FOR AGGREGATORS
* ==============================================================================

* Store source_abbr for later to loop over
glevelsof source_abbr if country_specific == "No", loc(sources)

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
    ds `s'*
    local vars `r(varlist)'
	
	preserve
	
	keep `s'* year ISO3

	egen rowmax = rowmax(`s'*)
	drop if rowmax == .

	// Calculate min, max, forecast years
	qui sum year if rowmax!=.
	loc from_`s' = r(min)
	loc to_`s' = r(max)
	loc forecast_`s' = r(max) - ($currdate - 1) // Minus 1 for the current year
	if `forecast_`s'' < 0 {
		loc forecast_`s' = 0
	}
	* Count unique countries for this source
	qui levelsof ISO3 if rowmax!=., local(iso3s)
	loc num_country_`s' = `: word count `iso3s''

	di "Minimum year for source `s': " `from_`s''
	di "Maximum year for source `s': " `to_`s''
	di "Forecast years for source `s': " `forecast_`s''
	di "Number of countries recorded in `s': " `num_country_`s''
	
	restore
}

* Now update the metadata file with the coverage dates
use `tab_no_sources_meta', clear
foreach s of loc sources {
    replace from = "`from_`s''" if source_abbr == "`s'"
    replace to = "`to_`s''" if source_abbr == "`s'"
    replace forecasts = "`forecast_`s''" if source_abbr == "`s'"
	replace num_country = "`num_country_`s''" if source_abbr == "`s'"
	
}
save `tab_no_sources_meta', replace

*
* ==============================================================================
* OPEN FULL DATASET, GET START AND END DATES FOR COUNTRY_SPECIFIC SOURCES
* ==============================================================================

* Store source_abbr for later to loop over
glevelsof source_abbr if country_specific == "Yes", loc(sources)

* Use clean_data_wide to identify data availability of each source
qui use "$data_final/clean_data_wide", clear

* Loop through sources to get coverage dates from wide data
foreach s of loc sources {
	
    * Extract ISO3 and CS number from source
    local iso3 = substr("`s'", 1, 3)
    local csnum = "CS" + substr("`s'", 5, .)
    
    * Get all variables for this source
    ds `csnum'*
    local vars `r(varlist)'
	
	preserve
	
	keep `csnum'* year ISO3 
	keep if ISO3 == "`iso3'"

	egen rowmax = rowmax(`csnum'*)
	drop if rowmax == .

	// Calculate min, max, forecast years
	qui sum year if rowmax!=.
	loc from_`s' = r(min)
	loc to_`s' = r(max)
	loc forecast_`s' = r(max) - ($currdate - 1) // Minus 1 for the current year
	if `forecast_`s'' < 0 {
		loc forecast_`s' = 0
	}
	* Count unique countries for this source
	loc num_country_`s' = 1

	di "Minimum year for source `s': " `from_`s''
	di "Maximum year for source `s': " `to_`s''
	di "Forecast years for source `s': " `forecast_`s''
	di "Number of countries recorded in `s': " `num_country_`s''
	
	restore
}

* Now update the metadata file with the coverage dates
use `tab_no_sources_meta', clear
foreach s of loc sources {
    replace from = "`from_`s''" if source_abbr == "`s'"
    replace to = "`to_`s''" if source_abbr == "`s'"
    replace forecasts = "`forecast_`s''" if source_abbr == "`s'"
	replace num_country = "`num_country_`s''" if source_abbr == "`s'"
	
}
save `tab_no_sources_meta', replace

* ==============================================================================
* Merge Download Date
* ==============================================================================
ren download_date download_date_bis
merge m:1 source_abbr using "${data_temp}/download_dates.dta"
replace download_date_bis = download_date if _merge == 3 
drop download_date _merge
ren download_date_bis download_date

* ==============================================================================
* MERGE TOGETHER RELEVANT INFORMATION, FORMAT TABLE 
* ==============================================================================
sort country_specific source_abbr
drop country_specific
gen row_num = _n
gen dataset = ""
order row_num source_abbr dataset download_date digitized from to forecasts varlist num_country

* Format table 
* Make everything into pretty strings
* format num %03.2f
tostring row_num digitized, usedisplayformat replace force
replace digitized = "" if digitized == "."
replace download_date = "" if download_date == "."

order row_num source_abbr dataset download_date digitized from to forecasts varlist num_country

* Drop
drop row_num dataset
drop if source_abbr == "IDCM"

* Add source citation 
replace source = "\citet{" + source_abbr + "}"

* Add source alias citation
replace source_abbr = "\citetalias{" + source_abbr + "}"

order source source_abbr download_date digitized from to forecast varlist num_country historical

* Plot forecasts as "---" if no forecasts for readability
replace forecasts = "---" if forecasts == "0"

* Export into LaTeX
gmdwriterows *, path("${tables}/tab_no_sources.tex")
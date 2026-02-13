* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* MERGE CLEANED DATASETS
* 
* Description: 
* This Stata program merges all cleaned input files together so that they can be
* processed further and used to construct harmonized long-run time series.

* Requirements:
* Input data from folder ../..data/clean
* List of variables from 
*
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 
* 2024-04-21
*
* ==============================================================================
* MAKE A BLANK COUNTRY-YEAR PANEL 
* ==============================================================================

* Open master list of countries 
use "$data_helper/countrylist", clear 

* Only keep ISO code 
keep ISO3 

* Set dates 
loc diff = $maxdate - $mindate

* Expand 
expand `diff'

* Make panel 
bysort ISO3: gen year = $mindate + _n

* Save 
save "$data_temp/blank_panel", replace




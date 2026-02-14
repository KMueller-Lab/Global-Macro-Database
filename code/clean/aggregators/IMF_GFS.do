* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-12
* 
* Description: 
* This Stata script cleans Government Finance Statistics from the IMF
*
* Data source: International Monetary Fund
* 
* 
* ==============================================================================
*
* ==============================================================================
*	SET UP
* ==============================================================================
* Clear all
clear 

* Define input and output files
global input "${data_raw}/aggregators/IMF/IMF_GFS/IMF_GFS.csv"
global output "${data_clean}/aggregators/IMF/IMF_GFS/IMF_GFS.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================
* Open
import delimited "$input", clear

* Add variables 
replace type_of_transformation  = "_GDP" if type_of_transformation  == "POGDP_PT"
replace type_of_transformation  = "" 	 if type_of_transformation  == "XDC"

replace indicator = "govtax" if indicator == "G11_T"
replace indicator = "govrev" if indicator == "G1_T"
replace indicator = "govexp" if indicator == "G2_T"
replace indicator = "govdef" if indicator == "GNLB_T"

replace sector = "c" if sector == "S1311"
replace sector = "gen_" if sector == "S13"

gen varname = sector + indicator + type_of_transformation


* Keep final variables
keep varname country time_period scale obs_value 

* Destring 
destring scale obs_value, replace ignore("NA")

* Convert units 
replace obs_value = obs_value / 10^6 if scale == 6
replace obs_value = obs_value / 10^6 if scale == 9
replace obs_value = obs_value / 10^6 if scale == 12

* Rename
ren(country time_period obs_value) (ISO3 year IMF_GFS_)
drop scale 

* Reshape 
greshape wide IMF_GFS_, i(ISO3 year) j(varname)

* Drop rows with no data 
qui ds ISO3 year, not
qui missings dropobs `r(varlist)', force 

* Fix ISO3 codes 
replace ISO3 = "PSE" if ISO3 == "WBG"
replace ISO3 = "XKX" if ISO3 == "KOS"

* Drop all data for Congo democratic republic 
drop if ISO3 == "COD"

* Drop wrong value for Mauritius
drop if ISO3 == "MUS" & year == 2015

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace

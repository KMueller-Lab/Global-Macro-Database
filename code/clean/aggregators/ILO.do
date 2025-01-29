* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and cleans data from international labor organization (ILO)
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-10-14
*
* URL: https://ilostat.ilo.org/topics/unemployment-and-labour-underutilization/
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
clear
global input "${data_raw}/aggregators/ILO/ILO"
global output "${data_clean}/aggregators/ILO/ILO.dta"

* ===============================================================================
*	PROCESS
* ===============================================================================

* Open
use $input, clear

* Keep unemployment for total population 
keep if sex_label == "Sex: Total"
keep if classif1_label == "Age (Youth, adults): 15+"

* Add common indicator 
gen indicator =  strtrim(substr(source_label , 1, strpos(source_label, "-")-1))

* Keep 
keep ref_area indicator obs_value time

* Destring 
destring time, replace

* Reshape
greshape wide obs_value, i(time ref_area) j(indicator)
ren obs_value* *



* Add ISO3 code
ren ref_area countryname

* Fix country names
replace countryname = "Cape Verde" if countryname == "Cabo Verde"
replace countryname = "Bolivia" if countryname == "Bolivia (Plurinational State of)"
replace countryname = "Brunei" if countryname == "Brunei Darussalam"
replace countryname = "Republic of the Congo" if countryname == "Congo"
replace countryname = "Democratic Republic of the Congo" if countryname == "Congo, Democratic Republic of the"
replace countryname = "Czech Republic" if countryname == "Czechia"
replace countryname = "Ivory Coast" if countryname == "Côte d'Ivoire"
replace countryname = "Hong Kong" if countryname == "Hong Kong, China"
replace countryname = "Iran" if countryname == "Iran (Islamic Republic of)"
replace countryname = "Laos" if countryname == "Lao People's Democratic Republic"
replace countryname = "Macau" if countryname == "Macao, China"
replace countryname = "Macedonia" if countryname == "North Macedonia"
replace countryname = "Syria" if countryname == "Syrian Arab Republic"
replace countryname = "Taiwan" if countryname == "Taiwan, China"
replace countryname = "Tanzania" if countryname == "Tanzania, United Republic of"
replace countryname = "Turkey" if countryname == "Türkiye"
replace countryname = "United Kingdom" if countryname == "United Kingdom of Great Britain and Northern Ireland"
replace countryname = "United States" if countryname == "United States of America"
replace countryname = "Venezuela" if countryname == "Venezuela (Bolivarian Republic of)"
replace countryname = "Vietnam" if countryname == "Viet Nam"

* Merge the country names list
merge m:1 countryname using $isomapping, keep(3) keepus(ISO3)

* Add unemployment column
egen unemp = rowmax(HIES HS ILO LFS OE PC)

* Keep 
keep unemp time ISO3

* Rename
ren (time unemp) (year ILO_unemp)


* ===============================================================================
* 	Output
* ===============================================================================

* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace

* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Description: 
* This Stata script reads in and clean historical debt statistics from the IMF
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 16-06-2024
*
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
* Clear panel
clear

* Define input and output files
global input "${data_raw}/aggregators/IMF/IMF_HDD.xls"
global output "${data_clean}/aggregators/IMF/IMF_HDD.dta"
* ==============================================================================
* 	PROCESS
* ==============================================================================
import excel using "$input", clear allstring sheet(DEBT1) 

* Drop row with no data 
drop in 2

* Replace NA indicator (no data) by empty space
qui ds
foreach var in `r(varlist)'{
	replace `var' = "" if  `var' == "no data"
}

* Set columns names as the first row
qui ds A, not
foreach var in `r(varlist)' {
    local newname = `var'[1]
    capture ren `var' yeardate_`newname'
}

* Drop row with no data
drop in 1
drop in 189/l

* Reshape
greshape long yeardate_, i(A) j(year) string

* Rename columns
ren yeardate_ GOVDEBT_GDP
ren A countryname
destring year GOVDEBT_GDP, replace

* Fix country names
replace countryname = "Bahamas" 							if countryname == "Bahamas, The"
replace countryname = "Brunei" 								if countryname == "Brunei Darussalam"
replace countryname = "Cape Verde" 							if countryname == "Cabo Verde"
replace countryname = "China" 								if countryname == "China, People's Republic of"
replace countryname = "Democratic Republic of the Congo"    if countryname == "Congo, Dem. Rep. of the"
replace countryname = "Republic of the Congo"				if countryname == "Congo, Republic of " 
replace countryname = "Ivory Coast" 						if countryname == "Côte d'Ivoire"
replace countryname = "Gambia" 								if countryname == "Gambia, The"
replace countryname = "Hong Kong" 							if countryname == "Hong Kong SAR"
replace countryname = "South Korea"							if countryname == "Korea, Republic of"
replace countryname = "Kyrgyzstan" 							if countryname == "Kyrgyz Republic"
replace countryname = "Laos"								if countryname == "Lao P.D.R."
replace countryname = "Micronesia (Federated States of)"	if countryname == "Micronesia, Fed. States of"
replace countryname = "Macedonia" 							if countryname == "North Macedonia "
replace countryname = "Slovakia" 							if countryname == "Slovak Republic"
replace countryname = "South Sudan" 						if countryname == "South Sudan, Republic of"
replace countryname = "Sao Tome and Principe"				if countryname == "São Tomé and Príncipe"
replace countryname = "Taiwan" 								if countryname == "Taiwan Province of China"
replace countryname = "Turkey" 								if countryname == "Türkiye, Republic of"

* Get ISO3 names
merge m:1 countryname using $isomapping
drop if year == .

* Order
order ISO3 year GOVDEBT_GDP

* Keep needed variables
keep ISO3 year GOVDEBT_GDP

* Rename 
ren GOVDEBT_GDP IMF_HDD_govdebt_GDP

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

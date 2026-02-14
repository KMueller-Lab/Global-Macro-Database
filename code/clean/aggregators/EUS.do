* ==============================================================================
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2025-03-26
*
* Description: 
* This Stata script downloads economic data from Eurostat
*
* Data source:
* Eurostat API
*
* ==============================================================================
* Define input and output files 
clear
global input "${data_raw}/aggregators/EUS"
global output "${data_clean}/aggregators/EUS/EUS.dta"

* ==============================================================================
* 	PROCESS EACH DATA SET APART
* ==============================================================================

* ==============================================================================
*   HICP
* ============================================================================== 
* Open 
use "$input/CPI.dta", clear

* Add indicator 
generat indicator = "CPI" if unit == "INX_A_AVG"
replace indicator = "infl" if unit == "RCH_A_AVG"

* Keep necessary columns
keep geo time_period obs_value indicator

* Save
tempfile temp_master
save `temp_master', replace 

* ==============================================================================
*   House price index (2015 = 100) - annual data (prc_hpi_a)	
* ============================================================================== 

* Open 
use "$input/HPI_A.dta", clear

* Keep necessary columns
keep geo time_period obs_value 

* Add indicator 
gen indicator = "HPI"

* Save 
merge 1:1 geo time_period indicator using `temp_master', nogen assert(1 2) 
save `temp_master', replace

* ==============================================================================
*   Unemployment
* ============================================================================== 

* Open 
use "$input/unemp.dta", clear

* Keep total population 
keep if age == "Y15-74"

* Keep necessary columns
keep geo time_period obs_value 

* Add indicator 
gen indicator = "unemp"

* Save 
merge 1:1 geo time_period indicator using `temp_master', nogen assert(1 2) 
save `temp_master', replace

* ==============================================================================
*   Government bond yields, 10 years' maturity
* ============================================================================== 

* Open 
use "$input/ltrate_1.dta", clear

* Add indicator 
generate indicator = "ltrate"

* Keep necessary columns
keep geo time_period obs_value  indicator

* Save 
merge 1:1 geo time_period indicator using `temp_master', nogen assert(1 2) 
save `temp_master', replace

* ==============================================================================
*   Central government bond yields 	
* ============================================================================== 

* Open 
use "$input/ltrate_2.dta", clear

* Add indicator 
generate indicator = "ltrate"

* Keep necessary columns
keep geo time_period obs_value  indicator

* Save 
merge 1:1 geo time_period indicator using `temp_master', update nogen
save `temp_master', replace

* ==============================================================================
*   Central government bond yields 	
* ============================================================================== 

* Open 
use "$input/ltrate_3.dta", clear

* Add indicator 
generate indicator = "ltrate"

* Keep necessary columns
keep geo time_period obs_value  indicator

* Save 
merge 1:1 geo time_period indicator using `temp_master', update nogen
save `temp_master', replace

* ==============================================================================
*   Effective exchange rates indices 
* ============================================================================== 

* Open 
use "$input/EER.dta", clear

* Add indicator 
generat indicator = "REER"

* Keep necessary columns
keep geo time_period obs_value  indicator

* Save 
merge 1:1 geo time_period indicator using `temp_master', nogen assert(1 2) 
save `temp_master', replace

* ==============================================================================
*   Gross domestic product (GDP) and main components (output, expenditure and income) (nama_10_gdp) 
* ============================================================================== 

* Open 
use "$input/NA_A.dta", clear

* Add indicator 
generat indicator = "nGDP" 		 if na_item == "B1GQ" 			& unit == "CP_MNAC"
replace indicator = "rGDP" 	     if na_item == "B1GQ" 			& unit == "CLV15_MNAC"
replace indicator = "cons" 		 if na_item == "P3"
replace indicator = "inv" 		 if na_item == "P5G"
replace indicator = "finv" 		 if na_item == "P51G"
replace indicator = "exports" 	 if na_item == "P6"
replace indicator = "imports" 	 if na_item == "P7"

* Drop chain linked volumes for all variables except real GDP
drop if unit == "CLV15_MNAC" & indicator != "rGDP"

* Keep necessary columns
keep geo time_period obs_value indicator

* Save 
merge 1:1 geo time_period indicator using `temp_master', nogen assert(1 2) 
save `temp_master', replace

* ==============================================================================
*   Government revenue, expenditure and main aggregates (gov_10a_main) 
* ============================================================================== 

* Open 
use "$input/GFS_A.dta", clear

* Add indicator for both central and general government
generat indicator = ""
replace indicator = "gen_govexp_GDP" 	 if na_item == "TE"  & sector == "S13"   & unit == "PC_GDP"
replace indicator = "gen_govdef_GDP" 	 if na_item == "B9"  & sector == "S13"   & unit == "PC_GDP"
replace indicator = "gen_govrev_GDP" 	 if na_item == "TR"  & sector == "S13"   & unit == "PC_GDP"
replace indicator = "cgovexp_GDP" 	 if na_item == "TE"  & sector == "S1311"   & unit == "PC_GDP"
replace indicator = "cgovdef_GDP" 	 if na_item == "B9"  & sector == "S1311"   & unit == "PC_GDP"
replace indicator = "cgovrev_GDP" 	 if na_item == "TR"  & sector == "S1311"   & unit == "PC_GDP"
drop if indicator == ""

* Keep necessary columns
keep geo time_period obs_value indicator


* Save 
merge 1:1 geo time_period indicator using `temp_master', nogen assert(1 2) 
save `temp_master', replace

* ==============================================================================
*  Main national accounts tax aggregates (gov_10a_taxag)	
* ============================================================================== 

* Open 
use "$input/govtax.dta", clear

* Add indicator 
generat indicator = ""
replace indicator = "gen_govtax_GDP" 	 if na_item == "D2_D5_D91_D61_M_D995"  & sector == "S13"
replace indicator = "cgovtax_GDP" 	 if na_item == "D2_D5_D91_D61_M_D995"  & sector == "S1311"
drop if indicator == ""

* Keep necessary columns
keep geo time_period obs_value indicator

* Save 
merge 1:1 geo time_period indicator using `temp_master', nogen assert(1 2) 
save `temp_master', replace

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Reshape into wide format
greshape wide obs_value, i(geo time_period) j(indicator)

* Rename
ren(geo time_period obs_value*) (ISO2 year EUS_*)

* Fix country name column
replace ISO2 = "GR" if ISO2 == "EL"
replace ISO2 = "GB" if ISO2 == "UK"

* Drop regional aggrates 
drop if regexm(ISO2, "[0-9]") | inlist(ISO2, "EEA", "EU", "EA")

* Derive ISO3
merge m:1 ISO2 using $isomapping, keepus(ISO3) assert(2 3) keep(3) nogen
drop ISO2 

* Derive government finances levels
gen EUS_gen_govrev = (EUS_gen_govrev_GDP * EUS_nGDP) / 100
gen EUS_gen_govdef = (EUS_gen_govdef_GDP * EUS_nGDP) / 100
gen EUS_gen_govtax = (EUS_gen_govtax_GDP * EUS_nGDP) / 100
gen EUS_gen_govexp = (EUS_gen_govexp_GDP * EUS_nGDP) / 100
gen EUS_cgovrev    = (EUS_cgovrev_GDP * EUS_nGDP) / 100
gen EUS_cgovtax    = (EUS_cgovtax_GDP * EUS_nGDP) / 100
gen EUS_cgovexp    = (EUS_cgovexp_GDP * EUS_nGDP) / 100
gen EUS_cgovdef    = (EUS_cgovdef_GDP * EUS_nGDP) / 100


* Derive varibles ratio to GDP 
gen EUS_cons_GDP = (EUS_cons / EUS_nGDP) * 100
gen EUS_inv_GDP  = (EUS_inv / EUS_nGDP) * 100
gen EUS_finv_GDP = (EUS_finv / EUS_nGDP) * 100
gen EUS_imports_GDP = (EUS_imports / EUS_nGDP) * 100
gen EUS_exports_GDP = (EUS_exports / EUS_nGDP) * 100

tempfile temp 
save `temp', replace 

* ==============================================================================
*  Historical unemployment data 
* ============================================================================== 

* Open the data
import excel using "$input/unemp.xlsx", clear sheet("Sheet 1")

* Drop the documentation rows 
drop in 1/9
drop in 2/7
drop in 38/l
qui ds A, not
foreach var in `r(varlist)' {
	local newname = `var'[1]
	ren `var' EUS_unemp1`newname'
}
drop in 1 

* Reshape 
greshape long EUS_unemp1, i(A) j(year) string

* Destring 
destring year EUS_unemp1, ignore(":") replace 

* Add ISO3 
ren A countryname
merge m:1 countryname using "$isomapping", keep(1 3) keepus(ISO3) 
replace ISO3 = "CZE" if countryname == "Czechia"
replace ISO3 = "MKD" if countryname == "North Macedonia"
replace ISO3 = "TUR" if countryname == "Türkiye"
drop if ISO3 == ""
drop _merge countryname 

merge 1:1 ISO3 year using `temp', nogen 

* Adjust unemployment data 
gen ratio = .
order *ratio 
levelsof ISO3 if EUS_unemp != . & EUS_unemp1 != ., local(countries) clean
foreach country of local countries {
	di "Doing `country'"
	su year if EUS_unemp != . & ISO3 == "`country'"
	local min_y = r(min)
	replace ratio = EUS_unemp / EUS_unemp1 if ISO3 == "`country'" & year == `min_y'
	qui su ratio if ISO3 == "`country'", meanonly
	replace EUS_unemp1 = EUS_unemp1 * r(mean) if ISO3 == "`country'"
}
order *unemp

* Keep final vars 
replace EUS_unemp = EUS_unemp1 if EUS_unemp == . 
drop EUS_unemp1 ratio 

* Rebase variables to $base_year
gmd_rebase EUS

* Check for ratios and levels 
check_gdp_ratios EUS

* ==============================================================================
*  Output
* ============================================================================== 

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* use
save "${output}", replace

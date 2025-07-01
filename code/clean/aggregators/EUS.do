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

* Add indicator 
generat indicator = ""
replace indicator = "govexp_GDP" 	 if na_item == "TE"  & sector == "S13"   & unit == "PC_GDP"
replace indicator = "govdef_GDP" 	 if na_item == "B9"  & sector == "S13"   & unit == "PC_GDP"
replace indicator = "govrev_GDP" 	 if na_item == "TR"  & sector == "S13"   & unit == "PC_GDP"
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
replace indicator = "govtax_GDP" 	 if na_item == "D2_D5_D91_D61_M_D995"  & sector == "S13"
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
gen EUS_govrev = (EUS_govrev_GDP * EUS_nGDP) / 100
gen EUS_govtax = (EUS_govtax_GDP * EUS_nGDP) / 100
gen EUS_govexp = (EUS_govexp_GDP * EUS_nGDP) / 100
gen EUS_govdef = (EUS_govdef_GDP * EUS_nGDP) / 100

* Derive varibles ratio to GDP 
gen EUS_cons_GDP = (EUS_cons / EUS_nGDP) * 100
gen EUS_inv_GDP  = (EUS_inv / EUS_nGDP) * 100
gen EUS_finv_GDP = (EUS_finv / EUS_nGDP) * 100
gen EUS_imports_GDP = (EUS_imports / EUS_nGDP) * 100
gen EUS_exports_GDP = (EUS_exports / EUS_nGDP) * 100

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* use
save "${output}", replace

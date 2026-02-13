* ==============================================================================
* Set up and initialize 
* ==============================================================================

* Create temporary file 
clear 
tempfile temp_master
save `temp_master', replace emptyok

* Keep only the variables that have raw data 
qui import delimited using "$data_helper/docvars.csv", clear
qui keep if finalvar == "Yes" & derived != "Yes"

* Drop rGDP in USD because it doesn't have raw data 
qui drop if codes == "rGDP_USD" 

* Drop crises variables 
qui drop if inlist(codes, "BankingCrisis", "SovDebtCrisis", "CurrencyCrisis")

* ==============================================================================
* Differentiate variables by type, make sure all are being checked 
* ==============================================================================

* Get list of all variables in the docvars 
qui levelsof codes, clean local(vars)

* Set locals for strictly positive and other ratios 
loc posratios "inv_GDP cons_GDP finv_GDP exports_GDP imports_GDP govexp_GDP govrev_GDP govtax_GDP govdebt_GDP cgovexp_GDP cgovrev_GDP cgovtax_GDP cgovdebt_GDP gen_govexp_GDP gen_govrev_GDP gen_govtax_GDP gen_govdebt_GDP"
loc othratios "CA_GDP govdef_GDP cgovdef_GDP gen_govdef_GDP"

* Set local for levels 
loc levels "CA CA_USD cons cons_USD exports exports_USD finv finv_USD imports imports_USD inv inv_USD M0 M1 M2 M3 M4 nGDP nGDP_USD pop rGDP_USD USDfx cgovdebt cgovdef cgovexp cgovrev cgovtax gen_govdebt gen_govdef gen_govexp gen_govrev gen_govtax govrev govexp govtax"

* Set local for indices/variables with a base year 
loc indices "REER HPI CPI deflator rGDP"

* Set local for variables in rates 
loc rates "cbrate strate ltrate infl unemp"

* Combine all categorized locals into one list for checking
local all_categorized "`posratios' `othratios' `levels' `rates' `indices'"

* Loop over every variable found in the docvars file
foreach var of local vars {
    
    * Check if the current variable is present in the categorized list
    * The 'list' command returns 1 if true, 0 if false
    local is_categorized : list var in all_categorized
    
    * If not found (0), display an error and break
    if `is_categorized' == 0 {
        di as error "ERROR: Variable `var' is present in docvars but not assigned to a local (levels, rates, etc.)"
        error 9
    }
}

* Loop over every variable we categorized 
foreach var of local all_categorized {

	* Check if the variable is in the docvars 
    local is_in_docvars : list var in vars
    if `is_in_docvars' == 0 {
        di as error "WARNING: Variable '`var'' is listed in a local but NOT in docvars (or was dropped)."
    }
}

* ==============================================================================
* Run general data checks applicable to any variable 
* ==============================================================================

foreach var in `vars' {

	* Check if the relevant file exists 
	capture confirm file "$data_final/chainlinked_`var'.dta"
	
	* If yes, continue 
	if _rc == 0 {
		
		* Print variable that is being checked 
		di as text "Checking `var'"

		* Import the raw data
		qui use "$data_final/chainlinked_`var'", clear
		cap drop if ISO3 == "USA"
		
		* Rename IMF WEO forecasts if they exist
		cap ren IMF_WEO_forecast* IMF_WEO_f*
		
		* Run the checks 
		qui check_func, name(`var') country(ISO3) time(year) posratios(`posratios') othratios(`othratios') levels(`levels') rates(`rates') indices(`indices')
		
		* Keep the variable to be checked 
		qui keep year ISO3 variables value reason* source check*
		
		* Keep only rows that we should check
		qui keep if check == 1
		
		* Append
		qui append using `temp_master'
		qui save `temp_master', replace 
	}
	
	* If not, print warning 
	else di as err "WARNING: `var' file not found in data/final folder, not checked"
}

* ==============================================================================
* Check that general government is larger than central government 
* ==============================================================================

* Loop over government variables to be checked 

foreach var in govtax govdebt govrev govexp {
    
    * Load only the specific variables needed for this check
    use ISO3 id year gen_`var' c`var' using "$data_distr/GMD", clear
    
    * Calculate the ratio (General / Central)
    gen value = gen_`var' / c`var'
    
    * Initialize check variables
    gen check = 0 
    gen strL reason = ""
	gen reason_cgovlargergengov = 0
    
    * Identify the variable name
    gen strL variables = "`var'"

    * Define error condition: General < Central 
    local error_cond "value!=. & value < 1"
    
    * Apply check
    replace check = 1 if `error_cond'
    replace reason = "; General `var' smaller than central `var'" if `error_cond'
    replace reason_cgovlargergengov = 1 if `error_cond'
	
    * Keep only the rows that failed
    keep if check == 1
    
    * Keep standardized columns for the master file
    keep ISO3 year variables value reason* check
    
    * Append to the local tempfile
    append using `temp_master'
    save `temp_master', replace
}

* ==============================================================================
* Check consistency of government deficits (Identity: Deficit ≈ Rev - Exp)
* ==============================================================================

/*
    Loop over all 3 deficit types:
    1. Combined ("")      -> govdef
    2. Central ("c")      -> cgovdef
    3. General ("gen_")   -> gen_govdef
*/

foreach prefix in "" "c" "gen_" {

    * 1. Define the specific variable names based on prefix
    local defvar "`prefix'govdef"
    local revvar "`prefix'govrev"
    local expvar "`prefix'govexp"
    
    * 2. Load only the relevant columns
    use ISO3 id year `defvar' `revvar' `expvar' using "$data_distr/GMD", clear

    * 3. Calculate Discrepancy Ratio (Deficit / (Rev - Exp))
    * This goes into 'value' so you can see the magnitude of the error
    gen test_calc = `revvar' - `expvar'
    gen value = `defvar' / test_calc
    
    * 4. Initialize check variables
    gen check = 0 
    gen strL reason = ""
    gen reason_govdef = 0
	
    * Set the variable name (e.g., "cgovdef")
    gen strL variables = "`defvar'"

    * 5. Set check flag 
    * Logic: Signs differ OR > 50% difference relative to manual calc
    replace check = 1 if value != . & (value < 0 | abs(value) > 1.5 | abs(value) < 0.5)

    * 6. Record reason
    * We make the reason specific to the government level
    if "`prefix'" == ""      local level "Combined"
    if "`prefix'" == "c"     local level "Central"
    if "`prefix'" == "gen_"  local level "General"
    
    replace reason = "; `level' Deficit discrepancy (Rev-Exp does not match Deficit)" if check == 1
	replace reason_govdef = 1 if check == 1 
	
    * 7. Keep only failures and append
    keep if check == 1
    
    * Ensure we keep the standard columns for the master file
    keep ISO3 year variables value reason* check
    
    append using `temp_master'
    save `temp_master', replace
}

	
* ==============================================================================
* Check consistency of changes in CPI and inflation rate 
* ==============================================================================

* Open relevant variables from GMD file 
use ISO3 id year CPI infl using "$data_distr/GMD", clear

* Set panel 
xtset id year 

* Make check and reason variables 
gen check = 0
gen strL reason = ""
gen reason_inflCPIdiscrp = 0

* Make growth rate of CPI 
gen CPI_gr = (CPI - L.CPI) / L.CPI

* Compute country-specific correlation
bysort id: egen value = corr(CPI_gr infl)
	
* Set check flag to 1 in case of a low correlation 
qui replace check = 1 if value < 0.3 

* Record reason and source with discrepancy 
qui replace reason = reason + "; < .3 correlation between inflation and CPI growth" if value < 0.3
qui replace reason_inflCPIdiscrp = 1 if value < 0.3

* Reformat
qui gen strL variables = "CPI and inflation rate consistency"

* Trim reason string 
qui replace reason = substr(reason,3,strlen(reason)) if substr(reason,1,1) == ";"

* Keep the variable to be checked 
qui keep year ISO3 variables reason* value check*

* Keep only rows that we should check
qui keep if check == 1

* Append
append using `temp_master'
save `temp_master', replace 


* ==============================================================================
* Check accounting identities and comovement of GDP components 
* ==============================================================================

/*
	Set up
*/ 

* Open relevant variables from GMD file 
use ISO3 id year exports imports govexp inv finv cons nGDP using "$data_distr/GMD", clear
xtset id year 

* Consolidate investment variables 
replace inv = finv if inv == . 

* Make check and reason variables 
gen check = 0
gen strL reason = ""
gen value = .
gen reason_GDPaccounting = 0

/*
	Accounting identities 
*/ 

* Make manual sum of GDP components 
gen sum = cons + inv + govexp + (exports - imports)

* Calculate ratio of nominal GDP with manual sum
replace value = sum / nGDP

* Set check flag to 1 if ratio has opposite signs or a 50% difference
replace check = 1 if value!=. & (value < 0 | abs(value) > 1.5 | abs(value) < 0.5)

* Record reason and variables 
replace reason = "; Sum of GDP components (C+I+G+NX) has a > 50% difference relative to nominal GDP" if value!=. & (value < 0 | abs(value) > 1.5 | abs(value) < 0.5)
replace reason_GDPaccounting = 1 if value!=. & (value < 0 | abs(value) > 1.5 | abs(value) < 0.5)
gen variables = "GDP components (accounting identities)"

* Keep only failures 
keep if check == 1

* Ensure we keep the standard columns for the master file
keep ISO3 year variables value reason* check

* Trim reason string 
qui replace reason = substr(reason,3,strlen(reason)) if substr(reason,1,1) == ";"

* Append, save 
append using `temp_master'
save `temp_master', replace

/*
	Comovement 
*/ 	

* Open relevant variables from GMD file 
use ISO3 id year exports imports govexp inv finv cons nGDP using "$data_distr/GMD", clear
xtset id year 

* Consolidate investment variables 
replace inv = finv if inv == . 

* Make check and reason variables 
gen check = 0
gen strL reason = ""
gen reason_GDPcompcorr = 0

* Calculate nominal GDP growth 
gen nGDP_gr = (nGDP - L.nGDP) / L.nGDP

* Define the variables we are checking
local components "exports imports govexp inv cons"

* 1. Calculate correlations for all variables first
foreach var in `components' {

    * Calculate growth rate 
    gen `var'_gr = (`var' - L.`var') / L.`var'
    
    * Compute country-specific correlation
    bysort id: egen corr_`var' = corr(nGDP_gr `var'_gr) 
}

* 2. Find the minimum correlation across the 5 variables for each country
egen min_corr = rowmin(corr_exports corr_imports corr_govexp corr_inv corr_cons)

* 3. Identify WHICH variable has that lowest correlation
gen str32 worst_var = ""
foreach var in `components' {
    replace worst_var = "`var'" if corr_`var' == min_corr & min_corr != .
}

* 4. Apply checks ONLY for the single worst variable
* We check if min_corr < 0 (and is not missing)
qui replace check = 1 if min_corr < 0 & min_corr != .

* Update reason string 
* We include the variable name and the actual value for clarity
qui replace reason = reason + "; Negative correlation (" + string(min_corr, "%9.2f") + ") between GDP and " + worst_var ///
    if min_corr < 0 & min_corr != .

* Update specific reason flag
qui replace reason_GDPcompcorr = 1 if min_corr < 0 & min_corr != .

* Rename min_corr into check value 
ren min_corr value 

* Keep only failures, make variables string 
keep if check == 1
gen variables = "GDP components (comovement)"

* Ensure we keep the standard columns for the master file
keep ISO3 year variables value reason* check

* Trim reason string 
qui replace reason = substr(reason,3,strlen(reason)) if substr(reason,1,1) == ";"

* Append, save 
append using `temp_master'
save `temp_master', replace


* ==============================================================================
* Prepare file for comparison with log 
* ==============================================================================

* Round variables; we do not want to check variables again that are extremely 
* similar to what has already been checked 

gen value_str = string(value, "%9.2f")

* Clean up 
order ISO3 year variables source reason value_str value reason_*
keep ISO3 year variables source reason value_str value reason_*

* Save the master 
save "$data_helper/master_check", replace 
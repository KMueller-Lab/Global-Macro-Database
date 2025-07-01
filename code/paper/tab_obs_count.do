* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
*
* MAKE TABLE COMPARING THE RAW NUMBER OF OBSERVATIONS WITH OTHER DATA SOURCES
*
* ==============================================================================

* Find GMD dataset statistic summary
use "$data_final/data_final", clear
drop countryname
isid ISO3 year
ren * data_*
ren data_ISO3 ISO3
ren data_year year
greshape long data_, i(ISO3 year) j(variable) string
ren data GMD

* Count non-missing observations
replace GMD = 1 if GMD != .
drop if GMD == .

* Calculate number of observations 
gcollapse (sum) GMD, by(variable)

* Trim variable
replace variable = strtrim(variable)

tempfile temp_GMD_summary
save `temp_GMD_summary', replace

* Open cleaned file
use "$data_final/clean_data_wide", clear

* Add interest rates from other OECD publications to the EO
replace OECD_EO_strate = OECD_KEI_strate if OECD_EO_strate == .
replace OECD_EO_strate = OECD_MEI_ARC_strate  if OECD_EO_strate == .
gen OECD_EO_ltrate = .
replace OECD_EO_ltrate = OECD_MEI_ARC_ltrate  if OECD_EO_ltrate == .
replace OECD_EO_ltrate = OECD_KEI_ltrate  if OECD_EO_ltrate == .
replace OECD_EO_ltrate = OECD_MEI_ltrate  if OECD_EO_ltrate == .
replace OECD_EO_cbrate = OECD_MEI_cbrate  if OECD_EO_cbrate == .
replace OECD_EO_cbrate = OECD_MEI_ARC_cbrate  if OECD_EO_cbrate == .

* Add monetary aggregates data to the OECD from other publications
gen OECD_EO_M1 = OECD_MEI_M1
gen OECD_EO_M3 = OECD_MEI_M3

* Add data from IMF GDD, HDD, MFS, GFS, and FPP to IFS 
gen IMF_IFS_govdebt_GDP = .
replace IMF_IFS_govdebt_GDP = IMF_FPP_govdebt_GDP if IMF_IFS_govdebt_GDP == .
replace IMF_IFS_govdebt_GDP = IMF_HDD_govdebt_GDP if IMF_IFS_govdebt_GDP == .
replace IMF_IFS_govdebt_GDP = IMF_GDD_govdebt_GDP if IMF_IFS_govdebt_GDP == .
replace IMF_IFS_cbrate = IMF_MFS_cbrate if IMF_IFS_cbrate == .
replace IMF_IFS_ltrate = IMF_MFS_ltrate if IMF_IFS_ltrate == .
replace IMF_IFS_strate = IMF_MFS_strate if IMF_IFS_strate == .
gen IMF_IFS_M0 = IMF_MFS_M0
gen IMF_IFS_M1 = IMF_MFS_M1
gen IMF_IFS_M2 = IMF_MFS_M2
gen IMF_IFS_govexp = IMF_GFS_govexp
gen IMF_IFS_govrev = IMF_GFS_govrev
gen IMF_IFS_govdef_GDP = IMF_GFS_govdef_GDP
gen IMF_IFS_govtax = IMF_GFS_govtax

* Add unemployment data to WDI 
gen WDI_unemp = ILO_unemp

* Merge in GFD processed data
merge 1:1 ISO3 year using  "$data_helper/GFD_processed.dta" , nogen

* In GFD, keep USDfx values after 1791 
replace GFD_USDfx = . if year <= 1791

drop WDI_ARC*
keep ISO3 year IMF_IFS_* IMF_WEO_* WDI_* OECD_EO_* UN_* JST_* Mitchell_* GFD_*
reshape long IMF_IFS_ IMF_WEO_ WDI_ OECD_EO_ UN_ JST_ Mitchell_ GFD_, i(ISO3 year) j(variable) string
ren IMF_IFS_ 	data_IMF_IFS
ren IMF_WEO_	data_IMF_WEO
ren WDI_ 		data_WDI
ren OECD_EO_	data_OECD_EO
ren UN_			data_UN
ren JST_		data_JST
ren Mitchell_ 	data_Mitchell
ren GFD_ 		data_GFD
greshape long data, i(ISO3 year variable) j(source) string

* Count non-missing observations for each source-variable combination
replace data = 1 if data != .
drop if data == .
gcollapse (sum) data, by(source variable)

* Reshape the data such that sources are columns
greshape wide data, i(variable) j(source)

* Trim variable
replace variable = strtrim(variable)

* Merge with GMD Data
merge 1:1 variable using `temp_GMD_summary', keep(3) nogen
order variable GMD

* Calculate the ratio
ds variable GMD, not
foreach var in `r(varlist)'{
	replace `var' = round((`var'/GMD) * 100, 1)	
}

* Replace missing with empty space for Latex
ds variable GMD, not
foreach var in `r(varlist)' {
	tostring `var', replace force
	replace `var' = "---" if `var' == "."
	replace `var' = `var'+ "" if `var' != " "
}

* Order the variables together
* Order variables by category and logical flow
gen order = .
* Monetary Policy & Interest Rates
replace order = 1 if var == "cbrate"      // Central Bank Rate
replace order = 2 if var == "strate"      // Short-term Interest Rate
replace order = 3 if var == "ltrate"      // Long-term Interest Rate

* Money Supply Measures
replace order = 4 if var == "M0"          // Money Supply (M0)
replace order = 5 if var == "M1"          // Money Supply (M1)
replace order = 6 if var == "M2"          // Money Supply (M2)
replace order = 7 if var == "M3"          // Money Supply (M3)
replace order = 8 if var == "M4"          // Money Supply (M3)

* GDP and Output
replace order = 9 if var == "rGDP"        // Real GDP
replace order = 10 if var == "nGDP"        // Nominal GDP
replace order = 11 if var == "cons"       // Consumption
replace order = 12 if var == "rcons"      // Real consumption
replace order = 13 if var == "inv"        // Investment
replace order = 14 if var == "finv"       // Fixed Investment
* External Sector
replace order = 15 if var == "CA_GDP"     // Current Account
replace order = 16 if var == "exports"    // Exports
replace order = 17 if var == "imports"    // Imports
replace order = 18 if var == "REER"       // Real Effective Exchange Rate
replace order = 19 if var == "USDfx"      // US Dollar Exchange Rate
* Government Finances
replace order = 20 if var == "govrev"     // Government Revenue
replace order = 21 if var == "govtax"     // Government Tax
replace order = 22 if var == "govexp"     // Government Expenditure
replace order = 23 if var == "govdebt_GDP" // Government Debt to GDP
replace order = 24 if var == "govdef_GDP" // Government Deficit to GDP
* Other Economic Indicators
replace order = 25 if var == "unemp"      // Unemployment Rate
replace order = 26 if var == "infl"       // Inflation Rate
replace order = 27 if var == "CPI"        // Consumer Price Index
replace order = 28 if var == "HPI"        // House Price Index
replace order = 29 if var == "pop"        // Population
drop if order == .

* Create more readable labels for all variables
replace variable = "Short-term interest rate" if var == "strate"
replace variable = "Long-term interest rate" if var == "ltrate"
replace variable = "Central bank policy rate" if var == "cbrate"
replace variable = "Money supply (M3)" if var == "M3"
replace variable = "Money supply (M2)" if var == "M2"
replace variable = "Money supply (M1)" if var == "M1"
replace variable = "Money supply (M0)" if var == "M0"
replace variable = "Money supply (M4)" if var == "M4"
replace variable = "Real GDP" if var == "rGDP"
replace variable = "Nominal GDP" if var == "nGDP"
replace variable = "Current account" if var == "CA_GDP"
replace variable = "Exports" if var == "exports"
replace variable = "Imports" if var == "imports"
replace variable = "Government revenue" if var == "govrev"
replace variable = "Government tax revenue" if var == "govtax"
replace variable = "Government expenditure" if var == "govexp"
replace variable = "Government debt" if var == "govdebt_GDP"
replace variable = "Government deficit" if var == "govdef_GDP"
replace variable = "House price index" if var == "HPI"
replace variable = "Gross fixed capital formation" if var == "finv"
replace variable = "Gross capital formation" if var == "inv"
replace variable = "Unemployment rate" if var == "unemp"
replace variable = "Inflation rate" if var == "infl"
replace variable = "Real consumption" if var == "rcons"
replace variable = "Consumption" if var == "cons"
replace variable = "Real effective exchange rate" if var == "REER"
replace variable = "US dollar exchange rate" if var == "USDfx"
replace variable = "Consumer price index" if var == "CPI"
replace variable = "Population" if var == "pop"

* Sort by the order variable
sort order
drop order 

* Rename
ren data_* *

* Make GMD column a string
tostring GMD, replace

* Add the decimal separator
gen x = strlen(GMD)
gen y = ""
replace y = substr(GMD, 1, 1) + "," + substr(GMD, 2, .) if x == 4 & variable != "Money supply (M4)"
replace y = substr(GMD, 1, 2) + "," + substr(GMD, 3, .) if x == 5 & variable != "Money supply (M4)"
replace y = GMD if variable == "Money supply (M4)" & y == ""
drop GMD x
ren y GMD 

* Order 
order variable GMD IMF_IFS IMF_WEO OECD_EO WDI UN JST Mitchell GFD

* Make inflation and equal to CPI 
levelsof GFD if variable == "Consumer price index", clean
qui replace GFD = r(levels) if variable == "Inflation rate"

* Replace M2 and M3 by a dash because we don't have access to the data 
replace GFD = "---" if inlist(variable, "Money supply (M2)", "Money supply (M3)")

* Output dataset
gmdwriterows *, path($tables/tab_obs_counts.tex)
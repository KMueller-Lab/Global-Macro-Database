* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN INTERNATIONAL MONETARY FUND (IMF) INTERNATIONAL FINANCIAL STATISTICS (IFS) DATA
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Last Editor:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-04-22
* Last update: 2025-06-23
*
* Description: This Stata script processes the raw IMF IFS data.
*
* Data source: IMF International Financial Statistics
* 
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================
* Clear all
clear

* Define input and output files
global input "${data_raw}/aggregators/IMF/IMF_IFS/IMF_IFS.csv"
global output "${data_clean}/aggregators/IMF/IMF_IFS/IMF_IFS.dta"

* ==============================================================================
* 	SET UP
* ==============================================================================
* Open.
import delimited using "${input}", clear varnames(1)

* Rename variables
generat varname = "nGDP" if indicator == "B1GQ" & price_type == "V"
replace varname = "rGDP" if indicator == "B1GQ" & price_type == "Q"
replace varname = "finv" if indicator == "P51G" 
replace varname = "inv" if indicator == "P5"
replace varname = "imports" if indicator == "P6"
replace varname = "exports" if indicator == "P7"
replace varname = "cons" if indicator == "P3" & price_type == "V"
replace varname = "REER" if indicator == "REER_IX_RY2010_ACW_RCPI"
replace varname = "strate" if indicator == "GSTBILY_RT_PT_A_PT" 
replace varname = "ltrate" if indicator == "S13BOND_RT_PT_A_PT"
replace varname = "cbrate" if indicator == "MFS166_RT_PT_A_PT"
replace varname = "discount" if indicator == "DISR_RT_PT_A_PT"
replace varname = "CA_USD" if indicator == "CAB" & unit == "USD"
replace varname = "unemp" if indicator == "U"
replace varname = "CPI" if type_of_transformation == "SRP_IX" & index_type == "CPI"
replace varname = "infl" if type_of_transformation == "SRP_POP_PCH_PA_PT" & index_type == "CPI"
replace varname = "USDfx" if indicator == "USD_XDC"
replace varname = "M3" if indicator == "BM_MAI" 
replace varname = "M0" if indicator == "NDMBM_MAI"
drop if varname == ""

* Keep final variables 
keep varname country time_period obs_value
destring time_period obs_value, ignore("NA") replace
drop if time_period == . 

* Reshape into a wide dataset.
greshape wide obs_value, i(time_period country) j(varname)
ren (obs_value* country time_period) (* ISO3 year)

* Derive current account in local currency 
replace USDfx = 1 / USDfx 

* Convert to euro 
merge m:1 ISO3 using "$eur_fx", keep(1 3)
replace USDfx = USDfx / EUR if _merge == 3 
drop EUR _merge 

* Derive 
qui gen CA = CA_USD * USD

* Convert Somalia to local currency
qui ds nGDP rGDP finv inv imports exports cons M0 M3
foreach var in `r(varlist)' {
	replace `var' = `var' / USDfx if ISO3 == "SOM" // Won't work because we don't have exchange rate to convert values

}

* Convert units 
qui ds nGDP rGDP finv inv imports exports cons
foreach var in `r(varlist)' {
	replace `var' = `var' * 1000 if ISO3 == "GNQ"
}

* Data for Burundi appears to be wrong for Fixed investment 
replace finv = . if ISO3 == "BDI"

* Units for Haiti Fixed investment are off before 1986 and there is a 
* break between 1989 and 1994 in consumption data
qui replace finv = finv * 10 if year <= 1986 & ISO3 == "HTI"
qui replace cons = . if inrange(year, 1989, 1994) & ISO3 == "HTI"

* Convert to millions 
qui ds nGDP rGDP finv inv imports exports cons CA_USD CA M0 M3
foreach var in `r(varlist)' {
	replace `var' = `var' / 10^6
	if !inlist("`var'", "nGDP", "rGDP", "M0", "M3") {
		qui gen `var'_GDP = (`var' / nGDP) * 100
	}
}

* Drop regional aggregates 
drop if regexm(ISO3, "[0-9]")

* Construct the central policy rate as the Monetary policy-related rate and the discount rate 
replace cbrate = discount if cbrate == . 
gmdaddnote_source IMF_IFS  "Using the discount rate when the monetary policy-related rate is missing" cbrate if cbrate == . & discount != . 
drop discount 
gmdaddnote_source IMF_IFS  "This is referred to in the original data as Broad Money" M3
gmdaddnote_source IMF_IFS  "This is referred to in the original data as National Definitions of Money Base Money" M0

* Fix ISO3 codes 
replace ISO3 = "PSE" if ISO3 == "WBG"
replace ISO3 = "XKX" if ISO3 == "KOS"

* Curaçao has two ISO3 codes and Yemen is now unified. 
drop if inlist(ISO3, "CWX", "YAR")

* Add source identifier 
qui ds ISO3 year, not
foreach var in `r(varlist)' {
	ren `var' IMF_IFS_`var'
}

* Convert M0 for Uruguay
replace IMF_IFS_M0 = IMF_IFS_M0 / 1000 if year >= 2018 & ISO3 == "URY"

* Rebase variables to $base_year
gmd_rebase IMF_IFS

* Check for ratios and levels 
check_gdp_ratios IMF_IFS

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Output
save "${output}", replace

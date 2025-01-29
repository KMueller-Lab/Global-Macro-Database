* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN DATA FROM THE WORLD DEVELOPMENT INDICATORS ARCHIVES
* 
* Description: 
* This Stata script reads in and cleans archival data from the World Bank's World 
* Development Indicators that is at times no longer included in the current version.
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-24
* ==============================================================================
* 	SET UP 
* ==============================================================================
* Define input and output files 
clear
global input "${data_raw}/aggregators/WB/WDI_1999.xlsx"
global output "${data_clean}/aggregators/WB/WDI_ARC"

* ==============================================================================
* 	PROCESS
* ==============================================================================
* Open 
import excel using "${input}", clear first allstring

* Keep only revelant columns
keep CountryCode SeriesName SeriesCode VersionCode YR*
qui missings dropvars, force

* Rename
ren CountryCode ISO3

* Destring
qui ds YR*
foreach var in `r(varlist)'{
	qui replace `var' = "" if `var' == ".."
	cap destring `var', replace
	if _rc != 0 {
		di as err "Variable not numeric"
		exit 198
	}
}

* Drop rows with no data
qui ds YR*
missings dropobs `r(varlist)', force

* Reshape
greshape long YR, i(ISO3 SeriesName SeriesCode VersionCode) j(year)

* Sort
gsort ISO3 SeriesCode  year VersionCode

* Drop missing values
drop if YR == .

* Keep the most recent edition for each observation
by ISO3 SeriesCode year: gen n = _n
by ISO3 SeriesCode year: egen n_max = max(n)
keep if n_max == n
drop n_max n 

* Drop 
drop SeriesName VersionCode

* Reshape wide
greshape wide YR, i(ISO3 year) j(SeriesCode)

* Rename
ren YR* *
ren(BN_CAB_XOKA_GD_ZS FP_CPI_TOTL FP_CPI_TOTL_ZG GB_DOD_TOTL_GD_ZS GB_TAX_TOTL_CN NE_CON_TOTL_CN NE_EXP_GNFS_CD NE_EXP_GNFS_CN NE_GDI_FTOT_CN NE_GDI_TOTL_CN NE_IMP_GNFS_CD NE_IMP_GNFS_CN NY_GDP_MKTP_CN NY_GDP_MKTP_KN PX_REX_REER SP_POP_TOTL) (CA_GDP CPI infl govdebt_GDP govtax cons exports_USD exports finv inv imports_USD imports nGDP rGDP REER pop)

* Set zeros to missing value (exclude inflation, which can be zero if rounded)
qui ds ISO3 year infl, not 
foreach var in `r(varlist)'{
	replace `var' = . if `var' == 0
}

* Convert units
foreach var of varlist  nGDP rGDP inv finv cons imports exports pop govtax {
	replace `var'= `var' / 1000000
}

* Drop regional aggregates
merge m:1 ISO3 using $isomapping, keep(3) keepusing(ISO3) nogen

* Fix the units


* Convert Venezuela values into current currency
foreach var of varlist  nGDP rGDP inv finv cons imports exports  govtax {
	replace `var'= `var' * (10^-14) if ISO3 == "VEN"
}

* Convert Romania values into current currency
foreach var of varlist  nGDP rGDP inv finv cons imports exports  govtax {
	replace `var'= `var'/10000 if ISO3 == "ROU"
}

* Convert Sao Tome values into current currency
foreach var of varlist  nGDP rGDP inv finv cons imports exports  govtax {
	replace `var'= `var'/1000 if ISO3 == "STP"
}

* Convert Afghanistan values into current currency
foreach var of varlist  nGDP rGDP inv finv cons imports exports  govtax {
	replace `var'= `var'/1000 if ISO3 == "AFG"
}

* Convert Turkey values into current currency
foreach var of varlist  nGDP rGDP inv finv cons imports exports  govtax {
	replace `var'= `var'/1000000 if ISO3 == "TUR"
}

* Convert Angola values into current currency
foreach var of varlist  nGDP rGDP inv finv cons imports exports  govtax {
	replace `var'= `var'/1000000 if ISO3 == "AGO"
}

* Convert Zambia values into current currency
foreach var of varlist  nGDP rGDP inv finv cons imports exports  govtax {
	replace `var'= `var'/1000 if ISO3 == "ZMB"
}


* Convert Suriname values into current currency
foreach var of varlist  nGDP rGDP inv finv cons imports exports  govtax {
	replace `var'= `var'/1000 if ISO3 == "SUR"
}

* Convert Mozambique values into current currency
foreach var of varlist  nGDP rGDP inv finv cons imports exports  govtax {
	replace `var'= `var'/1000 if ISO3 == "MOZ"
}

* Convert Bulgaria values into current currency
foreach var of varlist  nGDP rGDP inv finv cons imports exports  govtax {
	replace `var'= `var'/1000 if ISO3 == "BGR"
}


* Convert Ghana values into current currency
foreach var of varlist  nGDP rGDP inv finv cons imports exports  govtax {
	replace `var'= `var'/10000 if ISO3 == "GHA"
}

* Convert El Salvador values into current currency
foreach var of varlist  nGDP rGDP inv finv cons imports exports govtax {
	replace `var'= `var'/8.75 if ISO3 == "SLV"
}

* Convert Ecuador values into current currency
foreach var of varlist  nGDP rGDP inv finv cons imports exports govtax {
	replace `var'= `var'/25 if ISO3 == "ECU"
}

* Convert Turkmenistan values into current currency
foreach var of varlist  nGDP rGDP inv finv cons imports exports  govtax {
	replace `var'= `var'/5000 if ISO3 == "TKM"
}

* Convert Tajikstan values into current currency
foreach var of varlist  nGDP rGDP inv finv cons imports exports  govtax {
	replace `var'= `var'/1000 if ISO3 == "TJK"
}

* Convert Sudan values into current currency
foreach var of varlist  nGDP rGDP inv finv cons imports exports  govtax {
	replace `var'= `var'/1000 if ISO3 == "SDN"
}

* Convert Azerbaijan values into current currency
foreach var of varlist  nGDP rGDP inv finv cons imports exports govtax {
	replace `var'= `var'/10000 if ISO3 == "AZE"
}

* Convert Belarus values into current currency
foreach var of varlist  nGDP rGDP inv finv cons imports exports  govtax {
	replace `var'= `var'/1000000 if ISO3 == "BLR"
}

* Convert Congo RDC values into current currency
foreach var of varlist  nGDP rGDP inv finv cons imports exports  govtax {
	replace `var'= `var'/100000 if ISO3 == "COD"
}

* Convert Mauritania values into current currency
foreach var of varlist  nGDP rGDP inv finv cons imports exports  govtax {
	replace `var'= `var'/10 if ISO3 == "MRT"
}

* Drop real GDP for Zimbabwe, an index
replace rGDP = . if ISO3 == "ZWE"

* Convert currency for european countries
merge m:1 ISO3 using $eur_fx, keep(1 3)
foreach var of varlist  nGDP rGDP inv finv cons imports exports govtax {
	replace `var'= `var'/EUR_irrevocable_FX if _merge == 3
}
drop EUR_irrevocable_FX _merge

* Add ratios to gdp variables
gen cons_GDP = (cons / nGDP) * 100
gen imports_GDP = (imports / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100
gen govtax_GDP  = (govtax / nGDP) * 100
gen finv_GDP    = (finv / nGDP) * 100
gen inv_GDP     = (inv / nGDP) * 100


* Rename
qui ds ISO3 year, not 
foreach var in `r(varlist)'{
	replace `var' = . if `var' == 0
	ren `var' WDI_ARC_`var'
}

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

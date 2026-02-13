* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-05-14
* 
* Source: Organisation for Economic Co-operation and Development
*
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================

* Define globals 
global input "${data_raw}/aggregators/OECD/OECD_EO/OECD_EO.dta"
global output "${data_clean}/aggregators/OECD/OECD_EO/OECD_EO.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================


* Open
use "$input", clear

* Drop regional aggregates
keep if strlen(ref_area) == 3
drop if inlist(ref_area, "WXD", "W_O", "DAE")

* Add indicator and assing codes 
gen indicator = ""

* National Accounts - GDP and components
replace indicator = "nGDP"          if measure == "GDP"      	 & indicator == ""   // Gross domestic product, nominal value, market prices
replace indicator = "rGDP"          if measure == "GDPV"     	 & indicator == ""   // Gross domestic product, volume, market prices
replace indicator = "cons_h" 	    if measure == "CP"       	 & indicator == ""   // Private final consumption expenditure, nominal value, GDP expenditure approach
replace indicator = "cons_g"        if measure == "CG"       	 & indicator == ""   // Government final consumption expenditure, nominal value, GDP expenditure approach
replace indicator = "inv"           if measure == "ITISK"    	 & indicator == ""   // Gross capital formation, total, nominal value
replace indicator = "finv"          if measure == "IT"       	 & indicator == ""   // Gross fixed capital formation, total, nominal value
replace indicator = "exports"       if measure == "XGS"      	 & indicator == ""   // Exports of goods and services, nominal value (national accounts basis)
replace indicator = "imports"       if measure == "MGS"      	 & indicator == ""   // Imports of goods and services, nominal value (national accounts basis)

* External Sector - Current Account and Exchange Rates
replace indicator = "CA"            if measure == "CB"         	 & indicator == ""   // Current account balance
replace indicator = "CA_USD"        if measure == "CBD"      	 & indicator == ""   // Current account balance in USD
replace indicator = "CA_GDP"        if measure == "CBGDPR"   	 & indicator == ""   // Current account balance as a percentage of GDP
replace indicator = "USDfx"         if measure == "EXCH"     	 & indicator == ""   // Exchange rate, USD per national currency
replace indicator = "REER"          if measure == "EXCHER"       & indicator == ""   // Real effective exchange rate, constant trade weights

* Prices and Inflation
replace indicator = "CPI"           if measure == "CPI"          & indicator == ""   // Consumer price index
replace indicator = "inflH"         if measure == "CPIH_YTYPCT"  & indicator == ""   // Harmonised headline inflation
replace indicator = "infl"          if measure == "CPI_YTYPCT"   & indicator == ""   

* Labor Market
replace indicator = "unemp"         if measure == "UNR"     	 & indicator == ""   // Unemployment rate
replace indicator = "pop"           if measure == "POP"     	 & indicator == ""   // Total population

* Government Finance
replace indicator = "gen_govrev"        if measure == "YRGT"    	 & indicator == ""   // Total receipts of general government
replace indicator = "gen_govrev_GDP"    if measure == "YRGTQ"   	 & indicator == ""   // Total receipts of general government as a percentage of GDP
replace indicator = "gen_govexp"        if measure == "YPGT"    	 & indicator == ""   // Total disbursements of general government
replace indicator = "gen_govexp_GDP"    if measure == "YPGTQ"   	 & indicator == ""   // Total disbursements of general government as a percentage of GDP
replace indicator = "gen_govdebt"       if measure == "GGFLM"   	 & indicator == ""   // Gross public debt, Maastricht criterion
replace indicator = "gen_govdebt_GDP"   if measure == "GGFLMQ"  	 & indicator == ""   // Gross public debt, Maastricht criterion as a percentage of GDP
replace indicator = "gen_govdef"        if measure == "NLG"     	 & indicator == ""   // General government net lending
replace indicator = "gen_govdef_GDP"    if measure == "NLGQ"   	 	 & indicator == ""   // General government net lending as a percentage of GDP

* Financial and Monetary Indicators
replace indicator = "cbrate"        if measure == "IRCB"    	 & indicator == ""   // Central bank key interest rate
replace indicator = "strate"        if measure == "IRS"     	 & indicator == ""   // Short-term interest rate
replace indicator = "ltrate"        if measure == "IRL"     	 & indicator == ""   // Long-term interest rate on government bonds.

* Drop the rest of measures
drop if indicator == ""

* Keep relevant variables
keep time_period obs_value ref_area indicator

* Reshape
greshape wide obs_value, i(time_period ref_area) j(indicator)

* Rename
ren obs_value* *
ren (time_period ref_area) (year ISO3)

* Convert units to millions
qui ds nGDP* rGDP* pop finv inv exports imports cons_h cons_g CA gen_govrev gen_govexp gen_govdebt 
foreach var in `r(varlist)'{
	replace `var' = `var' / 10^6
}

* Fix REER and CPI values
qui ds CPI* REER 
foreach var in `r(varlist)'{
	replace `var' = `var' * 100
}

* Fix the USDfx 
replace USDfx = 1 / USDfx

* Derive total consumption as the sum of government and household consumptions
gen cons = cons_h + cons_g
drop cons_h cons_g

* Add the deflator
gen deflator = (nGDP / rGDP) * 100

* Derive variables to GDP ratios 
qui ds finv inv exports imports cons
foreach var in `r(varlist)'{
	gen `var'_GDP = (`var' / nGDP) * 100
}

* Add harmonised inflation column to the inflation column because the harmonised inflation is only for EU countries
replace infl = inflH if infl == .

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	ren `var' OECD_EO_`var'
}

* Rebase variables to $base_year
gmd_rebase OECD_EO

* Check for ratios and levels 
check_gdp_ratios OECD_EO

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

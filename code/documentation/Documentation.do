* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCT THE DOCUMENTATION FOR ALL VARIABLES
* 
* Created: 
* 2024-06-28
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 	
* ==============================================================================

* Nominal GDP
use "$data_final/chainlinked_nGDP", clear
gmdmakedoc nGDP, log ylabel("Nominal GDP, millions of LCU (Log scale)")	
gen variable = "nGDP"
gen variable_definition = "Nominal GDP"
save "$data_final/documentation_nGDP", replace

* Real GDP
use "$data_final/chainlinked_rGDP", clear
gmdmakedoc rGDP, log ylabel("Real GDP, millions of LCU (Log scale)")	
qui gen variable = "rGDP"
qui gen variable_definition = "Real GDP"
save "$data_final/documentation_rGDP", replace

* Investment 
use "$data_final/chainlinked_inv", clear
gmdmakedoc inv, log ylabel("Investment, millions of LCU (Log scale)")		
gen variable = "inv"
gen variable_definition = "Investment"
save "$data_final/documentation_inv", replace


* Investment to GDP ratio
use "$data_final/chainlinked_inv_GDP", clear
gmdmakedoc inv_GDP, ylabel("Investment, % of GDP") transformation("ratio")
gen variable = "inv_GDP"
gen variable_definition = "Investment to GDP ratio"
save "$data_final/documentation_inv_GDP", replace


* Fixed investment 
use "$data_final/chainlinked_finv", clear
gmdmakedoc finv, log ylabel("Fixed investment, millions of LCU (Log scale)")	
gen variable = "finv"
gen variable_definition = "Fixed investment"
save "$data_final/documentation_finv", replace


* Fixed investment to GDP ratio
use "$data_final/chainlinked_finv_GDP", clear
gmdmakedoc finv_GDP, ylabel("Fixed investment, % of GDP") transformation("ratio")
gen variable = "finv_GDP"
gen variable_definition = "Fixed investment to GDP ratio"
save "$data_final/documentation_finv_GDP", replace


* Real total consumption 
use "$data_final/chainlinked_rcons", clear
gmdmakedoc rcons, log ylabel("Real total consumption, millions of LCU (Log scale)")	
gen variable = "rcons"
gen variable_definition = "Real total consumption"
save "$data_final/documentation_rcons", replace


* Total consumption 
use "$data_final/chainlinked_cons", clear
gmdmakedoc cons, log ylabel("Total consumption, millions of LCU (Log scale)")	
gen variable = "cons"
gen variable_definition = "Total consumption"
save "$data_final/documentation_cons", replace


* Total consumption to GDP ratio
use "$data_final/chainlinked_cons_GDP", clear
gmdmakedoc cons_GDP, ylabel("Total consumption, % of GDP") transformation("ratio")
gen variable = "cons_GDP"
gen variable_definition = "Total consumption to GDP ratio"
save "$data_final/documentation_cons_GDP", replace


* Imports 
use "$data_final/chainlinked_imports", clear
gmdmakedoc imports, log ylabel("Imports, millions of LCU (Log scale)")	
gen variable = "imports"
gen variable_definition = "Imports"
save "$data_final/documentation_imports", replace


* Imports to GDP ratio
use "$data_final/chainlinked_imports_GDP", clear
gmdmakedoc imports_GDP, ylabel("Imports, % of GDP") transformation("ratio")
gen variable = "imports_GDP"
gen variable_definition = "Imports to GDP ratio"
save "$data_final/documentation_imports_GDP", replace


* Exports 
use "$data_final/chainlinked_exports", clear
gmdmakedoc exports, log ylabel("Exports, millions of LCU (Log scale)")	
gen variable = "exports"
gen variable_definition = "Exports"
save "$data_final/documentation_exports", replace


* Exports to GDP ratio
use "$data_final/chainlinked_exports_GDP", clear
gmdmakedoc exports_GDP, ylabel("Exports, % of GDP") transformation("ratio")
gen variable = "exports_GDP"
gen variable_definition = "Exports to GDP ratio"
save "$data_final/documentation_exports_GDP", replace


* Current account balance
use "$data_final/chainlinked_CA_GDP", clear
gmdmakedoc CA_GDP, ylabel("Current account balance, % of GDP") transformation("ratio")
gen variable = "CA_GDP"
gen variable_definition = "Current account balance"
save "$data_final/documentation_CA_GDP", replace


* Population
use "$data_final/chainlinked_pop", clear
gmdmakedoc pop, log ylabel("Population, millions of LCU (Log scale)")	
gen variable = "pop"
gen variable_definition = "Population"
save "$data_final/documentation_pop", replace


* Government Expenditure 
use "$data_final/chainlinked_govexp", clear
gmdmakedoc govexp, log ylabel("Government expenditure, millions of LCU (Log scale)")	
gen variable = "govexp"
gen variable_definition = "Government expenditure"
save "$data_final/documentation_govexp", replace


* Government Expenditure to GDP ratio
use "$data_final/chainlinked_govexp_GDP", clear
gmdmakedoc govexp, log ylabel("Government expenditure, % of GDP") transformation("ratio")
gen variable = "govexp_GDP"
gen variable_definition = "Government expenditure to GDP ratio"
save "$data_final/documentation_govexp_GDP", replace


* Government Revenue 
use "$data_final/chainlinked_govrev", clear
gmdmakedoc govrev, log ylabel("Government revenue, millions of LCU (Log scale)")	
gen variable = "govrev"
gen variable_definition = "Government revenue"
save "$data_final/documentation_govrev", replace


* Government Revenue to GDP ratio
use "$data_final/chainlinked_govrev_GDP", clear
gmdmakedoc govrev_GDP, ylabel("Government revenue, % of GDP") transformation("ratio")
gen variable = "govrev_GDP"
gen variable_definition = "Government revenue to GDP ratio"
save "$data_final/documentation_govrev_GDP", replace


* Government tax revenue 
use "$data_final/chainlinked_govtax", clear
gmdmakedoc govtax, log ylabel("Government tax revenue, millions of LCU (Log scale)")	
gen variable = "govtax"
gen variable_definition = "Government tax revenue"
save "$data_final/documentation_govtax", replace


* Government tax revenue to GDP ratio
use "$data_final/chainlinked_govtax_GDP", clear
gmdmakedoc govtax_GDP, ylabel("Government tax revenue, % of GDP") transformation("ratio")
gen variable = "govtax_GDP"
gen variable_definition = "Government tax revenue to GDP ratio"
save "$data_final/documentation_govtax_GDP", replace


* Government deficit to GDP ratio
use "$data_final/chainlinked_govdef_GDP", clear
gmdmakedoc govdef_GDP, ylabel("Government deficit, % of GDP") transformation("ratio")
gen variable = "govdef_GDP"
gen variable_definition = "Government deficit"
save "$data_final/documentation_govdef_GDP", replace


* Government debt to GDP ratio
use "$data_final/chainlinked_govdebt_GDP", clear
gmdmakedoc govdebt_GDP, ylabel("Government debt, % of GDP") transformation("ratio")
gen variable = "govdebt_GDP"
gen variable_definition = "Government debt"
save "$data_final/documentation_govdebt_GDP", replace


* Consumer price index
use "$data_final/chainlinked_CPI", clear
gmdmakedoc CPI, ylabel("Consumer price index, 2010 = 100") transformation("ratio")
gen variable = "CPI"
gen variable_definition = "Consumer price index"
save "$data_final/documentation_CPI", replace


* House price index
use "$data_final/chainlinked_HPI", clear
gmdmakedoc HPI, log ylabel("House price index, 2010 = 100") transformation("ratio")
gen variable = "HPI"
gen variable_definition = "House price index"
save "$data_final/documentation_HPI", replace


* Inflation
use "$data_final/chainlinked_infl", clear
gmdmakedoc infl, ylabel("Inflation, in percentage") transformation("rate")
gen variable = "infl"
gen variable_definition = "Inflation"
save "$data_final/documentation_infl", replace


* Unemployment
use "$data_final/chainlinked_unemp", clear
gmdmakedoc unemp, ylabel("Unemployment, in percentage") transformation("rate")
gen variable = "unemp"
gen variable_definition = "Unemployment"
save "$data_final/documentation_unemp", replace


* USD exchange rate
use "$data_final/chainlinked_USDfx", clear
gmdmakedoc USDfx, log ylabel("USD exchange rate, 1 USD in LCU (Log scale)")	
gen variable = "USDfx"
gen variable_definition = "USD exchange rate"
save "$data_final/documentation_USDfx", replace


* Real effective exchange rate
use "$data_final/chainlinked_REER", clear
gmdmakedoc REER, ylabel("Real effective exchange rate, 2010 = 100") transformation("rate")
gen variable = "REER"
gen variable_definition = "Real effective exchange rate"
save "$data_final/documentation_REER", replace


* Short term interest rate
use "$data_final/chainlinked_strate", clear
gmdmakedoc strate, ylabel("Short term interest rate, in percentage") transformation("rate")
gen variable = "strate"
gen variable_definition = "Short term interest rate"
save "$data_final/documentation_strate", replace


* Long term interest rate
use "$data_final/chainlinked_ltrate", clear
gmdmakedoc ltrate, ylabel("Long term interest rate, in percentage") transformation("rate")
gen variable = "ltrate"
gen variable_definition = "Long term interest rate"
save "$data_final/documentation_ltrate", replace


* Central bank policy rate
cap use "$data_final/chainlinked_cbrate", clear
gmdmakedoc cbrate, ylabel("Central bank policy rate, in percentage") transformation("rate")
gen variable = "cbrate"
gen variable_definition = "Central bank policy rate"
save "$data_final/documentation_cbrate", replace


* Money supply (M0)
use "$data_final/chainlinked_M0", clear
gmdmakedoc M0, log ylabel("Money supply (M0), millions of LCU (Log scale)")	
gen variable = "M0"
gen variable_definition = "Money supply (M0)"
save "$data_final/documentation_M0", replace


* Money supply (M1)
use "$data_final/chainlinked_M1", clear
gmdmakedoc M1, log ylabel("Money supply (M1), millions of LCU (Log scale)")	
gen variable = "M1"
gen variable_definition = "Money supply (M1)"
save "$data_final/documentation_M1", replace


* Money supply (M2)
use "$data_final/chainlinked_M2", clear
gmdmakedoc M2, log ylabel("Money supply (M2), millions of LCU (Log scale)")	
gen variable = "M2"
gen variable_definition = "Money supply (M2)"
save "$data_final/documentation_M2", replace


* Money supply (M3)
use "$data_final/chainlinked_M3", clear
gmdmakedoc M3, log ylabel("Money supply (M3), millions of LCU (Log scale)")	
gen variable = "M3"
gen variable_definition = "Money supply (M3)"
save "$data_final/documentation_M3", replace


* Money supply (M4)
use "$data_final/chainlinked_M4", clear
gmdmakedoc M4, log ylabel("Money supply (M4), millions of LCU (Log scale)")	
gen variable = "M4"
gen variable_definition = "Money supply (M4)"
save "$data_final/documentation_M4", replace

* Create the final documentation dataset
clear
tempfile documentation
save `documentation', replace emptyok

local vars nGDP rGDP inv inv_GDP finv finv_GDP rcons cons cons_GDP exports exports_GDP imports imports_GDP CA_GDP govexp govexp_GDP govrev govrev_GDP govtax govtax_GDP govdef_GDP govdebt_GDP CPI HPI infl pop unemp USDfx REER strate ltrate cbrate M0 M1 M2 M3 M4
foreach var of local vars {
	use "$data_final/documentation_`var'", clear
	
	* Append to documentation
	append using `documentation'
	
	* Save
	save `documentation', replace
}

* Save the documentation
save "$data_final/documentation", replace

* Merge in the notes
merge m:1 source variable using  "C:/Users/lehbib/Documents/Github/Global-Macro-Project/data/tempfiles/notes_sources.dta", nogen
replace notes = notes + ". " + note
drop note

* Save the documentation  
save "$data_final/documentation", replace


* ==============================================================================
* 	CREATE THE MASTER DOCUMENTATION
* ==============================================================================

gmdcombinedocs nGDP rGDP inv inv_GDP finv finv_GDP rcons cons cons_GDP exports exports_GDP imports imports_GDP CA_GDP govexp govexp_GDP govrev govrev_GDP govtax govtax_GDP govdef_GDP govdebt_GDP CPI HPI infl pop unemp USDfx REER strate ltrate cbrate M0 M1 M2 M3 M4


* ==============================================================================
* 	CREATE THE COUNTRY SPECIFIC DOCUMENTATION
* ==============================================================================
use "$data_final/documentation", clear
gmdmakedoc_cs
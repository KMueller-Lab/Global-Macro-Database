* ==============================================================================
* GLOBAL CREDIT DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and clean data for STATPOL
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-11-05
*
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
* Clear
clear
global input "${data_raw}/country_level/POL_1"
global output "${data_clean}/country_level/POL_1"

* ==============================================================================
*	POP
* ==============================================================================

* Open
use "$input", clear

* Destring variables
replace value = "" if value == "NA"
destring period value, replace

* Keep relevant columns
keep period value series_code series_name  ISO3

* Replace servies_code to GMD variable names
replace series_code = "CS1_CA_GDP" if series_code == "APF-57" // Relation of current account balance of payments to gross domestie productd - in % (line 57)
replace series_code = "CS1_cons" if series_code == "ANA-31" // Final consumption expenditure (current prices) - in mln zl (line 31)
replace series_code = "CS1_exports" if series_code == "ANA-39" // Exports of goods and services (current prices) - in mln zl (line 39)
replace series_code = "CS1_imports" if series_code == "ANA-40" // Imports of goods and services (current prices) - in mln zl (line 40)
replace series_code = "CS1_finv" if series_code == "ANA-37" // Gross capital formation (current prices) - gross fixed capital formation - in mln zl (line 37)
replace series_code = "CS1_inv" if series_code == "ANA-35" // Gross capital formation (current prices) - in mln zl (line 35)
replace series_code = "CS1_govdebt" if series_code == "APF-9" // Total debt of the public finance sector (public debt) - in mln zl (line 9)
replace series_code = "CS1_govdef" if series_code == "APF-8" // Total debt of the public finance sector (public debt) - in mln zl (line 9)
replace series_code = "CS1_govrev" if series_code == "APF-6" // Total debt of the public finance sector (public debt) - in mln zl (line 9)
replace series_code = "CS1_govexp" if series_code == "APF-7" // Total debt of the public finance sector (public debt) - in mln zl (line 9)
replace series_code = "CS1_M3" if series_code == "AMON-6" // Total money supply of M3 (end of the year) - in mln zl (line 6)
replace series_code = "CS1_nGDP" if series_code == "ANA-7" // Gross domestic product (current prices) - in mln zl (line 7)
replace series_code = "CS1_rGDP" if series_code == "ANA-45" // Gross domestic product (constant pricesd) - 1995=100 (line 45)
replace series_code = "CS1_USDfx" if series_code == "AMON-15" // Average exchange rate -  National Bank of Poland (NBP): - 100 USDd - in zl (line 15)
replace series_code = "CS1_cbrate" if series_code == "AMON-11" // Average exchange rate -  National Bank of Poland (NBP): - 100 USDd - in zl (line 15)
replace series_code = "CS1_M0" if series_code == "AMON-9" // Total money supplya of M3 (end of the year) - of which currency in circulation (excluding bank vault cash) - in mln zl (line 9)
replace series_code = "CS1_CPI" if series_code == "APRI-16" // Harmonized index of consumer prices (HICP)a - 2010=100 (line 16)
replace series_code = "CS1_pop" if series_code == "APOP-6" // Total population (as of 31 XII) - in thous. (line 6)

* Drop unused variables
drop if substr(series_code, 1, 3) != "CS1"
drop series_name

* Reshape
ren period year
greshape wide value, i(year) j(series_code)
ren value* *

* Convert the units
replace CS1_pop = CS1_pop / 1000
replace CS1_USDfx = CS1_USDfx/100

* Add ratios to gdp variables
gen CS1_cons_GDP    = (CS1_cons / CS1_nGDP) * 100
gen CS1_imports_GDP = (CS1_imports / CS1_nGDP) * 100
gen CS1_exports_GDP = (CS1_exports / CS1_nGDP) * 100
gen CS1_finv_GDP    = (CS1_finv / CS1_nGDP) * 100
gen CS1_inv_GDP     = (CS1_inv / CS1_nGDP) * 100
gen CS1_govrev_GDP = (CS1_govrev / CS1_nGDP) * 100
gen CS1_govexp_GDP = (CS1_govexp / CS1_nGDP) * 100
gen CS1_govdebt_GDP = (CS1_govdebt / CS1_nGDP) * 100

* ==============================================================================
* 	Output
* ==============================================================================

* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace

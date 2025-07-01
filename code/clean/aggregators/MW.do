* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script opens and cleans data from Measuring Worth.
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-10-02
*
* 
* Data Source: Measuring Worth
*
* URL: https://www.measuringworth.com/
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================

* Clear data 
clear

* Define globals 
global input "${data_raw}/aggregators/MW/Measuring_worth.xlsx"
global output "${data_clean}/aggregators/MW/MW.dta"

* ==============================================================================
* 	US GDP
* ==============================================================================

* Open
import excel using "${input}", clear sheet("US_GDP") first

* Convert
replace pop = pop / 1000
replace nGDP = nGDP * 1000
replace rGDP = rGDP * 1000

* Save 
tempfile temp_master
save `temp_master', replace 

* ==============================================================================
* 	US PRICES
* ==============================================================================

* Open
import excel using "${input}", clear sheet("US_prices") first

* Save and merge
tempfile temp_c
save `temp_c', replace
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace 

* ==============================================================================
* 	UK GDP
* ==============================================================================

* Open
import excel using "${input}", clear sheet("UK_GDP") first

* Convert
replace pop = pop / 1000

* Save and merge
tempfile temp_c
save `temp_c', replace
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace 


* ==============================================================================
* 	UK PRICES
* ==============================================================================

* Open
import excel using "${input}", clear sheet("UK_prices") first

* Save and merge
tempfile temp_c
save `temp_c', replace
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace 

* ==============================================================================
* 	RATES
* ==============================================================================

* Open
import excel using "${input}", clear sheet("Rates") first

* Save and merge
tempfile temp_c
save `temp_c', replace
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace 

* ==============================================================================
* 	SPAIN DATA
* ==============================================================================

* Open
import excel using "${input}", clear sheet("ESP") first

* Convert
replace pop = pop / 1000

* Save and merge
tempfile temp_c
save `temp_c', replace
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace 

* ==============================================================================
* 	AUSTRALIA DATA
* ==============================================================================

* Open
import excel using "${input}", clear sheet("AUS") first

* Consolidate nominal GDP numbers pre-1966 based on irrevocable exchange rate 
replace nGDP = nGDP_GBP * 2 if year<=1966

* Convert
replace pop = pop / 1000000

* Save and merge
tempfile temp_c
save `temp_c', replace
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace 


* ==============================================================================
* 	EXCHANGE RATE DATA
* ==============================================================================

* Open
import excel using "${input}", clear sheet("exchange_rates") first

* Drop zero Won exchange rate 
drop if USDfx == "0.00 Won"

* Extract the exchange rate
replace USDfx = regexs(0) if regexm(USDfx, "^[0-9.]+")

* Extract
destring USDfx, replace

* Drop duplicates
duplicates tag ISO3 year, gen(d)
sort ISO3 year
by ISO3 year: keep if _n == _N
drop d

* Save and merge
tempfile temp_c
save `temp_c', replace
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace 

* Derive inflation rate
sort ISO3 year
encode ISO3, gen(id)
xtset id year
by id: gen infl = (CPI - L.CPI) / L.CPI * 100  if L.CPI != .
drop id

* Add source identifier
qui ds year ISO3, not
foreach var in `r(varlist)' {
	ren `var' MW_`var'
}

* Convert currency for european countries
merge m:1 ISO3 using $eur_fx, keep(1 3)
qui ds year ISO3 EUR_irrevocable_FX _merge, not
replace MW_USDfx   = MW_USDfx / EUR_irrevocable_FX if _merge == 3
drop EUR_irrevocable_FX _merge

* Fix issues with exchange rate
replace MW_USDfx = . if MW_USDfx == 0

* Argentina
replace MW_USDfx = MW_USDfx / 10000 if year <= 1991 & ISO3 == "ARG"
replace MW_USDfx = MW_USDfx / 1000  if year <= 1984 & ISO3 == "ARG"
replace MW_USDfx = MW_USDfx / 10000 if year <= 1982 & ISO3 == "ARG"
replace MW_USDfx = MW_USDfx / 100   if year <= 1969 & ISO3 == "ARG"

* Australia
replace MW_USDfx = MW_USDfx * 2  if year <= 1965 & ISO3 == "AUS"

* Chile
replace MW_USDfx = MW_USDfx / 1000 if year <= 1975 & ISO3 == "CHL"
replace MW_USDfx = MW_USDfx / 1000 if year <= 1959 & ISO3 == "CHL"

* Mexico
replace MW_USDfx = MW_USDfx / 1000 if year <= 1992 & ISO3 == "MEX"

* New Zealand
replace MW_USDfx = MW_USDfx * 2 if year <= 1967 & ISO3 == "NZL"

* Peru
replace MW_USDfx = MW_USDfx / 1000000 if year <= 1990 & ISO3 == "PER"
replace MW_USDfx = MW_USDfx / 1000    if year <= 1984 & ISO3 == "PER"

* South Africa
replace MW_USDfx = MW_USDfx * 2 if year <= 1960 & ISO3 == "ZAF"

* Brazil
replace MW_USDfx = MW_USDfx / 2750 if year <= 1994 & ISO3 == "BRA"
replace MW_USDfx = MW_USDfx / 1000 if year <= 1993 & ISO3 == "BRA"
replace MW_USDfx = MW_USDfx / 1000 if year <= 1988 & ISO3 == "BRA"
replace MW_USDfx = MW_USDfx / 1000 if year <= 1985 & ISO3 == "BRA"
replace MW_USDfx = MW_USDfx / 1000 if year <= 1966 & ISO3 == "BRA"

* Venezuela
replace MW_USDfx = MW_USDfx / 1000 if ISO3 == "VEN" & year <= 2008

* Israel
replace MW_USDfx = MW_USDfx / 1000 if ISO3 == "ISR" & year <= 1985

* France
replace MW_USDfx = MW_USDfx / 100 if ISO3 == "FRA" & year <= 1959

* Finland
replace MW_USDfx = MW_USDfx / 100 if ISO3 == "FIN" & year <= 1941

* Belgium
replace MW_USDfx = MW_USDfx / 5 if ISO3 == "BEL"  & inrange(year, 1927, 1940)

* Germany: Drop exchange rate before 1924 (hyperinflation)
replace MW_USDfx = . if ISO3 == "DEU"  & year <= 1924

* Venezuela: Drop exchange rate after 2018, can't be trusted.
replace MW_USDfx = . if ISO3 == "VEN" & year >= 2018

* Drop
drop MW_nGDP_GBP MW_nGDP_pc

* ==============================================================================
* 	REBASE REAL GDP AND DEFLATOR TO 2010
* ==============================================================================

/* 
	Rebase real GDP to 2010 
*/

* Get value in base year, apply to whole panel 
gen temp = MW_rGDP if year == 2010
bysort ISO3: egen rGDP2010 = max(temp)
drop temp 

* Get nominal GDP value in 2010 value, apply to whole panel 
gen temp = MW_nGDP if year == 2010 
bysort ISO3: egen nGDP2010 = max(temp)
drop temp 

* Calculate price level ratio for adjustment 
gen ratio = nGDP2010 / rGDP2010

* Adjust original values with ratio 
replace MW_rGDP = MW_rGDP * ratio 

* Drop temporary variables 
drop nGDP2010 rGDP2010 ratio 


/* 
	Rebase real GDP per capita to 2010 
*/

* Drop original values 
drop MW_rGDP_pc

* Calculate using rebased real GDP 
gen MW_rGDP_pc = MW_rGDP / MW_pop


/* 
	Rebase deflator to 2010 
*/

* Get value in base year, apply to whole panel 
gen temp = MW_deflator if year == 2010
bysort ISO3: egen defl2010 = max(temp)
drop temp 

* Adjust original values with ratio 
replace MW_deflator = MW_deflator * (100 / defl2010)

* Drop temporary variables 
drop defl2010 

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid year ISO3 

* Save
save "${output}", replace

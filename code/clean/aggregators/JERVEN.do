* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Clean Fiscal data for African countries from
* The Fiscal State in Africa: Evidence from a century of growth
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-10-07
*
* URL: https://www.mortenjerven.com/the-fiscal-state-in-africa-evidence-from-a-century-of-growth/
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
clear
global CPI "${data_raw}/aggregators/JERVEN/cpi_inflation.dta"
global input1 "${data_raw}/aggregators/JERVEN/FISCAL_PANEL_V4.dta"
global input2 "${data_raw}/aggregators/JERVEN/FISCAL_PANEL_V4_SOMDJI.dta"
global output "${data_clean}/aggregators/JERVEN/JERVEN.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open
use "${CPI}", clear

* Use Frankema Waijenburg as primary source and fill with Reinhard Rogoff when missing
gen infl = inflation_frankema_waijenburg
replace infl = inflation_reinhard_rogoff if infl == .

* Keep relevant columns
keep year iso infl

* Save
tempfile temp_master
save `temp_master', replace emptyok

* Open
use "${input1}", clear

* Generate total tax as the sum of indirect and direct taxes
gen govtax = INDIRECT_NOMINAL + DIRECT_NOMINAL

* Generate total revenue as the sum of taxes, ordinary revenue, extraordinary revenue and resource revenue
gen govrev = govtax + NONTAX_ORDINARY_NOMINAL + EXTRAORDINARY_NOMINAL + RESOURCES_NOMINAL

* Keep relevant columns
keep year iso govrev govtax POPULATION 

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year iso using `temp_master', nogen
save `temp_master', replace	

* Open
use "${input2}", clear

* Generate total tax as the sum of indirect and direct taxes
gen govtax = INDIRECT_NOMINAL + DIRECT_NOMINAL

* Generate total revenue as the sum of taxes, ordinary revenue, extraordinary revenue and resource revenue
gen govrev = govtax + NONTAX_ORDINARY_NOMINAL + EXTRAORDINARY_NOMINAL + RESOURCES_NOMINAL

* Keep relevant columns
keep year iso govrev govtax POPULATION

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year iso using `temp_master', nogen
save `temp_master', replace	

* Rename
ren (iso POPULATION) (ISO3 pop)

* Convert units
replace pop = pop / 1000000
replace govrev = govrev / 1000000
replace govtax = govtax / 1000000

* Convert currency by country
replace govrev = govrev / 100 if year < 1960 & ISO3 == "DZA"
replace govtax = govtax / 100 if year < 1960 & ISO3 == "DZA"

replace govrev = govrev * 1000 if ISO3 == "ZMB"
replace govtax = govtax * 1000 if ISO3 == "ZMB"

replace govrev = govrev * 20 if ISO3 == "UGA" & year <= 1965
replace govtax = govtax * 20 if ISO3 == "UGA" & year <= 1965

replace govrev = govrev / 1000 if ISO3 == "TUN" & year <= 1953
replace govtax = govtax / 1000 if ISO3 == "TUN" & year <= 1953

replace govrev = govrev * 20 if ISO3 == "TZA" & year <= 1962
replace govtax = govtax * 20 if ISO3 == "TZA" & year <= 1962

replace govrev = govrev / 20 if ISO3 == "TZA" & year <= 1914
replace govtax = govtax / 20 if ISO3 == "TZA" & year <= 1914

replace govrev = govrev * 20 if ISO3 == "KEN" & year <= 1963
replace govtax = govtax * 20 if ISO3 == "KEN" & year <= 1963

replace govrev = govrev / 10 if ISO3 == "SDN" & year <= 1995
replace govtax = govtax / 10 if ISO3 == "SDN" & year <= 1995

replace govrev = govrev / 100 if ISO3 == "SDN" & year <= 2005
replace govtax = govtax / 100 if ISO3 == "SDN" & year <= 2005

replace govrev = govrev / 1000 if ISO3 == "MOZ" & year <= 1941
replace govtax = govtax / 1000 if ISO3 == "MOZ" & year <= 1941

replace govrev = govrev * 1000 if ISO3 == "MOZ" & year <= 1973
replace govtax = govtax * 1000 if ISO3 == "MOZ" & year <= 1973

replace govrev = govrev / 1000 if ISO3 == "MOZ" & inrange(year, 2002, 2004)
replace govtax = govtax / 1000 if ISO3 == "MOZ" & inrange(year, 2002, 2004)

replace govrev = govrev / 1000 if ISO3 == "MOZ" & year <= 2001
replace govtax = govtax / 1000 if ISO3 == "MOZ" & year <= 2001

replace govrev = govrev / 100 if ISO3 == "MAR" & year <= 1962
replace govtax = govtax / 100 if ISO3 == "MAR" & year <= 1962

replace govrev = govrev / 10 if ISO3 == "MRT" 
replace govtax = govtax / 10 if ISO3 == "MRT" 

replace govrev = govrev / 10000 if ISO3 == "GHA" & year <= 2004
replace govtax = govtax / 10000 if ISO3 == "GHA" & year <= 2004

replace govrev = govrev * (10^-3) if year <= 1994 & year >= 1974 & ISO3 == "AGO"
replace govtax = govtax * (10^-3) if year <= 1994 & year >= 1974 & ISO3 == "AGO"


replace govrev = govrev * (10^3) if inrange(year, 1942, 1972) & ISO3 == "GNB"
replace govrev = govrev * (10^3) if inrange(year, 1930, 1934) & ISO3 == "GNB"

replace govtax = govtax * (10^3) if inrange(year, 1942, 1972) & ISO3 == "GNB"
replace govtax = govtax * (10^3) if inrange(year, 1930, 1934) & ISO3 == "GNB"

replace govrev = govrev / 20 if ISO3 == "NAM" & year <= 1911
replace govtax = govtax / 20 if ISO3 == "NAM" & year <= 1911

replace govrev = govrev / 1000 if ISO3 == "ZMB" 
replace govtax = govtax / 1000 if ISO3 == "ZMB" 

replace govrev = govrev / 480 if ISO3 == "LBY" 
replace govtax = govtax / 480 if ISO3 == "LBY" 

replace govrev = govrev / 3000 if ISO3 == "COD" & year <= 1993
replace govtax = govtax / 3000 if ISO3 == "COD" & year <= 1993

replace govrev = govrev / 1000 if ISO3 == "COD" & year <= 1995
replace govtax = govtax / 1000 if ISO3 == "COD" & year <= 1995

replace govrev = govrev / 1000 if ISO3 == "COD" & year <= 1962
replace govtax = govtax / 1000 if ISO3 == "COD" & year <= 1962



* Add source identifier
qui ds year ISO3, not
foreach var in `r(varlist)'{
	ren `var' JERVEN_`var'
}


* ===============================================================================
* 	Output
* ===============================================================================

* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace

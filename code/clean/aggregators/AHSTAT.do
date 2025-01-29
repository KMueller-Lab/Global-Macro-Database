* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and clean historical data from Asian Historical Statistics (AHSTAT)
*
* Author:
* Ziliang Chen
* National University of Singapore
*
* Created: 2024-11-11
*
* URL: https://d-infra.ier.hit-u.ac.jp/English/ltes/a000.html
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
* Clear
clear
global input "${data_raw}/aggregators/AHSTAT"
global output "${data_clean}/aggregators/AHSTAT/AHSTAT"

* ==============================================================================
*	CHN
* ==============================================================================

* Open
import excel using "${input}/CHN", clear sheet("national_accounts") first

* Save
tempfile temp_master
save `temp_master', replace emptyok

* Open
local sheets pop emp gov currency money
foreach sheet of local sheets{
	
	* Open
	import excel using "${input}/CHN", clear sheet("`sheet'") first
	
	* Sort
	sort year
	
	* Save and merge
	tempfile temp_c
	save `temp_c', replace emptyok
	merge 1:1 year using `temp_master', nogen
	save `temp_master', replace	
	
}

* Add country's ISO3
gen ISO3 = "CHN"

* Fix exchange rate units
replace USDfx = USDfx / 100 

* Save to temp_master
save `temp_master', replace

* ==============================================================================
*	JPN
* ==============================================================================

* Open
import excel using "${input}/JPN", clear sheet("national_accounts") first

* Save
tempfile temp_JPN
save `temp_JPN', replace emptyok

* Open
local sheets pop finv money gov prices trade
foreach sheet of local sheets{
	
	* Open
	import excel using "${input}/JPN", clear sheet("`sheet'") first
	
	* Sort
	sort year
	
	* Save and merge
	tempfile temp_c
	save `temp_c', replace emptyok
	merge 1:1 year using `temp_JPN', nogen
	save `temp_JPN', replace	
}

* Add country's ISO3
gen ISO3 = "JPN"

* Derive inflation rate
sort ISO3 year
encode ISO3, gen(id)
xtset id year
by id: gen infl = (CPI - L.CPI) / L.CPI * 100
drop id

* Convert units
replace pop    = pop   / 1000000
replace USDfx  = USDfx / 100
replace USDfx  = 1     / USDfx

* Merge with temp_master
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace	

* ==============================================================================
*	KOR
* ==============================================================================

* Open
import excel using "${input}/KOR", clear sheet("trade") first

* Save
tempfile temp_KOR
save `temp_KOR', replace emptyok

* Open
local sheets emp expenditure
foreach sheet of local sheets{
	
	* Open
	import excel using "${input}/KOR", clear sheet("`sheet'") first
	
	* Sort
	sort year
	
	* Save and merge
	tempfile temp_c
	save `temp_c', replace emptyok
	merge 1:1 year using `temp_KOR', nogen
	save `temp_KOR', replace	
	
}

* Add country's ISO3
gen ISO3 = "KOR"

* Merge with temp_master
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace	

* ==============================================================================
*	RUS_1
* ==============================================================================

* Import nominal GDP
import excel using "${input}/RUS_1" , clear sheet("9.3.3")

* Drop unnecessary rows 
drop in 1/13

* Rename variables 
ren A year 
ren B nGDP
ren C cons
keep year nGDP cons

drop in 32/37

* Destring  
destring *, replace 

* Make country code 
gen ISO3 = "RUS"

* Merge with temp_master
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace	

* ==============================================================================
*	RUS_2 (including SUN)
* ==============================================================================

* Import real GDP 1860 - 1913
import excel using "${input}/RUS_2" , clear sheet("9.1.1")

* Drop unnecessary rows 
drop in 1/10

* Rename variables 
ren B year 
ren M SUN_rGDP
ren N RUS_rGDP // Pick "Modern Russia" GDP, not historical Russian empire
keep year RUS_rGDP SUN_rGDP

drop in 55/63

* Make numeric variables 
destring *, replace 

* Save Russian Data
preserve 
drop SUN_rGDP 
ren RUS_rGDP rGDP
gen ISO3 = "RUS"

* Merge with temp_master
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace	
restore 

* Save Soviet Union Data 
drop RUS_rGDP 
ren SUN_rGDP rGDP 
gen ISO3 = "SUN"

* Merge with temp_master
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace	

* ==============================================================================
*	RUS_3
* ==============================================================================
* Import real GDP 1913 - 1990
import excel using "${input}/RUS_3", clear sheet("9.2.1")

* Drop unnecessary rows 
drop in 1/7

* Rename variables 
ren A year 
replace year = substr(year,1,4)
keep year J

* Drop missing GDP growth (arising from change in price levels)
drop if inlist(J,""," ") & _n>1 

* Make GDP variables numeric 
destring *, replace 

* Rename
ren J rGDP_yoy

* Make country code 
gen ISO3 = "RUS"

* Merge with temp_master
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace	

sort ISO3 year

* Calcualte rGDP for RUS from 1914 to 1990
replace rGDP = rGDP[_n-1] * (1+ rGDP_yoy / 100) if ISO3 == "RUS" & year >= 1914

drop rGDP_yoy

save `temp_master', replace	

* ==============================================================================
*	TWN
* ==============================================================================
* Open nominal data 
import excel using "${input}/TWN", clear sheet("Table0.1")

* Only keep relevant columns 
keep A G H I J

* Rename 
ren A	year
ren G 	nGDP
ren H 	cons
ren J 	inv
ren I 	govexp


* Drop unnecessary rows 
drop in 1/7
drop in 49/55
destring *, replace 
drop if year == .

* Save
tempfile temp_TWN
save `temp_TWN', replace emptyok

* Open real GDP data 
import excel using "${input}/TWN", clear sheet("Table0.2")

* Only keep relevant columns 
keep A G 

* Rename 
ren A	year
ren G 	rGDP

* Drop unnecessary rows 
drop in 1/7
drop in 49/55
destring *, replace 
drop if year == .

* Merge back with nominal data 
merge 1:1 year using `temp_TWN', nogen
save `temp_TWN', replace	

* Generate ISO
gen ISO3 = "TWN"

* Convert units
ds year ISO3 rGDP, not
foreach var in `r(varlist)'{
	replace `var' = `var' / (10^6) if year <= 1948 & ISO3 == "TWN"
}

* Merge with temp_master
merge 1:1 year ISO3 using `temp_master', nogen
save `temp_master', replace	

* Add ratios to gdp variables
gen cons_GDP    = (cons / nGDP) * 100
gen imports_GDP = (imports / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100
gen govexp_GDP  = (govexp / nGDP) * 100
gen govrev_GDP  = (govrev / nGDP) * 100
gen govtax_GDP  = (govtax / nGDP) * 100
gen finv_GDP    = (finv / nGDP) * 100
gen inv_GDP     = (inv / nGDP) * 100


* ==============================================================================
* 	Output
* ==============================================================================
* Add source identifier
qui ds year ISO3, not
foreach var in `r(varlist)'{
	ren `var' AHSTAT_`var'
}

* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace

* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Description: 
* This Stata script opens and cleans macroeconomic data from the 
* Jordà-Schularick-Taylor Macrohistory Database.
*
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-06-25
*
* URL:
* https://www.macrohistory.net/database/
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================

* Clear 
clear

* First run WDI because we will use later 
do "$code_clean/aggregators/WDI.do"
clear

* Define input and output files
global input "${data_raw}/aggregators/JST/JSTdatasetR6.dta"
global output "${data_clean}/aggregators/JST/JST.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open 
use "${input}", clear

* Rename
ren (iso pop gdp iy cpi xrusd ca imports exports stir ltrate unemp debtgdp revenue expenditure hpnom money narrowm crisisJST rgdpbarro) (ISO3 JST_pop JST_nGDP JST_inv_GDP JST_CPI JST_USDfx JST_CA_LCU JST_imports JST_exports JST_strate JST_ltrate JST_unemp JST_govdebt_GDP JST_govrev JST_govexp JST_HPI JST_BroadM JST_NarrowM JST_crisisB JST_rGDP_pc_index )

* Keep only relevant variables
keep ISO3 year JST_*

* Drop rows with missing data
qui ds ISO3 year, not
missings dropobs `r(varlist)', force

* Identify M1 M2 and M3 for different countries based on JST documentation
gen JST_M0 =.
gen JST_M1 =.
gen JST_M2 =.
gen JST_M3 =.
gen JST_M4 =.

* M0
foreach c in NOR GBR USA {
	replace JST_M0 = JST_NarrowM if ISO3 == "`c'"
}

* M1
foreach c in AUS BEL CAD DNK FIN FRA DEU IRL ITA JPN NLD PRT ESP SWE CHE {
	replace JST_M1 = JST_NarrowM if ISO3 == "`c'"
}

* M2
foreach c in DNK CAD FIN FRA DEU IRL ITA JPN NLD NOR PRT {
	replace JST_M2 = JST_BroadM if ISO3 == "`c'"
}

* M3
foreach c in AUS BEL ESP SWE CHE USA {
	replace JST_M3 = JST_BroadM if ISO3 == "`c'"
}

* M4
replace JST_M4 = JST_BroadM if ISO3 == "GBR"


* Drop
drop JST_NarrowM JST_BroadM

* Convert JST_CA_LCU to JST_CA_GDP
gen JST_CA_GDP = 100 * (JST_CA_LCU / JST_nGDP)

* Convert JST_REVENUE_LCU to JST_REVENUE_GDP
gen JST_govrev_GDP = 100 * (JST_govrev / JST_nGDP)

* Convert JST_govexp to JST_govexp_GDP
gen JST_govexp_GDP = 100 * (JST_govexp / JST_nGDP)


* Convert JST_govdebt_GDP to percentage
replace JST_govdebt_GDP = JST_govdebt_GDP * 100

* Drop
drop JST_CA_LCU 

* Rescale indices so that 2010=100 (in raw data: 1990=100)
foreach var in JST_CPI JST_HPI {
	gen temp=`var' if year==2010
	bysort ISO3: egen scaler=max(temp)
	replace `var'=`var'*(100/scaler)
	drop temp scaler
}

* Define input files
global input ""${data_raw}/EUR/EUR_irrevocable_FX.dta""

* Merge in data on irrevocable Euro exchange rates 
merge m:1 ISO3 using "$eur_fx", keep(1 3) nogen 

* Convert national currency numbers for Eurozone members
foreach var in nGDP exports imports M0 M1 M2 M3 M4 govrev govexp USDfx {
	replace JST_`var' = JST_`var' / EUR_irrevocable_FX if EUR_irrevocable_FX!=.
}

drop EUR_irrevocable_FX

* Convert JST_inv_GDP to JST_inv
gen JST_inv = JST_inv_GDP * JST_nGDP
drop JST_inv_GDP
	
* Convert pop to millions
replace JST_pop = JST_pop / 1000

foreach c in USA CAN DNK FRA DEU ITA GBR {
	* Convert units to million
	foreach var in nGDP exports imports inv M0 M1 M2 M3 M4 {
		replace JST_`var' = JST_`var' * 1000 if ISO3 == "`c'"
	}
}

* Convert Japanese data to millions from trillions
foreach var in nGDP exports imports inv M1 M2 govexp govrev{
	replace JST_`var' = JST_`var' * 1000000 if ISO3 == "JPN"
}


* Derive inflation rate
sort ISO3 year
encode ISO3, gen(id)
xtset id year
by id: gen JST_infl = (JST_CPI - L.JST_CPI) / L.JST_CPI * 100 if L.JST_CPI != .
drop id

* Convert units for govexp
replace JST_govexp = JST_govexp * 1000
replace JST_govrev = JST_govrev * 1000

local countries AUS BEL CHE ESP FIN IRL JPN NLD NOR PRT SWE
foreach country of local countries {
	replace JST_govexp = JST_govexp / 1000 if ISO3 == "`country'"
	replace JST_govrev = JST_govrev / 1000 if ISO3 == "`country'"
}

* Add ratios to gdp variables
gen JST_imports_GDP = (JST_imports / JST_nGDP) * 100
gen JST_exports_GDP = (JST_exports / JST_nGDP) * 100
gen JST_inv_GDP     = (JST_inv / JST_nGDP) * 100


* ==============================================================================
* 	SPLICE JST REAL GDP PER CAPITA USING REAL GDP PER CAPITA FROM WDI
* ==============================================================================
* Merge in the dataset
merge 1:1 ISO3 year using "${data_clean}/aggregators/WB/WDI", nogen keep(1 3) keepus(WDI_rGDP_pc)

* Rename Barro 
ren JST_rGDP_pc_index JST_rGDP_pc

* Splice
splice, priority(WDI JST) generate(rGDP_pc) varname(rGDP_pc) method("chainlink") base_year(2006) save("NO")

* Rename 
drop JST_rGDP_pc
ren rGDP_pc JST_rGDP_pc

* Keep relevant variables 
keep ISO3 year JST*

* ==============================================================================
* 	Derive Real GDP for the entire country 
* ==============================================================================

* Calculate 
gen JST_rGDP = JST_rGDP_pc * JST_pop 

* Keep relevant variables 
keep ISO3 year  JST*

* Add government debt levels 
gen JST_govdebt = (JST_govdebt_GDP * JST_nGDP) / 100

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

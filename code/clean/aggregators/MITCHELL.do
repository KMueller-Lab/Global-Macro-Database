* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Description: 
* This Stata script reads in and cleans data from Mitchell (2013).
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-10-09
*
* ==============================================================================

* ==============================================================================
* SET UP 
* ==============================================================================

* Clear data 
clear

* Define output file
global input "${data_temp}/MITCHELL/"
global output "${data_clean}/aggregators/MITCHELL/Mitchell.dta"

* ==============================================================================
* CLEAN DATA
* ==============================================================================

* List files
filelist, directory("${input}") pat(*.dta)
gen dir = dirname + filename

* Import the first file
local f = dir[1]
drop in 1
qui levelsof dir, local(files)
use "`f'", clear

* Save
tempfile temp_master
save `temp_master', replace emptyok

* Merge the files
foreach file of local files {
	
	* Open
	use "`file'", replace
	
	* Merge and save
	qui tempfile temp_c
	qui save `temp_c', replace emptyok
	qui merge m:m year countryname using `temp_master', nogen
	qui save `temp_master', replace
	
}

* Fix country names
replace countryname = "Burkina Faso" 			 			if countryname == "BurkinaFaso"
replace countryname = "Central African Republic" 			if countryname == "CentralAfricanRepublic"
replace countryname = "Democratic Republic of the Congo" 	if countryname == "Zaire"
replace countryname = "Republic of the Congo" 				if countryname == "Congo"
replace countryname = "Costa Rica" 							if countryname == "CostaRica"
replace countryname = "Dominican Republic" 					if countryname == "DominicanRepublic"
replace countryname = "German Democratic Republic" 			if countryname == "EastGermany"
replace countryname = "El Salvador" 						if countryname == "ElSalvador"
replace countryname = "Hawaii" 								if countryname == "Hawaii"
replace countryname = "Hong Kong" 							if countryname == "HongKong"
replace countryname = "Ivory Coast" 						if countryname == "IvoryCoast"
replace countryname = "New Zealand" 						if countryname == "NewZealand"
replace countryname = "Papua New Guinea" 					if inlist(countryname, "Papua-NewGuinea", "PapuaNewGuinea")
replace countryname = "Puerto Rico" 						if countryname == "PuertoRico"
replace countryname = "Russian Federation" 					if countryname == "Russia"
replace countryname = "Saudi Arabia" 						if countryname == "SaudiArabia"
replace countryname = "Sierra Leone" 						if countryname == "SierraLeone"
replace countryname = "South Africa" 						if countryname == "SouthAfrica"
replace countryname = "South Korea" 						if countryname == "SouthKorea"
replace countryname = "Sri Lanka" 							if countryname == "SriLanka"
replace countryname = "Trinidad and Tobago" 				if countryname == "TrinidadandTobago"
replace countryname = "United States" 						if countryname == "USA"
replace countryname = "Soviet Union" 						if countryname == "USSR"
replace countryname = "United Kingdom" 						if countryname == "UnitedKingdom"
replace countryname = "United Arab Emirates" 				if countryname == "UnitedArabEmirates"
replace countryname = "North Korea"							if countryname == "NorthKorea"
replace countryname = "Czech Republic"						if countryname == "CzechRepublic"

drop if countryname == "Hawaii"
drop if countryname == "Korea"
drop if countryname == "FrenchEquatorialAfrica"
drop if countryname == "FrenchWestAfrica"
drop if countryname == "NIreland"
drop if countryname == "FrenchEquatorialAfrica"

* Extract ISO3
merge m:1 countryname using $isomapping, nogen keep(3) keepus(ISO3)
drop countryname

* Convert currency for Eurozone countries
merge m:1 ISO3 using $eur_fx, keep(1 3)
qui ds govexp exports imports govrev CA
foreach var in `r(varlist)'{
	replace `var' = `var'/EUR_irrevocable_FX if _merge == 3 & year <= 1993 & ISO3 != "CYP"
}
replace M1 = M1 / EUR_irrevocable_FX if _merge == 3 & year <= 1998 & ISO3 != "CYP"
replace M2 = M2 / EUR_irrevocable_FX if _merge == 3 & year <= 1998 & ISO3 != "CYP"
replace M0 = M0 / EUR_irrevocable_FX if _merge == 3 & year <= 1998 & ISO3 != "CYP"
replace nGDP_LCU = nGDP_LCU / EUR_irrevocable_FX if _merge == 3 & year <= 1998 & ISO3 != "CYP"
replace rGDP_LCU = rGDP_LCU / EUR_irrevocable_FX if _merge == 3 & year <= 1998 & ISO3 != "CYP"
replace govtax = govtax / EUR_irrevocable_FX if _merge == 3 & year <= 1999 & ISO3 != "CYP"

replace inv = inv / EUR_irrevocable_FX if _merge == 3 
qui ds year ISO3 EUR_irrevocable_FX _merge inv *USD, not
foreach var in `r(varlist)'{
	replace `var' = `var'/EUR_irrevocable_FX if _merge == 3 & ISO3 == "CYP"
}
drop EUR_irrevocable_FX _merge


* Derive trade variables using BIS exchange rate
merge 1:1 ISO3 year using "${data_clean}/aggregators/BIS/BIS_USDfx.dta", nogen
replace imports = imports_USD * BIS_USDfx if imports == .
replace exports = exports_USD * BIS_USDfx if exports == .
drop BIS_USDfx

* Exchange rate doesn't allow the correct conversion of trade values to USD for Congo
replace imports = . if year >= 1989 & ISO3 == "COD"
replace exports = . if year >= 1989 & ISO3 == "COD"

* Data on Indonesia shows values that are likely to be wrong
replace imports = . if year <= 1974 & ISO3 == "IDN"
replace exports = . if year <= 1974 & ISO3 == "IDN"
replace govtax = . if ISO3 == "IDN"

* Data on Russia will be dropped due to inconsistent definitions
replace inv = . if ISO3 == "RUS"

* Calculate gross capital formation as the sum of fixed capital formation and stocks
replace inv = finv + stocks if stocks != . & inv == .
drop stocks

* Data on Turkey shows values that are likely to be wrong
replace govtax = . if ISO3 == "TUR"
replace govrev = . if ISO3 == "TUR"
replace govexp = . if ISO3 == "TUR"

* Data on Argentina shows values that are likely to be wrong
replace govtax = . if ISO3 == "ARG"

* Poland showcases values that are not trusted to be correct 
replace inv = . if ISO3 == "POL"

* Add ratios to gdp variables
gen Mitchell_imports_GDP = (imports / nGDP) * 100
gen Mitchell_exports_GDP = (exports / nGDP) * 100
gen Mitchell_govexp_GDP  = (govexp / nGDP) * 100
gen Mitchell_govrev_GDP  = (govrev / nGDP) * 100
gen Mitchell_govtax_GDP  = (govtax / nGDP) * 100
gen Mitchell_finv_GDP    = (finv / nGDP) * 100
gen Mitchell_inv_GDP     = (inv / nGDP) * 100


* Poland showcases values that are not trusted to be correct 
replace Mitchell_imports_GDP = . if inrange(year, 1982, 1990) & ISO3 == "POL"
replace Mitchell_exports_GDP = . if inrange(year, 1982, 1990) & ISO3 == "POL"

* Greece showcases values that are not trusted to be correct 
replace Mitchell_imports_GDP = . if year <= 1940 & ISO3 == "GRC"
replace Mitchell_exports_GDP = . if year <= 1940 & ISO3 == "GRC"

* Data on Brazil shows values that are likely to be wrong
replace Mitchell_imports_GDP = . if year <= 1948 & ISO3 == "BRA"
replace Mitchell_exports_GDP = . if year <= 1948 & ISO3 == "BRA"

* Data on Turkey shows values that are likely to be wrong
replace Mitchell_imports_GDP = . if inrange(year, 1994, 1998) & ISO3 == "TUR"
replace Mitchell_exports_GDP = . if inrange(year, 1994, 1998) & ISO3 == "TUR"

* Data for Nicaragua is unlikely to be correct
replace Mitchell_govrev_GDP = . if ISO3 == "NIC"
replace Mitchell_govexp_GDP = . if ISO3 == "NIC"

* Data on trade for Chile is not correct because it's in a different currency than nGDP and we don't have the exchange rate
replace Mitchell_imports_GDP = . if year <= 1955 & ISO3 == "CHL"
replace Mitchell_exports_GDP = . if year <= 1955 & ISO3 == "CHL"

* Data on  the following countries is likely on current account balance
replace CA = . if inlist(ISO3, "ECU", "IRQ", "MEX", "SLE", "SDN", "TWN", "VEN", "ZMB")
replace CA_USD = . if inlist(ISO3, "ECU", "IRQ", "MEX", "SLE", "SDN", "TWN", "VEN", "ZMB")
replace Mitchell_govtax_GDP = . if ISO3 == "GRC" & year <= 1940

* Add government deficit as the difference between government revenue and expenditure
gen govdef_GDP = Mitchell_govexp_GDP - Mitchell_govrev_GDP
gen govdef     = Mitchell_govexp - Mitchell_govrev

* Rename
ren nGDP_LCU 	Mitchell_nGDP
ren rGDP_LCU 	Mitchell_rGDP
ren govexp   	Mitchell_govexp
ren imports  	Mitchell_imports
ren exports  	Mitchell_exports
ren exports_USD Mitchell_exports_USD
ren imports_USD Mitchell_imports_USD
ren M1 			Mitchell_M1
ren M2 			Mitchell_M2
ren M0			Mitchell_M0
ren CPI 		Mitchell_CPI
ren govrev 		Mitchell_govrev
ren govtax 		Mitchell_govtax
ren finv		Mitchell_finv
ren inv			Mitchell_inv
ren CA			Mitchell_CA
ren CA_USD		Mitchell_CA_USD
ren govdef_GDP	Mitchell_govdef_GDP
ren infl	 	Mitchell_infl

* All data for Yugoslavia and Zimbabwe is likely to be wrong
drop if inlist(ISO3, "YUG", "SRB", "ZMB")




* ==============================================================================
* 			Final set up
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace

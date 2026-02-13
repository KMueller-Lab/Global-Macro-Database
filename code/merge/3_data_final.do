* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* MERGE FINAL DATASETS
*
* ==============================================================================
* OPEN BLANK COUNTRY-YEAR PANEL 
* ==============================================================================

* Open master list of countries 
use "$data_temp/blank_panel", clear 

* ==============================================================================
* MERGE IN ALL DATASETS WHILE CHECKING CONSISTENCY 
* ==============================================================================

* Preserve 
preserve 

* Get files 
filelist, directory($data_final) pat(*.dta) 

* Keep only individual files we need
drop if strpos(filename,"clean_data_wide.dta")
drop if strpos(filename,"data_final.dta")
drop if strpos(filename,"documentation.dta")
drop if strpos(filename,"documentation")
drop if strpos(filename,"GMD.xlsx")
drop if strpos(filename,"GMD")

* Make list of actual files 
replace filename = dirname+"/"+filename
levelsof filename, loc(files)

* Extract varnames from filenames
gen identifier = regexs(1) if regexm(filename, "chainlinked_(.+)\.dta")
levelsof identifier, local(varnames) clean

* Restore 
restore 

* Loop 
foreach file of loc files {

	* Print name of file that is being merged
	if regexm("`file'", "chainlinked_(.+)\.dta") local printname = regexs(1)
	if strpos("`file'", "SovDebtCrisis.dta") > 0 local printname = "SovDebtCrisis"
	if strpos("`file'", "CurrencyCrisis.dta") > 0 local printname = "CurrencyCrisis"
	if strpos("`file'", "BankingCrisis.dta") > 0 local printname = "BankingCrisis"
	di "Merging file `printname'"

	* Merge 
	qui merge 1:1 ISO3 year using "`file'", update keepus(`printname')
	
	
	* Check that countries are in master panel 
	qui levelsof ISO3 if _merge == 2, loc(errorcountries) clean 
	if "`errorcountries'"!="" {
		di as err "Cannot merge because the following countries are not in the master list:"
		di as err "`errorcountries'"
		exit 198
	}
	
	* Check that years are in master panel 
	qui levelsof year if _merge == 2, loc(erroryears)
	if "`erroryears'"!="" {
		di as err "Cannot merge because the following years are not in the master list:"
		di as err "`erroryears'"
		exit 198
	}
	
	* Drop merge 
	drop _merge
}
 
* Keep 
keep ISO3 year `varnames' SovDebtCrisis CurrencyCrisis BankingCrisis

* Label the variables 
label variable ISO3 		  "ISO3 code"
label variable year 		  "Year"
label variable SovDebtCrisis  "Sovereign Debt Crisis"
label variable CurrencyCrisis "Currency Crisis"
label variable BankingCrisis  "Banking Crisis"
label variable nGDP 		  "Nominal Gross Domestic Product"
label variable nGDP_USD 	  "Nominal Gross Domestic Product in USD"
label variable rGDP 		  "Real Gross Domestic Product, in 2015 prices"
label variable deflator 	  "GDP deflator"
label variable rGDP_pc 		  "Real Gross Domestic Product per Capita"
label variable rGDP_USD 	  "Real Gross Domestic Product in USD"
label variable inv 			  "Total Investment"
label variable inv_USD 		  "Total Investment in USD"
label variable inv_GDP 		  "Total Investment as % of GDP"
label variable finv 		  "Fixed Investment"
label variable finv_GDP       "Fixed Investment as % of GDP"
label variable cons 		  "Total Consumption"
label variable cons_USD       "Total Consumption in USD"
label variable cons_GDP       "Total Consumption as % of GDP"
label variable exports 	   	  "Total Exports"
label variable exports_USD    "Total Exports in USD"
label variable exports_GDP 	  "Total Exports as % of GDP"
label variable imports 	   	  "Total Imports"
label variable imports_USD 	  "Total Imports in USD"
label variable imports_GDP    "Total Imports as % of GDP"
label variable CA 		   	  "Current Account Balance"
label variable CA_GDP 		  "Current Account Balance as % of GDP"
label variable govexp 		  "Consolidated government Expenditure"
label variable cgovexp 		  "Central government Expenditure"
label variable govexp_GDP     "Consolidated government Expenditure as % of GDP"
label variable cgovexp_GDP    "Central government Expenditure as % of GDP"
label variable govrev  	   	  "Consolidated government Revenue"
label variable cgovrev  	  "Central government Revenue"
label variable govrev_GDP     "Consolidated government Revenue as % of GDP"
label variable cgovrev_GDP    "Central government Revenue as % of GDP"
label variable govtax 		  "Consolidated government Tax Revenue"
label variable cgovtax 		  "Central government Tax Revenue"
label variable govtax_GDP     "Central government Tax Revenue as % of GDP"
label variable cgovtax_GDP    "Central government Tax Revenue as % of GDP"
label variable cgovdef 		  "Central government Deficit"
label variable cgovdef_GDP 	  "Central government Deficit as % of GDP"
label variable govdebt   	  "Consolidated government Debt"
label variable cgovdebt   	  "Central government Debt"
label variable govdebt_GDP    "Consolidated government Debt as % of GDP"
label variable cgovdebt_GDP   "Central government Debt as % of GDP"
label variable gen_govexp     "General government Expenditure"
label variable gen_govexp_GDP "General gentral government Expenditure as % of GDP"
label variable gen_govrev     "General government Revenue"
label variable gen_govrev_GDP "General government Revenue as % of GDP"
label variable gen_govtax 	  "General government Tax Revenue"
label variable gen_govtax_GDP "General government Tax Revenue as % of GDP"
label variable gen_govdef 	  "General government Deficit"
label variable gen_govdef_GDP "General government Deficit as % of GDP"
label variable gen_govdebt 	  "General government Debt"
label variable gen_govdebt_GDP "General government Debt as % of GDP"
label variable govexp 		  "Consolidated government Expenditure"
label variable govrev 		  "Consolidated government Revenue"
label variable govtax 		  "Consolidated government Tax Revenue"
label variable govdef 		  "Consolidated government Deficit"
label variable govdebt 		  "Consolidated government Debt"
label variable CPI 			  "Consumer Price Index, 2010 = 100"
label variable HPI 			  "House Price Index"
label variable infl 		  "Inflation Rate"
label variable pop 			  "Population"
label variable unemp 		  "Unemployment Rate"
label variable USDfx 		  "Exchange Rate against USD"
label variable REER 		  "Real Effective Exchange Rate, 2010 = 100"
label variable strate 		  "Short-term Interest Rate"
label variable ltrate 		  "Long-term Interest Rate"
label variable cbrate 		  "Central Bank Policy Rate"
label variable M0 			  "M0 Money Supply"
label variable M1 			  "M1 Money Supply"
label variable M2 			  "M2 Money Supply"
label variable M3 			  "M3 Money Supply"
label variable M4 			  "M4 Money Supply"

* Keep the first year with data for every country 
qui ds ISO3 year, not
local vars `r(varlist)'
qui egen all_missing = rowmiss(`vars')
qui replace all_missing = (all_missing == `:word count `vars'')

* Sort by country and year
sort ISO3 year
qui bysort ISO3 (year): egen first_year = min(year) if all_missing == 0
qui bysort ISO3: egen first_year_final = min(first_year)
qui keep if year >= first_year_final

* Drop 
drop all_missing first_year first_year_final

* Drop the years with no data for every country 
qui ds ISO3 year, not
local vars `r(varlist)'
qui egen all_missing = rowmiss(`vars')
qui replace all_missing = (all_missing == `:word count `vars'')

* Sort by country and year
sort ISO3 year
qui bysort ISO3 (year): egen last_year = max(year) if all_missing == 0
qui bysort ISO3: egen last_year_final = max(last_year)
qui keep if year <= last_year_final

* Drop 
drop all_missing last_year last_year_final

* Sort data
sort ISO3 year

* Add country name 
merge m:1 ISO3 using $isomapping, keepus(countryname) assert(2 3) keep(3) nogen

* Order
order countryname ISO3 year nGDP nGDP_USD rGDP rGDP_pc rGDP_USD deflator cons cons_GDP cons_USD inv inv_GDP inv_USD finv finv_GDP finv_USD exports exports_GDP exports_USD imports imports_GDP imports_USD CA CA_GDP USDfx REER govexp gen_govexp gen_govexp_GDP cgovexp cgovexp_GDP govrev gen_govrev cgovrev gen_govrev_GDP cgovrev_GDP govtax gen_govtax cgovtax gen_govtax_GDP cgovtax_GDP govdef_GDP gen_govdef_GDP gen_govdef cgovdef_GDP cgovdef govdebt_GDP gen_govdebt_GDP gen_govdebt cgovdebt_GDP cgovdebt HPI CPI infl pop unemp strate ltrate cbrate M0 M1 M2 M3 M4 SovDebtCrisis CurrencyCrisis BankingCrisis

* Make country names shorter
replace countryname = "St-Helena" if countryname == "Saint Helena, Ascension and Tristan da Cunha"
replace countryname = "USA Minor Outlying Islands" if countryname == "United States Minor Outlying Islands"
replace countryname = "Congo DR" if countryname == "Democratic Republic of the Congo"
replace countryname = "Micronesia" if countryname == "Micronesia (Federated States of)"
replace countryname = "St-Vincent" if countryname == "Saint Vincent and the Grenadines"
replace countryname = "Bonaire" if countryname == "Bonaire, Sint Eustatius and Saba"
replace countryname = "East Germany" if countryname == "German Democratic Republic"
replace countryname = "St-Pierre" if countryname == "Saint Pierre and Miquelon"
replace countryname = "Turks and Caicos" if countryname == "Turks and Caicos Islands"

* Recast
recast str3 ISO3
recast str26 countryname

* Set the panel
encode ISO3, gen(id)
xtset id year

* Label countryname
label variable countryname "Country name"

* Sort
sort ISO3 year

* Order 
order countryname ISO3 id year

* Add income groups 
merge m:1 ISO3 using "$data_helper/WB_income_groups", nogen

* Save 
save "$data_final/data_final", replace 

* Output
local version = "$current_version"
save "$data_distr/GMD_`version'", replace
save "$data_distr/GMD", replace

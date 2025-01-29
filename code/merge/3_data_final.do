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
	loc printname = subinstr("`file'","${data_final}/","",.)
	di "Merging file `printname'"

	* Merge 
	qui merge 1:1 ISO3 year using "`file'", update
	
	
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

* Calculate the real GDP per capita
gen rGDP_pc = (rGDP/pop)

* Calculate the deflator
gen deflator = (nGDP / rGDP) * 100

* Calculate variables in nominal terms
gen govdebt = (govdebt_GDP * nGDP) / 100
gen govdef = (govdef_GDP * nGDP) / 100
gen CA = (CA_GDP * nGDP) / 100

* Label the variables 
label variable ISO3 "ISO3 code"
label variable year "Year"
label variable SovDebtCrisis "Sovereign Debt Crisis"
label variable CurrencyCrisis "Currency Crisis"
label variable BankingCrisis "Banking Crisis"
label variable nGDP "Nominal Gross Domestic Product"
label variable rGDP "Real Gross Domestic Product"
label variable deflator "GDP deflator"
label variable rGDP_pc "Real Gross Domestic Product per Capita"
label variable rGDP_USD "Real Gross DOmestic Product in USD"
label variable inv "Total Investment"
label variable inv_GDP "Total Investment as % of GDP"
label variable finv "Fixed Investment"
label variable finv_GDP "Fixed Investment as % of GDP"
label variable rcons "Real Total Consumption"
label variable cons "Total Consumption"
label variable cons_GDP "Total Consumption as % of GDP"
label variable exports "Total Exports"
label variable exports_GDP "Total Exports as % of GDP"
label variable imports "Total Imports"
label variable imports_GDP "Total Imports as % of GDP"
label variable CA "Current Account Balance"
label variable CA_GDP "Current Account Balance as % of GDP"
label variable govexp "Government Expenditure"
label variable govexp_GDP "Government Expenditure as % of GDP"
label variable govrev "Government Revenue"
label variable govrev_GDP "Government Revenue as % of GDP"
label variable govtax "Government Tax Revenue"
label variable govtax_GDP "Government Tax Revenue as % of GDP"
label variable govdef "Government Deficit"
label variable govdef_GDP "Government Deficit as % of GDP"
label variable govdebt "Government Debt"
label variable govdebt_GDP "Government Debt as % of GDP"
label variable CPI "Consumer Price Index"
label variable HPI "House Price Index"
label variable infl "Inflation Rate"
label variable pop "Population"
label variable unemp "Unemployment Rate"
label variable USDfx "Exchange Rate against USD"
label variable REER "Real Effective Exchange Rate"
label variable strate "Short-term Interest Rate"
label variable ltrate "Long-term Interest Rate"
label variable cbrate "Central Bank Policy Rate"
label variable M0 "M0 Money Supply"
label variable M1 "M1 Money Supply"
label variable M2 "M2 Money Supply"
label variable M3 "M3 Money Supply"
label variable M4 "M4 Money Supply"

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


* Drop the years with data for every country 
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
order countryname ISO3 year nGDP rGDP rGDP_pc rGDP_USD deflator cons rcons cons_GDP inv inv_GDP finv finv_GDP exports exports_GDP imports imports_GDP CA CA_GDP USDfx REER govexp govexp_GDP govrev govrev_GDP govtax govtax_GDP govdef govdef_GDP govdebt govdebt_GDP HPI CPI infl pop unemp strate ltrate cbrate M0 M1 M2 M3 M4 SovDebtCrisis CurrencyCrisis BankingCrisis

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

* Label countryname
label variable countryname "Country name"

* Sort
sort ISO3 year

* Save 
save "$data_final/data_final", replace 



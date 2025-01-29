* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN ECONOMIC DATA FROM AFRISTAT
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-20
*
* Description: This file cleans data from AFRISTAT
* 
* Data source: Afristat
*
* URL: https://afristat.opendataforafrica.org/ (Archived on: 2024-09-25)
* ==============================================================================

* ==============================================================================
*			SET UP
* ==============================================================================

* First run WDI because we will use later 
do "$code_clean/aggregators/WDI.do"
clear

clear
global input "${data_raw}/aggregators/AFRISTAT/AFRISTAT"
global WDI  "${data_clean}/aggregators/WB/WDI"
global output "${data_clean}/aggregators/AFRISTAT/AFRISTAT"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open
import excel using "${input}", allstring sheet(M1) clear

* Drop
drop B

* Rename all columns before reshaping
ds A, not
foreach var in `r(varlist)'{
	local newname = `var'[1]
	ren `var' M1`newname'
}
ren A countryname
drop in 1

* Reshape
greshape long M1, i(countryname) j(year)

* Save
tempfile temp_master
save `temp_master', replace 

* Loop over the next sheets and merge
local variable_list M2 M0_1 M0_2 DEBT_1 DEBT_2 govexp TAXES REVENUE 
foreach variable of local variable_list {
	
	* Import data
	import excel using "${input}", allstring sheet(`variable') clear
	
	* Drop
	drop B
	
	* Rename all columns before reshaping
	ds A, not
	foreach var in `r(varlist)'{
		local newname = `var'[1]
		ren `var' `variable'`newname'
	}
	ren A countryname
	drop in 1
	
	* Reshape
	greshape long `variable', i(countryname) j(year)
	
	* Save and merge
	tempfile temp_c
	save `temp_c', replace emptyok
	merge 1:1 countryname year using `temp_master', nogen
	save `temp_master', replace

}

* Convert units
ds countryname year, not
foreach var in `r(varlist)' {
	destring `var', replace
	
	* Sao Tomé-et-Principe is recorded in million LCU, where other countries are recorded in billion LCU in the raw data. 
	replace `var' = `var' * 1000 if countryname != "Sao Tomé-et-Principe"
}

* Rename columns
ren REVENUE govrev
ren TAXES govtax

* Calculate aggregate variable
gen govdebt = DEBT_1 + DEBT_2
gen M0 		 = M0_1   + M0_2 
drop DEBT_1 DEBT_2 M0_1 M0_2

* Generate countries' ISO3 codes
gen ISO3 = ""
replace ISO3 = "BFA" if countryname == "Burkina Faso"
replace ISO3 = "BDI" if countryname == "Burundi"
replace ISO3 = "BEN" if countryname == "Bénin"
replace ISO3 = "CPV" if countryname == "Cabo Verde"
replace ISO3 = "CMR" if countryname == "Cameroun"
replace ISO3 = "COM" if countryname == "Comores"
replace ISO3 = "COG" if countryname == "Congo"
replace ISO3 = "CIV" if countryname == "Côte d'Ivoire"
replace ISO3 = "DJI" if countryname == "Djibouti"
replace ISO3 = "GAB" if countryname == "Gabon"
replace ISO3 = "GIN" if countryname == "Guinée"
replace ISO3 = "GNQ" if countryname == "Guinée équatoriale"
replace ISO3 = "GNB" if countryname == "Guinée-Bissau"
replace ISO3 = "MDG" if countryname == "Madagascar"
replace ISO3 = "MLI" if countryname == "Mali"
replace ISO3 = "MRT" if countryname == "Mauritanie"
replace ISO3 = "NER" if countryname == "Niger"
replace ISO3 = "CAF" if countryname == "République centrafricaine"
replace ISO3 = "STP" if countryname == "Sao Tomé-et-Principe"
replace ISO3 = "SEN" if countryname == "Sénégal"
replace ISO3 = "TCD" if countryname == "Tchad"
replace ISO3 = "TGO" if countryname == "Togo"
drop countryname

* Derive government debt-to-GDP using GDP values from WDI
merge 1:1 ISO3 year using $WDI, keepus(WDI_nGDP) nogen keep(1 3)
gen govdebt_GDP = (govdebt / WDI_nGDP) * 100

* Add ratios to gdp variables
gen govexp_GDP  = (govexp / WDI_nGDP) * 100
gen govrev_GDP  = (govrev / WDI_nGDP) * 100
gen govtax_GDP  = (govtax / WDI_nGDP) * 100

drop WDI_nGDP

* ==============================================================================
*			OUTPUT
* ==============================================================================

* Add source identifier
ds ISO3 year, not
foreach var in `r(varlist)'{
	ren `var' AFRISTAT_`var'
}

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace
	
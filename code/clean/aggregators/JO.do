* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Clean Jones-Obstfeld (1997) data
* 
* Author:
* Zekai Shen
* National University of Singapore
*
* Created: 2024-05-31
*
* Description: 
* This Stata script opens and cleans the Jones-Obstfeld (1997) data.
*
* Original download link:
* https://www.nber.org/research/data/jones-obstfeld-saving-investment-and-gold-data-13-countries
* ==============================================================================


* ==============================================================================
* 	SET-UP
* ==============================================================================
* Set the directories
clear
global input "${data_raw}/aggregators/JO"
global output "${data_clean}/aggregators/JO/JO.dta"

* Create a temporary file
tempfile temp_master
save `temp_master', replace emptyok

* Get the filelist
tempfile filelist
filelist, dir("$input") pattern("*.xls") save("`filelist'")
use "`filelist'", clear
list filename
levelsof filename, local(files)

* Loop over the files to process the data:
foreach file in `files' {
    import excel using "$input/`file'", sheet(Final) first clear

	* Get the country name
	ds
	local first_var : word 1 of `r(varlist)'
	di "`first_var'"
	gen Country = "`first_var'"

	*drop uselss row
	drop if `first_var' ==.
	
	* Generate the year
	rename `first_var' Year
	keep Country Year B C D E
	
	*append and save
	tempfile temp_nGDP
	save `temp_nGDP', replace emptyok
	append using `temp_master'
	save `temp_master', replace

}


* ==============================================================================
* 	PROCESS
* ==============================================================================
* Rename the variables:
rename B JO_nGDP
rename C JO_finv
rename D JO_stock_change
rename E JO_CA
rename Country ISO3
rename Year year

* Rename the countries according to ISO3:
replace ISO3 = "GBR" if ISO3 == "U_K"
replace ISO3 = "USA" if ISO3 == "USA"
replace ISO3 = "SWE" if ISO3 == "SWEDEN"
replace ISO3 = "RUS" if ISO3 == "RUSSIA"
replace ISO3 = "NOR" if ISO3 == "NORWAY"
replace ISO3 = "JPN" if ISO3 == "JAPAN"
replace ISO3 = "ITA" if ISO3 == "ITALY"
replace ISO3 = "DEU" if ISO3 == "GERMANY"
replace ISO3 = "FRA" if ISO3 == "FRANCE"
replace ISO3 = "FIN" if ISO3 == "FINLAND"
replace ISO3 = "DNK" if ISO3 == "DENMARK"
replace ISO3 = "CAN" if ISO3 == "CANADA"
replace ISO3 = "AUS" if ISO3 == "AUSTRALIA"

* Destring
destring JO_CA JO_finv JO_nGDP JO_stock_change, replace 

* Convert French francs to new French francs
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	replace `var' = `var'/100 if ISO3 == "FRA"
}

* Convert Finnish data
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	replace `var' = `var'/100000 if ISO3 == "FIN" // Data in thousands of old markka = 1/100 new markka
}

* Convert Australian currency to dollar
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	replace `var' = `var'*2 if ISO3 == "AUS"
}

* Fix value for Germany
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	replace `var' = `var'/(10^12) if ISO3 == "DEU" & year <= 1913
}

* Convert currencies with Eurozone irrevocable exchange rate
merge m:1 ISO3 using "$eur_fx", keep(1 3) nogen 
ds ISO3 year EUR_irrevocable_FX, not
foreach var in `r(varlist)'{
	replace `var' = `var' / EUR_irrevocable_FX if EUR_irrevocable_FX  != .
}
drop EUR_irrevocable_FX

* Generate Capital Account as a percentage of Gross Domestic Product:
generate JO_CA_GDP = (JO_CA / JO_nGDP) * 100

* Create total investment 
generate JO_inv = JO_finv + JO_stock_change
drop JO_stock_change
replace JO_inv = . if JO_inv < 0

* Add ratios to gdp variables
gen JO_finv_GDP = (JO_finv / JO_nGDP) * 100
gen JO_inv_GDP     = (JO_inv / JO_nGDP) * 100


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


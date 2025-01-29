* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script cleans data on banking crises from Laeven and Valencia (2020).
*
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-10-17
*
* Last downloaded:
* 2024-10-17 from https://static-content.springer.com/esm/art%3A10.1057%2Fs41308-020-00107-3/MediaObjects/41308_2020_107_MOESM1_ESM.xlsx
* ==============================================================================
*
* ==============================================================================
*			SET UP
* ==============================================================================

clear
global input "${data_raw}/aggregators/LV/41308_2020_107_MOESM1_ESM.xlsx"
global output "${data_clean}/aggregators/LV/LV"

* ==============================================================================
* Clean data 
* ==============================================================================

* Open 
import excel "$input", clear first sheet("Crisis Years")
drop in 1

* Split cells 
foreach var in 	SystemicBankingCrisisstartin CurrencyCrisis SovereignDebtCrisisyear SovereignDebtRestructuringye {
	replace `var' = "" if `var' == "n.a."
	split `var', parse(",")
	drop `var'
}

* Reshape 
greshape long SystemicBankingCrisisstartin CurrencyCrisis SovereignDebtCrisisyear SovereignDebtRestructuringye, i(Country) j(number)

* Clean 
missings dropobs SystemicBankingCrisisstartin CurrencyCrisis SovereignDebtCrisisyear SovereignDebtRestructuringye, force
drop number 
destring *, replace

* Make country code 
ren Country country_name 
kountry country_name, from(other) stuck
ren _ISO3N_ ISO3n
kountry ISO3n, from(iso3n) to(iso3c)
ren _ISO3C_ ISO3
drop ISO3n 

replace ISO3 = "CHN" if country_name == "China, P.R."
replace ISO3 = "CAF" if country_name == "Central African Rep."
replace ISO3 = "COD" if country_name == "Congo, Dem. Rep. of"
replace ISO3 = "CIV" if country_name == "Côte d'Ivoire"
replace ISO3 = "CIV" if regexm(country_name,"Ivoire")
replace ISO3 = "IRN" if country_name == "Iran, I.R. of"
replace ISO3 = "LAO" if country_name == "Lao People's Dem. Rep."
replace ISO3 = "SRB" if country_name == "Serbia, Republic of"
replace ISO3 = "KNA" if regexm(country_name,"Kitts and Nevis")
replace ISO3 = "CZE" if regexm(country_name,"ech Republic")
replace ISO3 = "COL" if regexm(country_name,"lombia")
replace ISO3 = "SYR" if regexm(country_name,"rian Arab Republic")
replace ISO3 = "STP" if country_name == "São Tomé and Principe"
replace ISO3 = "STP" if regexm(country_name,"and Principe")

* Drop Yugoslavia 
drop if ISO3 == ""

* Make temporary year variable 
egen year = rowmax(SystemicBankingCrisisstartin CurrencyCrisis SovereignDebtCrisisyear SovereignDebtRestructuringye)

* Make years panel of countries and years (1970-2017)
tempfile country_year
save `country_year', replace 

duplicates drop ISO3, force 
keep ISO3 country_name
expand 48
bysort ISO3: gen year = 1969 + _n

merge 1:m ISO3 year using `country_year', nogen

* Make dummies 
gen LV_crisisB   = 0
gen LV_crisisC 	 = 0
gen LV_crisisSD1 = 0
gen LV_crisisSD2 = 0

* Rename original variables 
ren (SystemicBankingCrisisstartin CurrencyCrisis SovereignDebtCrisisyear SovereignDebtRestructuringye) (LV_crisisByears LV_crisisCyears LV_crisisSD1years LV_crisisSD2years)

* Loop over countries 
levelsof ISO3, loc(countries) clean 
foreach iso of loc countries {
	
	* Loop over variables 
	foreach var in LV_crisisB LV_crisisC LV_crisisSD1 LV_crisisSD2 {
		levelsof `var'years if ISO3 == "`iso'", loc(years)
			
		* Loop over crisis years 
		foreach y of loc years {
			replace `var' = 1 if year == `y' & ISO3 == "`iso'"
		}
	}
}
	
* Only keep relevant variables 
keep ISO3 year LV_crisisB LV_crisisC LV_crisisSD1 LV_crisisSD2

* Drop duplicates 
duplicates drop ISO3 year, force 

* ==============================================================================
* 	Output
* ==============================================================================

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace

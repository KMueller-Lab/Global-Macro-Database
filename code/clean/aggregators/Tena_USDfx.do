* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and clean exchange rates data 
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-10-08
*
* URL https://www.uc3m.es/ss/Satellite/UC3MInstitucional/es/TextoMixta/1371246243217/ 
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
* Clear
clear
global input "${data_raw}/aggregators/Tena/trade/Tena_USDfx"
global output "${data_clean}/aggregators/Tena/trade/Tena_USDfx.dta"

* ===============================================================================
*	PROCESS
* ===============================================================================
import excel using "${input}", clear sheet("Processed") first

* Rename before reshaping
qui ds year, not
foreach var in `r(varlist)' {
	ren `var' USDfx`var'
}

* Reshape
qui greshape long USDfx, i(year) j(countryname) string

* Extract ISO3
replace countryname = "Brazil" 		   		if countryname == "Brasil"
replace countryname = "Costa Rica" 		    if countryname == "CostaRica"
replace countryname = "Czechoslovakia" 		if countryname == "Czechoslowakia"
replace countryname = "Dominican Republic"  if countryname == "DominicanRepublic"
replace countryname = "El Salvador" 		if countryname == "ElSalvador"
replace countryname = "South Korea"			if countryname == "Korea"
replace countryname = "New Zealand" 		if countryname == "NewZeland"
replace countryname = "Turkey"			 	if countryname == "OttomanEmpireTurkey"
replace countryname = "Iran" 				if countryname == "PersiaIran"
replace countryname = "Russian Federation"  if countryname == "RussiaUSSR"
replace countryname = "Serbia" 				if countryname == "SerbiaYugoslavia"
replace countryname = "Thailand" 			if countryname == "SiamThailand"
replace countryname = "United Kingdom" 		if countryname == "UnitedKingdom"
replace countryname = "United States" 		if countryname == "Unitedstates"
merge m:1 countryname using $isomapping, keepus(ISO3) assert(2 3) keep(3) nogen
drop countryname

* Zero refers to instances where the country was not in extant. 
replace USDfx = . if USDfx == 0

* Add source identifier
ren USDfx Tena_USDfx

* Fix exchange rate issues
* Australia
replace Tena_USDfx = Tena_USDfx * 2 if ISO3 == "AUS"

* Bolivia
replace Tena_USDfx = Tena_USDfx * (10^-9) if ISO3 == "BOL"

* New Zealand
replace Tena_USDfx = Tena_USDfx * 2 if ISO3 == "NZL"

* Uruguay
replace Tena_USDfx = Tena_USDfx * (10^-6) if ISO3 == "URY"

* Brazil
replace Tena_USDfx = Tena_USDfx / 2750 if ISO3 == "BRA"
replace Tena_USDfx = Tena_USDfx * (10^-12) if ISO3 == "BRA"

* Venezuela
replace Tena_USDfx = Tena_USDfx / 1000 if ISO3 == "VEN"

* Mexico
replace Tena_USDfx = Tena_USDfx / 1000 if ISO3 == "MEX"

* Nicaragua
replace Tena_USDfx = Tena_USDfx / 500000000 if ISO3 == "NIC"
replace Tena_USDfx = Tena_USDfx / 12.5 if ISO3 == "NIC"

* Bulgaria
replace Tena_USDfx = Tena_USDfx * (10^-6) if ISO3 == "BGR"

* Paraguay
replace Tena_USDfx = Tena_USDfx / 100 if ISO3 == "PRY"

* Peru
replace Tena_USDfx = Tena_USDfx / 1000000000 if ISO3 == "PER"

* Chile
replace Tena_USDfx = Tena_USDfx / 1000 if ISO3 == "CHL"

* Iceland
replace Tena_USDfx = Tena_USDfx / 100 if ISO3 == "ISL"

* France
replace Tena_USDfx = Tena_USDfx / 100 if ISO3 == "FRA"

* France
replace Tena_USDfx = Tena_USDfx / 100000 if ISO3 == "TUR"

* Romania
replace Tena_USDfx = Tena_USDfx * (10^-8) if ISO3 == "ROU"
replace Tena_USDfx = Tena_USDfx / 2 if ISO3 == "ROU"

* Argentina
replace Tena_USDfx = Tena_USDfx * (10^-13) if ISO3 == "ARG"

* Venezuela 
replace Tena_USDfx = Tena_USDfx * (10^-11) if ISO3 == "VEN"

* Estonia 
replace Tena_USDfx = Tena_USDfx * (10^-1) if ISO3 == "EST"

* Estonia 
replace Tena_USDfx = Tena_USDfx * (10^-1) if ISO3 == "EST"

* Latvia 
replace Tena_USDfx = Tena_USDfx / 200 if ISO3 == "LVA"

* Lithuania 
replace Tena_USDfx = Tena_USDfx / 200 if ISO3 == "LTU"

* Russia 
replace Tena_USDfx = Tena_USDfx / 10000 if ISO3 == "RUS"

* Drop Serbia exchange rate
drop if ISO3 == "SRB"

* Convert currency for european countries
merge m:1 ISO3 using $eur_fx, keep(1 3)
replace Tena_USDfx  = Tena_USDfx / EUR_irrevocable_FX if _merge == 3 & year <= 1998
drop EUR_irrevocable_FX _merge

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




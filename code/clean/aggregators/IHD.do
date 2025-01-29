* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Clean Interwar data from the paper "The Ends of 27 Big Depression"
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-10-07
*
* URL:  https://cepr.org/research/data-set-items/Interwar_High_Frequency_Data 
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
clear
global input "${data_raw}/aggregators/IHD/IHD.csv"
global output "${data_clean}/aggregators/IHD/IHD.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================
* Open
import delimited using "${input}", clear

* Keep relevant categories
keep if inlist(title1eng, "Foreign trade", "Money and Credit", "Prices")

* Filter each sector to keep only relevant information
drop if title1eng == "Foreign trade"    & title2eng != "Overall movement"
drop if title1eng == "Money and Credit" & !inlist(title3eng, "Banknotes in circulation", "Bank Discount", "Discount Bank (Bank of Italy)", "Discount rate of the Banco de la Nacion de comercio pagares for-credit banks", "Discount rate of the Imperial Bank of India", "Market discount (Milan)", "Reichsbank discount")
drop if title1eng == "Prices" & !inlist(title3eng,"Overall index", "Overall index of")


* Generate the variable column
gen IHD = ""
replace IHD = "exports"    if title3eng == "Export"
replace IHD = "imports"    if title3eng == "Importing"
replace IHD = "strate"     if title3eng == "Bank Discount"
replace IHD = "M0"         if title3eng == "Banknotes in circulation"
replace IHD = "strate" 	   if title3eng == "Discount rate of the Banco de la Nacion de comercio pagares for-credit banks"
replace IHD = "exports"    if title3eng == "Export incl gold bullion and coins"
replace IHD = "re-exports" if title3eng == "Re-export"
replace IHD = "cbrate"     if inlist(title3eng, "Discount Bank (Bank of Italy)", "Discount rate of the Imperial Bank of India", "Reichsbank discount")
replace IHD = "strate"     if title3eng == "Market discount (Milan)"
replace IHD = "CPI"     	if title3eng == "Overall index"
replace IHD = "CPI"     	if title3eng == "Overall index of"
drop if title3eng == "Exports excluding gold bullion and coins"

* Keep only relevant columns
keep country year month value note1eng IHD book table

* Destring
qui replace value = "" if inlist(value, ".", "-")
destring value month, replace

* Convert units
gen units = substr(note1eng , 1, 4)
replace value = value / 1000 if inlist(units, "1000", "£1,")
drop units note1eng

* Rename countries
gen ISO3 = ""
replace ISO3 = "ARG" if country == "Argentinien"
replace ISO3 = "AUS" if country == "Australischer Bund"
replace ISO3 = "BEL" if country == "Belgien"
replace ISO3 = "BRA" if country == "Brasilien"
replace ISO3 = "IND" if country == "Britisch Indien"
replace ISO3 = "BGR" if country == "Bulgarien"
replace ISO3 = "CHL" if country == "Chile"
replace ISO3 = "COL" if country == "Columbien"
replace ISO3 = "DNK" if country == "Daenemark"
replace ISO3 = "DEU" if country == "Deutsches Reich"
replace ISO3 = "EST" if country == "Estland"
replace ISO3 = "FIN" if country == "Finnland"
replace ISO3 = "FRA" if country == "Frankreich"
replace ISO3 = "GRC" if country == "Griechenland"
replace ISO3 = "GBR" if country == "Grossbritannien" | country == "Grossbritannien und Nordirland"
replace ISO3 = "ITA" if country == "Italien"
replace ISO3 = "JPN" if country == "Japan"
replace ISO3 = "YUG" if country == "Jugoslawien"
replace ISO3 = "CAN" if country == "Kanada"
replace ISO3 = "LVA" if country == "Lettland"
replace ISO3 = "LTU" if country == "Litauen"
replace ISO3 = "MEX" if country == "Mexiko"
replace ISO3 = "NZL" if country == "Neuseeland"
replace ISO3 = "IDN" if country == "Niederlaendisch Indien"
replace ISO3 = "NLD" if country == "Niederlande"
replace ISO3 = "NOR" if country == "Norwegen"
replace ISO3 = "AUT" if country == "Oesterreich"
replace ISO3 = "PER" if country == "Peru"
replace ISO3 = "POL" if country == "Polen"
replace ISO3 = "PRT" if country == "Portugal"
replace ISO3 = "ROU" if country == "Rumaenien"
replace ISO3 = "RUS" if country == "Russland (UdSSR)"
replace ISO3 = "SWE" if country == "Schweden"
replace ISO3 = "CHE" if country == "Schweiz"
replace ISO3 = "ESP" if country == "Spanien"
replace ISO3 = "ZAF" if country == "Suedafrikanische Union" | country == "Union von Suedafrika"
replace ISO3 = "CSK" if country == "Tschechoslowakei"
replace ISO3 = "HUN" if country == "Ungarn"
replace ISO3 = "USA" if country == "Ver. St. v. Amerika" | country == "Vereinigte Staaten von Amerika"
replace ISO3 = "IRL" if country == "Irischer Freistaat"
drop country

* Drop duplicates (Keep only data from book 1)
sort ISO3 year month IHD book
duplicates drop ISO3 year month IHD, force

* Drop columns no longer needed
drop book table

* Reshape
greshape wide value, i(ISO3 year month) j(IHD)

* Rename
ren value* *

* Take yearly value of imports and exports
sort ISO3 year
by ISO3 year: gen exports_s = sum(exports)
by ISO3 year: gen imports_s = sum(imports)
drop imports exports
ren (imports_s exports_s) (imports exports)

* Keep end-of-year value
keep if month == 12

* Turn to missing
replace exports = . if exports == 0
replace imports = . if imports == 0

* Add re-exports to exports
replace exports = exports + re_exports if re_exports != .

* Drop month and re-exports
drop month re_exports

* Convert Australia currency
replace imports = imports * 2 if ISO3 == "AUS"
replace exports = exports * 2 if ISO3 == "AUS"
replace M0 = M0 * 2 if ISO3 == "AUS"

* Convert Finland currency
qui replace exports = exports / 100   if ISO3 == "FIN" 
qui replace imports = imports / 100   if ISO3 == "FIN" 
qui replace imports = imports / 100   if ISO3 == "FIN" 

* Convert France currency
qui replace exports = exports / 100   if ISO3 == "FRA" 
qui replace imports = imports / 100   if ISO3 == "FRA" 
qui replace imports = imports / 100   if ISO3 == "FRA" 

* Convert Uruguay currency
replace imports = imports / 1000000 if ISO3 == "URY"
replace exports = exports / 1000000 if ISO3 == "URY"
replace M0 = M0 / 1000000 if ISO3 == "URY"

* Convert Peru currency
replace imports = imports * (10^-9) if ISO3 == "PER"
replace exports = exports * (10^-9) if ISO3 == "PER"
replace M0 = M0 * (10^-9) if ISO3 == "PER"

* Convert Mexico currency
replace imports = imports / 1000 if ISO3 == "MEX"
replace exports = exports / 1000 if ISO3 == "MEX"
replace M0 = M0 / 1000 if ISO3 == "MEX"

* Convert Brazil currency
replace imports = imports * (2.750e-15) if ISO3 == "BRA"
replace exports = exports * (2.750e-15) if ISO3 == "BRA"
replace M0 = M0 * (2.750e-15) if ISO3 == "BRA"

* Convert Argentina currency
replace imports = imports * (10^-13) if ISO3 == "ARG"
replace exports = exports * (10^-13) if ISO3 == "ARG"
replace M0 = M0 * (10^-13) if ISO3 == "ARG"

* Convert Bulgaria currency
replace imports = imports * (10^-6) if ISO3 == "BGR"
replace exports = exports * (10^-6) if ISO3 == "BGR"
replace M0 = M0 * (10^-6) if ISO3 == "BGR"

* Convert Chile currency
replace imports = imports * (10^-3) if ISO3 == "CHL"
replace exports = exports * (10^-3) if ISO3 == "CHL"
replace M0 = M0 * (10^-3) if ISO3 == "CHL"

* Convert Nicaragua currency 
replace exports = exports / 500000000 if ISO3 == "NIC"
replace imports = imports / 500000000 if ISO3 == "NIC"
replace imports = imports / 500000000 if ISO3 == "NIC"

* Convert Poland currency
replace imports = imports * (10^-3) if ISO3 == "POL"
replace exports = exports * (10^-3) if ISO3 == "POL"
replace M0 = M0 * (10^-3) if ISO3 == "POL"

* Convert Greece currency
replace imports = imports * (10^-3) if ISO3 == "GRC"
replace exports = exports * (10^-3) if ISO3 == "GRC"
replace M0 = M0 * (10^-3) if ISO3 == "GRC"

* Convert Romania currency
replace imports = imports * (10^-8) / 2 if ISO3 == "ROU"
replace exports = exports * (10^-8) / 2 if ISO3 == "ROU"
replace M0 = M0 * (10^-8) / 2 if ISO3 == "ROU"

* Convert South Africa currency
replace imports = imports * 2 if ISO3 == "ZAF"
replace exports = exports * 2 if ISO3 == "ZAF"
replace M0 = M0 * 2 if ISO3 == "ZAF"

* Drop values for Yuguslava
replace imports = . if ISO3 == "YUG"
replace exports = . if ISO3 == "YUG"
replace M0 = . if ISO3 == "YUG"

* Convert currencies to euro
merge m:1 ISO3 using $eur_fx, keep(1 3)
qui ds imports exports M0
foreach var in `r(varlist)'{
	replace `var' = `var'/EUR_irrevocable_FX if _merge == 3
}
drop EUR_irrevocable_FX _merge

* Derive inflation rate
sort ISO3 year
encode ISO3, gen(id)
xtset id year
by id: gen infl = (CPI - L.CPI) / L.CPI * 100 if L.CPI != .
drop id

* Add source identifier
qui ds year ISO3, not
foreach var in `r(varlist)'{
	ren `var' IHD_`var'
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

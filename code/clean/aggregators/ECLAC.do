* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN ECONOMIC DATA FROM THE ECLAC
* 
* Description: 
* This stata script cleans economic data from ECLAC
*
* Author
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-09-25
*
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================

* Clear data 
clear

* Define input and output files 
global BOP "${data_raw}/aggregators/ECLAC/ECLAC_BOP.xlsx"
global cbrate "${data_raw}/aggregators/ECLAC/ECLAC_cbrate.xlsx"
global CPI "${data_raw}/aggregators/ECLAC/ECLAC_CPI.xlsx"
global debt "${data_raw}/aggregators/ECLAC/ECLAC_debt.xlsx"
global govexp "${data_raw}/aggregators/ECLAC/ECLAC_govexp.xlsx"
global infl "${data_raw}/aggregators/ECLAC/ECLAC_infl.xlsx"
global M0 "${data_raw}/aggregators/ECLAC/ECLAC_M0.xlsx"
global M1 "${data_raw}/aggregators/ECLAC/ECLAC_M1.xlsx"
global M2 "${data_raw}/aggregators/ECLAC/ECLAC_M2.xlsx"
global M3 "${data_raw}/aggregators/ECLAC/ECLAC_M3.xlsx"
global nGDP "${data_raw}/aggregators/ECLAC/ECLAC_nGDP.xlsx"
global REVENUE "${data_raw}/aggregators/ECLAC/ECLAC_REVENUE.xlsx"
global strate "${data_raw}/aggregators/ECLAC/ECLAC_strate.xlsx"
global output "${data_clean}/aggregators/ECLAC/ECLAC.dta"

* ==============================================================================
* 	NATIONAL ACCOUNTS
* ==============================================================================

* Open
qui import excel using "${nGDP}", clear 

* Clean variables definitions
replace C = subinstr(C, "Plus: ", "", .)
replace C = subinstr(C, "Less: ", "", .)
replace C = subinstr(C, "Equals: ", "", .)
replace C = strtrim(C)

* Keep only relevant rows
replace C = "_nGDP" if C == "Gross domestic product at market prices"
replace C = "_sav" if C == "National saving"
replace C = "_cons" if C == "Total final consumption expenditure"
replace C = "_inv" if C == "Gross capital formation"
keep if strpos(C, "_") 

* Keep only needed columns
keep B C D E

* Extract country name
gen countryname = substr(B, 1, strpos(B, "[") - 1)
replace countryname = strtrim(countryname)

* Fix Chile's name
replace countryname = "Chile" if countryname == "Chili"

* Extract the base year
gen base_year = substr(B, strpos(B, "]")-5, strpos(B, "]")-1)
replace base_year = substr(strtrim(base_year), 1, 4)

* Destring
destring base_year D E, replace

* Turn zeros by missing values
replace E = . if E == 0

* Keep the base year closest to the observation's year
gen dif = abs(base_year-D)
order countryname D dif
sort countryname C D dif
by countryname C D: keep if _n == 1

* Rename
ren C series
ren D year
ren E ECLAC

* Drop
drop B dif base_year

* Reshape
greshape wide ECLAC, i(countryname year) j(series)

* Generate countries' ISO3 code
replace countryname = "Bolivia" if countryname == "Bolivia (Plurinational State of)"
replace countryname = "Saint Vincent and the Grenadines" if countryname == "Saint Vincent and The Grenadines"
replace countryname = "Suriname" if countryname == "Surinam"
replace countryname = "Venezuela" if countryname == "Venezuela (Bolivarian Republic of)"
merge m:1 countryname using $isomapping, keep(3) nogen keepusing(ISO3)
drop countryname

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
tempfile temp_na
save `temp_na', replace

* ==============================================================================
* 	Government Expenditure
* ==============================================================================

* Open
qui import excel using "${govexp}", clear 

* Keep only needed columns and rows
keep B C D E F
drop in 1

* Keep only total expenditure
keep if D == "Total expenditure"

* Rename
ren C countryname
ren E year
ren F value
drop D

* Destring
destring year value, replace

* Add variable 
gen variable = "cgovexp" if B == "Central government"
replace variable = "gen_govexp" if B == "General government"

* Reshape
drop B 
greshape wide value, i(countryname year) j(variable) 
ren value* ECLAC_*

* Generate countries' ISO3 code
replace countryname = "Bolivia" if countryname == "Bolivia (Plurinational State of)"
replace countryname = "Venezuela" if countryname == "Venezuela (Bolivarian Republic of)"
merge m:1 countryname using $isomapping, assert(2 3) keep(3) keepusing(ISO3) nogen
drop countryname

* Keep
keep ISO3 year ECLAC_cgovexp ECLAC_gen_govexp

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
tempfile temp_govexp
save `temp_govexp', replace
merge 1:1 ISO3 year using `temp_na', nogen
save `temp_na', replace

* ==============================================================================
* 	Government Revenue
* ==============================================================================

* Open
qui import excel using "${REVENUE}", clear 

* Keep only needed columns and rows
keep C D E F
drop in 1

* Keep only relevant rows
replace D = "_gen_govrev_GDP" if D == "Total revenue and grants" 
replace D = "_gen_govdef_GDP" if D == "Overall fiscal balance"
keep if strpos(D, "_") 

* Rename
ren C countryname
ren D series
ren E year
ren F ECLAC

* Destring
destring year ECLAC, replace

* Reshape
greshape wide ECLAC, i(countryname year) j(series)

* Generate countries' ISO3 code
replace countryname = "Bolivia" if countryname == "Bolivia (Plurinational State of)"
replace countryname = "Venezuela" if countryname == "Venezuela (Bolivarian Republic of)"
merge m:1 countryname using $isomapping, assert(2 3) keep(3) keepusing(ISO3) nogen
drop countryname

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
tempfile temp_REVENUE
save `temp_REVENUE', replace
merge 1:1 ISO3 year using `temp_na', nogen
save `temp_na', replace

* ==============================================================================
* 	CONSUMER PRICE INDEX: Base Index 2018=100
* ==============================================================================

* Open
qui import excel using "${CPI}", clear 

* Keep only needed columns and rows
keep B C D 
drop in 1

* Rename
ren B countryname
ren C year
ren D ECLAC_CPI

* Destring
destring year ECLAC_CPI, replace

* Generate countries' ISO3 code
replace countryname = "Bolivia" if countryname == "Bolivia (Plurinational State of)"
replace countryname = "Venezuela" if countryname == "Venezuela (Bolivarian Republic of)"
merge m:1 countryname using $isomapping, assert(2 3) keep(3) keepusing(ISO3) nogen
drop countryname

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
tempfile temp_CPI
save `temp_CPI', replace
merge 1:1 ISO3 year using `temp_na', nogen
save `temp_na', replace

* ==============================================================================
* 	Inflation
* ==============================================================================

* Open
qui import excel using "${infl}", clear 

* Keep only needed columns and rows
keep B C D 
drop in 1

* Rename
ren B countryname
ren C year
ren D ECLAC_infl

* Destring
destring year ECLAC_infl, replace

* Generate countries' ISO3 code
replace countryname = "Bolivia" if countryname == "Bolivia (Plurinational State of)"
replace countryname = "Venezuela" if countryname == "Venezuela (Bolivarian Republic of)"
merge m:1 countryname using $isomapping, keep(3) keepusing(ISO3) nogen
drop countryname

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
tempfile temp_infl
save `temp_infl', replace
merge 1:1 ISO3 year using `temp_na', nogen
save `temp_na', replace


* ==============================================================================
* 	Central Bank policy rate
* ==============================================================================

* Open
qui import excel using "${cbrate}", clear

* Turn countries' names into ISO3 because they are in Spanish
replace B = "ATG" if B == "Antigua y Barbuda"
replace B = "ARG" if B == "Argentina"
replace B = "BHS" if B == "Bahamas"
replace B = "BRB" if B == "Barbados"
replace B = "BLZ" if B == "Belice"
replace B = "BOL" if B == "Bolivia (Estado Plurinacional de)"
replace B = "BRA" if B == "Brasil"
replace B = "CHL" if B == "Chile"
replace B = "COL" if B == "Colombia"
replace B = "CRI" if B == "Costa Rica"
replace B = "DMA" if B == "Dominica"
replace B = "SLV" if B == "El Salvador"
replace B = "GRD" if B == "Granada"
replace B = "GTM" if B == "Guatemala"
replace B = "GUY" if B == "Guyana"
replace B = "HTI" if B == "Haití"
replace B = "HND" if B == "Honduras"
replace B = "JAM" if B == "Jamaica"
replace B = "MEX" if B == "México"
replace B = "NIC" if B == "Nicaragua"
replace B = "PRY" if B == "Paraguay"
replace B = "PER" if B == "Perú"
replace B = "DOM" if B == "República Dominicana"
replace B = "KNA" if B == "Saint Kitts y Nevis"
replace B = "VCT" if B == "San Vicente y las Granadinas"
replace B = "LCA" if B == "Santa Lucía"
replace B = "TTO" if B == "Trinidad y Tabago"
replace B = "UKR" if B == "Ucrania"
replace B = "URY" if B == "Uruguay"
replace B = "VEN" if B == "Venezuela (República Bolivariana de)"

* Keep only needed columns and rows
keep B C E
drop in 1

* Rename
ren B ISO3
ren C year
ren E ECLAC_cbrate

* Destring
destring year ECLAC_cbrate, replace

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
tempfile temp_cbrate
save `temp_cbrate', replace
merge 1:1 ISO3 year using `temp_na', nogen
save `temp_na', replace

* ==============================================================================
* 	Short term interest rate
* ==============================================================================

* Open
qui import excel using "${strate}", clear

* Turn countries' names into ISO3 because they are in Spanish
replace B = "ATG" if B == "Antigua y Barbuda"
replace B = "ARG" if B == "Argentina"
replace B = "BHS" if B == "Bahamas"
replace B = "BRB" if B == "Barbados"
replace B = "BLZ" if B == "Belice"
replace B = "BOL" if B == "Bolivia (Estado Plurinacional de)"
replace B = "BRA" if B == "Brasil"
replace B = "CHL" if B == "Chile"
replace B = "COL" if B == "Colombia"
replace B = "CRI" if B == "Costa Rica"
replace B = "DMA" if B == "Dominica"
replace B = "ECU" if B == "Ecuador"
replace B = "SLV" if B == "El Salvador"
replace B = "GRD" if B == "Granada"
replace B = "GTM" if B == "Guatemala"
replace B = "GUY" if B == "Guyana"
replace B = "HTI" if B == "Haití"
replace B = "NLD" if B == "Holanda"
replace B = "HND" if B == "Honduras"
replace B = "JAM" if B == "Jamaica"
replace B = "MEX" if B == "México"
replace B = "NIC" if B == "Nicaragua"
replace B = "PAN" if B == "Panamá"
replace B = "PRY" if B == "Paraguay"
replace B = "PER" if B == "Perú"
replace B = "DOM" if B == "República Dominicana"
replace B = "KNA" if B == "Saint Kitts y Nevis"
replace B = "VCT" if B == "San Vicente y las Granadinas"
replace B = "LCA" if B == "Santa Lucía"
replace B = "SUR" if B == "Suriname"
replace B = "TTO" if B == "Trinidad y Tabago"
replace B = "URY" if B == "Uruguay"
replace B = "VEN" if B == "Venezuela (República Bolivariana de)"

* Keep only needed columns and rows
keep B C E
drop in 1

* Rename
ren B ISO3
ren C year
ren E ECLAC_strate

* Destring
destring year ECLAC_strate, replace

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
tempfile temp_strate
save `temp_strate', replace
merge 1:1 ISO3 year using `temp_na', nogen
save `temp_na', replace

* ==============================================================================
* 	M0
* ==============================================================================

* Open
qui import excel using "${M0}", clear

* Turn countries' names into ISO3 because they are in Spanish
replace B = "ATG" if B == "Antigua y Barbuda"
replace B = "ARG" if B == "Argentina"
replace B = "BHS" if B == "Bahamas"
replace B = "BRB" if B == "Barbados"
replace B = "BLZ" if B == "Belice"
replace B = "BOL" if B == "Bolivia (Estado Plurinacional de)"
replace B = "BRA" if B == "Brasil"
replace B = "CHL" if B == "Chile"
replace B = "CUB" if B == "Cuba"
replace B = "COL" if B == "Colombia"
replace B = "CRI" if B == "Costa Rica"
replace B = "DMA" if B == "Dominica"
replace B = "ECU" if B == "Ecuador"
replace B = "SLV" if B == "El Salvador"
replace B = "GRD" if B == "Granada"
replace B = "GTM" if B == "Guatemala"
replace B = "GUY" if B == "Guyana"
replace B = "HTI" if B == "Haití"
replace B = "NLD" if B == "Holanda"
replace B = "HND" if B == "Honduras"
replace B = "JAM" if B == "Jamaica"
replace B = "MEX" if B == "México"
replace B = "NIC" if B == "Nicaragua"
replace B = "PAN" if B == "Panamá"
replace B = "PRY" if B == "Paraguay"
replace B = "PER" if B == "Perú"
replace B = "DOM" if B == "República Dominicana"
replace B = "KNA" if B == "Saint Kitts y Nevis"
replace B = "VCT" if B == "San Vicente y las Granadinas"
replace B = "LCA" if B == "Santa Lucía"
replace B = "SUR" if B == "Suriname"
replace B = "TTO" if B == "Trinidad y Tabago"
replace B = "URY" if B == "Uruguay"
replace B = "VEN" if B == "Venezuela (República Bolivariana de)"

* Keep only needed columns and rows
keep B C E
drop in 1

* Rename
ren B ISO3
ren C year
ren E ECLAC_M0

* Destring
destring year ECLAC_M0, replace

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
tempfile temp_M0
save `temp_M0', replace
merge 1:1 ISO3 year using `temp_na', nogen
save `temp_na', replace

* ==============================================================================
* 	M1
* ==============================================================================

* Open
qui import excel using "${M1}", clear

* Turn countries' names into ISO3 because they are in Spanish
replace B = "ATG" if B == "Antigua y Barbuda"
replace B = "ARG" if B == "Argentina"
replace B = "BHS" if B == "Bahamas"
replace B = "BRB" if B == "Barbados"
replace B = "BLZ" if B == "Belice"
replace B = "BOL" if B == "Bolivia (Estado Plurinacional de)"
replace B = "BRA" if B == "Brasil"
replace B = "CHL" if B == "Chile"
replace B = "COL" if B == "Colombia"
replace B = "CRI" if B == "Costa Rica"
replace B = "CUB" if B == "Cuba"
replace B = "DMA" if B == "Dominica"
replace B = "ECU" if B == "Ecuador"
replace B = "SLV" if B == "El Salvador"
replace B = "GRD" if B == "Granada"
replace B = "GTM" if B == "Guatemala"
replace B = "GUY" if B == "Guyana"
replace B = "HTI" if B == "Haití"
replace B = "HND" if B == "Honduras"
replace B = "JAM" if B == "Jamaica"
replace B = "MEX" if B == "México"
replace B = "NIC" if B == "Nicaragua"
replace B = "PAN" if B == "Panamá"
replace B = "PRY" if B == "Paraguay"
replace B = "PER" if B == "Perú"
replace B = "DOM" if B == "República Dominicana"
replace B = "KNA" if B == "Saint Kitts y Nevis"
replace B = "VCT" if B == "San Vicente y las Granadinas"
replace B = "LCA" if B == "Santa Lucía"
replace B = "SUR" if B == "Suriname"
replace B = "TTO" if B == "Trinidad y Tabago"
replace B = "URY" if B == "Uruguay"
replace B = "VEN" if B == "Venezuela (República Bolivariana de)"
 
* Keep only needed columns and rows
keep B C E
drop in 1

* Rename
ren B ISO3
ren C year
ren E ECLAC_M1

* Destring
destring year ECLAC_M1, replace

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
tempfile temp_M1
save `temp_M1', replace
merge 1:1 ISO3 year using `temp_na', nogen
save `temp_na', replace

* ==============================================================================
* 	M2
* ==============================================================================

* Open
qui import excel using "${M2}", clear

* Turn countries' names into ISO3 because they are in Spanish
replace B = "ATG" if B == "Antigua y Barbuda"
replace B = "ARG" if B == "Argentina"
replace B = "BHS" if B == "Bahamas"
replace B = "BOL" if B == "Bolivia (Estado Plurinacional de)"
replace B = "BRA" if B == "Brasil"
replace B = "CHL" if B == "Chile"
replace B = "COL" if B == "Colombia"
replace B = "CRI" if B == "Costa Rica"
replace B = "CUB" if B == "Cuba"
replace B = "DMA" if B == "Dominica"
replace B = "ECU" if B == "Ecuador"
replace B = "SLV" if B == "El Salvador"
replace B = "GRD" if B == "Granada"
replace B = "GTM" if B == "Guatemala"
replace B = "HTI" if B == "Haití"
replace B = "HND" if B == "Honduras"
replace B = "JAM" if B == "Jamaica"
replace B = "MEX" if B == "México"
replace B = "NIC" if B == "Nicaragua"
replace B = "PAN" if B == "Panamá"
replace B = "PRY" if B == "Paraguay"
replace B = "PER" if B == "Perú"
replace B = "DOM" if B == "República Dominicana"
replace B = "KNA" if B == "Saint Kitts y Nevis"
replace B = "VCT" if B == "San Vicente y las Granadinas"
replace B = "LCA" if B == "Santa Lucía"
replace B = "SUR" if B == "Suriname"
replace B = "TTO" if B == "Trinidad y Tabago"
replace B = "URY" if B == "Uruguay"
replace B = "VEN" if B == "Venezuela (República Bolivariana de)"

* Keep only needed columns and rows
keep B C E
drop in 1

* Rename
ren B ISO3
ren C year
ren E ECLAC_M2

* Destring
destring year ECLAC_M2, replace

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
tempfile temp_M2
save `temp_M2', replace
merge 1:1 ISO3 year using `temp_na', nogen
save `temp_na', replace

* ==============================================================================
* 	M3
* ==============================================================================

* Open
qui import excel using "${M3}", clear

* Turn countries' names into ISO3 because they are in Spanish
replace B = "ATG" if B == "Antigua y Barbuda"
replace B = "ARG" if B == "Argentina"
replace B = "BHS" if B == "Bahamas"
replace B = "BRB" if B == "Barbados"
replace B = "BLZ" if B == "Belice"
replace B = "BOL" if B == "Bolivia (Estado Plurinacional de)"
replace B = "BEL" if B == "Bélgica"
replace B = "CHL" if B == "Chile"
replace B = "CRI" if B == "Costa Rica"
replace B = "DMA" if B == "Dominica"
replace B = "GRD" if B == "Granada"
replace B = "GTM" if B == "Guatemala"
replace B = "GUY" if B == "Guyana"
replace B = "HTI" if B == "Haití"
replace B = "NLD" if B == "Holanda"
replace B = "HND" if B == "Honduras"
replace B = "JAM" if B == "Jamaica"
replace B = "MEX" if B == "México"
replace B = "NIC" if B == "Nicaragua"
replace B = "PAN" if B == "Panamá"
replace B = "PRY" if B == "Paraguay"
replace B = "PER" if B == "Perú"
replace B = "DOM" if B == "República Dominicana"
replace B = "KNA" if B == "Saint Kitts y Nevis"
replace B = "VCT" if B == "San Vicente y las Granadinas"
replace B = "LCA" if B == "Santa Lucía"
replace B = "SUR" if B == "Suriname"
replace B = "TTO" if B == "Trinidad y Tabago"
replace B = "URY" if B == "Uruguay"

* Keep only needed columns and rows
keep B C E
drop in 1

* Rename
ren B ISO3
ren C year
ren E ECLAC_M3

* Destring
destring year ECLAC_M3, replace

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
tempfile temp_M3
save `temp_M3', replace
merge 1:1 ISO3 year using `temp_na', nogen
save `temp_na', replace

* ==============================================================================
* 	Convert units in case of undocumented inconsistencies in reporting units
* ==============================================================================

replace ECLAC_nGDP = ECLAC_nGDP / 1000 if ISO3 == "BHS"
replace ECLAC_nGDP = ECLAC_nGDP / 1000 if ISO3 == "BOL"
replace ECLAC_nGDP = ECLAC_nGDP / 1000 if ISO3 == "BOL" & year <= 1984
replace ECLAC_cons  = ECLAC_nGDP / 25 if year < 2007 & ISO3== "ECU"
replace ECLAC_cons  = ECLAC_nGDP / 1000 if year >= 2007 & ISO3== "ECU"
replace ECLAC_nGDP = ECLAC_nGDP / 1000 if ISO3 == "MEX" & year <= 1986
replace ECLAC_nGDP = ECLAC_nGDP / 1000 if ISO3 == "MEX" & year <= 2005 & year >= 2003
replace ECLAC_nGDP = ECLAC_nGDP / 1000 if ISO3 == "PRY" & year <= 2007 & year >= 2005
replace ECLAC_nGDP = ECLAC_nGDP / 1000 if year <= 2004 & ISO3 == "BRA"
replace ECLAC_nGDP = ECLAC_nGDP / 2750 if year <= 1990 & ISO3 == "BRA"
replace ECLAC_nGDP = ECLAC_nGDP / 1000 if year <= 1980 & ISO3 == "BRA"
replace ECLAC_nGDP = ECLAC_nGDP * (10^-8) if ISO3 == "VEN"
replace ECLAC_nGDP = ECLAC_nGDP * (10^-3) if ISO3 == "URY"
replace ECLAC_nGDP = ECLAC_nGDP * (10^-3) if ISO3 == "SUR"
replace ECLAC_nGDP = ECLAC_nGDP / 1000 if year <= 2006 & ISO3 == "PER"
replace ECLAC_nGDP = ECLAC_nGDP / 1000 if ISO3 == "ARG" & year <= 1988
replace ECLAC_nGDP = ECLAC_nGDP / 10000000 if ISO3 == "ARG" & year <= 1979
replace ECLAC_nGDP = ECLAC_nGDP * 1000 if year >= 2011 & ISO3 == "CHL"
replace ECLAC_nGDP = ECLAC_nGDP / 1000 if year <= 1973 & ISO3 == "CHL"
replace ECLAC_nGDP = ECLAC_nGDP / 8.75 if year <= 1989 & ISO3 == "SLV"
replace ECLAC_nGDP = ECLAC_nGDP * 1000 if ISO3 == "COL" & year >= 2003

replace ECLAC_cgovexp = ECLAC_cgovexp * (10^-8) if ISO3 == "VEN"
replace ECLAC_gen_govexp = ECLAC_gen_govexp * (10^-8) if ISO3 == "VEN"

replace ECLAC_inv    = ECLAC_inv * (10^-8) if ISO3 == "VEN"
replace ECLAC_inv    = ECLAC_inv * (10^-3) if ISO3 == "URY"
replace ECLAC_inv    = ECLAC_inv * (10^-3) if ISO3 == "SUR"
replace ECLAC_inv    = ECLAC_inv * (10^-3) if ISO3 == "PER" & year <= 2006
replace ECLAC_inv    = ECLAC_inv * (10^-3)  if inrange(year, 2005, 2007) & ISO3 == "PRY"
replace ECLAC_inv    = ECLAC_inv * (10^-3) if ISO3 == "MEX" & year <= 1986
replace ECLAC_inv    = ECLAC_inv * (10^-3) if inrange(year, 2003, 2005) & ISO3 == "MEX"
replace ECLAC_inv    = ECLAC_inv / 8.75 if year <= 1989 & ISO3 == "SLV"
replace ECLAC_inv    = ECLAC_inv / 25 if year < 2007 & ISO3 == "ECU"
replace ECLAC_inv    = ECLAC_inv / 1000 if year >= 2007 & ISO3 == "ECU"
replace ECLAC_inv    = ECLAC_inv * 1000 if year >= 2003 & ISO3 == "COL"
replace ECLAC_inv    = ECLAC_inv * 1000 if year >= 2011 & ISO3 == "CHL"
replace ECLAC_inv    = ECLAC_inv / 1000 if year <= 1973 & ISO3 == "CHL"
replace ECLAC_inv 	 = ECLAC_inv / 1000 if year <= 2005 & ISO3 == "BRA"
replace ECLAC_inv  	 = ECLAC_inv / 2750 if year <= 1990 & ISO3 == "BRA"
replace ECLAC_inv  	 = ECLAC_inv / 1000 if year <= 1980 & ISO3 == "BRA"
replace ECLAC_inv    = ECLAC_inv * (10^-3) if ISO3 == "BOL"
replace ECLAC_inv    = ECLAC_inv * (10^-3) if ISO3 == "BOL" & year <= 1984
replace ECLAC_inv    = ECLAC_inv * (10^-3) if year <= 1988 & ISO3 == "ARG"
replace ECLAC_inv    = ECLAC_inv * (10^-7) if year <= 1979 & ISO3 == "ARG"

replace ECLAC_M0   = . if ISO3 == "VEN"
replace ECLAC_M1   = . if ISO3 == "VEN"
replace ECLAC_M2   = . if ISO3 == "VEN"

replace ECLAC_cons  = ECLAC_cons * (10^-3) if year <= 1988 & ISO3 == "ARG"
replace ECLAC_cons  = ECLAC_cons * (10^-7) if year <= 1979 & ISO3 == "ARG"
replace ECLAC_cons  = ECLAC_cons / 1000 if ISO3 == "BHS"
replace ECLAC_cons  = ECLAC_cons / 1000 if ISO3 == "BOL"
replace ECLAC_cons  = ECLAC_cons * (10^-3) if ISO3 == "BOL" & year <= 1984
replace ECLAC_cons 	= ECLAC_cons / 1000 if year <= 2005 & ISO3 == "BRA"
replace ECLAC_cons  = ECLAC_cons / 2750 if year <= 1990 & ISO3 == "BRA"
replace ECLAC_cons  = ECLAC_cons / 1000 if year <= 1980 & ISO3 == "BRA"
replace ECLAC_cons  = ECLAC_cons * 1000 if year >= 2011 & ISO3 == "CHL"
replace ECLAC_cons  = ECLAC_cons / 1000 if year <= 1973 & ISO3 == "CHL"
replace ECLAC_cons  = ECLAC_cons * 1000 if year >= 2003 & ISO3 == "COL"
replace ECLAC_cons  = ECLAC_cons / 8.75 if year <= 1989 & ISO3== "SLV"
replace ECLAC_cons  = ECLAC_cons * (10^-3) if ISO3== "MEX" & year <= 1986
replace ECLAC_cons  = ECLAC_cons * (10^-3) if inrange(year, 2003, 2005) & ISO3== "MEX"
replace ECLAC_cons  = ECLAC_cons * (10^-3)  if inrange(year, 2005, 2007) & ISO3== "PRY"
replace ECLAC_cons  = ECLAC_cons * (10^-3) if ISO3== "PER" & year <= 2006
replace ECLAC_cons  = ECLAC_cons * (10^-8) if ISO3== "VEN"
replace ECLAC_cons  = ECLAC_cons * (10^-3) if ISO3== "URY"
replace ECLAC_cons  = ECLAC_cons * (10^-3) if ISO3== "SUR"

* Add ratios to gdp variables
gen ECLAC_cons_GDP    = (ECLAC_cons / ECLAC_nGDP) * 100
gen ECLAC_inv_GDP     = (ECLAC_inv / ECLAC_nGDP) * 100

* Drop negative M0 for Panama
replace ECLAC_M0 = . if ISO3 == "PAN"


* Derive gov finances in GDP
gen ECLAC_cgovexp_GDP = (ECLAC_cgovexp / ECLAC_nGDP) * 100
gen ECLAC_gen_govexp_GDP = (ECLAC_gen_govexp / ECLAC_nGDP) * 100

* Derive gov finances in nominal values
gen ECLAC_gen_govrev = (ECLAC_gen_govrev_GDP * ECLAC_nGDP) 
gen ECLAC_gen_govdef = (ECLAC_gen_govdef_GDP * ECLAC_nGDP) 

* Drop data on the Netherlands because we don't know really which part of the Netherlands is covered by this data (Notes provide no documentation: web research shows that data is likely for Curacao or the Dutch Antilles but it's unclear)
drop if ISO3 == "NLD"
drop if ISO3 == "ECU"

* Recast 
recast str3 ISO3 

* According to the notes, Brazilian data between 1990 and 1994 is not 
* comparable to the rest of the series and we can't convert it to the correct units even using the correct ratios
qui drop if inrange(year, 1990,  1994) & ISO3 == "BRA"

* Rebase variables to $base_year
gmd_rebase ECLAC

* Check for ratios and levels 
check_gdp_ratios ECLAC

* ==============================================================================
* 	Output
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
save "${output}", replace

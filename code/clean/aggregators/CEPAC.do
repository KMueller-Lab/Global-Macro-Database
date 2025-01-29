* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN ECONOMIC DATA FROM THE CEPAC
* 
* Description: 
* This stata script cleans economic data from CEPAC
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
global BOP "${data_raw}/aggregators/CEPAC/CEPAC_BOP.xlsx"
global cbrate "${data_raw}/aggregators/CEPAC/CEPAC_cbrate.xlsx"
global CPI "${data_raw}/aggregators/CEPAC/CEPAC_CPI.xlsx"
global debt "${data_raw}/aggregators/CEPAC/CEPAC_debt.xlsx"
global govexp "${data_raw}/aggregators/CEPAC/CEPAC_govexp.xlsx"
global infl "${data_raw}/aggregators/CEPAC/CEPAC_infl.xlsx"
global M0 "${data_raw}/aggregators/CEPAC/CEPAC_M0.xlsx"
global M1 "${data_raw}/aggregators/CEPAC/CEPAC_M1.xlsx"
global M2 "${data_raw}/aggregators/CEPAC/CEPAC_M2.xlsx"
global M3 "${data_raw}/aggregators/CEPAC/CEPAC_M3.xlsx"
global nGDP "${data_raw}/aggregators/CEPAC/CEPAC_nGDP.xlsx"
global REVENUE "${data_raw}/aggregators/CEPAC/CEPAC_REVENUE.xlsx"
global strate "${data_raw}/aggregators/CEPAC/CEPAC_strate.xlsx"
global output "${data_clean}/aggregators/CEPAC/CEPAC.dta"

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
ren E CEPAC

* Drop
drop B dif base_year

* Reshape
greshape wide CEPAC, i(countryname year) j(series)

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
* 	Government Debt
* ==============================================================================

* Open
qui import excel using "${debt}", clear 

* Keep only needed columns and rows
keep B C D 
drop in 1

* Rename
ren B countryname
ren C year
ren D CEPAC_govdebt_GDP

* Destring
destring year CEPAC_govdebt_GDP, replace

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
tempfile temp_debt
save `temp_debt', replace
merge 1:1 ISO3 year using `temp_na', nogen
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
ren F CEPAC_govexp

* Destring
destring year CEPAC_govexp, replace

* Encode types of government
encode B, gen(B_order)

* For countries that have both central government and general government, use central government
sort countryname year B_order
by countryname year: keep if _n == 1

* Generate countries' ISO3 code
replace countryname = "Bolivia" if countryname == "Bolivia (Plurinational State of)"
replace countryname = "Venezuela" if countryname == "Venezuela (Bolivarian Republic of)"
merge m:1 countryname using $isomapping, assert(2 3) keep(3) keepusing(ISO3) nogen
drop countryname

* Keep
keep ISO3 year CEPAC_govexp

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
replace D = "_govrev_GDP" if D == "Total revenue and grants"
replace D = "_govdef_GDP" if D == "Overall fiscal balance"
keep if strpos(D, "_") 

* Rename
ren C countryname
ren D series
ren E year
ren F CEPAC

* Destring
destring year CEPAC, replace

* Reshape
greshape wide CEPAC, i(countryname year) j(series)

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
ren D CEPAC_CPI

* Destring
destring year CEPAC_CPI, replace

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
ren D CEPAC_infl

* Destring
destring year CEPAC_infl, replace

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
ren E CEPAC_cbrate

* Destring
destring year CEPAC_cbrate, replace

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
ren E CEPAC_strate

* Destring
destring year CEPAC_strate, replace

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
ren E CEPAC_M0

* Destring
destring year CEPAC_M0, replace

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
ren E CEPAC_M1

* Destring
destring year CEPAC_M1, replace

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
ren E CEPAC_M2

* Destring
destring year CEPAC_M2, replace

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
ren E CEPAC_M3

* Destring
destring year CEPAC_M3, replace

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

* Derive gov finances in GDP
gen CEPAC_govexp_GDP = CEPAC_govexp / CEPAC_nGDP

* Derive gov finances in nominal values
gen CEPAC_govrev = CEPAC_govrev_GDP * CEPAC_nGDP 
gen CEPAC_govdef = CEPAC_govdef_GDP * CEPAC_nGDP 

* ==============================================================================
* 	Convert units in case of undocumented inconsistencies in reporting units
* ==============================================================================

replace CEPAC_nGDP = CEPAC_nGDP / 1000 if ISO3 == "BHS"
replace CEPAC_nGDP = CEPAC_nGDP / 1000 if ISO3 == "BOL"
replace CEPAC_nGDP = CEPAC_nGDP / 1000 if ISO3 == "ECU"
replace CEPAC_nGDP = CEPAC_nGDP / 1000 if ISO3 == "MEX" & year <= 1986
replace CEPAC_nGDP = CEPAC_nGDP / 1000 if ISO3 == "MEX" & year <= 2005 & year >= 2003
replace CEPAC_nGDP = CEPAC_nGDP / 1000 if ISO3 == "PRY" & year <= 2007 & year >= 2005
replace CEPAC_nGDP = CEPAC_nGDP / 1000 if year <= 2005 & ISO3 == "BRA"
replace CEPAC_nGDP = CEPAC_nGDP / 2750 if year <= 1990 & ISO3 == "BRA"
replace CEPAC_nGDP = CEPAC_nGDP / 1000 if year <= 1980 & ISO3 == "BRA"
replace CEPAC_nGDP = CEPAC_nGDP * (10^-14) if ISO3 == "VEN"
replace CEPAC_nGDP = CEPAC_nGDP * (10^-3) if ISO3 == "URY"
replace CEPAC_nGDP = CEPAC_nGDP * (10^-3) if ISO3 == "SUR"
replace CEPAC_nGDP = CEPAC_nGDP / 1000 if year <= 2006 & ISO3 == "PER"
replace CEPAC_nGDP = CEPAC_nGDP / 1000 if ISO3 == "BOL" & year <= 1984
replace CEPAC_nGDP = CEPAC_nGDP / 1000 if ISO3 == "ARG" & year <= 1987
replace CEPAC_nGDP = CEPAC_nGDP / 10000000 if ISO3 == "ARG" & year <= 1979
replace CEPAC_nGDP = CEPAC_nGDP * 1000 if year >= 2011 & ISO3 == "CHL"
replace CEPAC_nGDP = CEPAC_nGDP / 1000 if year <= 1973 & ISO3 == "CHL"
replace CEPAC_nGDP = CEPAC_nGDP / 8.75 if year <= 1989 & ISO3 == "SLV"
replace CEPAC_nGDP = CEPAC_nGDP * 1000 if ISO3 == "COL" & year >= 2003

replace CEPAC_govrev = CEPAC_govrev / 100 if year <= 2010 & ISO3 == "CHL"
replace CEPAC_govrev = CEPAC_govrev * 10 if year > 2010 & ISO3 == "CHL"
replace CEPAC_govrev = CEPAC_govrev / 100 if ISO3 == "PER"
replace CEPAC_govrev = CEPAC_govrev / 1000 if year <= 2006 & ISO3 == "PER"
replace CEPAC_govrev = CEPAC_govrev / 100000 if ISO3 == "BOL"
replace CEPAC_govrev = CEPAC_govrev / 100 if ISO3 == "CRI"
replace CEPAC_govrev = CEPAC_govrev / 100 if ISO3 == "BRA"
replace CEPAC_govrev = CEPAC_govrev / 1000 if ISO3 == "BRA" & year <= 2004

replace CEPAC_govexp = CEPAC_govexp * (10^-8) if ISO3 == "VEN"

replace CEPAC_inv    = CEPAC_inv * (10^-8) if ISO3 == "VEN"
replace CEPAC_inv    = CEPAC_inv * (10^-6) if ISO3 == "VEN"
replace CEPAC_inv    = CEPAC_inv * (10^-3) if ISO3 == "URY"
replace CEPAC_inv    = CEPAC_inv * (10^-3) if ISO3 == "SUR"
replace CEPAC_inv    = CEPAC_inv * (10^-3) if ISO3 == "PER" & year <= 2006
replace CEPAC_inv    = CEPAC_inv * (10^-3)  if inrange(year, 2005, 2007) & ISO3 == "PRY"
replace CEPAC_inv    = CEPAC_inv * (10^-3) if ISO3 == "MEX" & year <= 1986
replace CEPAC_inv    = CEPAC_inv * (10^-3) if inrange(year, 2003, 2005) & ISO3 == "MEX"
replace CEPAC_inv    = CEPAC_inv / 8.75 if year <= 1989 & ISO3 == "SLV"
replace CEPAC_inv    = CEPAC_inv / 25 if year < 2007 & ISO3 == "ECU"
replace CEPAC_inv    = CEPAC_inv / 1000 if year >= 2007 & ISO3 == "ECU"
replace CEPAC_inv    = CEPAC_inv * 1000 if year >= 2003 & ISO3 == "COL"
replace CEPAC_inv    = CEPAC_inv * 1000 if year >= 2011 & ISO3 == "CHL"
replace CEPAC_inv    = CEPAC_inv / 1000 if year <= 1973 & ISO3 == "CHL"
replace CEPAC_inv    = CEPAC_inv * (10^-3) if inrange(year, 1990, 2004) & ISO3 == "BRA"
replace CEPAC_inv    = CEPAC_inv * (10^-6) if year <= 1989 & ISO3 == "BRA"
replace CEPAC_inv    = CEPAC_inv * (10^-3) if year <= 1980 & ISO3 == "BRA"
replace CEPAC_inv    = CEPAC_inv * (10^-3) if ISO3 == "BOL"
replace CEPAC_inv    = CEPAC_inv * (10^-3) if ISO3 == "BOL" & year <= 1984
replace CEPAC_inv    = CEPAC_inv * (10^-3) if year <= 1988 & ISO3 == "ARG"
replace CEPAC_inv    = CEPAC_inv * (10^-7) if year <= 1979 & ISO3 == "ARG"

replace CEPAC_M0   = CEPAC_M0 * (10^-8) if ISO3 == "VEN"
replace CEPAC_M1   = CEPAC_M1 * (10^-8) if ISO3 == "VEN"
replace CEPAC_M2   = CEPAC_M2 * (10^-8) if ISO3 == "VEN"

replace CEPAC_M0   = . if CEPAC_M0 == 0
replace CEPAC_M1   = . if CEPAC_M1 == 0
replace CEPAC_M2   = . if CEPAC_M2 == 0

replace CEPAC_cons  = CEPAC_cons * (10^-3) if year <= 1988 & ISO3 == "ARG"
replace CEPAC_cons  = CEPAC_cons * (10^-7) if year <= 1979 & ISO3 == "ARG"
replace CEPAC_cons  = CEPAC_cons / 1000 if ISO3 == "BHS"
replace CEPAC_cons  = CEPAC_cons / 1000 if ISO3 == "BOL"
replace CEPAC_cons  = CEPAC_cons * (10^-3) if inrange(year, 1991, 2005) & ISO3 == "BRA"
replace CEPAC_cons  = CEPAC_cons * (10^-6) if year <= 1990 & ISO3 == "BRA"
replace CEPAC_cons  = CEPAC_cons * (10^-3) if year <= 1980 & ISO3 == "BRA"
replace CEPAC_cons  = CEPAC_cons * 1000 if year >= 2011 & ISO3 == "CHL"
replace CEPAC_cons  = CEPAC_cons / 1000 if year <= 1973 & ISO3 == "CHL"
replace CEPAC_cons  = CEPAC_cons * 1000 if year >= 2003 & ISO3 == "COL"
replace CEPAC_cons  = CEPAC_cons / 25 if year < 2007 & ISO3== "ECU"
replace CEPAC_cons  = CEPAC_cons / 1000 if year >= 2007 & ISO3== "ECU"
replace CEPAC_cons  = CEPAC_cons / 8.75 if year <= 1989 & ISO3== "SLV"
replace CEPAC_cons  = CEPAC_cons * (10^-3) if ISO3== "MEX" & year <= 1986
replace CEPAC_cons  = CEPAC_cons * (10^-3) if inrange(year, 2003, 2005) & ISO3== "MEX"
replace CEPAC_cons  = CEPAC_cons * (10^-3)  if inrange(year, 2005, 2007) & ISO3== "PRY"
replace CEPAC_cons  = CEPAC_cons * (10^-3) if ISO3== "PER" & year <= 2006
replace CEPAC_cons  = CEPAC_cons * (10^-15) if ISO3== "VEN"
replace CEPAC_cons  = CEPAC_cons * (10^-3) if ISO3== "URY"
replace CEPAC_cons  = CEPAC_cons * (10^-3) if ISO3== "SUR"

* Add ratios to gdp variables
gen CEPAC_cons_GDP    = (CEPAC_cons / CEPAC_nGDP) * 100
gen CEPAC_inv_GDP     = (CEPAC_inv / CEPAC_nGDP) * 100

* Drop negative M0 for Panama
replace M0 = . if ISO3 == "PAN"

* ==============================================================================
* 	Output
* ==============================================================================
* Remove 
ren * *

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
save "${output}", replace

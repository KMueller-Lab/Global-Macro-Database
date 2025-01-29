* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Description: 
* This Stata script reads in and clean historical trade statistics data
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-06-16
*
* URL: https://www.uc3m.es/ss/Satellite/UC3MInstitucional/es/TextoMixta/1371246237481/Federico-Tena_World_Trade_Historical_Database
* ==============================================================================

* ==============================================================================
* SET UP 
* ==============================================================================
* Clear panel
clear

* Define input and output files
global input "${data_raw}/aggregators/Tena/trade"
global output "${data_clean}/aggregators/Tena/trade/Tena_trade.dta"

* Create empty file to store the data
tempfile temp_master
save `temp_master', replace emptyok

* ==============================================================================
*     IMPORTING DATA FOR AFRICA
* ==============================================================================

* Open
import excel using "$input/africa_1817_1938", clear sheet(Current prices, current borders)

* Keeping only data for imports. Dropping all columns that have exports for now.
drop AW AX AY AZ 
local dropvars ""
foreach var of varlist B* C*{
    if "`var'" != "B" & "`var'" != "C" {
        local dropvars `dropvars' `var'
    }
}
drop `dropvars'

* Drop empty rows
drop in 1/5

* Drop countries with no data
missings dropvars, force

* Drop Spanish colonies that are part of Spain today
drop M N 

* Drop ambiguous countries (French Equatorial Africa-Congo-Final, French West Africa & Togo)
drop T R

* Drop French colony that is a part of France today
drop AH

* Rename countries
ren A year
ren B DZA
ren C AGO
ren F COD
ren I KEN // British East Africa (Kenia & Uganda)
ren J SOM_1 // British Somaliland 
ren K CPV
ren L CMR
ren O EGY
ren P ERI
ren Q ETH
ren S DJI // French Somalia
ren U GMB
ren V NAM
ren W GHA
ren X GNB
ren Y SOM_2 // Italian Somalia
ren Z LBY
ren AA LBR
ren AB MDG
ren AC MWI
ren AD MAR
ren AE MUS
ren AF MOZ
ren AG NGA
ren AI ZWE
ren AJ RWA // Rwanda and Burundi
ren AL STP
ren AM SYC
ren AN SLE
ren AO ZAF
ren AQ SDN
ren AS TZA_1 // Tanganika
ren AT TGO
ren AU TUN
ren AV TZA_2 // Zanzibar


* Destring
destring *, replace

* Aggregate countries to match their current borders
replace TZA_1 = 0 if TZA_1 == .
replace TZA_2 = 0 if TZA_2 == .
gen TZA = TZA_1 + TZA_2 // Modern day Tanzania is formed after the merger of Zanzibar and Tanganika
replace TZA = . if TZA == 0

replace SOM_1 = 0 if SOM_1 == .
replace SOM_2 = 0 if SOM_2 == .
gen SOM = SOM_1 + SOM_2 // Modern day Somalia is formed after the merger of British Somaliland and Italian Somalia
drop TZA_1 TZA_2 SOM_1 SOM_2
replace SOM = . if SOM == 0

* Treating zeros as missing values
replace TGO = . if TGO == 0
replace COD = . if COD == 0

* Renaming the countries before reshaping into a long dataset
ds year, not
foreach var in `r(varlist)'{
	ren `var' imports`var'
}

* Drop rows other than year that have no data
missings dropobs imports*, force

* Reshape
greshape long imports, i(year) j(ISO3) string

* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid ISO3 year

* Save and merge
tempfile temp_africa_imports
save `temp_africa_imports', replace emptyok
append using `temp_master'
save `temp_master', replace
* ==============================================================================
*     AFRICA'S EXPORTS
* ==============================================================================

* Open
import excel using "$input/africa_1817_1938", clear sheet(Current prices, current borders)

* Keeping only data for exports. Dropping all columns that have imports for now.
local dropvars ""
foreach var of varlist B* C*{
    if "`var'" != "B" & "`var'" != "C" {
        local dropvars `dropvars' `var'
    }
}
keep A AY AZ `dropvars'


* Drop empty rows
drop in 1/5

* Drop countries with no data
missings dropvars, force

* Drop Spanish colonies that are part of Spain today
drop BJ BK

* Drop ambiguous countries (French Equatorial Africa-Congo-Final, French West Africa & Togo)
drop BO BQ

* Drop French colony that is a part of France today
drop CE

* Rename countries
ren A year
ren AY DZA
ren AZ AGO
ren BC COD
ren BF KEN 
ren BG SOM_1
ren BH CPV
ren BI CMR
ren BL EGY
ren BM ERI
ren BN ETH
ren BP DJI
ren BR GMB
ren BS NAM
ren BT GHA
ren BU GNB
ren BV SOM_2
ren BW LBY
ren BX LBR
ren BY MDG
ren BZ MWI
ren CA MAR
ren CB MUS
ren CC MOZ
ren CD NGA
ren CF ZWE
ren CG RWA
ren CI STP
ren CJ SYC
ren CK SLE
ren CL ZAF
ren CN SDN
ren CP TZA_1
ren CQ TGO
ren CR TUN
ren CS TZA_2

* Destring
destring *, replace

* Aggregate countries to match their current borders
* Tanzania:
replace TZA_1 = 0 if TZA_1 == .
replace TZA_2 = 0 if TZA_2 == .
gen TZA = TZA_1 + TZA_2 // Modern day Tanzania is formed after the merger of Zanzibar and Tanganika
replace TZA = . if TZA == 0

* Somalia:
replace SOM_1 = 0 if SOM_1 == .
replace SOM_2 = 0 if SOM_2 == .
gen SOM = SOM_1 + SOM_2 // Modern day Somalia is formed after the merger of British Somaliland and Italian Somalia
drop TZA_1 TZA_2 SOM_1 SOM_2
replace SOM = . if SOM == 0

* Treating zeros as missing values
replace TGO = . if TGO == 0
replace COD = . if COD == 0

* Renaming the countries before reshaping into a long dataset
ds year, not
foreach var in `r(varlist)'{
	ren `var' exports`var'
}

* Drop rows other than year that have no data
missings dropobs exports*, force

* Reshape
greshape long exports, i(year) j(ISO3) string

* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid ISO3 year

* Save and merge
tempfile temp_africa_exports
save `temp_africa_exports', replace emptyok
merge 1:1 ISO3 year using `temp_master'
drop _merge
save `temp_master', replace

* ==============================================================================
*     EUROPE'S IMPORTS
* ==============================================================================

* Open
import excel using "$input/europe_1800_1938.xlsx", clear sheet(Current prices, current borders)

* Keeping only data for imports. Dropping all columns that have exports for now.
local dropvars ""
foreach var of varlist B* C*{
    if "`var'" != "B" & "`var'" != "C" {
        local dropvars `dropvars' `var'
    }
}
drop AP AQ AR AS AT AU AV AW AX AY AZ `dropvars'

* Drop documentation rows
drop in 1/2

* Drop empty rows
missings dropobs, force

* Rename
qui ds A, not
foreach var in `r(varlist)' {
    local newname = `var'[1]
    capture ren `var' `newname'
}

* Drop Austria-Hungary for now
drop E

* Destring
drop in 1
destring *, replace

* Drop columns with no data
missings dropvars, force

* Turn 0 for Romania into missing values
replace Romania = . if Romania == .

* Add Ionian islands and Crete to Greece
replace Crete = 0 if Crete == .
replace V = 0 if V == .
replace Greece = Crete + V

* Drop
drop Crete V

* Rename
ren A year
ren Albania ALB
ren Austria AUT
ren Belgium BEL
ren Bulgaria BGR
ren Cyprus CYP
ren Czechoslowakia CSK
ren Denmark DNK
ren Estonia EST
ren Finland FIN
ren France FRA
ren Greece GRC
ren Hungary HUN
ren Iceland ISL
ren Ireland IRL
ren Italy ITA
ren Latvia LVA
ren Lithuania LTU
ren Netherland NLD
ren Norway NOR
ren Poland POL
ren Portugal PRT
ren Romania ROU
ren Spain ESP
ren Sweden SWE
ren Switzerland CHE
ren AK YUG
ren Q DEU // Rename Germany/Zollverein to Germany
ren AJ RUS // Rename Russia/USSR to Russia 
ren AO GBR

* Renaming the countries before reshaping into a long dataset
ds year, not
foreach var in `r(varlist)'{
	ren `var' imports`var'
}

* Drop rows other than year that have no data
missings dropobs imports*, force

* Reshape
greshape long imports, i(year) j(ISO3) string

* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid ISO3 year

* Save and merge
tempfile temp_europe_imports
save `temp_europe_imports', replace emptyok
merge 1:1 ISO3 year using `temp_master'
drop _merge
save `temp_master', replace

* ==============================================================================
*     EUROPE'S EXPORTS
* ==============================================================================

* Open
import excel using "$input/europe_1800_1938.xlsx", clear sheet(Current prices, current borders)

* Keeping only data for exports. Dropping all columns that have imports for now.
local dropvars ""
foreach var of varlist B* C*{
    if "`var'" != "B" & "`var'" != "C" {
        local dropvars `dropvars' `var'
    }
}
keep A AR AS AT AU AV AW AX AY AZ `dropvars'

* Drop documentation rows
drop in 1/2

* Drop empty rows
missings dropobs, force

* Rename
qui ds A, not
foreach var in `r(varlist)' {
    local newname = `var'[1]
    capture ren `var' `newname'
}

* Drop Austria-Hungary for now
drop AU

* Destring
drop in 1
destring *, replace

* Drop columns with no data
missings dropvars, force

* Add Ionian islands and Crete to Greece
replace Crete = 0 if Crete == .
replace BL = 0 if BL == .
replace Greece = Crete + BL
replace Greece = . if Greece == 0

* Drop
drop Crete BL

* Rename columns
ren A year
ren Albania ALB
ren Austria AUT
ren Belgium BEL
ren Bulgaria BGR
ren Cyprus CYP
ren Czechoslowakia CSK
ren Denmark DNK
ren Estonia EST
ren Finland FIN
ren France FRA
ren Greece GRC
ren Hungary HUN
ren Iceland ISL
ren Ireland IRL
ren Italy ITA
ren Latvia LVA
ren Lithuania LTU
ren Netherland NLD
ren Norway NOR
ren Poland POL
ren Portugal PRT
ren Romania ROU
ren Spain ESP
ren Sweden SWE
ren Switzerland CHE
ren CA YUG
ren BG DEU // Rename Germany/Zollverein to Germany
ren BZ RUS // Rename Russia/USSR to Russia 
ren CE GBR


* Renaming the countries before reshaping into a long dataset
ds year, not
foreach var in `r(varlist)'{
	ren `var' exports`var'
}

* Drop rows other than year that have no data
missings dropobs exports*, force

* Reshape
greshape long exports, i(year) j(ISO3) string

* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid ISO3 year

* Save and merge
tempfile temp_europe_exports
save `temp_europe_exports', replace emptyok
merge 1:1 ISO3 year using `temp_master'
drop _merge
save `temp_master', replace

* ==============================================================================
*     ASIA'S IMPORTS
* ==============================================================================

* Open
import excel using "$input/asia_1800_1938.xlsx", clear sheet(Current prices, current borders)

* Keeping only data for imports. Dropping all columns that have exports for now.
local dropvars ""
foreach var of varlist B* C* D* {
    if "`var'" != "B" & "`var'" != "BA" & "`var'" != "BB" & "`var'" != "C" & "`var'" != "D"  {
        local dropvars `dropvars' `var'
    }
}
drop `dropvars'

* Drop documentation rows
drop in 1/2

* Drop empty rows
missings dropobs, force

* Rename
qui ds A, not
foreach var in `r(varlist)' {
    local newname = `var'[1]
    capture ren `var' `newname'
}

* Drop Chinese territories
drop Manchukuo 

* Drop Syria and Lebanon
drop AY

* Rename
ren A year
ren Afghanistan AFG
ren China CHN
ren Iraq IRQ
ren India IND_1
ren Japan JPN
ren Palestine PSE
ren Philippines PHL
ren AS MYS_3 // Sabah (British Borneo)
ren H MYS_1 // British Malaya
ren K LKA
ren O IDN
ren P TWN
ren Q IND_2 // French India
ren R VNM
ren Korea KOR
ren AJ YEM
ren AL TUR
ren AN IRN
ren AP IND_3 // Portuguese India
ren Sarawak MYS_2
ren AU SAU
ren AW THA
ren Nepal NPL
ren Brunei BRN

* Destring
drop in 1
destring *, replace


* Drop columns with no data
missings dropvars, force

* Aggregate countries
* Malaysia
replace MYS_1 = 0 if MYS_1 == .
replace MYS_2 = 0 if MYS_2 == .
replace MYS_3 = 0 if MYS_3 == .
gen MYS = MYS_1 + MYS_2 + MYS_3
drop MYS_*
replace MYS = . if MYS == 0


* India
replace IND_1 = 0 if IND_1 == .
replace IND_2 = 0 if IND_2 == .
replace IND_3 = 0 if IND_3 == .
gen IND = IND_1 + IND_2 + IND_3
drop IND_*


* Renaming the countries before reshaping into a long dataset
ds year, not
foreach var in `r(varlist)'{
	ren `var' imports`var'
}

* Drop rows other than year that have no data
missings dropobs imports*, force

* Reshape
greshape long imports, i(year) j(ISO3) string

* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid ISO3 year

* Save and merge
tempfile temp_asia_imports
save `temp_asia_imports', replace emptyok
merge 1:1 ISO3 year using `temp_master'
drop _merge
save `temp_master', replace

* ==============================================================================
*     ASIA'S EXPORTS
* ==============================================================================

* Open
import excel using "$input/asia_1800_1938.xlsx", clear sheet(Current prices, current borders)

* Keeping only data for exports. Dropping all columns that have imports for now.
local dropvars ""
foreach var of varlist B* C* D* {
    if "`var'" != "B" & "`var'" != "BA" & "`var'" != "BB" & "`var'" != "C" & "`var'" != "D"  {
        local dropvars `dropvars' `var'
    }
}
keep A `dropvars'

* Drop documentation rows
drop in 1/2

* Drop empty rows
missings dropobs, force

* Rename
qui ds A, not
foreach var in `r(varlist)' {
    local newname = `var'[1]
    capture ren `var' `newname'
}

* Drop Chinese territories
drop Manchukuo 

* Drop Syria and Lebanon
drop DC

* Rename
ren A year
ren Afghanistan AFG
ren China CHN
ren Iraq IRQ
ren India IND_1
ren Japan JPN
ren Palestine PSE
ren Philippines PHL
ren CW MYS_3
ren BL MYS_1
ren BO LKA
ren BS IDN
ren BT TWN
ren BU IND_2
ren BV VNM
ren Korea KOR
ren CN YEM
ren CP TUR
ren CR IRN
ren CT IND_3
ren Sarawak MYS_2
ren CY SAU
ren DA THA
ren Nepal NPL
ren Brunei BRN

* Destring
drop in 1
destring *, replace

* Drop columns with no data
missings dropvars, force

* Aggregate countries
* Malaysia
replace MYS_1 = 0 if MYS_1 == .
replace MYS_2 = 0 if MYS_2 == .
replace MYS_3 = 0 if MYS_3 == .
gen MYS = MYS_1 + MYS_2 + MYS_3
drop MYS_*
replace MYS = . if MYS == 0

* India
replace IND_1 = 0 if IND_1 == .
replace IND_2 = 0 if IND_2 == .
replace IND_3 = 0 if IND_3 == .
gen IND = IND_1 + IND_2 + IND_3
drop IND_*

* Renaming the countries before reshaping into a long dataset
ds year, not
foreach var in `r(varlist)'{
	ren `var' exports`var'
}

* Drop rows other than year that have no data
missings dropobs exports*, force

* Reshape
greshape long exports, i(year) j(ISO3) string

* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid ISO3 year

* Save and merge
tempfile temp_asia_exports
save `temp_asia_exports', replace emptyok
merge 1:1 ISO3 year using `temp_master'
drop _merge
save `temp_master', replace

* ==============================================================================
*     AMERICAS' IMPORTS
* ==============================================================================

* Open
import excel using "$input/america_1800_1938.xlsx", clear sheet(Current prices, current borders)

* Keeping only data for imports. Dropping all columns that have exports for now.
local dropvars ""
foreach var of varlist B* C* D* E* {
    if "`var'" != "B" & "`var'" != "C" & "`var'" != "D" & "`var'" != "E"  {
        local dropvars `dropvars' `var'
    }
}
drop AU AV AW AX AY AZ `dropvars'

* Drop documentation rows
drop in 1/2
drop in 2

* Drop empty rows
missings dropobs, force

* Rename
qui ds A, not
foreach var in `r(varlist)' {
    local newname = `var'[1]
    capture ren `var' `newname'
}

* Drop countries no longer exist Leward Island (L.I Antigua, L.I Dominica, L.I St.Christopher, Montserrat, Nevis, Virgin Island), New Foundland, Danish Virgin Island (US Virgin Islands keep lound)
drop O AB 

* Drop Dutch colonies
drop Q 

* Rename
ren A year
ren Argentina ARG
ren Bahamas BHS
ren Barbados BRB
ren Bermuda BMU
ren Bolivia BOL
ren Brasil BRA
ren H GUY
ren I BLZ
ren Canada CAN
ren Chile CHL
ren Colombia COL
ren M CRI
ren Cuba CUB
ren P DOM
ren Ecuador ECU
ren S SLV
ren V GRD
ren Guatemala GTM
ren W GLP
ren U GUF
ren AK BLM
ren AJ PRI
ren AC MTQ
ren AN SPM
ren AE VIR
ren T FLK
ren Haiti HTI
ren Honduras HND
ren Jamaica JAM
ren Mexico MEX
ren Nicaragua NIC
ren Panama PAN
ren Paraguay PRY
ren Peru PER
ren AL VCT
ren AM LCA
ren AO SUR
ren AP TTO
ren AQ TCA
ren AR USA
ren Uruguay URY
ren Venezuela VEN


* Destring
drop in 1
destring *, replace
replace PRI = . if PRI == 0


* Drop columns with no data
missings dropvars, force

* Renaming the countries before reshaping into a long dataset
ds year, not
foreach var in `r(varlist)'{
	ren `var' imports`var'
}

* Drop rows other than year that have no data
missings dropobs imports*, force

* Reshape
greshape long imports, i(year) j(ISO3) string

* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid ISO3 year

* Save and merge
tempfile temp_americas_imports
save `temp_americas_imports', replace emptyok
merge 1:1 ISO3 year using `temp_master'
drop _merge
save `temp_master', replace

* ==============================================================================
*     AMERICAS' EXPORTS
* ==============================================================================
* Open
import excel using "$input/america_1800_1938.xlsx", clear sheet(Current prices, current borders)

* Keeping only data for exports. Dropping all columns that have imports for now.
local dropvars ""
foreach var of varlist B* C* {
    if "`var'" != "B" & "`var'" != "C" & "`var'" != "D" & "`var'" != "E"  {
        local dropvars `dropvars' `var'
    }
}
keep A AW AX AY AZ `dropvars'


* Drop documentation rows
drop in 1/2
drop in 2

* Drop empty rows
missings dropobs, force

* Rename
qui ds A, not
foreach var in `r(varlist)' {
    local newname = `var'[1]
    capture ren `var' `newname'
}

* Drop countries no longer exist Leward Island (L.I Antigua, L.I Dominica, L.I St.Christopher, Montserrat, Nevis, Virgin Island), New Foundland, Danish Virgin Island (US Virgin Islands)
drop BW BZ

* Drop Dutch colonies
drop BL

* Rename
ren A year
ren Argentina ARG
ren Bahamas BHS
ren Barbados BRB
ren Bermuda BMU
ren Bolivia BOL
ren Brasil BRA
ren BC GUY
ren BD BLZ
ren Canada CAN
ren Chile CHL
ren Colombia COL
ren BH CRI
ren Cuba CUB
ren BK DOM
ren Ecuador ECU
ren BN SLV
ren BQ GRD
ren Guatemala GTM
ren BR GLP
ren BP GUF
ren CF BLM
ren CE PRI
ren BX MTQ
ren CI SPM
ren BJ VIR
ren BO FLK
ren Haiti HTI
ren Honduras HND
ren Jamaica JAM
ren Mexico MEX
ren Nicaragua NIC
ren Panama PAN
ren Paraguay PRY
ren Peru PER
ren CG VCT
ren CH LCA
ren CJ SUR
ren CK TTO
ren CL TCA
ren CM USA
ren Uruguay URY
ren Venezuela VEN

* Destring
drop in 1
destring *, replace
replace PRI = . if PRI == 0

* Drop columns with no data
missings dropvars, force

* Renaming the countries before reshaping into a long dataset
ds year, not
foreach var in `r(varlist)'{
	ren `var' exports`var'
}

* Drop rows other than year that have no data
missings dropobs exports*, force

* Reshape
greshape long exports, i(year) j(ISO3) string

* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid ISO3 year

* Save and merge
tempfile temp_americas_exports
save `temp_americas_exports', replace emptyok
merge 1:1 ISO3 year using `temp_master'
drop _merge
save `temp_master', replace

* ==============================================================================
*     AUSTRALIA'S IMPORTS AND EXPORTS
* ==============================================================================
* Open
import excel using "$input/australia_1826_1938.xlsx", clear sheet(Current prices)

* Keep columns with data
keep A B C

* Dropping rows with no data
drop in 1/6
missings dropobs B C, force

* Rename
ren A year
ren B imports
ren C exports

* Destring
destring *, replace

* Create ISO3 column
gen ISO3 = "AUS"

* Order
order ISO3 year 
tempfile temp_australia
save `temp_australia', replace emptyok
merge 1:1 ISO3 year using `temp_master'
drop _merge
save `temp_master', replace

* ==============================================================================
*     NEW ZEALAND'S IMPORTS AND EXPORTS
* ==============================================================================
* Open
import excel using "$input/new_zealand_1826_1938.xlsx", clear sheet(Current prices)

* Keep columns with data
keep A B C

* Dropping rows with no data
drop in 1/6
missings dropobs B C, force

* Rename
ren A year
ren B imports
ren C exports

* Destring
destring *, replace

* Create ISO3 column
gen ISO3 = "NZL"

* Order
order ISO3 year 
tempfile temp_nzl
save `temp_nzl', replace emptyok
merge 1:1 ISO3 year using `temp_master'
drop _merge
save `temp_master', replace

* ==============================================================================
*    FIX THE UNITS
* ==============================================================================

* Rename columns
ren imports Tena_imports_USD
ren exports Tena_exports_USD

* Convert values to local currency using Tena USDfx
merge 1:1 ISO3 year using "${data_clean}/aggregators/Tena/trade/Tena_USDfx.dta", nogen
gen Tena_imports = Tena_imports_USD * Tena_USDfx
gen Tena_exports = Tena_exports_USD * Tena_USDfx
drop Tena_USDfx


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
save "$output", replace

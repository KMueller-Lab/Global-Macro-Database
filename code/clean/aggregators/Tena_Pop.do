* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Author:
* Ziliang Chen
* National University of Singapore
*
* Created: 2024-06-21
*
* Description: 
* This Stata script cleans historical population statistics from Federico-Tena
*
* ==============================================================================

* ==============================================================================
* 						SET UP 
* ==============================================================================
clear
global input "${data_raw}/aggregators/Tena/pop/"
global output "${data_clean}/aggregators/Tena/pop/Tena_pop.dta"

* Create empty file to store the data
tempfile temp_master
save `temp_master', replace emptyok

* ==============================================================================
*     IMPORTING DATA FOR AFRICA
* ==============================================================================

* Open
import excel using "$input/africa_1800-1938_FTWPHD_2023_v01", clear sheet(AFRICA)

* Rename Columns
ren A year
ren B DZA
ren C AGO
ren D LSO
ren E BWA
ren F COD
ren H CPV
ren I CMR
ren L EGY
ren M GNQ
ren N ERI
ren O ETH
ren Q DJI
ren S GMB
ren T TZA_1
ren U NAM
ren V TGO
ren W GHA
ren X GNB
ren Y LBY
ren AA LBR
ren AB MDG
ren AC MWI
ren AD MUS
ren AE MAR
ren AF MOZ
ren AG NGA
ren AH ZMB
ren AL STP
ren AM SYC
ren AN SLE
ren AO ZAF
ren AP ZWE
ren AQ ESH
ren AR SDN
ren AS SWZ
ren AT TUN
ren AU TZA_2

drop G J K P R Z AI AJ AK AV

drop in 1/4
drop in -2/L

* Destring
destring *, replace

* Aggregate countries to match their current borders
replace TZA_1 = 0 if TZA_1 == .
replace TZA_2 = 0 if TZA_2 == .
gen TZA = TZA_1 + TZA_2 	// Modern day Tanzania is formed after the merger of Zanzibar and Tanganika
replace TZA = . if TZA == 0
drop TZA_1 TZA_2

* Renaming the countries before reshaping into a long dataset
ds year, not
foreach var in `r(varlist)'{
	ren `var' Tena_pop`var'
}

* Reshape
greshape long Tena_pop, i(year) j(ISO3) string

* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid ISO3 year

* Save and merge
tempfile temp_africa_pop
save `temp_africa_pop', replace emptyok
append using `temp_master'
save `temp_master', replace




* ==============================================================================
*     IMPORTING DATA FOR AMERICA
* ==============================================================================

* Open
import excel using "$input/america_1800-1938_FTWPHD_2023_v01", clear sheet(AMERICA)

* Rename Columns
ren A year
ren B ARG
ren C BHS
ren D BRB
ren E BMU
ren F BOL
ren G BRA
ren H GUY
ren I BLZ
ren J CAN
ren K CHL
ren L COL
ren M CRI
ren N CUB
ren O VIR
ren P DOM
ren R ECU
ren S SLV
ren T FLK
ren U GUF
ren V GRD
ren W GLP
ren X GTM
ren Y HTI
ren Z HND
ren AA JAM
ren AC MTQ
ren AD MEX
ren AF NIC
ren AG PAN
ren AH PRY
ren AI PER
ren AJ PRI
ren AK BLM
ren AL LCA
ren AM SPM
ren AN VCT
ren AO SUR
ren AP TTO
ren AQ TCA
ren AR USA
ren AS URY
ren AT VEN

drop Q AB AE AU

drop in 1/2
drop in -2/L

* Destring
destring *, replace

* Renaming the countries before reshaping into a long dataset
ds year, not
foreach var in `r(varlist)'{
	ren `var' Tena_pop`var'
}

* Reshape
greshape long Tena_pop, i(year) j(ISO3) string

* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid ISO3 year

* Save and merge
tempfile temp_america_pop
save `temp_america_pop', replace emptyok
append using `temp_master'
save `temp_master', replace

* ==============================================================================
*     IMPORTING DATA FOR ASIA
* ==============================================================================

* Open
import excel using "$input/asia_1800-1938_FTWPHD_2023_v01", clear sheet(ASIA)

* Rename Columns
ren A year
ren B YEM_1
ren C AFG
ren D SAU
ren E BHR
ren F BTN
ren G MYS
ren I BRN
ren J LKA
ren K CHN
ren L IDN
ren M TLS
ren P HKG
ren Q IND
ren R IRQ
ren S JPN
ren T UZB
ren U KOR
ren V KWT
ren W MAC
ren Y MNG
ren Z NPL
ren AA YEM_2
ren AB OMN
ren AC TUR
ren AD PSE
ren AE IRN
ren AF PHL
ren AH QAT
ren AJ THA
ren AL ARE

drop H N O X AG AI AK AM

drop in 1/2
drop in -2/L

* Destring
destring *, replace

* Aggregate countries to match their current borders
replace YEM_1 = 0 if YEM_1 == .
replace YEM_2 = 0 if YEM_2 == .
gen YEM = YEM_1 + YEM_2 	
replace YEM = . if YEM == 0
drop YEM_1 YEM_2

* Renaming the countries before reshaping into a long dataset
ds year, not
foreach var in `r(varlist)'{
	ren `var' Tena_pop`var'
}

* Reshape
greshape long Tena_pop, i(year) j(ISO3) string

* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid ISO3 year

* Save and merge
tempfile temp_asia_pop
save `temp_asia_pop', replace emptyok
append using `temp_master'
save `temp_master', replace


* ==============================================================================
*     IMPORTING DATA FOR EUROPE
* ==============================================================================

* Open
import excel using "$input/europe_1800-1938_FTWPHD_2023_v01", clear sheet(EUROPA)

* Rename Columns
ren A year
ren B ALB
ren C AND
ren D AUT
ren F BEL
ren G BGR
ren H GRC_1
ren I CYP // Cyprus (Aegean Islands)
ren K DNK
ren L GRC_2
ren M EST
ren N FIN
ren O FRA
ren P DEU
ren Q GIB
ren R GRC_3
ren S HUN
ren T ISL
ren U GRC_4
ren V IRL
ren W ITA
ren X LVA
ren Y LTU
ren Z LUX
ren AA MLT
ren AB MCO
ren AC MNE
ren AD NLD
ren AE NOR
ren AG POL
ren AH PRT
ren AI ROU
ren AJ RUS
ren AL ESP
ren AM SWE
ren AN CHE
ren AO GBR

drop E J AF AK AP

drop in 1/2
drop in -2/L

* Destring
destring *, replace

* Aggregate countries to match their current borders
replace GRC_1 = 0 if GRC_1 == .
replace GRC_2 = 0 if GRC_2 == .
replace GRC_3 = 0 if GRC_3 == .
replace GRC_4 = 0 if GRC_4 == .
gen GRC = GRC_1 + GRC_2 + GRC_3 + GRC_4
replace GRC = . if GRC == 0
drop GRC_1 GRC_2 GRC_3 GRC_4

* Renaming the countries before reshaping into a long dataset
ds year, not
foreach var in `r(varlist)'{
	ren `var' Tena_pop`var'
}

* Reshape
greshape long Tena_pop, i(year) j(ISO3) string

* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid ISO3 year

* Save and merge
tempfile temp_europe_pop
save `temp_europe_pop', replace emptyok
append using `temp_master'
save `temp_master', replace

* ==============================================================================
*     IMPORTING DATA FOR OCEANIA
* ==============================================================================
* Open
import excel using "$input/oceania_1800-1938_FTWPHD_2023_v01", clear sheet(OCEANIA)

* Rename Columns
ren A year
ren B AUS
ren C Hawaii
ren D NZL
ren F FSM

drop H E G

drop in 1/2
drop in -2/L

* Destring
destring *, replace

* Renaming the countries before reshaping into a long dataset
ds year, not
foreach var in `r(varlist)'{
	ren `var' Tena_pop`var'
}

* Reshape
greshape long Tena_pop, i(year) j(ISO3) string

* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid ISO3 year

* Save and merge
tempfile temp_oceania_pop
save `temp_oceania_pop', replace emptyok
append using `temp_master'
save `temp_master', replace

* Add Hawaii to USA
replace ISO3 = "USA" if ISO3 == "Hawaii"

* Sum the populations for the USA, now including both the original USA and Hawaii entries
bysort ISO3 year: egen total_pop = total(Tena_pop)

* Replace the original Tena_pop with the new total_pop for USA
replace Tena_pop = total_pop if ISO3 == "USA"

* Drop total pop
drop total_pop

* Sort data by ISO3 and year
sort ISO3 year

* Drop duplicates for the USA after replacing populations
by ISO3 year, sort: gen count = _n
drop if ISO3 == "USA" & count > 1
drop count

* Covert unit to million
replace Tena_pop = Tena_pop / 1000

* Turn Saint Berthelemy (ISO3: BLM) population into missing when the value is 0
replace Tena_pop = . if Tena_pop == 0 & ISO3 == "BLM"

* ==============================================================================
* 	FINAL STEPS
* ==============================================================================
* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Output
save "$output", replace

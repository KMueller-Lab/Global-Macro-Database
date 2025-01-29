* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN MITCHELL INTERNATIONAL HISTORICAL STATISTICS DATA
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-08-27
*
* Description: 
* This Stata script opens and cleans data on government revenue from Mitchell IHS
* 
* Data Source:
* MITCHELL HISTORICAL STATISTICS
*
* ==============================================================================

* ==============================================================================
* Set up
* ==============================================================================

* Clear data 
clear

* Define globals 
global input "${data_raw}/aggregators/MITCHELL/Europe_govrev"
global output "${data_temp}/MITCHELL/Europe_govtax"

*===============================================================================
* 			govtax: Sheet2
*===============================================================================
clear
import_columns "${input}" "2"

* Keep
keep year C F G H

* Destring
qui drop if year == ""
destring_check


* Calculate total tax revenue
egen UnitedKingdomtax  = rowtotal(F G H)
ren C Austriatax
keep year *tax
ren *tax *

* Convert units
convert_units UnitedKingdom 1750 1799 "Th"

* Reshape and save
reshape_data govtax
tempfile temp_c
save `temp_c', emptyok replace


*===============================================================================
* 			govtax: Sheet3
*===============================================================================

import_columns_first "${input}" "3"

qui ds year, not
local varlist `r(varlist)'
forvalues i = 1/2 {
    local newname = ""
    foreach var in `varlist' {
        if strlen(`var'[`i']) != 0 {
            local newname = `var'[`i']
        }
        if strlen(`var'[`i']) == 0 & "`newname'" != "" {
            qui replace `var' = "`newname'" in `i'
        }
    }
}

* Keep only total revenue
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 2
	if `var'[2] != "total" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	local newname = `var'[1]
	cap ren `var' `newname'
}
ren S Russia

* Destring
qui drop if year == ""
destring_check


* Calculate total tax revenue
egen Austriatax = rowtotal(Austria D E F)
egen UnitedKingdomtax = rowtotal(UnitedKingdom X Y)
egen Belgiumtax = rowtotal(Belgium I J)
egen Francetax = rowtotal(France M)
egen Netherlandstax = rowtotal(Netherlands P Q)
egen Russiatax = rowtotal(Russia T U)
keep year *tax
ren *tax *

* Convert units
convert_units UnitedKingdom 1800 1809 "Th"

* Reshape and append
reshape_data govtax
replace govtax = . if govtax == 0
save_merge `temp_c'

*===============================================================================
* 			govtax: Sheet4
*===============================================================================

import_columns_first "${input}" "4"

qui ds year, not
local varlist `r(varlist)'
forvalues i = 1/2 {
    local newname = ""
    foreach var in `varlist' {
        if strlen(`var'[`i']) != 0 {
            local newname = `var'[`i']
        }
        if strlen(`var'[`i']) == 0 & "`newname'" != "" {
            qui replace `var' = "`newname'" in `i'
        }
    }
}

* Keep only total revenue
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 2
	if `var'[2] != "total" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	local newname = `var'[1]
	cap ren `var' `newname'
}
ren BC Russia

* Destring
qui drop if year == ""
destring_check


* Calculate total tax revenue
egen Austriatax = rowtotal(Austria D E F)
egen Belgiumtax = rowtotal(Belgium I J)
egen Bulgariatax = rowtotal(Bulgaria M N)
egen Denmarktax = rowtotal(Denmark Q R)
egen Finlandtax = rowtotal(Finland U)
egen Francetax = rowtotal(France X Y Z)
egen Germanytax = rowtotal(Germany AC)
egen Greecetax = rowtotal(Greece AF AG)
egen Hungarytax = rowtotal(Hungary AJ)
egen Italytax = rowtotal(Italy AM AN)
egen Netherlandstax = rowtotal(Netherlands AQ AR)
egen Norwaytax = rowtotal(Norway AU AV)
egen Portugaltax = rowtotal(Portugal AY AZ)
egen Serbiatax = rowtotal(Serbia BJ BK)
egen Spaintax = rowtotal(Spain BN BO BP)
egen Swedentax = rowtotal(Sweden BS BT)
egen Russiatax = rowtotal(Russia BE BF)
egen UnitedKingdomtax = rowtotal(UnitedKingdom X Y)
ren Romania Romaniatax
ren Switzerland Switzerlandtax
keep year *tax
ren *tax *

* Reshape and append
reshape_data govtax
replace govtax = . if govtax == 0
save_merge `temp_c'


*===============================================================================
* 			govtax: Sheet5
*===============================================================================
import_columns_first "${input}" "5"

qui ds year, not
local varlist `r(varlist)'
forvalues i = 1/2 {
    local newname = ""
    foreach var in `varlist' {
        if strlen(`var'[`i']) != 0 {
            local newname = `var'[`i']
        }
        if strlen(`var'[`i']) == 0 & "`newname'" != "" {
            qui replace `var' = "`newname'" in `i'
        }
    }
}

* Keep only total revenue
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 2
	if `var'[2] != "total" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	local newname = `var'[1]
	cap ren `var' `newname'
}
ren CA Russia
ren CX Serbia

* Destring
qui drop if year == ""
destring_check


* Calculate total tax revenue
egen Austriatax = rowtotal(Austria D E F)
egen Belgiumtax = rowtotal(Belgium I J)
egen Bulgariatax = rowtotal(Bulgaria M N)
egen Czechoslovakiatax = rowtotal(Czechoslovakia Q R S)
egen Denmarktax = rowtotal(Denmark V W)
egen Finlandtax = rowtotal(Finland Z AA AB)
egen Francetax = rowtotal(France AE AF AG AH)
egen Germanytax = rowtotal(Germany AK AL AM)
egen Greecetax = rowtotal(Greece AP AQ)
egen Hungarytax = rowtotal(Hungary AT AU AV)
egen Irelandtax = rowtotal(Ireland AY AZ)
egen Italytax = rowtotal(Italy BC BD BE)
egen Netherlandstax = rowtotal(Netherlands BH BI BJ)
egen Norwaytax = rowtotal(Norway BM BN)
egen Polandtax = rowtotal(Poland BQ BR)
egen Portugaltax = rowtotal(Portugal BU BV)
egen Romaniatax = rowtotal(Romania BY)
egen Spaintax = rowtotal(Spain CG CH CI)
egen Swedentax = rowtotal(Sweden CL CM CN)
egen Russiatax = rowtotal(Russia CB CC CD)
egen Switzerlandtax = rowtotal(Switzerland CQ CR)
egen UnitedKingdomtax = rowtotal(UnitedKingdom CU CV)
egen Serbiatax = rowtotal(Serbia CY CZ)
keep year *tax
ren *tax *


* Convert units
convert_units Serbia 1942 1949 "B"
convert_units France 1945 1949 "B"
convert_units Italy  1946 1949 "B"

* Reshape and append
reshape_data govtax
save_merge `temp_c'

*===============================================================================
* 			govtax: Sheet6
*===============================================================================
import_columns_first "${input}" "6"

qui ds year, not
local varlist `r(varlist)'
forvalues i = 1/2 {
    local newname = ""
    foreach var in `varlist' {
        if strlen(`var'[`i']) != 0 {
            local newname = `var'[`i']
        }
        if strlen(`var'[`i']) == 0 & "`newname'" != "" {
            qui replace `var' = "`newname'" in `i'
        }
    }
}

* Keep only total revenue
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 2
	if `var'[2] != "total" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	local newname = `var'[1]
	cap ren `var' `newname'
}
ren BN Russia
ren WestGermany Germany

* Destring
qui drop if year == ""
destring_check


* Calculate total tax revenue
egen Austriatax = rowtotal(Austria D E F)
egen Belgiumtax = rowtotal(Belgium I J)
egen Denmarktax = rowtotal(Denmark M N O)
egen Finlandtax = rowtotal(Finland R S T)
egen Francetax = rowtotal(France W X Y Z)
egen Germanytax = rowtotal(Germany AC AD AE)
egen Greecetax = rowtotal(Greece AH AI AJ)
egen Irelandtax = rowtotal(Ireland AM AN AO)
egen Italytax = rowtotal(Italy AR AS AT AU AV)
egen Netherlandstax = rowtotal(Netherlands AY AZ BA)
egen Norwaytax = rowtotal(Norway BD BE)
egen Portugaltax = rowtotal(Portugal BH BI BJ)
egen Spaintax = rowtotal(Spain BS BT BU)
egen Swedentax = rowtotal(Sweden BX BY BZ)
egen Russiatax = rowtotal(Russia BO BP)
egen Switzerlandtax = rowtotal(Switzerland CC CD)
egen UnitedKingdomtax = rowtotal(UnitedKingdom CG CH CI)
ren Romania Romaniatax
keep year *tax
ren *tax *


* Convert units
local countries Austria Belgium Finland France Germany Italy Romania Spain
foreach country of local countries {
	convert_units `country' 1950 2010 "B"
}

* Convert units
local countries Denmark Greece
foreach country of local countries {
	convert_units `country' 1970 2010 "B"
}

* Convert units
local countries Sweden Portugal Norway Netherlands Italy
foreach country of local countries {
	convert_units `country' 1975 2010 "B"
}
convert_units UnitedKingdom 1980 2010 "B"
 
* Reshape and append
reshape_data govtax
replace govtax = . if govtax == 0
save_merge `temp_c'

*===============================================================================
* 			Convert units
*===============================================================================
qui greshape wide govtax, i(year) j(countryname) 
ren govtax* *
convert_currency Austria 1892 2
convert_currency Hungary 1892 2
convert_currency Russia 1839 1/4
convert_currency Austria 1923 1/10000
convert_currency Hungary 1924 1/12500
convert_currency Russia  1939 1/10000
convert_currency France  1959 1/100
convert_units Italy 1999 "B"
convert_currency Bulgaria  1959 1/1000000

* Reshape
reshape_data govtax

* Fix units
replace govtax = govtax / 100 if year <= 1962 & countryname == "Finland"
replace govtax = govtax * (10^-6) / 5 if countryname == "Greece" & year <= 1940
replace govtax = govtax / 10000 if countryname == "Romania"
replace govtax = govtax / 10000 if countryname == "Romania" & year <= 1943
replace govtax = govtax / 1000 if countryname == "Italy" & year >= 1999
replace govtax = govtax / (10^12)   if countryname == "Germany" & year <= 1923
replace govtax = govtax * 1000 if countryname == "Russia"



* Drop Portugal after 1999 because we have only customs
replace govtax = . if countryname == "Portugal" & year >= 1999

* Remove zeros
replace govtax =  . if govtax == 0
*===============================================================================
* 			Final set up
*===============================================================================
* Sort
sort countryname year

* Order
order countryname year

* Check for duplicates
isid countryname year

* Save
save "${output}", replace


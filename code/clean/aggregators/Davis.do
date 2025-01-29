* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Description: 
* This Stata script opens and cleans nominal GDP data from the UC Davis GPIH.
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2022-06-01
* ==============================================================================


* ==============================================================================
* SET UP 
* ==============================================================================
* Clear data 
clear

* Define input and output files
global input1 "${data_raw}/aggregators/Davis/Nominal_GDP_Africa.xlsx"
global input2 "${data_raw}/aggregators/Davis/Nominal_GDP_West_Europe.xlsx"
global input3 "${data_raw}/aggregators/Davis/Nominal_GDP_East_Europe.xlsx"
global input4 "${data_raw}/aggregators/Davis/Nominal_GDP_MidEast_SAsia.xlsx"
global input5 "${data_raw}/aggregators/Davis/Nominal_GDP_East_Asia_Oceania.xlsx"
global input6 "${data_raw}/aggregators/Davis/Nominal_GDP_Americas.xlsx"
global output "${data_clean}/aggregators/Davis/Davis.dta"

* Create temporary file to store data before merging
tempfile temp_master
save `temp_master', replace emptyok

* ==============================================================================
* 	CLEAN DATA FOR AFRICA
* ==============================================================================
* Open
import excel using "${input1}", clear sheet(nominal GDP) 

drop in 1/3

ds
foreach var in `r(varlist)' {
    if `"`= `var'[2]'"' == "World Bank" {
        drop `var'
    }
}

******** Dropping the following columns
* Egypt, Nigeria, and Madagascar because only historical data is needed
drop V AT BL

* Zaire because the historical data is contained in RDC's column. 
drop CG CH

* Zimbabwe because we need only GDP
drop CL CN

* Drop empty rows
drop in 1/3

* Renaming countries
ds
foreach var in `r(varlist)' {
    qui replace `var' = subinstr(`var', "Algeria", "DZA", .)
    qui replace `var' = subinstr(`var', "Benin", "BEN", .)
    qui replace `var' = subinstr(`var', "Burkina Faso", "BFA", .)
    qui replace `var' = subinstr(`var', "Burundi", "BDI", .)
    qui replace `var' = subinstr(`var', "Cameroon", "CMR", .)
    qui replace `var' = subinstr(`var', "Central African Rep.", "CAF", .)
    qui replace `var' = subinstr(`var', "Chad", "TCD", .)
    qui replace `var' = subinstr(`var', "Congo, Dem. Rep.", "COD", .)
    qui replace `var' = subinstr(`var', "Egypt", "EGY", .)
    qui replace `var' = subinstr(`var', "Ethiopia", "ETH", .)
    qui replace `var' = subinstr(`var', "Gabon", "GAB", .)
    qui replace `var' = subinstr(`var', "Ghana", "GHA", .)
    qui replace `var' = subinstr(`var', "Ivory Coast", "CIV", .)
    qui replace `var' = subinstr(`var', "Kenya", "KEN", .)
    qui replace `var' = subinstr(`var', "Lesotho", "LSO", .)
    qui replace `var' = subinstr(`var', "Liberia", "LBR", .)
    qui replace `var' = subinstr(`var', "Libya", "LBY", .)
    qui replace `var' = subinstr(`var', "Madagascar", "MDG", .)
    qui replace `var' = subinstr(`var', "Malawi", "MWI", .)
    qui replace `var' = subinstr(`var', "Mali", "MLI", .)
    qui replace `var' = subinstr(`var', "Mauritania", "MRT", .)
    qui replace `var' = subinstr(`var', "Mauritius", "MUS", .)
    qui replace `var' = subinstr(`var', "Morocco", "MAR", .)
    qui replace `var' = subinstr(`var', "Mozambique", "MOZ", .)
	qui replace `var' = subinstr(`var', "Nigeria", "NGA", .)
    qui replace `var' = subinstr(`var', "Niger", "NER", .)
    qui replace `var' = subinstr(`var', "Rwanda", "RWA", .)
    qui replace `var' = subinstr(`var', "Senegal", "SEN", .)
    qui replace `var' = subinstr(`var', "Sierra Leone", "SLE", .)
    qui replace `var' = subinstr(`var', "South Africa", "ZAF", .)
    qui replace `var' = subinstr(`var', "Sudan", "SDN", .)
    qui replace `var' = subinstr(`var', "Tanzania", "TZA", .)
    qui replace `var' = subinstr(`var', "Togo", "TGO", .)
    qui replace `var' = subinstr(`var', "Tunisia", "TUN", .)
    qui replace `var' = subinstr(`var', "Uganda", "UGA", .)
    qui replace `var' = subinstr(`var', "Zambia", "ZMB", .)
    qui replace `var' = subinstr(`var', "Zimbabwe", "ZWE", .)
}


* Rename the columns with the first row content
qui ds
foreach var in `r(varlist)' {
    local newname = `var'[1]
    capture ren `var' Davis_nGDP`newname'
}

* Rename the variables with the first row content. 
ren Davis_nGDPYear year
drop in 1

* Reshape the data into long
greshape long Davis_nGDP, i(year) j(ISO3) string

* Destring
destring year Davis_nGDP, replace

* Convert the units
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "DZA"
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "BEN"
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "BFA"
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "BDI"
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "CAF"
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "CMR"
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "CIV"
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "COD"
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "GAB"
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "KEN"
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "MDG"
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "MLI"
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "MRT"
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "MAR"
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "NGA"
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "NER"
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "RWA"
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "SEN"
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "TZA"
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "TCD"
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "TGO"
replace Davis_nGDP = Davis_nGDP / 1000 if ISO3 == "MWI"
replace Davis_nGDP = Davis_nGDP / 1000 if ISO3 == "GHA"

* Sort
sort ISO3 year

* Order 
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save
tempfile temp_nGDP_Africa
save `temp_nGDP_Africa', replace emptyok
append using `temp_master'
save `temp_master', replace


* ==============================================================================
* 	CLEAN DATA FOR WESTERN EUROPE
* ==============================================================================
* Open
import excel using "${input2}", clear  sheet(nominal GDP)

* Keeping historical data that has not yet been added.
keep A B D G P

* Drop rows that are not needed
drop in 1/7

* Rename countries to ISO3
ren A year
ren B AUT
ren D BEL
ren G DNK
ren P DEU

* Rename columns before reshaping
ds year, not
foreach var in `r(varlist)'{
	ren `var' Davis_nGDP`var'
}
drop in 1/2

* Reshape
greshape long Davis_nGDP, i(year) j(ISO3) string

* Destring
destring year Davis_nGDP, replace

* Convert currencies
merge m:1 ISO3 using "$eur_fx", keep(1 3) nogen 
ds ISO3 year EUR_irrevocable_FX, not
foreach var in `r(varlist)'{
	replace `var' = `var' / EUR_irrevocable_FX if EUR_irrevocable_FX  != .
}
drop EUR_irrevocable_FX

* Sort
sort ISO3 year

* Order 
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save temporarily before merging with the other dataset
tempfile temp_nGDP_West_Europe
save `temp_nGDP_West_Europe', replace emptyok
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 	CLEAN DATA FOR EASTERN EUROPE
* ==============================================================================
* Open
import excel using "${input3}", clear  sheet(nominal GDP)

* Keeping historical data that has not yet been added.
keep A E N R Z

* Drop rows that are not needed
drop in 1/7

* Rename countries to ISO3
ren A year
ren E BGR
ren N GRC
ren R HUN
ren Z POL

* Rename columns before reshaping
ds year, not
foreach var in `r(varlist)'{
	ren `var' Davis_nGDP`var'
}

* Drop rows not needed or empty
drop in 1/2
missings dropobs, force

* Reshape
greshape long Davis_nGDP, i(year) j(ISO3) string

* Destring
destring year Davis_nGDP, replace

* Convert units
replace Davis_nGDP = Davis_nGDP * 1000 if ISO3 == "POL"

* Convert currencies (only Greece)
merge m:1 ISO3 using "$eur_fx", keep(1 3) nogen 
ds ISO3 year EUR_irrevocable_FX, not
foreach var in `r(varlist)'{
	replace `var' = `var' / EUR_irrevocable_FX if EUR_irrevocable_FX  != .
}
drop EUR_irrevocable_FX

* Sort
sort ISO3 year

* Order 
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save temporarily before merging with the other dataset
tempfile temp_nGDP_East_Europe
save `temp_nGDP_East_Europe', replace emptyok
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 	CLEAN DATA FOR INDIA
* ==============================================================================
* Open
import excel using "${input4}", clear  sheet(nominal GDP)

* Drop rows not needed or empty
drop in 1/57

* Keep only India because Dincecco Prado provides only India and we have processed other countries
keep A L

* Rename
ren A year
ren L Davis_nGDP

* Destring
destring *, replace

* Create ISO3 column
gen ISO3 = "IND"

* Sort
sort ISO3 year

* Order 
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save temporarily before merging with the other dataset
tempfile temp_nGDP_India
save `temp_nGDP_India', replace emptyok
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 	CLEAN DATA FOR ASIA PACIFIC (Only China and New Zealand)
* ==============================================================================
* Open
import excel using "${input5}", clear  sheet(nominal GDP)

* Keep only China 1932 and New Zealand 1870
keep A I AK
drop in 1/8

* Rename columns
ren A year
ren I Davis_nGDPCHN
ren AK Davis_nGDPNZL

* Destring
destring *, replace

* Reshape
reshape long Davis_nGDP, i(year) j(ISO3) string

* Sort
sort ISO3 year

* Order 
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save temporarily before merging with the other dataset
tempfile temp_nGDP_Asia
save `temp_nGDP_Asia', replace emptyok
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 	CLEAN DATA FOR THE AMERICAS
* ==============================================================================
* Open
import excel using "${input6}", clear  sheet(nominal GDP)

* Keeping only sources we do not yet have
keep A B K R S W AD BH BW CQ	

* Rename the columns
ren A year
ren B ARG
ren K BRA
ren R CAN
ren S CHL
ren W COL
ren AD CRI
ren BH MEX
ren BW PER
ren CQ URY
drop in 1

* Rename columns before reshaping
ds year, not
foreach var in `r(varlist)'{
	ren `var' Davis_nGDP`var'
}

* Drop rows not needed or empty
missings dropobs Davis_nGDP*, force
drop in 1/4

* Destring
destring *, force replace

* Reshape
reshape long Davis_nGDP, i(year) j(ISO3) string

* Save temporarily before merging with the other dataset
tempfile temp_nGDP_Americas
save `temp_nGDP_Americas', replace emptyok
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 	Convert units in case of undocumented inconsistencies in reporting units
* ==============================================================================

gmdfixunits Davis_nGDP if ISO3 == "MWI", multiply(1000)
gmdfixunits Davis_nGDP if ISO3 == "ZMB", divide(1000)
gmdfixunits Davis_nGDP if ISO3 == "GHA", divide(10)
gmdfixunits Davis_nGDP if ISO3 == "CRI", divide(1000)
gmdfixunits Davis_nGDP if ISO3 == "SDN", divide(1000)
gmdfixunits Davis_nGDP if ISO3 == "DEU" & year <= 1923, divide(10^12)
gmdfixunits Davis_nGDP if ISO3 == "POL", divide(10^4)
gmdfixunits Davis_nGDP if ISO3 == "COD", missing



* ==============================================================================
* 	OUTPUT
* ==============================================================================

* Sort
sort ISO3 year

* Order 
order ISO3 year

* Check for duplicates
isid ISO3 year

* Output
save "${output}", replace

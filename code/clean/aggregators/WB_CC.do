* ==============================================================================
* Global Macro DATABASE
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
* CLEAN DATA FROM THE WORLD DEVELOPMENT INDICATORS
* 
* Description: 
* This Stata script reads in and cleans data on Inflation from the World Bank's World 
* Development Indicators.
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-09-05
*
* URL: https://thedocs.worldbank.org/en/doc/1ad246272dbbc437c74323719506aa0c-0350012021/a-cross-country-database-of-inflation
* ==============================================================================
* SET UP 
* ==============================================================================
* Define input and output files 
clear
global input "${data_raw}/aggregators/WB/WB_inflation.xlsx"
global output "${data_clean}/aggregators/WB/WB_CC.dta"

* ==============================================================================
* 	Clean data for yearly headline inflation 
* ==============================================================================
* Open 
import excel using "$input", sheet(hcpi_a) clear

* Drop empty columns
missings dropvars, force


* Drop notes columns and rows
drop B C D E BH
drop in 205/l
recast str3 A, force

* Rename columns
ren A ISO3 
qui ds ISO3, not
foreach var in `r(varlist)'{
	local newname = `var'[1]
	ren `var' infl`newname'
}
drop in 1

* Reshape
qui greshape long infl, i(ISO3) j(year)

* Rename
ren infl WB_CC_infl

* Save 
tempfile temp_master
save `temp_master', replace

* ==============================================================================
* 	Clean data for annual gdp deflator  
* ==============================================================================
* Open 
import excel using "$input", sheet(def_a) clear

* Drop empty columns
missings dropvars, force


* Drop notes columns and rows
drop B C D E
drop in 198/l
recast str3 A, force

* Rename columns
ren A ISO3 
qui ds ISO3, not 
foreach var in `r(varlist)'{
	local newname = `var'[1]
	ren `var' deflator`newname'
}
drop in 1

* Reshape
qui greshape long deflator, i(ISO3) j(year)

* Rename
ren deflator WB_CC_deflator

*  Merge
merge 1:1 ISO3 year using `temp_master', nogen

* ==============================================================================
* 	Output
* ==============================================================================
* Drop regional aggregates 
drop if ISO3 == "XXK"

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year 

* Save 
save "${output}" , replace 

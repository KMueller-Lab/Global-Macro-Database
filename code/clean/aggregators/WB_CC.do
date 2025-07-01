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

* Derive CPI 
sort ISO3 year
encode ISO3, gen(id)
xtset id year

* Identify gaps and drop countries with gaps in their Data
sort id year
bys ISO3: egen min_year = min(year)  if infl != .
bys ISO3: egen min_year_f = min(min_year)
bys ISO3: egen max_year = max(year)  if infl != .
bys ISO3: egen max_year_f = min(max_year)
bys ISO3: gen  count_year = max_year - min_year + 1
bys ISO3: egen has_gap = count(infl) if infl != .
drop if has_gap != count_year

* Drop nations with only one count of inflation 
bys ISO3: egen total_count = count(infl) if infl != .
bys ISO3: egen total_count_f = max(total_count)
drop if total_count_f == 1

bys ISO3: gen to_drop = 1 if year < min_year_f - 1 | year > max_year_f
drop if to_drop == 1

sort id year
by id: gen CPI_recon = .  // Create a new variable for reconstructed CPI

* Set the base year CPI (replace 100 with your actual base year CPI if known)
by id: replace CPI_recon = 100 if _n == 1

* Reconstruct CPI for subsequent years
by id: replace CPI_recon = CPI_recon[_n-1] * (1 + infl[_n]/100) if _n > 1

* Rename
keep ISO3 year CPI infl
ren infl WB_CC_infl
ren CPI_recon WB_CC_CPI

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
* Adjust Kosovo ISO3
drop if ISO3 == "XXK"

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year 

* Save 
save "${output}" , replace 

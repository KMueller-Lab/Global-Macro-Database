* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script opens and cleans the dataset on Historical National Accounts
* from the Groningen Growth and Development Centre. Note that the raw data are 
* reported in a set of files that have a slightly different format. 
*
* Author:
* Karsten Müller
* National University of Singapore
* 
* Created: 2024-09-25
*
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================

* Define input and output files
clear 
global input1 "${data_raw}/aggregators/Groningen/western_europe/"
global input2 "${data_raw}/aggregators/Groningen/latin_america/hna_latam_10.xls"
global inputs: dir `"$input1"'  files "*.xls"
global output "${data_clean}/aggregators/Groningen/GNA"

* ==============================================================================
* 	WESTERN EUROPE
* ==============================================================================

* Make placeholder files 
tempfile nGDP
tempfile rGDP 
save `nGDP', replace emptyok
save `rGDP', replace emptyok


* Loop over input files 
foreach file of glo inputs {
	
	* ==========================================================================
	* Import nominal GDP 
	* ==========================================================================	
	
	* Check if Germany or Italy (no nominal GDP data)
	if "`file'" != "hna_ger_09.xls" &  "`file'" != "hna_ita_09.xls" {
		
		* Open 
		qui import excel using "${input1}/`file'", clear sheet("VA")
		
		* Get first year 
		loc year = D[4] 
		
		* Only keep GDP numbers 
		keep if B == "GDP"
			
		* Drop unneeded columns 
		drop A B C
		
		* Rename years 
		qui ds 
		foreach var in `r(varlist)' {
			loc newname = "GNA_nGDP_LCU"+"`year'"
			ren `var' `newname'
			loc year = `year' + 1
		}
		
		* Make country name 
		loc name = upper(substr("`file'",5,3))
		gen ISO3 = "`name'"
		
		* Drop duplicates 
		keep in 1
		
		* Reshape 
		qui greshape long GNA_nGDP_LCU, i(ISO3) j(year)
		qui destring *, replace 
		
		* Append to empty file 
		qui append using `nGDP'
		qui save `nGDP', replace 
	}
	
	* ==========================================================================	
	* Import real GDP 
	* ==========================================================================
	
	* Set parameters 
	loc sheet "VA-K"
	loc varname "GNA_rGDP_LCU"
	
	* If France, adjust parameters because only index available 
	if "`file'" == "hna_fra_09.xls" {
		loc sheet "VA-Ki"
		loc varname "GNA_rGDP_LCU_index"
	}
	
	* Open 
	qui import excel using "${input1}/`file'", clear sheet("`sheet'")
	
	* Get first year 
	loc year = D[4] 
	
	* Only keep GDP numbers 
	keep if B == "GDP"
		
	* Drop unneeded columns 
	drop A B C
	
	* Rename years 
	qui ds 
	foreach var in `r(varlist)' {
		loc newname = "`varname'"+"`year'"
		ren `var' `newname'
		loc year = `year' + 1
	}
	
	* Make country name 
	loc name = upper(substr("`file'",5,3))
	gen ISO3 = "`name'"
	
	* Drop duplicates 
	keep in 1
	
	* Reshape 
	qui greshape long `varname', i(ISO3) j(year)
	qui destring *, replace 
	
	* Append to empty file 
	qui append using `rGDP'
	qui save `rGDP', replace 
}

* Merge nominal and real GDP; real GDP is main frame at this point 
merge 1:1 ISO3 year using `nGDP', nogen

* Fix wrong country code for Germany
replace ISO3 = "DEU" if ISO3 == "GER"

* Delete rows with all missing data 
missings dropobs GNA*, force

* Convert French data from Frank to New Frank
replace GNA_nGDP_LCU = GNA_nGDP_LCU / 100 if ISO3 == "FRA"
replace GNA_rGDP_LCU = GNA_rGDP_LCU / 100 if ISO3 == "FRA"

* Convert Finland to millions
replace GNA_nGDP_LCU = GNA_nGDP_LCU / 1000 if ISO3 == "FIN"
replace GNA_rGDP_LCU = GNA_rGDP_LCU / 1000 if ISO3 == "FIN"

* Converting the currency
merge m:1 ISO3 using $eur_fx, keep(1 3)
replace GNA_nGDP_LCU = GNA_nGDP_LCU/EUR_irrevocable_FX if _merge == 3
replace GNA_rGDP_LCU = GNA_rGDP_LCU/EUR_irrevocable_FX if _merge == 3
drop EUR_irrevocable_FX _merge

* Save
tempfile temp_master
save `temp_master', replace emptyok


* ===============================================================================
*	LATIN AMERICA
* ===============================================================================

* Open
clear
tempfile temp_latin_america
save `temp_latin_america', replace emptyok

local countries Argentina Bolivia Brasil Chile Colombia "Costa Rica" Mexico Peru Venezuela
foreach country of local countries {
	
	* Open
	qui import excel using "${input2}", clear sheet(`country') allstring
	
	* Drop unnecessary rows and columns
	drop in 1/3
	missings dropvars, force
	missings dropobs, force
	
	* Rename the columns
	qui ds A, not
	foreach var in `r(varlist)'{
		loc newname = `var'[1]
		ren `var' GNA_rGDP_LCU`newname'
	}
	
	* Keep only GDP row
	keep if strpos(A, "GDP") > 0
	
	* Reshape
	qui greshape long GNA_rGDP_LCU, i(A) j(year) string
	
	* Drop
	drop A
	
	* Destring
	destring *, replace
	
	* Add country name
	gen countryname = "`country'"
	
	* Order
	order countryname year
	
	* Save and append
	qui tempfile temp_c
	qui save `temp_c', replace emptyok
	qui append using `temp_latin_america'
	qui save `temp_latin_america', replace
		
}

* Merge with country list to get the ISO3 code
replace countryname = "Brazil" if countryname == "Brasil"
merge m:1 countryname using $isomapping, keep(3) nogen

* Keep relevant columns
keep ISO3 year GNA*

* Merge with temp_master
merge 1:1 ISO3 year using `temp_master', nogen

* Remove _LCU
ren *_LCU *
ren GNA_rGDP_LCU_index GNA_rGDP_index
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
save "${output}" , replace 

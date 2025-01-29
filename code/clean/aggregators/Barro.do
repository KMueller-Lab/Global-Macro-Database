* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN BARRO-URSÚA (2010) DATA
* 
* Author:
* Karsten Müller
* National University of Singapore
* 
* Created: 2024-04-05
*
* Description: 
* This Stata script opens and cleans the Barro-Ursúa (2010) data.
*
* URL: https://scholar.harvard.edu/barro/data_sets (Archived: 2024-09-25) 
*
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================

* Clear 
clear

* First run WDI because we will use later 
do "$code_clean/aggregators/WDI.do"
clear

* Define globals 
global input "${data_raw}/aggregators/BARRO/GDP_Barro-Ursua.xls"
global output "${data_clean}/aggregators/BARRO/BARRO.dta"


* ==============================================================================
* 	REAL GDP PER CAPITA INDEX
* ==============================================================================

* Open 
import excel using "${input}", sheet(GDP) first clear

* Prepare for reshaping
drop in 1 
qui destring *, replace
ren (*) (c*)
ren cGDPpc year

* Reshape 
greshape long c, i(year) j(countryname) string
ren c BARRO_rGDP_pc_index

* Fix country names
replace countryname = "South Korea" if countryname == "Korea"
replace countryname = "New Zealand" if countryname == "NewZealand"
replace countryname = "Russian Federation" if countryname == "Russia"
replace countryname = "South Africa" if countryname == "SAfrica"
replace countryname = "Sri Lanka" if countryname == "SriLanka"
replace countryname = "United Kingdom" if countryname == "UnitedKingdom"
replace countryname = "United States" if countryname == "UnitedStates"

* Get ISO3 codes
merge m:1 countryname using $isomapping, keep(3) keepus(ISO3) nogen

* Drop
drop countryname

* Save in a temporary file
tempfile temp_master
save `temp_master', replace emptyok
 
* ==============================================================================
*	REAL CONSUMPTION PER CAPITA INDEX
* ==============================================================================

* Open 
import excel using "${input}", sheet(C) first clear

* Prepare for reshaping
drop in 1 
qui destring *, replace
ren (*) (c*)
ren cCpc year

* Reshape 
greshape long c, i(year) j(countryname) string
ren c BARRO_rcons_pc_index

* Fix country names
replace countryname = "South Korea" if countryname == "Korea"
replace countryname = "New Zealand" if countryname == "NewZealand"
replace countryname = "Russian Federation" if countryname == "Russia"
replace countryname = "South Africa" if countryname == "SAfrica"
replace countryname = "Sri Lanka" if countryname == "SriLanka"
replace countryname = "United Kingdom" if countryname == "UnitedKingdom"
replace countryname = "United States" if countryname == "UnitedStates"

* Get ISO3 codes
merge m:1 countryname using $isomapping, keep(3) keepus(ISO3) nogen

* Drop
drop countryname

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 ISO3 year using `temp_master', keep(1 3) nogen


* ==============================================================================
* 	SPLICE BARRO REAL GDP PER CAPITA USING REAL GDP PER CAPITA FROM WDI
* ==============================================================================
* Merge in the dataset from WDI but ensure WDI has been processed
merge 1:1 ISO3 year using "${data_clean}/aggregators/WB/WDI", nogen keep(1 3) keepus(WDI_rGDP_pc)

* Rename Barro 
ren BARRO_rGDP_pc_index BARRO_rGDP_pc

* Splice
splice, priority(WDI BARRO) generate(rGDP_pc) varname(rGDP_pc) method("chainlink") base_year(2006) save("NO") 

* Rename 
drop BARRO_rGDP_pc
ren rGDP_pc BARRO_rGDP_pc

* Keep relevant variables 
keep ISO3 year BARRO_rcons_pc_index BARRO_rGDP_pc

* ==============================================================================
* 	SPLICE WDI REAL CONSUMPTION USING BARRO CONSUMPTION PER CAPITA INDEX
* ==============================================================================
* Merge in the dataset from WDI but ensure WDI has been processed
merge 1:1 ISO3 year using "${data_clean}/aggregators/WB/WDI", nogen keep(1 3) keepus(WDI_rcons)

* Rename Barro 
ren BARRO_rcons_pc_index BARRO_rcons

* Splice
splice, priority(WDI BARRO) generate(rcons) varname(rcons) method("chainlink") base_year(2006) save("NO") 

* Rename 
drop BARRO_rcons
ren rcons BARRO_rcons

* Keep relevant variables 
keep ISO3 year BARRO_rcons BARRO_rGDP_pc


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

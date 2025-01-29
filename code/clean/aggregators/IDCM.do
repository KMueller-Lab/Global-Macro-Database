* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CLEAN IDCM DATASET FROM ECB
* 
* Description: 
* This Stata script reads in and cleans data from ECB 
*
* Author:
* Mohamed lehbib
* National University of Singapore
*
* ==============================================================================
* SET UP 
* ==============================================================================
* Define input and output files 
clear
global input "${data_raw}/aggregators/IDCM/IDCM.dta"
global output "${data_clean}/aggregators/IDCM/IDCM.dta"

* ==============================================================================
* Clean the data
* ==============================================================================
* Open 
use "$input", clear

* Drop non-country rows
drop if regexm(ref_area, "[0-9]")

* Convert ISO2 to ISO3 
ren ref_area ISO2
merge m:1 ISO2 using ${isomapping}, nogen assert(2 3) keep(3) keepusing(ISO3)
drop ISO2
ren period year

* Create a new variable for type based on series_name
gen type = ""
replace type = "IDCM_nGDP_LCU" 	if strpos(series_code, "W2.S1.S1.B.B1GQ._Z._Z._Z.XDC.V.N")
replace type = "IDCM_rGDP_LCU" 	if strpos(series_code, "W2.S1.S1.B.B1GQ._Z._Z._Z.XDC.Q.N")
replace type = "IDCM_CA" 		if strpos(series_code, "W0.S1.S1.B.B9._Z._Z._Z.XDC.V.N")
replace type = "IDCM_cons" 		if strpos(series_code, "W0.S1.S1.D.P3._Z._Z._T.XDC.V.N")
replace type = "IDCM_inv" 		if strpos(series_code, "W0.S1.S1.D.P5.N1G._T._Z.XDC.V.N")
replace type = "IDCM_finv" 		if strpos(series_code, "W0.S1.S1.D.P51G.N11G._T._Z.XDC.V.N")
replace type = "IDCM_exports" 	if strpos(series_code, "W1.S1.S1.D.P6._Z._Z._Z.XDC.V.N")
replace type = "IDCM_imports" 	if strpos(series_code, "W1.S1.S1.C.P7._Z._Z._Z.XDC.V.N")
replace type = "IDCM_savings_1" if strpos(series_code, "W0.S1.S1.B.B8N._Z._Z._Z.XDC.V.N")
replace type = "IDCM_savings_2" if strpos(series_code, "W2.S1.S1.D.P51C.N1G._T._Z.XDC.V.N")
replace type = "IDCM_emp"		if strpos(series_code, "W2.S1.S1._Z.EMP._Z._T._Z.PS._Z.N")
drop if type == ""

* Keep relevant columns 
keep ISO3 year type value

* Reshape
greshape wide value, i(ISO3 year) j(type)

* Rename
ren value* *

* Calculate gross savings
gen IDCM_sav = IDCM_savings_1 + IDCM_savings_2

* Drop savings' components
drop IDCM_savings*

* Turn zero values to missing
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	
	replace `var' = . if `var' == 0
	
}

* Remove _LCU
ren *_LCU *

* ==============================================================================
* Output
* ==============================================================================

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates 
isid  ISO3 year

* Save
save "${output}", replace 

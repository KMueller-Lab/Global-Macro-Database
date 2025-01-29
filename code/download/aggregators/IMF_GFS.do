* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, and Ziliang Chen
* ==============================================================================
* Download Government Finance Statistics (GFS) data from IMF 
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-12
*
* Description: 
* This Stata script downloads Government Finance Statistics from the IMF
*
* Data source:
* DBnomics API
* 
* ==============================================================================

* Define output file name
global output "${data_raw}\aggregators\IMF\IMF_GFS"

* Make empty file 
clear 
tempfile temp_master
qui save `temp_master', replace emptyok

* Budgetary central government Net lending (+) / Net borrowing (-)
cap dbnomics import, pr(IMF) dataset(GFSMAB) CLASSIFICATION(GNLB__Z) REF_SECTOR(S1311B) UNIT_MEASURE(XDC_R_B1GQ) clear	
qui ds, has(type string)
foreach var in `r(varlist)' {
		qui replace `var' = strtrim(`var')
		qui gen length = strlen(`var')
		qui su length
		qui recast str`r(max)' `var', force
		qui drop length
}
qui append using `temp_master'
save `temp_master', replace

* Budgetary Central government Tax revenue
cap dbnomics import, pr(IMF) dataset(GFSMAB) CLASSIFICATION(G11__Z) REF_SECTOR(S1311B) UNIT_MEASURE(XDC) clear
qui ds, has(type string)
foreach var in `r(varlist)' {
		qui replace `var' = strtrim(`var')
		qui gen length = strlen(`var')
		qui su length
		qui recast str`r(max)' `var', force
		qui drop length
}
qui append using `temp_master'
save `temp_master', replace

* Budgetary Central government Expenditure
cap dbnomics import, pr(IMF) dataset(GFSMAB) CLASSIFICATION(G2M__Z) REF_SECTOR(S1311B) UNIT_MEASURE(XDC) clear
qui ds, has(type string)
foreach var in `r(varlist)' {
		qui replace `var' = strtrim(`var')
		qui gen length = strlen(`var')
		qui su length
		qui recast str`r(max)' `var', force
		qui drop length
}
qui append using `temp_master'
save `temp_master', replace
	
* Budgetary Central government Revenue
cap dbnomics import, pr(IMF) dataset(GFSMAB) CLASSIFICATION(G1__Z) REF_SECTOR(S1311B) UNIT_MEASURE(XDC) clear
qui ds, has(type string)
foreach var in `r(varlist)' {
		qui replace `var' = strtrim(`var')
		qui gen length = strlen(`var')
		qui su length
		qui recast str`r(max)' `var', force
		qui drop length
}
qui append using `temp_master'
save `temp_master', replace

* Central government Net lending (+) / Net borrowing (-)
cap dbnomics import, pr(IMF) dataset(GFSMAB) CLASSIFICATION(GNLB__Z) REF_SECTOR(S1311) UNIT_MEASURE(XDC_R_B1GQ) clear	
qui ds, has(type string)
foreach var in `r(varlist)' {
		qui replace `var' = strtrim(`var')
		qui gen length = strlen(`var')
		qui su length
		qui recast str`r(max)' `var', force
		qui drop length
}
qui append using `temp_master'
save `temp_master', replace

* Central government Tax revenue
cap dbnomics import, pr(IMF) dataset(GFSMAB) CLASSIFICATION(G11__Z) REF_SECTOR(S1311) UNIT_MEASURE(XDC) clear
qui ds, has(type string)
foreach var in `r(varlist)' {
		qui replace `var' = strtrim(`var')
		qui gen length = strlen(`var')
		qui su length
		qui recast str`r(max)' `var', force
		qui drop length
}
qui append using `temp_master'
save `temp_master', replace

* Central government Expenditure
cap dbnomics import, pr(IMF) dataset(GFSMAB) CLASSIFICATION(G2M__Z) REF_SECTOR(S1311) UNIT_MEASURE(XDC) clear
qui ds, has(type string)
foreach var in `r(varlist)' {
		qui replace `var' = strtrim(`var')
		qui gen length = strlen(`var')
		qui su length
		qui recast str`r(max)' `var', force
		qui drop length
}
qui append using `temp_master'
save `temp_master', replace
	
* Central government Revenue
cap dbnomics import, pr(IMF) dataset(GFSMAB) CLASSIFICATION(G1__Z) REF_SECTOR(S1311) UNIT_MEASURE(XDC) clear
qui ds, has(type string)
foreach var in `r(varlist)' {
		qui replace `var' = strtrim(`var')
		qui gen length = strlen(`var')
		qui su length
		qui recast str`r(max)' `var', force
		qui drop length
}
qui append using `temp_master'
save `temp_master', replace

* Save download date 
gmdsavedate, source(IMF_GFS)

* Save
savedelta ${output}, id(period REF_AREA series_code dataset_code)

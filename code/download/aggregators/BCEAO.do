* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD WEST AFRICAN ECONOMIC DATA FROM BCEAO (BANQUE COMMUNAUTE ECONOMIQUE AFRIQUE DE L'OUEST)
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-12
*
* Description: 
* This Stata script downloads economic data for west african currency union members
*
* Data source:
* DBnomics API
* 
* Last downloaded:
* 2024-07-15
*
* ==============================================================================


* Run the master file
do "code/0_master.do"


global output "${data_raw}/aggregators/BCEAO/BCEAO"

* Create a temporary file where to save the datasets.
tempfile BCEAO
save `BCEAO', replace emptyok

* ==============================================================================
* 				NATIONAL ACCOUNTS
* ==============================================================================

* Download and save
dbnomics import, pr(BCEAO) d(PIBN) clear

* Save
append using `BCEAO'
save `BCEAO', replace

* ==============================================================================
* 				REAL GROSS DOMESTIC PRODUCT
* ==============================================================================

* Download and save
dbnomics import, pr(BCEAO) d(PIBC) clear  

* Save
append using `BCEAO'
save `BCEAO', replace

* ==============================================================================
* 				MACROECONOMIC INDICATORS
* ==============================================================================
* Download and save
dbnomics import, pr(BCEAO) d(IMECO) clear

* Save
append using `BCEAO'
save `BCEAO', replace

* ==============================================================================
* 				CONSUMER PRICE INDEX
* ==============================================================================
* Download and save
dbnomics import, pr(BCEAO) d(IHPC) clear

* Save
append using `BCEAO'
save `BCEAO', replace


* ==============================================================================
* 				CURRENT ACCOUNT BALANCE
* ==============================================================================
* Download and save
dbnomics import, pr(BCEAO) d(BDP4) clear

* Save
append using `BCEAO'
save `BCEAO', replace


* ==============================================================================
* 				PUBLIC DEBT
* ==============================================================================
* Download and save
dbnomics import, pr(BCEAO) d(DPE) clear

* Save
append using `BCEAO'
save `BCEAO', replace

* ==============================================================================
* 				MONETARY AGGREGATES (1)
* ==============================================================================
* Download and save
dbnomics import, pr(BCEAO) d(SIM) clear

* Save
append using `BCEAO'
save `BCEAO', replace


* ==============================================================================
* 				MONETARY AGGREGATES (2)
* ==============================================================================
* Download and save
dbnomics import, pr(BCEAO) d(AM_A) clear

* Save
append using `BCEAO'
save `BCEAO', replace

* ==============================================================================
* 				GOVERNMENT FINANCES
* ==============================================================================
* Download and save
dbnomics import, pr(BCEAO) d(TOFE) clear

* Save
append using `BCEAO'
save `BCEAO', replace


* ==============================================================================
* 				Output
* ==============================================================================

* Sort
sort period country

* Save download date 
gmdsavedate, source(BCEAO)

* Save
save ${output}, replace

* Create the log
clear
set obs 1
gen variable = "BCEAO"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save
save "$data_temp/download_log/BCEAO_log.dta", replace

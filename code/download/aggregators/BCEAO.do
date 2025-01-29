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

clear
global output "${data_raw}\aggregators\BCEAO\BCEAO"

* Create a temporary file where to save the datasets.
tempfile temp_master
save `temp_master', replace emptyok

* ==============================================================================
* 				NATIONAL ACCOUNTS
* ==============================================================================

* Download and save
dbnomics import, pr(BCEAO) d(PIBN) clear

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 				REAL GROSS DOMESTIC PRODUCT
* ==============================================================================

* Download and save
dbnomics import, pr(BCEAO) d(PIBC) clear  

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 				MACROECONOMIC INDICATORS
* ==============================================================================
* Download and save
dbnomics import, pr(BCEAO) d(IMECO) clear

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 				CONSUMER PRICE INDEX
* ==============================================================================
* Download and save
dbnomics import, pr(BCEAO) d(IHPC) clear

* Save
append using `temp_master'
save `temp_master', replace


* ==============================================================================
* 				CURRENT ACCOUNT BALANCE
* ==============================================================================
* Download and save
dbnomics import, pr(BCEAO) d(BDP4) clear

* Save
append using `temp_master'
save `temp_master', replace


* ==============================================================================
* 				PUBLIC DEBT
* ==============================================================================
* Download and save
dbnomics import, pr(BCEAO) d(DPE) clear

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 				MONETARY AGGREGATES (1)
* ==============================================================================
* Download and save
dbnomics import, pr(BCEAO) d(SIM) clear

* Save
append using `temp_master'
save `temp_master', replace


* ==============================================================================
* 				MONETARY AGGREGATES (2)
* ==============================================================================
* Download and save
dbnomics import, pr(BCEAO) d(AM_A) clear

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 				GOVERNMENT FINANCES
* ==============================================================================
* Download and save
dbnomics import, pr(BCEAO) d(TOFE) clear

* Save
append using `temp_master'
save `temp_master', replace


* ==============================================================================
* 				Output
* ==============================================================================

* Sort
sort period country

* Save download date 
gmdsavedate, source(BCEAO)

* Save
savedelta ${output}, id(country period series_code dataset_code)

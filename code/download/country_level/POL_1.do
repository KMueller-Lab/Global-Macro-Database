* ==============================================================================
* GLOBAL CREDIT DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD MONETARY AGGREGATES FROM STATPOL
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-11-06
*
* Description: 
* This stata script downloads data from STATPOL using DBnomics API
* 
* Data source:
* DBnomics API
* 
* Last downloaded:
* 2024-11-06
* ==============================================================================
clear 
* Define output file name 
global output "${data_raw}/country_level/POL_1"

* Create temporary file
clear
tempfile temp_master
save `temp_master', replace emptyok

* BALANCE OF PAYMENTS
dbnomics import, pr(STATPOL) d(ABOP) FREQ(A) clear
append using `temp_master', force
save `temp_master', replace 

* FOREIGN TRADE
dbnomics import, pr(STATPOL) d(AFT) FREQ(A) clear
append using `temp_master', force
save `temp_master', replace 

* GOV DEFICIT AND DEBT
dbnomics import, pr(STATPOL) d(AGG) FREQ(A) clear
append using `temp_master', force
save `temp_master', replace 

* PUBLIC FINANCE
dbnomics import, pr(STATPOL) d(APF) FREQ(A) clear
append using `temp_master', force
save `temp_master', replace 

* INVESTMENTS
dbnomics import, pr(STATPOL) d(AINV) FREQ(A) clear
append using `temp_master', force
save `temp_master', replace 

* MONEY
dbnomics import, pr(STATPOL) d(AMON) FREQ(A) clear
append using `temp_master', force
save `temp_master', replace 

* NATIONAL ACCOUNTS
dbnomics import, pr(STATPOL) d(ANA) FREQ(A) clear
append using `temp_master', force
save `temp_master', replace 

* POPULATION
dbnomics import, pr(STATPOL) d(APOP) FREQ(A) clear
append using `temp_master', force
save `temp_master', replace 

* PRICE INDICES
dbnomics import, pr(STATPOL) d(APRI) FREQ(A) clear
append using `temp_master', force
save `temp_master', replace 

* Save download date 
gmdsavedate, source(POL_1)

* Add ISO3
gen ISO3 = "POL"

* Save
savedelta ${output}, id(period ISO3 dataset_code series_code)

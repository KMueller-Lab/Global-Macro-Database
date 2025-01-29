* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD Türkiye Cumhuriyet Merkez Bankasi Data (Central Bank of Türkiye)
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-11-06
* ==============================================================================
clear 
* Define output file name 
global output "${data_raw}/country_level/TUR_1"

* Create temporary file
clear
tempfile temp_master
save `temp_master', replace emptyok

* Consumer Price Index (2003=100) (TURKSTAT)
dbnomics import, pr(TCMB) d(CPI) clear
append using `temp_master', force
save `temp_master', replace 

* CPI Based Real Effective Exchange Rate (2003=100)
dbnomics import, pr(TCMB) d(CPIREER) clear
append using `temp_master', force
save `temp_master', replace 

* Save download date 
gmdsavedate, source(TUR_1)

* Save
savedelta ${output}, id(period dataset_code series_code)

* ==============================================================================
* GLOBAL CREDIT DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD MONETARY AGGREGATES FROM ISTAT (ITALY STATISTICAL OFFICE)
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-11-06
*
* ==============================================================================
clear 
* Define output file name 
global output "${data_raw}/country_level/ITA_3"

* Create temporary file
clear
tempfile temp_master
save `temp_master', replace emptyok

* NATIONAL ACCOUNTS
dbnomics import, pr(ISTAT) d(92_506_DF_DCCN_PILN_1) EDITION(2024M9)  clear
append using `temp_master', force
save `temp_master', replace 

* Save download date 
gmdsavedate, source(ITA_3)

* Save
savedelta ${output}, id(period dataset_code series_code)

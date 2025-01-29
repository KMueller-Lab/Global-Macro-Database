* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD SAUDI DATA
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-11-06
* ==============================================================================
clear 
* Define output file name 
global output "${data_raw}/country_level/SAU_1"

* Create temporary file
clear
tempfile temp_master
save `temp_master', replace emptyok
	
* BALANCE OF PAYMENTS (MILLIONS RIYALS)
dbnomics import, pr(SAMA) d(BPR) freq(A) clear
append using `temp_master', force
save `temp_master', replace 

* CONSUMER PRICE INDICES FOR MAIN DIVISIONS (2013=100)
dbnomics import, pr(SAMA) d(CPI) freq(A) clear
append using `temp_master', force
save `temp_master', replace 

* EXPENDITURE ON GROSS DOMESTIC PRODUCT (AT PURCHASERS' VALUES AT CURRENT PRICES) (MILLION RIYALS)
dbnomics import, pr(SAMA) d(EGDP1) clear
append using `temp_master', force
save `temp_master', replace 

* EXPENDITURE ON GROSS DOMESTIC PRODUCT (AT PURCHASERS' VALUES AT CONSTANT PRICES (2010 = 100)) (MILLION RIYALS)
dbnomics import, pr(SAMA) d(EGDP2) clear
append using `temp_master', force
save `temp_master', replace 

* Save download date 
gmdsavedate, source(SAU_1)

* Save
savedelta ${output}, id(period dataset_code series_code)

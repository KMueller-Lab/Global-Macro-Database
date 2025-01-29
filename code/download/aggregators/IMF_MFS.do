* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* Download IMF Monetary Financial Statistics 
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-07-04
*
* Description: 
* This Stata script downloads IMF MFS (Monetary Financial Statistics) Data using dbnomics package
* 
* Data source:
* IMF 
* 
* ==============================================================================

clear

* Define output file name 
global output "${data_raw}\aggregators\IMF\IMF_MFS"


* Create master tempfile to store all the datasets
tempfile temp_master
save `temp_master', replace emptyok

* Monetary, Monetary Authorities, Reserve Money (Non-Standardized Presentation), Domestic Currency (M0)
dbnomics import, pr(IMF) d(MFS) INDICATOR(14____XDC) FREQ(A) clear
destring value, replace force 
tempfile temp_M0
save `temp_M0', replace emptyok
append using `temp_master'
save `temp_master', replace


* Monetary, Base Money, Domestic Currency (M0, with more modern data) 
dbnomics import, pr(IMF) d(MFS) INDICATOR(FMA_XDC) FREQ(A) clear
destring value, replace force 
tempfile temp_M0
save `temp_M1', replace emptyok
append using `temp_master'
save `temp_master', replace

* Monetary, Monetary Survey, Money (Non-Standardized Presentation), Domestic Currency (M1)
dbnomics import, pr(IMF) d(MFS) INDICATOR(34____XDC) FREQ(A) clear
destring value, replace force 
tempfile temp_M1
save `temp_M1', replace emptyok
append using `temp_master'
save `temp_master', replace

* Monetary, Broad Money, Currency Issued by Central Government, Domestic Currency (M1, with more modern data)
dbnomics import, pr(IMF) d(MFS) INDICATOR(FMBCC_XDC) FREQ(A) clear
destring value, replace force 
tempfile temp_M1
save `temp_M1', replace emptyok
append using `temp_master'
save `temp_master', replace

* Monetary, Monetary Survey, Money plus Quasi-Money (Non-Standardized Presentation), Domestic Currency (M2)
dbnomics import, pr(IMF) d(MFS) INDICATOR(35L___XDC) FREQ(A) clear
destring value, replace force 
tempfile temp_M2
save `temp_M2', replace emptyok
append using `temp_master'
save `temp_master', replace

* Monetary, Broad Money, Domestic Currency (M2, with more modern data)
dbnomics import, pr(IMF) d(MFS) INDICATOR(FMB_XDC) FREQ(A) clear
destring value, replace force 
tempfile temp_M2
save `temp_M2', replace emptyok
append using `temp_master'
save `temp_master', replace

* Financial, Interest Rates, Government Securities, Treasury Bills, Percent per annum
dbnomics import, provider(IMF) dataset(MFS) INDICATOR(FITB_PA) FREQ(A) clear
destring value, replace force  
tempfile temp_strate
save `temp_strate', replace emptyok
append using `temp_master'
save `temp_master', replace

* Financial, Interest Rates, Monetary Policy-Related Interest Rate, Percent per annum
dbnomics import, provider(IMF) dataset(MFS) INDICATOR(FPOLM_PA) FREQ(A) clear
destring value, replace force  
tempfile temp_cbrate
save `temp_cbrate', replace emptyok
append using `temp_master'
save `temp_master', replace

* Financial, Interest Rates, Government Securities, Government Bonds, Percent per annum
dbnomics import, provider(IMF) dataset(MFS) INDICATOR(FIGB_PA) FREQ(A) clear
destring value, replace force  
tempfile temp_ltrate
save `temp_ltrate', replace emptyok
append using `temp_master'

* Save download date 
gmdsavedate, source(IMF_MFS)

* Save
savedelta ${output}, id(period ref_area series_code dataset_code)

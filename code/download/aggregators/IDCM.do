* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, and Ziliang Chen
* ==============================================================================
* Download macroeconomic data from the IDCM dataset
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* Created: 2024-05-13
*
* Description: 
* This Stata script downloads and saves data from the IDCM.
* 
* Dataset description:
* The International Data Cooperation (IDCM) dataset is a collection of national accounts data from Eurostat, IMF, OECD, and UN, and is aimed to improve data timeliness and accuracy through shared principles among participating organizations. (ECB definition)
*
* Data Source:
* DBnomics API
*
* ==============================================================================

* Define output file name 
global output "${data_raw}\aggregators\IDCM\IDCM"

* Create master tempfile to store all the datasets
clear
tempfile temp_master
save `temp_master', replace emptyok

* Nominal GDP in LCU
dbnomics import, provider(ECB) dataset(IDCM) FREQ(A) STO(B1GQ) PRICES(V) UNIT_MEASURE(XDC)  clear
destring value, replace 
append using `temp_master'
save `temp_master', replace

* Real GDP in LCU
dbnomics import, provider(ECB) dataset(IDCM) FREQ(A) STO(B1GQ) PRICES(Q) UNIT_MEASURE(XDC) clear
destring value, replace 
append using `temp_master'
save `temp_master', replace

* Current account balance
dbnomics import, provider(ECB) dataset(IDCM) FREQ(A) STO(B9) UNIT_MEASURE(XDC)  clear
destring value, replace 
append using `temp_master'
save `temp_master', replace

* Total employment
dbnomics import, provider(ECB) dataset(IDCM) FREQ(A) STO(EMP) REF_SECTOR(S1)  clear
destring value, replace 
append using `temp_master'
save `temp_master', replace

* Consumption of fixed capital
dbnomics import, provider(ECB) dataset(IDCM) FREQ(A) STO(P51C) REF_SECTOR(S1)  clear
destring value, replace 
append using `temp_master'
save `temp_master', replace

* Net saving (When added to consumption of fixed capital results in gross savings)
dbnomics import, provider(ECB) dataset(IDCM) FREQ(A) STO(B8N) REF_SECTOR(S1)  clear
destring value, replace 
append using `temp_master'
save `temp_master', replace

* Consumption 
dbnomics import, provider(ECB) dataset(IDCM) FREQ(A) STO(P3) REF_SECTOR(S1) PRICES(V) UNIT_MEASURE(XDC)  clear
destring value, replace 
append using `temp_master'
save `temp_master', replace

* Investments
dbnomics import, provider(ECB) dataset(IDCM) FREQ(A) STO(P5) REF_SECTOR(S1) PRICES(V) UNIT_MEASURE(XDC)  clear
destring value, replace 
append using `temp_master'
save `temp_master', replace

* Gross fixed capital formation
dbnomics import, provider(ECB) dataset(IDCM) FREQ(A) STO(P51G) REF_SECTOR(S1) PRICES(V) UNIT_MEASURE(XDC)  clear
destring value, replace 
append using `temp_master'
save `temp_master', replace

* Exports
dbnomics import, provider(ECB) dataset(IDCM) FREQ(A) STO(P6) REF_SECTOR(S1) PRICES(V) UNIT_MEASURE(XDC)  clear
destring value, replace 
append using `temp_master'
save `temp_master', replace


* Imports
dbnomics import, provider(ECB) dataset(IDCM) FREQ(A) STO(P7) REF_SECTOR(S1) PRICES(V) UNIT_MEASURE(XDC)  clear
destring value, replace 
append using `temp_master'
save `temp_master', replace



* Assert that country and year uniquely identify observations
isid ref_area series_name period

* Save download date 
gmdsavedate, source(IDCM)

* Save
savedelta ${output}, id(period ref_area series_code dataset_code)

* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD OECD QUARTERLY NATIONAL ACCOUNTS DATA
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-10
*
* Description: 
* This Stata script downloads quarterly national accounts data using DBnomics API
* 
* Data source:
* DBnomics API
* 
* ==============================================================================

clear

* Define output file name 
global output "${data_raw}\aggregators\OECD\OECD_QNA"

* Create master tempfile to store all the datasets
tempfile temp_master
save `temp_master', replace emptyok

* Gross capital formation	
dbnomics import, provider(OECD) dataset(QNA) FREQUENCY(A) SUBJECT(P5) MEASURE(CQR) clear
cap replace value = "" if value == "NA"
destring value, replace 
tempfile temp_CPI
save `temp_CPI', replace emptyok
append using `temp_master'
save `temp_master', replace

* Gross fixed capital formation
dbnomics import, provider(OECD) dataset(QNA) FREQUENCY(A) SUBJECT(P51) MEASURE(CQR) clear
cap replace value = "" if value == "NA"
destring value, replace 
tempfile temp_strate
save `temp_strate', replace emptyok
append using `temp_master'
save `temp_master', replace

* Final consumption expenditure
dbnomics import, provider(OECD) dataset(QNA) FREQUENCY(A) SUBJECT(P3) MEASURE(CQR) clear
cap replace value = "" if value == "NA"
destring value, replace 
tempfile temp_ltrate
save `temp_ltrate', replace emptyok
append using `temp_master'
save `temp_master', replace

* Gross domestic product
dbnomics import, provider(OECD) dataset(QNA) FREQUENCY(A) SUBJECT(B1_GS1) MEASURE(CQR) clear
cap replace value = "" if value == "NA"
destring value, replace 
tempfile temp_CA
save `temp_CA', replace emptyok
append using `temp_master'
save `temp_master', replace

* Save download date 
gmdsavedate, source(OECD_QNA)

* Save data
savedelta ${output}, id(period location series_code dataset_code)

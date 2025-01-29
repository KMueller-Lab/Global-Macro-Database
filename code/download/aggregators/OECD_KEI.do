* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD OECD KEY ECONOMIC INDICATORS DATA
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-10
*
* Description: 
* This Stata script downloads key economic indicators data from OECD
* 
* Data source:
* DBnomics API
* 
* ==============================================================================

clear

* Define output file name 
global output "${data_raw}\aggregators\OECD\OECD_KEI"

* Create master tempfile to store all the datasets
tempfile temp_master
save `temp_master', replace emptyok

* Consumer prices: all items
dbnomics import, provider(OECD) dataset(KEI) FREQUENCY(A) SUBJECT(CPALTT01) clear
cap replace value = "" if value == "NA"
destring value, replace 
tempfile temp_CPI
save `temp_CPI', replace emptyok
append using `temp_master'
save `temp_master', replace

* 3 month interbank rate
dbnomics import, provider(OECD) dataset(KEI) FREQUENCY(A) SUBJECT(IR3TIB01) clear
cap replace value = "" if value == "NA"
destring value, replace 
tempfile temp_strate
save `temp_strate', replace emptyok
append using `temp_master'
save `temp_master', replace

* Long-term interest rate
dbnomics import, provider(OECD) dataset(KEI) FREQUENCY(A) SUBJECT(IRLTLT01) clear
cap replace value = "" if value == "NA"
destring value, replace 
tempfile temp_ltrate
save `temp_ltrate', replace emptyok
append using `temp_master'
save `temp_master', replace

* Current account as a % of GDP, s.a.
dbnomics import, provider(OECD) dataset(KEI) FREQUENCY(A) SUBJECT(B6BLTT02) clear
cap replace value = "" if value == "NA"
destring value, replace 
tempfile temp_CA
save `temp_CA', replace emptyok
append using `temp_master'
save `temp_master', replace

* Monthly unemployment rate: all persons, s.a.
dbnomics import, provider(OECD) dataset(KEI) FREQUENCY(A) SUBJECT(LRHUTTTT) clear
cap replace value = "" if value == "NA"
destring value, replace 
tempfile temp_unemp
save `temp_unemp', replace emptyok
append using `temp_master'

* Save download date 
gmdsavedate, source(OECD_KEI)

* Save
savedelta ${output}, id(period location series_code dataset_code)

* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD OECD MEI
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-07-04
*
* Description: 
* This Stata script downloads OECD MEI (main economic indicators) Data using DBnomics API
* 
* Data source:
* DBnomics API OECD MEI Data
* 
* ==============================================================================

clear

* Define output file name 
global output "${data_raw}\aggregators\OECD\OECD_MEI"

* Create master tempfile to store all the datasets
tempfile temp_master
save `temp_master', replace emptyok

* Monetary aggregates and their components > Broad money and components > M3 > M3
dbnomics import, provider(OECD) dataset(MEI) SUBJECT(MABMM301) MEASURE(STSA) FREQUENCY(A) clear
destring value, replace 
tempfile temp_M3
save `temp_M3', replace emptyok
append using `temp_master'
save `temp_master', replace

* Monetary aggregates and their components > Narrow money and components > M1 and components > M1
dbnomics import, provider(OECD) dataset(MEI) SUBJECT(MANMM101) MEASURE(STSA) FREQUENCY(A) clear
destring value, replace 
tempfile temp_M1
save `temp_M1', replace emptyok
append using `temp_master'
save `temp_master', replace


* Currency Conversions > Real effective exchange rates > Overall Economy > CPI
dbnomics import, provider(OECD) dataset(MEI) SUBJECT(CCRETT01) FREQUENCY(A) clear
destring value, replace 
tempfile temp_reer
save `temp_reer', replace emptyok
append using `temp_master'
save `temp_master', replace


* Interest Rates > Long-term government bond yields > 10-year > Main (including benchmark)
dbnomics import, provider(OECD) dataset(MEI) SUBJECT(IRLTLT01) FREQUENCY(A) clear
destring value, replace 
tempfile temp_ltrate
save `temp_ltrate', replace emptyok
append using `temp_master'
save `temp_master', replace

* Interest Rates > Immediate rates (< 24 hrs) > Central bank rates > Total
dbnomics import, provider(OECD) dataset(MEI) SUBJECT(IRSTCB01) FREQUENCY(A) clear
replace value = "" if value == "NA"
destring value, replace 
tempfile temp_cbrate
save `temp_cbrate', replace emptyok
append using `temp_master'

* Save download date 
gmdsavedate, source(OECD_MEI)

* Save
savedelta ${output}, id(period location series_code dataset_code)

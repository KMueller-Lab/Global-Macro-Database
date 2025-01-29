* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD REVENUE STATISTICS - OECD COUNTRIES: COMPARATIVE TABLES 
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-10
*
* Description: 
* This Stata script downloads revenue statistics from OECD
* 
* Data source:
* DBnomics API
* 
* ==============================================================================

clear

* Define output file name 
global output "${data_raw}\aggregators\OECD\OECD_REV"

* Total tax revenue
dbnomics import, pr(OECD) dataset(REV) VAR(TAXNAT) TAX(TOTALTAX) GOV(FED) clear
replace value = "" if value == "NA"
destring value, replace 

* Save download date 
gmdsavedate, source(OECD_REV)

* Save file 
savedelta ${output}, id(period cou series_code dataset_code)

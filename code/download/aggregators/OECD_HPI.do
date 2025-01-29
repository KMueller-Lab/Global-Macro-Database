* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD OECD HOUSE_PRICES DATA
* 
* Author:
* Ziliang Chen
* National University of Singapore
* 
* Created: 2024-05-14
*
* Description: 
* This Stata script downloads OECD House Prices Data using DBnomics API
*
* This code downloads:
* (1) Nominal House Prices Indices - OECD
* (2) Real House Prices Indices - (OECD)
* 
* Data source:
* DBnomics API 
* 
* ==============================================================================

* Define output file name 
global output "${data_raw}\aggregators\OECD\OECD_HPI"

* Download
dbnomics import, provider(OECD) dataset(HOUSE_PRICES) FREQUENCY(A) clear

* Save download date 
gmdsavedate, source(OECD_HPI)

* Save
savedelta ${output}, id(period cou series_code dataset_name)

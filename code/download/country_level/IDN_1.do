* ==============================================================================
* GLOBAL CREDIT DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD BANK INDONESIA DATA FROM DBNOMICS
* 
* Author:
* Ziliang Chen
* National University of Singapore
*
* Created: 2024-11-06
* ==============================================================================
clear 
* Define output file name 
global output "${data_raw}/country_level/IDN_1"

* Create temporary file
clear
tempfile temp_master
save `temp_master', replace emptyok
	
* Download 
local datasets TABEL1_1 TABEL1_2 TABEL1_25 TABEL4_1 TABEL4_2 TABEL4_3 TABEL4_4 TABEL5_1 TABEL5_40 TABEL7_1 TABEL7_3 TABEL7_6 TABEL8_1
foreach dataset of local datasets {
	* Import
	dbnomics import, pr(BI) d(`dataset') freq(A) clear
	
	* Append and save
	append using `temp_master', force
	save `temp_master', replace
}

* Gen REF_AREA
gen REF_AREA = "IDN"

* Save download date 
gmdsavedate, source(IDN_1)

* Save
savedelta ${output}, id(period dataset_code series_code)

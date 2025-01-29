* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD CPI DATA FROM BIS
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-04-14
*
* Description: 
* This Stata script downloads CPI data from BIS.
* 
* Data Source: Bank of International Settlements.
*
* ==============================================================================

* ==============================================================================
* SET UP
* ==============================================================================
clear
global output "${data_raw}\aggregators\BIS\BIS_CPI"

* Create tempfile
tempfile temp_master
save `temp_master', replace emptyok


* ==============================================================================
* CONSUMER PRICE INDEX: Index, 2010 = 100
* ==============================================================================
* Download
dbnomics import, provider(BIS) dataset(WS_LONG_CPI) FREQ(A) UNIT_MEASURE(628) clear

* Merge and save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* CONSUMER PRICE INDEX: Year-on-year changes, in per cent
* ==============================================================================
* Download
dbnomics import, provider(BIS) dataset(WS_LONG_CPI) FREQ(A) UNIT_MEASURE(771) clear

* Merge and save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* OUTPUT
* ==============================================================================
* Save date 
gmdsavedate, source(BIS_CPI)
gmdsavedate, source(BIS_infl)

* Save
savedelta ${output}, id(period ref_area series_code)

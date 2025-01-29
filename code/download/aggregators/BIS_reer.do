* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD REAL EFFECTIVE EXCHANGE RATES FROM BIS
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-04-09
* 
* Description: 
* This Stata script downloads effective exchange rate from BIS
*
* Source: Bank for International Settlements.
*
* ==============================================================================

* Define output file name 
global output "${data_raw}\aggregators\BIS\BIS_REER"


* Download broad basket data 
dbnomics import, provider(BIS) dataset(WS_EER) FREQ(M) EER_TYPE(R) EER_BASKET(B) clear

* Save download date 
gmdsavedate, source(BIS_REER)

* Save
savedelta ${output}, id(period ref_area series_code)

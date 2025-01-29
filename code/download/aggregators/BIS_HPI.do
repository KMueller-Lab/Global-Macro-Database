* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD HOUSING PRICES FROM BIS
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-04-05
*
* Description: 
* This Stata script downloads housing prices from BIS
* 
* Data Source: Bank of International Settlements.
*
* =========================================================

* Define output file name 
global output "${data_raw}\aggregators\BIS\BIS_HPI"

dbnomics import, provider(BIS) dataset(WS_SPP) UNIT_MEASURE(628) VALUE(N) clear

* Only keep relevant information
keep period value dataset_name freq ref_area series_name series_code

* Assert that country and year uniquely identify observations
isid ref_area series_name period

* Save download date 
gmdsavedate, source(BIS_HPI)

* Save
savedelta ${output}, id(period ref_area series_code)

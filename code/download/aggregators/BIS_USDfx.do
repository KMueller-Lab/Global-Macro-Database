* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD US DOLLAR EXCHANGE RATES FROM BIS
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-04-05
*
* Description: 
* This Stata script downloads US dollar exchange rates from BIS.
* 
* Data source: Bank for International Settlements.
*
* =========================================================

* Define output file name 
global output "${data_raw}\aggregators\BIS\BIS_USDfx"

* import data
dbnomics import, provider(BIS) dataset(WS_XRU) FREQ(A) COLLECTION(A) clear

* Save download date 
gmdsavedate, source(BIS_USDfx)

* Save
savedelta ${output}, id(period ref_area series_code)

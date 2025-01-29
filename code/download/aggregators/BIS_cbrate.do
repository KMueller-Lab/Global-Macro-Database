* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD CENTRAL BANK POLICY RATES FROM BIS
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-04-05
*
* Description: 
* This Stata script downloads Central Bank Policy Rates from BIS
* 
* Data source: Bank of International Settlements
*
* ==============================================================================

* Define output file name 
global output "${data_raw}\aggregators\BIS\BIS_cbrate"

* Download
dbnomics import, provider(BIS) dataset(WS_CBPOL) FREQ(M) clear insecure

* Save download date 
gmdsavedate, source(BIS_cbrate)

* Save
savedelta ${output}, id(period ref_area series_code)

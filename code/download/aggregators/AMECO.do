* ==============================================================================
* GLOBAL CREDIT DATABASE
* by Karsten Müller, Ziliang Chen, and Mohamed Lehbib
* ==============================================================================
* DOWNLOAD DATA FROM AMECO
* 
* Author:
* Ziliang Chen
* National University of Singapore
*
* Created: 2024-11-06
*
* Description: 
* This stata script downloads data from AMECO using DBnomics API
* 
* Data source:
* DBnomics API
* 
* Last downloaded:
* 2024-11-06
* ==============================================================================
clear 
* Define output file name 
global output "${data_raw}\aggregators\AMECO\AMECO"

* Create temporary file
clear
tempfile temp_master
save `temp_master', replace emptyok


* Real effective exchange rates
dbnomics import, pr(AMECO) d(XUNRQ-1)  clear
append using `temp_master', force
save `temp_master', replace

* Nominal short-term interest rates
dbnomics import, pr(AMECO) d(ISN) unit(-)   clear
append using `temp_master', force
save `temp_master', replace

* Nominal long-term interest rates
dbnomics import, pr(AMECO) d(ILN) unit(-)  clear
append using `temp_master', force
save `temp_master', replace

* Exports of goods and services at current prices
dbnomics import, pr(AMECO) d(UXGS) clear
append using `temp_master', force
save `temp_master', replace

* Imports of goods and services at current prices
dbnomics import, pr(AMECO) d(UMGS) clear
append using `temp_master', force
save `temp_master', replace

* Total consumption at current prices
dbnomics import, pr(AMECO) d(UCNT) clear
append using `temp_master', force
save `temp_master', replace

* Gross fixed capital formation at current prices
dbnomics import, pr(AMECO) d(UIGT) clear
append using `temp_master', force
save `temp_master', replace

* Gross capital formation at current prices
dbnomics import, pr(AMECO) d(UITT) clear
append using `temp_master', force
save `temp_master', replace

* Gross domestic product at current prices
dbnomics import, pr(AMECO) d(UVGD) clear
append using `temp_master', force
save `temp_master', replace

* Gross domestic product at 2015 reference levels
dbnomics import, pr(AMECO) d(OVGD) clear
append using `temp_master', force
save `temp_master', replace

* Total population
dbnomics import, pr(AMECO) d(NPTD) clear
append using `temp_master', force
save `temp_master', replace

* Total unemployment 
dbnomics import, pr(AMECO) d(NUTN) clear
append using `temp_master', force
save `temp_master', replace

* National consumer price index
dbnomics import, pr(AMECO) d(ZCPIN)  clear
append using `temp_master', force
save `temp_master', replace

* Save download date 
gmdsavedate, source(AMECO)

* Save
savedelta ${output}, id(period period_start_day geo dataset_code series_code)

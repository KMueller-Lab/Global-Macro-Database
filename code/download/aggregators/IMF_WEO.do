* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD WORLD ECONOMIC OUTLOOK (WEO) DATABASE FROM IMF
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-04-04
*
* Description: 
* This Stata script downloads World Economic Outlook (WEO) databases from IMF 
* using DBnomics API
*
* This code downloads:
*
* (1) NGDP_R
* (2) NGDP
* (3) NGDPRPC
* (4) NID_NGDP
* (5) PCPI
* (6) TM_RPCH
* (7) TX_RPCH
* (8) LUR
* (9) LP
* (10) GGR_NGDP
* (11) GGX_NGDP
* (12) GGXCNL_NGDP
* (13) GGSB_NPGDP
* (14) GGXWDG_NGDP
* (15) BCA_NGDPD
* All values are in annual frequency
*
* Data source:
* DBnomics API IMF WEO:2023-10 Data
* 
* Notes:
* The DBnomics API permits data downloads by specific release 
* (e.g., WEO:2023-10, which refers to the WEO dataset for the  
*  WEO by countries 2023-10 release). 
* 
* For future updates, it will be necessary to manually 
* adjust the code to access the latest data releases.
*
* ==============================================================================

* Define output file name 
global output "${data_raw}\aggregators\IMF\IMF_WEO"

* Define variables to be downloaded
local initial NGDP
local subjects NGDP_R NGDPRPC NID_NGDP PCPI TM_RPCH TX_RPCH LUR LP GGR_NGDP GGX_NGDP GGXCNL_NGDP GGSB_NPGDP GGXWDG_NGDP BCA_NGDPD

* Set up locals for querying current version 
loc thisyear = $currdate
loc lastyear = $currdate - 1
di "`lastyear'"

* Is current version from this year October?
cap noisily dbnomics datastructure, provider(IMF) dataset(WEO:`thisyear'-10) clear
if _rc == 0 loc version "`thisyear'-10"

* If not, is it from this year April?
if _rc != 0 {
	cap noisily dbnomics datastructure, provider(IMF) dataset(WEO:`thisyear'-04) clear
	if _rc == 0 loc version "`thisyear'-04"

	* If not, it must be last year October
	if _rc != 0 loc version "`lastyear'-10"	
}

* Loop over variables, download data, append 
foreach var of local initial {
    dbnomics import, provider(IMF) dataset(WEO:`version') weo-subject(`var') clear
	tempfile temp_master
	save `temp_master', replace
	foreach subj of local subjects {
		dbnomics import, provider(IMF) dataset(WEO:`version') weo-subject(`subj') clear
		append using `temp_master'
		save `temp_master', replace
		}
}

* Only keep relevant information
keep period value dataset_code dataset_name unit weo_country weo_subject provider_code series_code series_name series_name


* Assert that country and year uniquely identify observations
isid weo_country series_code period

* Save download date 
gmdsavedate, source(IMF_WEO)

* Save
savedelta ${output}, id(period weo_country series_code dataset_code)

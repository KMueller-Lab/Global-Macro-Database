* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
*
* Constructing CPI Index
* 
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-10-17
*
* ==============================================================================

* Open the data
use "$data_final/clean_data_wide", clear

* Set up the priority list
splice, priority(IMF_WEO BIS IMF_IFS EUS OECD_EO OECD_KEI WDI WDI_ARC BCEAO  ADB AMECO CS1 CS2 MOXLAD IHD JST CEPAC MW AHSTAT HFS NBS FZ Mitchell) generate(CPI) varname(CPI) base_year(2018) method("chainlink")

* Rebasing to 2010
bysort ISO3: egen CPI_2010 = mean(CPI) if year == 2010
bysort ISO3: egen CPI_2010_all = mean(CPI_2010)
gen CPI_rebased = (CPI * 100) / CPI_2010_all
drop CPI_2010 CPI_2010_all
sort ISO3 year

* Use non-rebased data for countries with no data in 2010
replace CPI_rebased = CPI if CPI_rebased == .
drop CPI
ren CPI_rebased CPI

* Save
save "$data_final/chainlinked_CPI", replace 

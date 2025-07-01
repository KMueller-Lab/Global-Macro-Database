* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing government taxes
* 
* Created: 
* 2024-06-28
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 	
* ==============================================================================

* ==============================================================================
* Open the data
use "$data_final/clean_data_wide", clear

* ==============================================================================
* Add notes on definitional differences in government expenditure.
* ==============================================================================

gmdaddnote_source WDI_ARC  "Data refers to central government." govtax_GDP
gmdaddnote_source WDI 	   "Data refers to central government." govtax_GDP
gmdaddnote_source NBS	   "Data refers to both central and general governments." govtax_GDP
gmdaddnote_source IMF_GFS  "Data refers to central government." govtax_GDP
gmdaddnote_source OECD_EO  "Data refers to general government." govtax_GDP
gmdaddnote_source AMF 	   "Data refers to general government." govtax_GDP
gmdaddnote_source AFRISTAT "Data refers to general government." govtax_GDP
gmdaddnote_source BCEAO    "Data refers to general government." govtax_GDP
gmdaddnote_source ADB 	   "Data refers to general government." govtax_GDP
gmdaddnote_source AHSTAT   "Data refers to central government." govtax_GDP
gmdaddnote_source HFS 	   "Data refers to central government." govtax_GDP
gmdaddnote_source Mitchell "Data refers to central government." govtax_GDP
gmdaddnote_source EUS 	   "Data refers to general government." govtax_GDP
gmdaddnote_source JERVEN   "Data refers to general government." govtax_GDP
gmdaddnote_source MD  	   "Data refers to general government." govtax_GDP
gmdaddnote_source CS1_CAN "Data refers to central government." govtax_GDP
gmdaddnote_source CS1_PRT "Data refers to central government." govtax_GDP
gmdaddnote_source CS1_USA "Data refers to central government." govtax_GDP
gmdaddnote_source CS1_ZAF "Data refers to central government." govtax_GDP
gmdaddnote_source CS2_ISL "Data refers to general government." govtax_GDP


* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================

* Set up the priority list
splice, priority(AFRISTAT AMF BCEAO OECD_EO EUS WDI WDI_ARC CS1 CS2 NBS ADB AHSTAT Mitchell AHSTAT MD) generate(govtax_GDP) varname(govtax_GDP) method("none") base_year(2017)

* ==============================================================================
* Derive government tax revenue levels using our spliced ratio series and GDP
* ==============================================================================
use "$data_final/chainlinked_govtax_GDP", clear

* Merge GDP series 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", nogen keepus(nGDP) 

* Compute the level series 
gen GMD_estimated_govtax = (govtax_GDP * nGDP) / 100
keep ISO3 year GMD_estimated_govtax

* Add raw data of government revenue
merge 1:1 ISO3 year using "$data_final/clean_data_wide", nogen

* Splice Guinea later 
drop if ISO3 == "GIN" | ISO3 == "SSD"

* Splice government tax revenue series and use our GMD_estimated as the first priority
splice, priority(GMD_estimated AFRISTAT AMF BCEAO IMF_GFS EUS OECD_REV OECD_EO WDI WDI_ARC CS1 CS2 NBS ADB AHSTAT Mitchell JERVEN AHSTAT) generate(govtax) varname(govtax) method("chainlink") base_year(2018)

* Now chainlink Guinea and append 
tempfile temp_master
save `temp_master', replace

use "$data_final/chainlinked_govtax_GDP", clear

* Merge GDP series 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", nogen keepus(nGDP) 

* Compute the level series 
gen GMD_estimated_govtax = (govtax_GDP * nGDP) / 100
keep ISO3 year GMD_estimated_govtax

* Add raw data of government revenue
merge 1:1 ISO3 year using "$data_final/clean_data_wide", nogen

* Now chainlink Guinea
keep if ISO3 == "GIN"

* Splice government tax revenue series and use our GMD_estimated as the first priority
splice, priority(GMD_estimated AFRISTAT AMF BCEAO IMF_GFS EUS OECD_REV OECD_EO WDI WDI_ARC CS1 CS2 NBS ADB AHSTAT Mitchell JERVEN AHSTAT) generate(govtax) varname(govtax) method("chainlink") base_year(2014)

* Append 
append using `temp_master'
save `temp_master', replace

use "$data_final/chainlinked_govtax_GDP", clear

* Merge GDP series 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", nogen keepus(nGDP) 

* Compute the level series 
gen GMD_estimated_govtax = (govtax_GDP * nGDP) / 100
keep ISO3 year GMD_estimated_govtax

* Add raw data of government revenue
merge 1:1 ISO3 year using "$data_final/clean_data_wide", nogen


* Now chainlink South Sudan
keep if ISO3 == "SSD"

* Splice government tax revenue series and use our GMD_estimated as the first priority
splice, priority(GMD_estimated AFRISTAT AMF BCEAO IMF_GFS EUS OECD_REV OECD_EO WDI WDI_ARC CS1 CS2 NBS ADB AHSTAT Mitchell JERVEN AHSTAT) generate(govtax) varname(govtax) method("chainlink") base_year(2022)

* Append 
append using `temp_master'
save `temp_master', replace


* Sort 
sort ISO3 year

* Save 
save "$data_final/chainlinked_govtax", replace











* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing exports 
* 
* Created: 
* 2024-06-28
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 	
* ==============================================================================
* Clear the panel
clear

* Open the data
use "$data_final/clean_data_wide", clear

* Merge chainlinked USD exchange rate
merge 1:1 ISO3 year using "$data_final/chainlinked_USDfx", nogen keepus(USDfx)

* Derive trade values from UN_trade
gen UN_trade_imports = (UN_trade_imports_USD * USDfx)
gen UN_trade_exports = (UN_trade_exports_USD * USDfx)

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================
* Set up the priority list
splice, priority(OECD_EO EUS AMECO WDI UN BCEAO AMF ADB WDI_ARC IMF_WEO IMF_IFS CS1 CS2 CS3 JST UN_trade Tena AHSTAT Mitchell NBS HFS IHD TH_ID FZ IMF_WEO_forecast) generate(exports) varname(exports) base_year(2019) method("chainlink")



* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing population
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

* Create temporary file to store the data
tempfile temp_master
save `temp_master', replace emptyok

* Open the data
use "$data_final/clean_data_wide", clear

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================

* Set up the priority list
splice, priority(WDI EUS OECD_EO ADB IMF_IFS WDI_ARC UN AMECO IMF_WEO CS1 CS2 AHSTAT Gapminder JERVEN MW Tena FZ BORDO JST MD MOXLAD NBS PWT HFS MAD PWT IMF_WEO_forecast) generate(pop) varname(pop) base_year(2018) method("chainlink")



* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCT SHORT TERM INTEREST RATE SERIES
* 
* Created: 
* 2024-06-28
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 	
* ==============================================================================

* Open the data
use "$data_final/clean_data_wide", clear

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================

* Set up the priority list
splice, priority(IMF_MFS OECD_KEI OECD_MEI_ARC OECD_EO IMF_IFS ADB CEPAC AMECO CS1 CS2 JST BORDO NBS Homer_Sylla MW IHD HFS) generate(strate) varname(strate) base_year(2017) method("none")

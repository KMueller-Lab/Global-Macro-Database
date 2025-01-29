* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
*
* CONSTRUCING CENTRAL BANK POLICY RATE
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

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================

* Set up the priority list
splice, priority(BIS IMF_MFS OECD_MEI OECD_MEI_ARC OECD_EO Grimm IMF_IFS BCEAO CS1 CS2 NBS Homer_Sylla IHD FZ CEPAC) generate(cbrate) varname(cbrate) base_year(2017) method("none")




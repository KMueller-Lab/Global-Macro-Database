* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing long-term interest rate 
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
splice, priority(OECD_MEI OECD_KEI OECD_MEI_ARC IMF_MFS JST BORDO AMECO CS1 CS2 FZ MD MW NBS Homer_Sylla CLIO Schmelzing) generate(ltrate) varname(ltrate) base_year(2020) method("none")

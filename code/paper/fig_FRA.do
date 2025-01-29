* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* MAKE PAPER EXHIBIT FOR FRANCE
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2025-01-18
*
* ==============================================================================

* Investment
use "$data_final/chainlinked_inv", clear
keep if ISO3 == "FRA"

gmdmakeplot_cs inv, log ylabel("Investment, millions of LCU (Log scale)") y_axislabel(`"0 "1" 2 "10000" 4 "100000" 6 "500000" 8 "1000000""') graphformat("eps")

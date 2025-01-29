* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* MAKE PAPER EXHIBITS FOR UK
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2025-01-18
*
* ==============================================================================

* Nominal GDP
use "$data_final/chainlinked_nGDP", clear
keep if ISO3 == "GBR"
gmdmakeplot_cs nGDP, log ylabel("Nominal GDP, millions of LCU (Log scale)") y_axislabel(`"0 "1" 2 "10000" 4 "100000" 6 "2000000" 8 "4000000""') graphformat("eps")

* Exports
use "$data_final/chainlinked_exports", clear
keep if ISO3 == "GBR"
gmdmakeplot_cs exports, log ylabel("Exports, millions of LCU (Log scale)") y_axislabel(`"0 "1" 2 "1000" 4 "100000" 6 "500000" 8 "1000000""') graphformat("eps")

* Government debt
use "$data_final/chainlinked_govdebt_GDP", clear
keep if ISO3 == "GBR"
gmdmakeplot_cs govdebt_GDP, ylabel("Government debt, % of GDP")  y_axislabel(`"0 "0" 50 "50" 100 "100" 150 "150" 200 "200" 250 "250" 300 "300""') graphformat("eps")


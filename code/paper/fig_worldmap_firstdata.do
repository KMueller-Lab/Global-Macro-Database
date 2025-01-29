* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* WORLD MAP SHOWING FIRST YEAR FOR EACH VARIABLE 
* 
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-10-11
*
* ==============================================================================

* ==============================================================================
* PREPARE MAP DATA 
* ==============================================================================

/* 	Read in World Bank's world map coordinates 
	Note that this generates two files in the working directory we will
	later want to delete to avoid cluttering the HD:
	- world_shp.dta 
	- world.dta
*/
* Set up the font for the graphs
graph set window fontface "Times New Roman"

* Open
clear 
spshape2dta "${data_helper}/WB_countries_Admin0_10m/WB_countries_Admin0_10m.shp", replace saving(world)

use world
geo2xy *CY *CX, proj(web_mercator) replace
drop if ISO_A3 == "-99" & ISO_A3_EH != "FRA"
replace ISO_A3 = "FRA" if ISO_A3_EH == "FRA"
ren ISO_A3 ISO3 
duplicates drop ISO3, force 
save world, replace

* Load and prepare the data
use "$data_final/clean_data_wide", clear
drop *_pop

* Drop missing observations.
qui ds ISO3 year, not 
qui missings dropobs `r(varlist)', force 
gcollapse (min) year, by(ISO3)
merge 1:1 ISO3 using world, nogen 

* ==============================================================================
* PLOT MAP 
* ==============================================================================
* Get min and max years for breaks
sum year 
local min = `r(min)'
local max = `r(max)'

* Add breaks
local breaks `min' 1800 1850 1900 1925 1950 1975 `max'

* Plot
spmap year using world_shp, ///
    id(_ID) ///
    fcolor(BuYlRd) ///
    clmethod(custom) ///
    clbreaks(`breaks') ///
    legstyle(2) ///
    legend(pos(7) size(*2)) ///
    plotregion(margin(zero)) ///
    bgcolor(white) ///
    ocolor(gs10 ...) ///
    osize(vthin ...) ///
    ndfcolor(gs14) ///
    ndocolor(gs8) ///
    ndsize(vthin) ///
	xsize(7) ysize(4) ///
    ndlabel("No data")	
	graph export "${graphs}/world_map.eps", replace

* Clean up by removing world
rm "world.dta"
rm "world_shp.dta"

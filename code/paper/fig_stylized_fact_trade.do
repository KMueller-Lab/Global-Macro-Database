* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
*
* FIGURE SHOWING INTEREST RATES VARIATION OVER TIME
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-12-11
*
* ==============================================================================
* Set up the font for the graphs
graph set window fontface "Times New Roman"

* Import the data
use "$data_final/chainlinked_exports", clear
merge 1:1 ISO3 year using "$data_final/chainlinked_USDfx", keep(3) nogen
keep ISO3 year exports USDfx
gen exports_USD = exports / USDfx

* Drop countries with questionable data 
drop if inlist(ISO3, "MMR", "SLE", "ROU", "ZWE", "POL", "YUG")

* Keep relevant variables
keep ISO3 year exports_USD
drop if missing(exports_USD)
sort year ISO3 
keep if year >= 1850 & year <= 2024

* Generate total world exports for each year
bys year: egen total_exports = sum(exports_USD)

* Calculate shares for each country
gen export_share = (exports_USD/total_exports)*100


* Instead of ranking, directly keep only the countries of interest
keep if inlist(ISO3, "USA", "DEU", "FRA", "GBR", "JPN", "CHN") | ISO3 != ""

* Calculate ROW (all other countries)
bys year: egen selected_sum = sum(export_share) if inlist(ISO3, "USA", "DEU", "FRA", "GBR", "JPN", "CHN")
bys year: egen ROW_sum = sum(export_share) if !inlist(ISO3, "USA", "DEU", "FRA", "GBR", "JPN", "CHN")

* Create a new rank variable for these specific countries
gen rank = .
replace rank = 1 if ISO3 == "USA"
replace rank = 2 if ISO3 == "FRA"
replace rank = 3 if ISO3 == "GBR"
replace rank = 4 if ISO3 == "JPN"
replace rank = 5 if ISO3 == "CHN"
replace rank = 6 if ISO3 == "DEU"
replace rank = 7 if ISO3 == "ROW"

* Combine all other countries into ROW and compute shares
replace ISO3 = "ROW" if !inlist(ISO3, "USA", "DEU", "FRA", "GBR", "JPN", "CHN")
replace export_share = ROW_sum if ISO3 == "ROW"
duplicates drop ISO3 year, force
gsort year rank
by year: gen cum_share = sum(export_share)

* Colors
local color1 "51 119 179" 
local color2 "107 174 214"   
local color3 "34 139 34"
local color4 "60 179 113"
local color5 "102 205 170"
local color6 "144 238 144"
local color7 "233 242 238"  

* Plot
twoway (area cum_share year if ISO3 == "ROW", color("`color7'") fintensity(90)) ///
       (area cum_share year if ISO3 == "DEU", color("`color6'") fintensity(90)) ///
       (area cum_share year if ISO3 == "CHN", color("`color5'") fintensity(90)) ///
       (area cum_share year if ISO3 == "JPN", color("`color4'") fintensity(90)) ///
       (area cum_share year if ISO3 == "GBR", color("`color3'") fintensity(90)) ///
       (area cum_share year if ISO3 == "FRA", color("`color2'") fintensity(90)) ///
       (area cum_share year if ISO3 == "USA", color("`color1'") fintensity(90)), ///
       ytitle("Share of Global Exports (%)", size(medium)) ///
       xtitle("") ///
       ylabel(0(20)100, angle(0) grid labsize(4)) ///
       xlabel(1850(25)2000 2024, angle(0) nogrid labsize(4)) ///
       graphregion(color(white) margin(medium)) ///
       plotregion(margin(medium)) bgcolor(white) ///
legend(order(7 "United States" 6 "France" 5 "United Kingdom" 4 "Japan" 3 "China" 2 "Germany"  1 "Rest of World") ///
       cols(4) rows(2) position(6)  region(lcolor(none) color(none))  size(medium) ///
       symxsize(7) bmargin(medium)) ///
       scheme(s2color) ///
       xsize(12) ysize(7)
graph export "$graphs/stylized_fact_trade.eps", replace

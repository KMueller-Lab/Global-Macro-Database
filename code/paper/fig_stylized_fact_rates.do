* ==============================================================================
* Global Macro Project
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
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

* Import the data and keep relevant variables and years
use "$data_final/chainlinked_ltrate",clear
keep ISO3 year ltrate Schmelzing_ltrate 
keep if year >= 1875

* Keep countries over time
keep if inlist(ISO3, "ITA", "GBR", "NLD", "DEU", "FRA", "USA", "ESP", "JPN") | inlist(ISO3, "BEL", "CHE", "SWE", "NOR", "DNK", "CAN")

* Calculate Schmelzing average rate 
replace ltrate = . if inlist(ISO3, "ITA", "GBR", "NLD", "DEU", "FRA", "USA", "ESP", "JPN")
sort year
by year: egen Schmelzing_mean = mean(Schmelzing_ltrate)
replace ISO3 = "Schmelzing" if inlist(ISO3, "ITA", "GBR", "NLD", "DEU", "FRA", "USA", "ESP", "JPN")
duplicates drop ISO3 year, force

* Get country names
merge m:1 ISO3 using $isomapping, keepus(countryname) nogen keep(1 3)

* Add a column with interest rates combined 
replace ltrate = Schmelzing_mean if ISO3 == "Schmelzing"
sort countryname year
keep if year <= 2024

* Plot
twoway (line ltrate year if ISO3=="Schmelzing", lwidth(medthick) lcolor(black))  ///
       (line ltrate year if ISO3=="BEL", lwidth(medthin))  ///
       (line ltrate year if ISO3=="CHE", lwidth(medthin))  ///
       (line ltrate year if ISO3=="SWE", lwidth(medthin))  ///
       (line ltrate year if ISO3=="NOR", lwidth(medthin))  ///
       (line ltrate year if ISO3=="DNK", lwidth(medthin))  ///
       (line ltrate year if ISO3=="CAN", lwidth(medthin)),  ///
       ytitle("") ///
       xtitle("") ///
       xlabel(1875(25)2025, angle(0) labsize(4.5)) ///
       ylabel(0(5)25, labsize(4.5) angle(0)) ///
       legend(order(0 "Country:" 1 "Schmelzing (2019)" 2 "Belgium" 3 "Switzerland" 4 "Sweden" 5 "Norway" ///
              6 "Denmark" 7 "Canada")) ///
       legend(size(medium) rows(2) symxsize(5) keygap(1) bmargin(zero) region(lcolor(white)) position(6)) ///
       graphregion(color(white)) 
graph export "$graphs/stylized_fact_rates.eps", replace
	
	
	
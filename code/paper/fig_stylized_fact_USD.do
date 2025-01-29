* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
*
* FIGURE SHOWING USD EXCHANGE RATE VOLATILITY
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-12-11
*
* ==============================================================================
* Import
use "$data_final/chainlinked_USDfx", clear

* Set up the font for the graphs
graph set window fontface "Times New Roman"

* Prepare the data
keep if !missing(USDfx)
keep ISO3 year USDfx
keep if year <= 2023
sort ISO3 year

* Add the year to the country names 
sort ISO3 year
by ISO3: egen min_year = min(year)
by ISO3: egen max_year = max(year)
replace ISO3 = ISO3 + " (" + string(min_year) + "-" + string(max_year) + ")"

* Calculate the log change
gen logfx = log(USDfx)
encode ISO3, gen(id)
xtset id year
gen dlogfx = d.logfx
gcollapse (sd) dlogfx, by(ISO3)

* Keep country with no-peg / quasi-peg
keep if dlogfx != 0

*Rank countries by depreciation
egen rank = rank(dlogfx)
egen n_countries = count(ISO3)

* Categorize performance
gen performance = "Middle"
replace performance = "Top 20" if rank <= 20
replace performance = "Bottom 20" if rank > n_countries - 20

* Keep only top and bottom performers
keep if performance != "Middle"

* Get the country name
ren ISO3 range 
gen ISO3 = substr(range, 1, 3)
merge 1:1 ISO3 using $isomapping, keepus(countryname) keep(3) 
replace countryname = "Congo DRC" if countryname == "Democratic Republic of the Congo"
replace countryname = "St-Vincent" if countryname == "Saint Vincent and the Grenadines"
replace countryname = "St-Kitts and Nevis" if countryname == "Saint Kitts and Nevis"

* Add the range to country names 
replace countryname = countryname + substr(range, 4, .)

* Plot
preserve 
keep if performance != "Top 20"
graph hbar (asis) dlogfx, ///
    over(countryname, sort(dlogfx) label(labsize(small) angle(0))) ///
    subtitle("", size(small)) ///
    ylabel(, angle(0) format(%4.2f) grid labsize(4.5)) ///
    ytitle("") ///
    bar(1, color("220 20 20")) ///
    graphregion(color(white) margin(right=0.2)) ///
    plotregion(margin(left=2)) ///
    ysize(16) xsize(10) ///
    scheme(s2color)
graph export "$graphs/stylized_fact_rates_USD_1.eps", replace
restore

preserve
keep if performance == "Top 20"
graph hbar (asis) dlogfx, ///
    over(countryname, sort(dlogfx) label(labsize(small) angle(0))) ///
    subtitle("", size(small)) ///
    ylabel(, angle(0) format(%4.2f) grid labsize(4.5)) ///
    ytitle("") ///
    bar(1, color("31 107 42")) ///
    graphregion(color(white) margin(right=0.2)) ///
    plotregion(margin(left=2) lcolor(white)) ///
     ysize(16) xsize(10) ///
    scheme(s2color)
graph export "$graphs/stylized_fact_rates_USD_2.eps", replace
restore


* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* FIGURE SHOWING SHARE OF WORLD GDP COVERED BY EACH VARIABLE 
* 
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-10-11
*
* ==============================================================================

* ==============================================================================
* CALCULATE STATISTICS BY VARIABLE FROM FINAL DATASET 
* ==============================================================================

* Set up the font for the graphs
graph set window fontface "Times New Roman"
use "$data_final/data_final", clear
drop countryname income_group

qui merge 1:1 ISO3 year using "$data_final/chainlinked_USDfx", keep(3) nogen

drop if ISO3 == "ZWE"
drop if ISO3 == "SLE"
drop if ISO3 == "ROU"
drop if ISO3 == "DEU" & year <= 1945
drop if ISO3 == "YUG"
drop if ISO3 == "IRQ"
drop if ISO3 == "URY"
drop if inlist(ISO3, "MMR", "SLE", "YUG", "ROM", "ZWE", "SRB", "POL", "RUS")

gen nGDP_USDfx = nGDP / USDfx


bysort year: egen total_gdp = sum(nGDP_USDfx)
gen gdp_share = (nGDP_USDfx / total_gdp) * 100
keep ISO3 year gdp_share

merge 1:1 ISO3 year using "$data_final/data_final", nogen
drop countryname income_group
drop if inlist(ISO3, "MMR", "SLE", "YUG", "ROM", "ZWE")

keep if year >= 1900
drop if gdp_share <= 0.1
drop if gdp_share == .

drop nGDP

qui ds ISO3 year gdp_share, not
foreach var in `r(varlist)'{
	qui replace `var' = 1 if `var' != .
	qui replace `var' = 0 if `var' == .
}

foreach var in CA_GDP USDfx HPI M0 M1 M2 M3 REER cbrate cons exports finv gen_govdebt_GDP gen_govdef_GDP gen_govexp gen_govrev gen_govtax cgovdebt_GDP cgovdef_GDP cgovexp cgovrev cgovtax imports infl inv ltrate strate unemp {
    qui replace `var' = `var' * gdp_share
}
qui ds ISO3 year gdp_share, not
collapse (sum) `r(varlist)', by(year)

foreach var in CA_GDP HPI USDfx M0 M1 M2 M3 REER cbrate cons exports finv gen_govdebt_GDP gen_govdef_GDP gen_govexp gen_govrev gen_govtax cgovdebt_GDP cgovdef_GDP cgovexp cgovrev cgovtax imports infl inv ltrate strate unemp {
    qui replace `var' = . if `var' == 0
}

local vars "CA_GDP HPI M0 M1 M2 M3 rGDP USDfx cbrate cons exports finv gen_govdebt_GDP gen_govdef_GDP gen_govexp gen_govrev gen_govtax cgovdebt_GDP cgovdef_GDP cgovexp cgovrev cgovtax imports infl inv ltrate strate unemp"
qui keep if year <= 2020

********************************************************************************		
* Plot government finance variables
local vars "gen_govexp gen_govrev gen_govtax gen_govdebt_GDP gen_govdef_GDP cgovexp cgovrev cgovtax cgovdebt_GDP cgovdef_GDP"
label variable gen_govexp "General government expenditure"
label variable gen_govrev "General government revenue"
label variable gen_govdef_GDP "General government deficit-to-GDP"
label variable gen_govtax "General government tax revenue"
label variable gen_govdebt_GDP "General government debt-to-GDP"
label variable cgovexp "Central government expenditure"
label variable cgovrev "Central government revenue"
label variable cgovtax "Central government tax revenue"
label variable cgovdebt_GDP "Central government debt-to-GDP"
label variable cgovdef_GDP "Central government deficit-to-GDP"

keep if year <= 2020

* Plot
line `vars' year, ///
    lwidth(thick) ///
    lpattern(solid solid solid solid solid) ///
    lcolor(navy crimson forest_green gold purple) ///
    ylabel(0(20)100, ///
        angle(0) ///
        labsize(5) ///
        grid ///
        glcolor(gs96) ///
        glwidth(vthin) ///
        glpattern(dot) /// 
        format(%3.0f)) ///
    xlabel(1900(20)2020, ///
        angle(0) ///
        labsize(5) ///
        grid ///
        glcolor(gs96) /// 
        glwidth(vthin) /// 
        glpattern(dot)) /// 
    xtitle("") ///
    legend(rows(2) ///
		cols(3) ///
		size(vlarge) ///
		region(lcolor(white) lwidth(none)) ///
		position(6) ///
		bmargin(small)) ///
    graphregion(color(white) margin(medium)) ///
    plotregion(margin(medlarge medlarge medlarge medlarge)) ///
	xmtick(#400, tlength(.05cm))
	graph export "${graphs}/government_finances.eps", replace

********************************************************************************		
* Plot money and interest rate variables
local vars "M0 M1 M2 M3 strate ltrate cbrate"
label variable M0 "Money supply (M0)"
label variable M1 "Money supply (M1)"
label variable M2 "Money supply (M2)"
label variable M3 "Money supply (M3)"
label variable strate "Short-term interest rate"
label variable ltrate "Long-term interest rate"
label variable cbrate "Central bank policy rate"


keep if year <= 2020

* Plot
line `vars' year, ///
    lwidth(thick) ///
    lpattern(solid solid solid solid solid) ///
    lcolor(navy crimson forest_green gold purple) ///
    ylabel(0(20)100, ///
        angle(0) ///
        labsize(5) ///
        grid ///
        glcolor(gs96) ///
        glwidth(vthin) ///
        glpattern(dot) /// 
        format(%3.0f)) ///
    xlabel(1900(20)2020, ///
        angle(0) ///
        labsize(5) ///
        grid ///
        glcolor(gs96) /// 
        glwidth(vthin) /// 
        glpattern(dot)) /// 
    xtitle("") ///
    legend(rows(4) ///
        size(vlarge) ///
        region(lcolor(white) lwidth(none)) ///
        position(6) ///
        bmargin(small)) ///
    graphregion(color(white) margin(medium)) ///
    plotregion(margin(medlarge medlarge medlarge medlarge)) ///
	xmtick(#400, tlength(.05cm))
	graph export "${graphs}/Money_Rates.eps", replace

********************************************************************************		
* Plot National accounts
local vars "cons inv finv exports imports CA_GDP"
label variable cons "Consumption"
label variable inv "Gross capital formation"
label variable finv "Gross fixed capital formation"
label variable exports "Exports"
label variable imports "Imports"
label variable CA_GDP "Current account"

keep if year <= 2020

* Plot
line `vars' year, ///
    lwidth(thick) ///
    lpattern(solid solid solid solid solid) ///
    lcolor(navy crimson forest_green gold purple) ///
    ylabel(0(20)100, ///
        angle(0) ///
        labsize(5) ///
        grid ///
        glcolor(gs96) ///
        glwidth(vthin) ///
        glpattern(dot) /// 
        format(%3.0f)) ///
    xlabel(1900(20)2020, ///
        angle(0) ///
        labsize(5) ///
        grid ///
        glcolor(gs96) /// 
        glwidth(vthin) /// 
        glpattern(dot)) /// 
    xtitle("") ///
    legend(rows(3) ///
        size(vlarge) ///
        region(lcolor(white) lwidth(none)) ///
        position(6) ///
        bmargin(small)) ///
    graphregion(color(white) margin(medium)) ///
    plotregion(margin(medlarge medlarge medlarge medlarge)) ///
	xmtick(#400, tlength(.05cm))
	graph export "${graphs}/National_accounts_gdp.eps", replace

********************************************************************************		
* Plot Prices and Exchange rates
local vars "infl USDfx REER HPI unemp"
label variable unemp "Unemployment rate"
label variable REER "Real effective exchange rate"
label variable USDfx "USD exchange rate"
label variable infl "Inflation"
label variable HPI "House price index"

keep if year <= 2020

* Plot
line `vars' year, ///
    lwidth(thick) ///
    lpattern(solid solid solid solid solid) ///
    lcolor(navy crimson forest_green gold purple) ///
    ylabel(0(20)100, ///
        angle(0) ///
        labsize(5) ///
        grid ///
        glcolor(gs96) ///
        glwidth(vthin) ///
        glpattern(dot) /// 
        format(%3.0f)) ///
    xlabel(1900(20)2020, ///
        angle(0) ///
        labsize(5) ///
        grid ///
        glcolor(gs96) /// 
        glwidth(vthin) /// 
        glpattern(dot)) /// 
    xtitle("") ///
    legend(rows(3) ///
        size(vlarge) ///
        region(lcolor(white) lwidth(none)) ///
        position(6) ///
        bmargin(small)) ///
    graphregion(color(white) margin(medium)) ///
    plotregion(margin(medlarge medlarge medlarge medlarge)) ///
	xmtick(#400, tlength(.05cm))
	graph export "${graphs}/Prices_labor.eps", replace
	
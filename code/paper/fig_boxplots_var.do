* ==============================================================================
* Global Macro DATABASE
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
*
* FIGURE SHOWING TYPICAL NUMBER OF SOURCES PER VARIABLE 
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

use "$data_final/clean_data_wide", clear

ren OECD_HPI OECD_EO_HPI
ren WB_CC_infl WBCC_infl
drop *rHPI
keep if inlist(year, 1900, 1950, 1980, 2008)

* Make WEO name shorter 
ren IMF_WEO_forecast_* WEO_fcst_*

* Reshape into a long dataset
reshape long ADB_ AFDB_ AFRISTAT_ AHSTAT_ AMF_ BARRO_ BCEAO_ BG_ BIS_ BORDO_ BRUEGEL_ CEPAC_ DALLASFED_ Davis_ EUS_ FLORA_ FRANC_ZONE_ FZ_ GNA_ Gapminder_ Grimm_ HFS_ Homer_Sylla_ IDCM_ IHD_ IMF_FPP_ IMF_GDD_ IMF_GFS_ IMF_HDD_ IMF_IFS_ IMF_MFS_ IMF_WEO_ WEO_fcst_ JO_ JORVEN_ JST_ MAD_ MD_ Mitchell_ MOXLAD_ MW_ NBS_ OECD_EO_  OECD_KEI_ OECD_MEI_ OECD_QNA_ OECD_REV_ PWT_ OECD_MEI_ARC_  RR_ RR_debt_ FAO_ TH_ID_ Tena_ UN_ WDI_ WDI_ARC_ CS1_ CS2_ CS3_ AMECO_ LUND_ Schmelzing_ CLIO_ BIT_ ILO_ WBCC_ UN_trade_, i(ISO3 year) j(variable) string

* Rename the variables
qui ds ISO3 year variable, not
foreach var in `r(varlist)'{
	qui ren `var' data_`var'
}

* Reshape again
greshape long data, i(ISO3 year variable) j(source) string

* Drop rows with no data
drop if data == .

replace variable = subinstr(variable, "_USD", "", .) if strpos(variable, "exports")
replace variable = subinstr(variable, "_USD", "", .) if strpos(variable, "imports")

* Make dummy for available data 
replace data = 1 if data !=.

* Find a variable's total number of sources by period and country
bysort variable year ISO3: egen num_sources = nvals(source)
bysort variable year ISO3: keep if _n == 1

* Keep relevant variables
keep if inlist(variable, "CA_GDP", "HPI", "M0", "M1", "M2", "M3", "rGDP", "USDfx", "cbrate") | inlist(variable, "govdebt_GDP", "govdef_GDP", "govexp", "govrev", "govtax", "imports", "infl", "inv", "ltrate") | inlist(variable, "cons", "rcons", "exports", "finv", "strate", "unemp", "nGDP", "REER", "pop")


* Create more readable labels for all variables
gen      varname = "Short-term interest rate" if variable == "strate"
replace varname = "Long-term interest rate" if variable == "ltrate"
replace varname = "Central bank policy rate" if variable == "cbrate"
replace varname = "Total money" if variable == "M3"
replace varname = "Broad money" if variable == "M2"
replace varname = "Narrow money" if variable == "M1"
replace varname = "Base money" if variable == "M0"
replace varname = "Real GDP" if variable == "rGDP"
replace varname = "Nominal GDP" if variable == "nGDP"
replace varname = "Current account" if variable == "CA_GDP"
replace varname = "Exports" if variable == "exports"
replace varname = "Imports" if variable == "imports"
replace varname = "Government revenue" if variable == "govrev"
replace varname = "Government tax revenue" if variable == "govtax"
replace varname = "Government expenditure" if variable == "govexp"
replace varname = "Government debt" if variable == "govdebt_GDP"
replace varname = "Government deficit" if variable == "govdef_GDP"
replace varname = "House Price Index" if variable == "HPI"
replace varname = "Gross fixed capital formation" if variable == "finv"
replace varname = "Gross capital formation" if variable == "inv"
replace varname = "Unemployment rate" if variable == "unemp"
replace varname = "Inflation rate" if variable == "infl"
replace varname = "Real consumption" if variable == "rcons"
replace varname = "Consumption" if variable == "cons"
replace varname = "Real effective exchange rate" if variable == "REER"
replace varname = "US dollar exchange rate" if variable == "USDfx"
replace varname = "Population" if variable == "pop"
drop if substr(varname, -4, .) == "_GDP"

* Box plot
levelsof variable, local(vars) clean
foreach var of local vars {
    preserve
    keep if variable == "`var'"  
	qui levelsof varname if variable == "`var'"
	local full_name = `r(levels)'
    graph box num_sources, over(year) ///
        ylabel(, ///
            angle(0) ///
            nogrid ///
            glcolor(gs90) ///
            glpattern(solid) ///
            glwidth(thin) ///
            format(%2.0f) ///
			labsize(5.5) ///
        ) ///
        ytitle("", size(medium)) ///
        box(1, color("230 238 249") fintensity(100) lcolor("43 91 132")) ///
        medline(lcolor("227 66 52") lwidth(thick)) ///
        marker(1, mcolor("43 91 132") msymbol(circle) msize(small)) ///
        yline(0, lstyle(none)) ///
        graphregion(color(white) margin(medium)) ///
        plotregion(margin(zero)) ///
        bgcolor(white) ///
        scheme(s2color) ///
        note("") legend(off)
		
		graph export "${graphs}/Boxplot_`var'.eps", replace

    restore
}

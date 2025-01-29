* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* A SIMPLE PROGRAM TO DOCUMENT THE DATA SOURCES 
* 
* Description: 
* This Stata program takes the combined country-year panel in long format and 
* uses the 'source' variable to generate a documentation of sources.
* 
* Created: 
* 2024-06-28
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 	
* ==============================================================================

* ==============================================================================
* DEFINE PROGRAM SYNTAX --------------------------------------------------------
* ==============================================================================

cap program drop gmdmakeplot_cs
program define gmdmakeplot_cs
syntax varlist (min=1), [log YLABel(string) TRANSFormation(string) GRAPHFormat(string) Y_axislabel(string)]


* Set up the font for the graphs
graph set window fontface "Times New Roman"

* ==============================================================================
* SET UP PANEL -----------------------------------------------------------------
* ==============================================================================
set graphics off
* Set panel
encode ISO3, gen(id)
qui xtset id year

* If panel is set, put panel and time variables into locals 
loc timevar = r(timevar)
loc panelvar = r(panelvar)

* Merge in country name
qui merge m:1 ISO3 using "$data_helper/countrylist", keepus(countryname) assert(2 3) nogen 

* Add source change if there is none
cap gen source_change = .

* Set default graph format if not specified
if "`graphformat'" == "" {
    local graphformat "pdf"
}

* Validate graph format
if !inlist("`graphformat'", "pdf", "eps", "png", "tif", "gif", "jpg") {
    di as error "Invalid graph format. Supported formats are: pdf, eps, png, tif, gif, jpg"
    exit 198
}



* ==============================================================================
* GENERATE TIME SERIES PLOTS COMPARING ALL -------------------------------------
* ==============================================================================

* Delete all columns labels
foreach var of varlist _all {
    label variable `var' ""
}

* Loop over countries with non-missing data for this variable 
qui levelsof ISO3 if `varlist'!=., clean local(countries)

foreach iso of loc countries {

	* Preserve, only keep relevant country for now 
	preserve 
	qui keep if ISO3 == "`iso'"
	
	* Make variable in logs if option is specified 
	if "`log'" != "" {
			
		qui ds *`varlist'
		foreach var in `r(varlist)'{
			qui replace `var' = log10(`var') if `var' != .
		}
			* Calculate exact y-axis range
			qui egen row_min = rowmin(*`varlist')
			qui egen row_max = rowmax(*`varlist')
			qui su row_min
			local y_min = r(min) * 0.9
			qui su row_max 
			local y_max = r(max) * 1.2
			local exp_min = floor(`y_min')
			local exp_max = ceil(`y_max') 
			local exp_step = ceil((`exp_max' - `exp_min')/5)
			qui mylabels `exp_min'(`exp_step')`exp_max', myscale(10^(@)) clean local(ylabels)
			local n_labels : word count `ylabels'
			local y_min : word 1 of `ylabels'
			* Extract shaded area minimum value
			local area_min = `y_min'
			
			qui mylabels `exp_min'(`exp_step')`exp_max', clean local(ylabels)
			* Drop 
			qui drop row_max row_min
	}
	
	else {
		qui su `varlist'
		local exp_max = r(max)
		local exp_min = r(min)
	}
	
	if "`y_axislabel'" == "" {
		di "Using labels"
	}
	else {
		local ylabels `y_axislabel'
	}
		
	* Get first and last year for plot
	qui tempvar nonmiss
	qui egen `nonmiss' = rownonmiss(*`varlist')
	qui sum year if `nonmiss' > 0
	loc ymin = r(min)
	loc ymax = r(max)
	drop `nonmiss'
	
	* Only keep relevant years 
	qui keep if inrange(year,`ymin',`ymax')	
	
	* Delete all columns labels
	foreach var of varlist _all {
		label variable `var' ""
	}

	* Get first and last year for plot with floor and ceilings for better visualization
	qui tempvar nonmiss
	qui egen `nonmiss' = rownonmiss(*`varlist')
	qui sum year if `nonmiss' > 0
	loc ymin = floor(r(min)/10) * 10
	loc ymax = ceil(r(max)/10) * 10
	drop `nonmiss'
	
	* Count the number of rows for the graph labels
	qui describe, short
	local nvars = r(k)
	if `nvars' < 8 {
	local legend_layout "legend(size(small) region(lstyle(none) lwidth(none) lpattern(dot)) position(12) cols(`nvars') keygap(1))"
	}
	
	else {
		* Calculate number of columns needed for even distribution
		local cols = ceil(`nvars'/2)  
		local legend_layout "legend(size(small) region(lstyle(none) lwidth(none) lpattern(dot)) position(12) rows(3) cols(`cols') keygap(1))"
	}
	
	* Make scatter plot with all variables 
	sort year 
	
	* Remove the variable identifier from column names
	qui ds ISO3 year id source source_change `varlist' countryname chainlinking_ratio, not
	foreach var in `r(varlist)'{
		local newname = substr("`var'", 1, strpos("`var'", "_`varlist'") - 1)
		qui ren `var' `newname'
	}
	
	* Label columns with underscore in their names 
	qui ds ISO3 year id source source_change `varlist' countryname chainlinking_ratio, not
	foreach var in `r(varlist)'{
    if strpos("`var'", "_") > 0 {
        local label = subinstr("`var'", "_", " ", .)
        label variable `var' "`label'"
		
		}
	}
	
	* Define the y-axis label
	local y_label_text "`label'"
	if "`ylabel'" != "" {
		local y_label_text "`ylabel'"
	}
	
	* Define the x axis increments
	qui su year 
	if r(N) <= 100 {
		local increment = 10
	}
	if r(N) > 100 & r(N) <= 200 {
		local increment = 20
	}
	if r(N) > 200 {
		local increment = 30
	}
	
	* Set up the colors for the plots
	local colors navy maroon forest_green purple brown olive_teal blue teal orange
	local color_list: word count `colors'
	
	* Drop columns with no data
	qui ds ISO3 year id source source_change `varlist' countryname chainlinking_ratio, not
	qui missings dropvars `r(varlist)', force

	* Create a scatter plot for each variable
	qui ds ISO3 year id source source_change `varlist' countryname chainlinking_ratio, not
	local scatter_plot
	local counter = 0
	foreach var in `r(varlist)' {
		
		* Set the color
		local color_index = mod(`counter', `color_list') + 1
		local current_color: word `color_index' of `colors'
		local c_color = "`current_color'%70"
		* Add an offset to the year axis
		qui local scatter_plot `scatter_plot' (scatter `var' year if inrange(year,`ymin',`ymax'), msymbol(circle) msize(small) mcolor(`c_color') jitter(1) mlwidth(vvthin))
		local counter = `counter' + 1
	}

	* Create temporary variable for area_max
	tempvar area_max
	qui gen `area_max' = `exp_max' if year >= 2024
	qui sum `area_max' 
	local has_data = r(N)
	
	* Label the columns
	label variable `area_max'  "GMD forecast"
	label variable `varlist'   "GMD estimate"
	
	* Order
	order ISO3 year `area_max' `varlist'

	* Extracts the vertical lines year using source_change
	qui su source_change
	if r(N) > 0 {	
		* Source changes
		qui levelsof year if source_change == 1, local(xlevels)
		* Plot the graphs together
	    twoway ///
		(area `area_max' year if year >= 2024 & `has_data' > 0, color(gs14) base(`area_min')) /// Shaded area for provisional data
		(line `varlist' year, lwidth(medium) lcolor(black)) `scatter_plot' /// 
		   if inrange(year,`ymin',`ymax'), ///
		   graphregion(color(white)) plotregion(color(white) margin(zero)) ///
		   ylabel(`ylabels', ///
				  format(%12.0f) angle(0) labsize(3) nogrid ///
				  labcolor(black) tlcolor(black) tlength(.1cm)) ///
		   ytitle("`y_label_text'", size(small) margin(medium)) ///
		   `legend_layout' ///
		   xlabel(`ymin'(`increment')`ymax', labsize(3.5) nogrid tlength(.1cm) angle(90)) ///
		   xmtick(##`increment', tlength(.05cm)) ///
		   xtitle("") ///
		   xline(`xlevels', lwidth(thin) lpattern(solid)) 
		   
		graph export "${graphs}/`iso'_`varlist'.`graphformat'", replace 
		
	}

	* Restore
	restore
}
set graphics on

end

* ==============================================================================
* GLOBAL MACRO DATABASE
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

cap program drop gmdmakedoc
program define gmdmakedoc
syntax varlist (min=1), [log YLABel(string) TRANSFormation(string) GRAPHFormat(string)]

* Set up the font for the graphs
graph set window fontface "Times New Roman"

* ==============================================================================
* SET UP PANEL -----------------------------------------------------------------
* ==============================================================================

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

* Set graphics off
set graphics off

* Loop over countries with non-missing data for this variable 
qui levelsof ISO3 if `varlist'!=., clean local(countries)

foreach iso of loc countries {

	* Preserve, only keep relevant country for now 
	preserve 
	qui keep if ISO3 == "`iso'"
	
	* Get first and last year for plot
	qui tempvar nonmiss
	qui egen `nonmiss' = rownonmiss(*`varlist')
	qui sum year if `nonmiss' > 0
	loc ymin = r(min)
	loc ymax = r(max)
	drop `nonmiss'
	
	* Only keep relevant years 
	qui keep if inrange(year,`ymin',`ymax')
	
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
			
			* Drop 
			qui drop row_max row_min
	}

	di as txt "Exporting time series plot for `iso'"
	
	if "`transformation'" == "rate" {
	
			* Calculate exact y-axis range
			* Reshape to find the minimum vand the maximum values across all variables.
			qui egen row_min = rowmin(*`varlist')
			qui egen row_max = rowmax(*`varlist')
			qui su row_min
			local exp_min = floor(r(min)/10) * 10 
			qui su row_max 
			local exp_max = ceil(r(max)/10) * 10 
			qui nicelabels `exp_min' `exp_max', local(ylabels) nvals(7)
			local n_labels : word count `ylabels'
			local y_max : word `n_labels' of `ylabels'
			local y_min : word 1 of `ylabels'
			
			* Extract shaded area minimum value
			local area_min = `exp_min'
			
			* Drop 
			qui drop row_max row_min
		
	}
	
	if "`transformation'" == "ratio" {
			
			* Calculate exact y-axis range
			* Reshape to find the minimum vand the maximum values across all variables.
			qui egen row_min = rowmin(*`varlist')
			qui egen row_max = rowmax(*`varlist')
			qui su row_min
			local exp_min = floor(r(min)/10) * 10 
			qui su row_max 
			local exp_max = ceil(r(max)/10) * 10 
			qui nicelabels `exp_min' `exp_max', local(ylabels) nvals(5)
			local n_labels : word count `ylabels'
			local y_max : word `n_labels' of `ylabels'
			local y_min : word 1 of `ylabels'
			
			* Extract shaded area minimum value
			local area_min = `exp_min'
			
			* Drop 
			qui drop row_max row_min
	}
	
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
	
	* Extract the forecast year
	qui su year if strpos(source, "forecast")
	if r(N) > 0 {
		local forecast_year = r(min)
	}
	else {
		local current_year = year(date(c(current_date), "DMY"))
		local forecast_year = `current_year' + 1
	}

	* Create temporary variable for area_max
	tempvar area_max
	qui gen `area_max' = `exp_max' if year >= `forecast_year'
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
		qui twoway ///
		(area `area_max' year if year >= `forecast_year' & `has_data' > 0, color(gs14) base(`area_min')) /// Shaded area for provisional data
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
		   
		qui graph export "$doc/graphs/`iso'_`varlist'.`graphformat'", replace 
		
	}

	else {
		* Plot the graphs together
		qui twoway ///
		(line `varlist' year, lwidth(medium) lcolor(black)) `scatter_plot' ///
		   if inrange(year,`ymin',`ymax'), ///
		   graphregion(color(white)) plotregion(color(white) margin(zero)) ///
		   ylabel(`ylabels', ///
				  format(%9.0f) angle(0) labsize(3) nogrid ///
				  labcolor(black) tlcolor(black) tlength(.1cm)) ///
		   ytitle("`y_label_text'", size(small) margin(medium)) ///
			`legend_layout' ///
		   xlabel(`ymin'(`increment')`ymax', labsize(3.5) nogrid tlength(.1cm) angle(90)) ///
		   xtitle("") ///
		   xmtick(##`increment', tlength(.05cm))
		   
		qui graph export "$doc/graphs/`iso'_`varlist'.`graphformat'", replace
	}

	* Restore
	restore
}

* Set graphics back on if they were turned off 
set graphics on


* ==============================================================================
* IDENTIFY SPELLS OF SOURCES USED IN THE DATA SET ------------------------------
* ==============================================================================

* Make indicator for non-missing observations following a missing one 
sort id year
tempvar newsource
by `panelvar': gen `newsource' = cond(source!=source[_n-1],1,0)

* Make number of spells 
sort id year
tempvar counter
by `panelvar': gen `counter' = sum(`newsource')

* Make final source number variable 
qui gen sourcenum = 1 if source!=""
qui replace sourcenum = sourcenum + `counter' if source!=""


* ==============================================================================
* FOR EACH SPELL, MAKE YEAR RANGE VARIABLE 
* ==============================================================================

* Get variable label 
local header: variable label `varlist'

* Get start and end dates for each spell of data 
qui bysort `panelvar' sourcenum: egen startyear = min(`timevar')
qui bysort `panelvar' sourcenum: egen endyear   = max(`timevar')

* Make string with date range 
qui gen range = string(startyear) + " - " + string(endyear)

* Only keep relevant information 
qui duplicates drop country sourcenum, force
qui drop if source == ""
qui replace source = subinstr(source, "_`varlist'", "", .)
qui keep ISO3 countryname range source chainlinking_ratio
qui replace chainlinking_ratio = chainlinking_ratio * 100

* Create notes column
format chainlinking_ratio %9.1f
qui gen x1 = round(chainlinking_ratio, 0.1)
qui gen start_year = substr(range, 1, 4)
qui gen end_year   = substr(range, -4, .)
qui destring *_year, replace
qui gen notes = ""
quietly {
    gen base_overlap = (start_year <= 2018 & end_year > 2018)
    replace notes = "Baseline source, overlaps with base year 2018." if base_overlap == 1
    replace notes = "Spliced using overlapping data in " + string(end_year + 1) + "." if base_overlap == 0 & x1 == 100
    replace notes = "Spliced using overlapping data in " + string(end_year + 1) + ": (ratio = " + string(x1) + "\%)." if base_overlap == 0 & x1 != 100   
    drop base_overlap
}
qui keep countryname range notes source ISO3

* Generate source id
qui gen source_id = ""
qui replace source_id = source + "_" + ISO3 if strpos(source, "CS")
qui replace source_id = source if source_id == ""
qui replace source = "\cite{" + source_id + "}"
qui drop source_id 


* Make tiny countries appear last
qui merge m:1 ISO3 using "$data_helper/countrylist", keepus(tiny) keep(1 3) nogen 

* ==============================================================================
* GENERATE TEX REPORT 
* ==============================================================================
capture file close mytex
file open mytex using "$doc/`varlist'.tex", write replace

* Add varname 
local varname ""
if "`varlist'" == "nGDP" local varname "Nominal Gross Domestic Product"
else if "`varlist'" == "rGDP" local varname "Real Gross Domestic Product"
else if "`varlist'" == "rcons" local varname "Real Consumption"
else if "`varlist'" == "cons" local varname "Consumption"
else if "`varlist'" == "cons_GDP" local varname "Consumption to GDP"
else if "`varlist'" == "inv" local varname "Gross Capital Formation"
else if "`varlist'" == "inv_GDP" local varname "Gross Capital Formation to GDP"
else if "`varlist'" == "finv" local varname "Gross Fixed Capital Formation"
else if "`varlist'" == "finv_GDP" local varname "Gross Fixed Capital Formation to GDP"
else if "`varlist'" == "pop" local varname "Population"
else if "`varlist'" == "exports_GDP" local varname "Exports to GDP"
else if "`varlist'" == "imports_GDP" local varname "Imports to GDP"
else if "`varlist'" == "exports" local varname "Exports"
else if "`varlist'" == "imports" local varname "Imports"
else if "`varlist'" == "CA_GDP" local varname "Current Account"
else if "`varlist'" == "USDfx" local varname "USD Exchange Rate"
else if "`varlist'" == "REER" local varname "Real Effective Exchange Rate"
else if "`varlist'" == "govtax" local varname "Government Tax Revenue"
else if "`varlist'" == "govtax_GDP" local varname "Government Tax Revenue to GDP"
else if "`varlist'" == "govexp" local varname "Government Expenditure"
else if "`varlist'" == "govexp_GDP" local varname "Government Expenditure to GDP"
else if "`varlist'" == "govdef_GDP" local varname "Government Deficit"
else if "`varlist'" == "govdebt_GDP" local varname "Government Debt"
else if "`varlist'" == "govrev" local varname "Government Revenue"
else if "`varlist'" == "govrev_GDP" local varname "Government Revenue to GDP"
else if "`varlist'" == "M0" local varname "Money Supply (M0)"
else if "`varlist'" == "M1" local varname "Money Supply (M1)"
else if "`varlist'" == "M2" local varname "Money Supply (M2)"
else if "`varlist'" == "M3" local varname "Money Supply (M3)"
else if "`varlist'" == "M4" local varname "Money Supply (M4)"
else if "`varlist'" == "cbrate" local varname "Central Bank Policy Rate"
else if "`varlist'" == "strate" local varname "Short-term Interest Rate"
else if "`varlist'" == "ltrate" local varname "Long-term Interest Rate"
else if "`varlist'" == "CPI" local varname "Consumer Prices Index"
else if "`varlist'" == "HPI" local varname "House Prices Index"
else if "`varlist'" == "infl" local varname "Inflation"
else if "`varlist'" == "unemp" local varname "Unemployment"

* Write LaTeX preamble
file write mytex "\documentclass[12pt,a4paper,landscape]{article}" _n
file write mytex "\usepackage[utf8]{inputenc}" _n
file write mytex "\usepackage[T1]{fontenc}" _n
file write mytex "\usepackage{graphicx}" _n
file write mytex "\usepackage{booktabs}" _n
file write mytex "\usepackage[margin=0.5in, top=0.5in, headsep=0.1in, paperheight=16in, paperwidth=11in]{geometry}" _n
file write mytex "\usepackage{caption}" _n
file write mytex "\usepackage{float}" _n
file write mytex "\usepackage[authoryear,round]{natbib}" _n
file write mytex "\usepackage{xcolor}" _n
file write mytex "\usepackage{colortbl}" _n
file write mytex "\usepackage{rotating}" _n
file write mytex "\usepackage{tabularx}" _n
file write mytex "\usepackage{pdflscape}" _n
file write mytex "\usepackage{adjustbox}" _n
file write mytex "\usepackage{times}" _n
file write mytex "\usepackage{array}" _n
file write mytex "\usepackage{fancyhdr}" _n
file write mytex "\usepackage[colorlinks=true, allcolors=blue]{hyperref}" _n _n

* Add fancy header setup
file write mytex "% Setup fancy headers" _n
file write mytex "\fancypagestyle{mainStyle}{%" _n
file write mytex "    \fancyhf{}" _n
file write mytex "    \renewcommand{\headrulewidth}{0pt}" _n
file write mytex "    \fancyhead[R]{\footnotesize\hyperref[toc]{Back to contents}}" _n
file write mytex "}" _n _n
file write mytex "\pagestyle{mainStyle}" _n _n

* Add custom commands for our needs
file write mytex "\newcommand{\countryheader}[2]{\large\bfseries\hyperref[#1]{#2}}" _n
file write mytex "\captionsetup[table]{labelformat=empty}" _n
file write mytex "\definecolor{lightgray}{gray}{0.85}" _n _n

* Write initial pages
file write mytex "\begin{document}" _n
file write mytex "\title{\Large `varname'}" _n
file write mytex "\date{" `"`=string(date(c(current_date),"DMY"),"%tdMonth_DD,_CCYY")'"' "}" _n
file write mytex "\maketitle" _n
file write mytex "\thispagestyle{empty}" _n _n

* Add TOC with hyperlinks
file write mytex "\clearpage" _n
file write mytex "\setcounter{page}{1}" _n
file write mytex "\hypersetup{colorlinks=true,linkcolor=blue,linktoc=all}" _n
file write mytex "\phantomsection" _n 
file write mytex "\label{toc}" _n   
file write mytex "\tableofcontents" _n
file write mytex "\thispagestyle{empty}" _n 

* Initialize page counter
file write mytex "\setcounter{page}{3}" _n

* Loop over non-tiny countries 
qui glevelsof countryname if tiny == 0, local(countries)
foreach country of local countries {
	preserve
	qui keep if countryname == "`country'"  & tiny == 0
	
	local country_name = countryname[1]
	local country_code = ISO3[1]

	* Create a single page container
	file write mytex "\begin{adjustbox}{max totalsize={\paperwidth}{\paperheight},center}" _n
	file write mytex "\begin{minipage}[t][\textheight][t]{\textwidth}" _n
	
	* Add country header with proper spacing
	file write mytex "\vspace*{0.5cm}" _n
	file write mytex "\phantomsection" _n
	file write mytex "\addcontentsline{toc}{section}{`country_name'}" _n
	file write mytex "\begin{center}" _n
	file write mytex "{\Large\bfseries `country_name'}" _n
	file write mytex "\end{center}" _n
	file write mytex "\vspace{0.5cm}" _n
	
	* Table with adjusted size
	file write mytex "\begin{table}[H]" _n
	file write mytex "\centering" _n
	file write mytex "\small" _n 
	file write mytex "\begin{tabular}{|l|l|l|}" _n
	file write mytex "\hline" _n
	file write mytex "\textbf{Source} & \textbf{Time span} & \textbf{Notes} \\" _n
	file write mytex "\hline" _n
	
	* Table content
	qui levelsof range, local(ranges)
	local color_toggle = 0
	
	foreach rng of local ranges {
		qui levelsof source if range == "`rng'"
		local src = r(levels)
		qui levelsof notes if range == "`rng'"
		local note = r(levels)
		
		if `color_toggle' == 0 {
			file write mytex "\rowcolor{white}"
			local color_toggle = 1
		}
		else {
			file write mytex "\rowcolor{lightgray}"
			local color_toggle = 0
		}
		
		cap file write mytex `src' "& `rng' &" `note' "\\" _n
	}
	
	* Close table
	file write mytex "\hline" _n
	file write mytex "\end{tabular}" _n
	file write mytex "\end{table}" _n
	
	* Graph with dynamic sizing
	file write mytex "\begin{figure}[H]" _n
	file write mytex "\centering" _n
	file write mytex "\includegraphics[width=\textwidth,height=0.6\textheight,keepaspectratio]{graphs/`country_code'_`varlist'.`graphformat'}" _n
	file write mytex "\end{figure}" _n
	
	* Close the single page container
	file write mytex "\end{minipage}" _n
	file write mytex "\end{adjustbox}" _n
	
	restore
}


* Loop over non-tiny countries 
count if tiny == 1
if r(N) > 0 {
		qui glevelsof countryname if tiny == 1, local(countries)
		foreach country of local countries {
		preserve
		qui keep if countryname == "`country'"  & tiny == 1
		
		local country_name = countryname[1]
		local country_code = ISO3[1]

		* Create a single page container
		file write mytex "\begin{adjustbox}{max totalsize={\paperwidth}{\paperheight},center}" _n
		file write mytex "\begin{minipage}[t][\textheight][t]{\textwidth}" _n
		
		* Add country header with proper spacing
		file write mytex "\vspace*{0.5cm}" _n
		file write mytex "\phantomsection" _n
		file write mytex "\addcontentsline{toc}{section}{`country_name'}" _n
		file write mytex "\begin{center}" _n
		file write mytex "{\Large\bfseries `country_name'}" _n
		file write mytex "\end{center}" _n
		file write mytex "\vspace{0.5cm}" _n
		
		* Table with adjusted size
		file write mytex "\begin{table}[H]" _n
		file write mytex "\centering" _n
		file write mytex "\small" _n 
		file write mytex "\begin{tabular}{|l|l|l|}" _n
		file write mytex "\hline" _n
		file write mytex "\textbf{Source} & \textbf{Time span} & \textbf{Notes} \\" _n
		file write mytex "\hline" _n
		
		* Table content
		qui levelsof range, local(ranges)
		local color_toggle = 0
		
		foreach rng of local ranges {
			qui levelsof source if range == "`rng'"
			local src = r(levels)
			qui levelsof notes if range == "`rng'"
			local note = r(levels)
			
			if `color_toggle' == 0 {
				file write mytex "\rowcolor{white}"
				local color_toggle = 1
			}
			else {
				file write mytex "\rowcolor{lightgray}"
				local color_toggle = 0
			}
			
			cap file write mytex `src' "& `rng' &" `note' "\\" _n
		}
		
		* Close table
		file write mytex "\hline" _n
		file write mytex "\end{tabular}" _n
		file write mytex "\end{table}" _n
		
		* Graph with dynamic sizing
		file write mytex "\begin{figure}[H]" _n
		file write mytex "\centering" _n
		file write mytex "\includegraphics[width=\textwidth,height=0.6\textheight,keepaspectratio]{graphs/`country_code'_`varlist'.`graphformat'}" _n
		file write mytex "\end{figure}" _n
		
		* Close the single page container
		file write mytex "\end{minipage}" _n
		file write mytex "\end{adjustbox}" _n
		
		restore
	}
}

else {
	di "No tiny countries in the list"
}


* References section
file write mytex "\phantomsection" _n
file write mytex "\addcontentsline{toc}{section}{References}" _n
file write mytex "\begin{center}" _n
file write mytex "{\Large\bfseries References}" _n
file write mytex "\end{center}" _n
file write mytex "\small" _n
file write mytex "\bibliographystyle{plainnat}" _n
file write mytex "\bibliography{bib}" _n
file write mytex "\end{document}" _n

* Close the LaTeX file
file close mytex
end

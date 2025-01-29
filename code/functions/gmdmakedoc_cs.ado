* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* A SIMPLE PROGRAM TO DOCUMENT THE DATA SOURCES FOR EACH COUNTRY
* 
* Description: 
* This Stata program takes the combined documentation generated in the gmdmakedoc to generate a country specific documentation
* 
* Created: 
* 2025-01-20
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 	
* ==============================================================================

* ==============================================================================
* DEFINE PROGRAM SYNTAX --------------------------------------------------------
* ==============================================================================

cap program drop gmdmakedoc_cs
program define gmdmakedoc_cs

* ==============================================================================
* GENERATE TEX REPORT 
* ==============================================================================

qui glevelsof ISO3, local(isos) clean
foreach iso of local isos {

	capture file close mytex
	capture file open mytex using "$doc/`iso'.tex", write replace
	* Write LaTeX preamble
	file write mytex "\documentclass[12pt,a4paper,landscape]{article}" _n
	file write mytex "\usepackage[utf8]{inputenc}" _n
	file write mytex "\usepackage[T1]{fontenc}" _n
	file write mytex "\usepackage{graphicx}" _n
	file write mytex "\usepackage{booktabs}" _n
	file write mytex "\usepackage[margin=0.5in, top=0.5in, headsep=0.1in]{geometry}" _n
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
	file write mytex "    \fancyhead[R]{\footnotesize\hyperref[toc]{Back to Contents}}" _n
	file write mytex "}" _n _n
	file write mytex "\pagestyle{mainStyle}" _n _n

	* Add custom commands for our needs
	file write mytex "\newcommand{\countryheader}[2]{\large\bfseries\hyperref[#1]{#2}}" _n
	file write mytex "\captionsetup[table]{labelformat=empty}" _n
	file write mytex "\definecolor{lightgray}{gray}{0.85}" _n _n
	
	* Get country name
	qui levelsof countryname if ISO3 == "`iso'", clean
	local cname = r(levels)

	* Write initial pages
	file write mytex "\begin{document}" _n
	file write mytex "\title{\Large Country Data and Graphs for `cname'}" _n
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
	
	
	* Add the heatmap:
	file write mytex "\clearpage" _n
	file write mytex "\phantomsection" _n
	file write mytex "\addcontentsline{toc}{section}{Data availability heatmap}" _n
	file write mytex "\begin{center}" _n
	file write mytex "{\Large\bfseries Data availability heatmap}" _n
	file write mytex "\end{center}" _n
	file write mytex "\vspace{1cm}" _n
	file write mytex "\begin{figure}[H]" _n
	file write mytex "\centering" _n
	file write mytex "\includegraphics[width=\textwidth,height=0.8\textheight,keepaspectratio]{graphs/`iso'_heatmap.pdf}" _n
	file write mytex "\end{figure}" _n

	* Initialize page counter
	file write mytex "\setcounter{page}{3}" _n
	sort variable range
	qui glevelsof variable if ISO3 == "`iso'", local(vars)
	foreach var of local vars {
		preserve
		qui keep if variable == "`var'"  & ISO3 == "`iso'"
		sort range
		local var_name = variable_definition[1]
		local country_code = ISO3[1]

		* Create a single page container
		file write mytex "\begin{adjustbox}{max totalsize={\paperwidth}{\paperheight},center}" _n
		file write mytex "\begin{minipage}[t][\textheight][t]{\textwidth}" _n
		
		* Add country header with proper spacing
		file write mytex "\vspace*{0.5cm}" _n
		file write mytex "\phantomsection" _n
		file write mytex "\addcontentsline{toc}{section}{`var_name'}" _n
		file write mytex "\begin{center}" _n
		file write mytex "{\Large\bfseries `var_name'}" _n
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
		file write mytex "\includegraphics[width=\textwidth,height=0.6\textheight,keepaspectratio]{graphs/`country_code'_`var'.pdf}" _n
		file write mytex "\end{figure}" _n
		
		* Close the single page container
		file write mytex "\end{minipage}" _n
		file write mytex "\end{adjustbox}" _n
		
		restore
	}



	* References section
	file write mytex "\phantomsection" _n
	file write mytex "\addcontentsline{toc}{section}{References}" _n
	file write mytex "\begin{center}" _n
	file write mytex "{\Large\bfseries References}" _n
	file write mytex "\end{center}" _n
	file write mytex "\small" _n
	file write mytex "\bibliographystyle{qje}" _n
	file write mytex "\bibliography{bib}" _n
	file write mytex "\end{document}" _n

	* Close the LaTeX file
	file close mytex
	}
end
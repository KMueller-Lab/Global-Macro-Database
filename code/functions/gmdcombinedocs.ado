* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* A PROGRAM TO COMBINE MULTIPLE DOCUMENTATION FILES INTO A SINGLE MASTER DOCUMENT
* 
* Created: 
* 2024-12-10
* 
* ==============================================================================
capture program drop gmdcombinedocs
program define gmdcombinedocs
    syntax anything

    * Parse input files
    local files `anything'
    
    * Initialize master tex file
    cap file close mastertex
    file open mastertex using "$doc/master.tex", write replace

    * Write master preamble with additional spacing commands
    file write mastertex "\documentclass[12pt,a4paper,landscape]{article}" _n
    file write mastertex "\usepackage[utf8]{inputenc}" _n
    file write mastertex "\usepackage[T1]{fontenc}" _n
    file write mastertex "\usepackage{graphicx}" _n
    file write mastertex "\usepackage{booktabs}" _n
    file write mastertex "\usepackage[margin=0.4in, top=0.5in, headsep=0.2in]{geometry}" _n
    file write mastertex "\usepackage{caption}" _n
    file write mastertex "\usepackage{float}" _n
    file write mastertex "\usepackage[authoryear,round]{natbib}" _n
    file write mastertex "\usepackage{xcolor}" _n
    file write mastertex "\usepackage{colortbl}" _n
    file write mastertex "\usepackage{rotating}" _n
    file write mastertex "\usepackage{tabularx}" _n
    file write mastertex "\usepackage{pdflscape}" _n
    file write mastertex "\usepackage{adjustbox}" _n
    file write mastertex "\usepackage{longtable}" _n
    file write mastertex "\usepackage{times}" _n
    file write mastertex "\usepackage{array}" _n
    file write mastertex "\usepackage{fancyhdr}" _n
    file write mastertex "\usepackage[colorlinks=true, allcolors=blue]{hyperref}" _n _n

    * Add fancy header setup
    file write mastertex "% Setup fancy headers" _n
    file write mastertex "\fancypagestyle{mainStyle}{%" _n
    file write mastertex "    \fancyhf{}" _n
    file write mastertex "    \renewcommand{\headrulewidth}{0pt}" _n
    file write mastertex "    \fancyhead[R]{\hyperref[main-toc]{Back to Main contents}}" _n
    file write mastertex "}" _n _n
    
    * Add section-specific styles for all variables
    foreach var in nGDP rGDP rcons cons inv finv exports imports CA_GDP USDfx REER ///
				   cons_GDP inv_GDP finv_GDP exports_GDP imports_GDP  ///
                   govtax govexp govdef_GDP govdebt_GDP govrev ///
				   govtax_GDP govexp_GDP govrev_GDP  ///
                   M0 M1 M2 M3 M4 cbrate strate ltrate CPI HPI infl unemp pop {
        file write mastertex "\fancypagestyle{`var'Style}{%" _n
        file write mastertex "    \fancyhf{}" _n
        file write mastertex "    \renewcommand{\headrulewidth}{0pt}" _n
        file write mastertex "    \fancyhead[R]{\hyperref[`var'-toc]{Back to " ///
        
        * Add proper variable names in the header
        if "`var'" == "nGDP" local varname "Nominal GDP"
        else if "`var'" == "rGDP" local varname "Real GDP"
		else if "`var'" == "rcons" local varname "Real consumption"
        else if "`var'" == "cons" local varname "Consumption"
		else if "`var'" == "cons_GDP" local varname "Consumption to GDP"
        else if "`var'" == "inv" local varname "Gross capital formation"
        else if "`var'" == "inv_GDP" local varname "Gross capital formation to GDP"
		else if "`var'" == "finv" local varname "Gross fixed capital formation"
		else if "`var'" == "finv_GDP" local varname "Gross fixed capital formation to GDP"
        else if "`var'" == "pop" local varname "Population"
        else if "`var'" == "exports_GDP" local varname "Exports to GDP"
        else if "`var'" == "imports_GDP" local varname "Imports to GDP"
		else if "`var'" == "exports" local varname "Exports"
        else if "`var'" == "imports" local varname "Imports"
        else if "`var'" == "CA_GDP" local varname "Current account"
        else if "`var'" == "USDfx" local varname "USD exchange rate"
        else if "`var'" == "REER" local varname "Real effective exchange rate"
        else if "`var'" == "govtax" local varname "Government tax revenue"
        else if "`var'" == "govtax_GDP" local varname "Government tax revenue to GDP"
		else if "`var'" == "govexp" local varname "Government expenditure"
		else if "`var'" == "govexp_GDP" local varname "Government expenditure to GDP"
        else if "`var'" == "govdef_GDP" local varname "Government deficit"
        else if "`var'" == "govdebt_GDP" local varname "Government debt"
        else if "`var'" == "govrev" local varname "Government revenue"
		else if "`var'" == "govrev_GDP" local varname "Government revenue to GDP"
        else if "`var'" == "M0" local varname "Money supply (M0)"
        else if "`var'" == "M1" local varname "Money supply (M1)"
        else if "`var'" == "M2" local varname "Money supply (M2)"
        else if "`var'" == "M3" local varname "Money supply (M3)"
		else if "`var'" == "M4" local varname "Money supply (M4)"
        else if "`var'" == "cbrate" local varname "Central bank policy rate"
        else if "`var'" == "strate" local varname "Short-term interest rate"
        else if "`var'" == "ltrate" local varname "Long-term interest rate"
        else if "`var'" == "CPI" local varname "Consumer prices index"
        else if "`var'" == "HPI" local varname "House prices index"
        else if "`var'" == "infl" local varname "Inflation"
        else if "`var'" == "unemp" local varname "Unemployment"
        
        file write mastertex "`varname' contents}}" _n
        file write mastertex "}" _n _n
    }

    file write mastertex "\pagestyle{mainStyle}" _n _n

    * Add custom commands
    file write mastertex "\newcommand{\countryheader}[2]{\large\bfseries\hyperref[#1]{#2}}" _n
    file write mastertex "\captionsetup[table]{labelformat=empty}" _n
    file write mastertex "\definecolor{lightgray}{gray}{0.85}" _n _n

    * Start document
    file write mastertex "\begin{document}" _n
    
    * Title page
    file write mastertex "\title{\Large Global Macro Project: Data Documentation}" _n
    file write mastertex "\date{" `"`=string(date(c(current_date),"DMY"),"%tdMonth_DD,_CCYY")'"' "}" _n
    file write mastertex "\maketitle" _n
    file write mastertex "\thispagestyle{empty}" _n _n

    * Main table of contents
    file write mastertex "\clearpage" _n
    file write mastertex "\setcounter{page}{1}" _n
    file write mastertex "\hypersetup{colorlinks=true,linkcolor=blue,linktoc=all}" _n
    file write mastertex "\phantomsection" _n 
    file write mastertex "\label{main-toc}" _n
    file write mastertex "\vspace*{2cm}" _n  
    file write mastertex "\begin{center}" _n
    file write mastertex "{\Large\bfseries Contents}" _n
    file write mastertex "\end{center}" _n
    file write mastertex "\vspace{1cm}" _n

    * Create custom entry format for main TOC
    file write mastertex "\begin{center}" _n
    file write mastertex "\renewcommand{\arraystretch}{1.5}" _n
    file write mastertex "\begin{longtable}{p{\dimexpr\textwidth-1cm\relax}r}" _n
    
    * Calculate number of pages for each section
    tempname fh
    foreach var of local files {
        local `var'_pages = 0
        file open `fh' using "$doc/`var'.tex", read
        file read `fh' line
        while r(eof) == 0 {
            if regexm(`"`line'"', "\\addcontentsline{toc}{section}{([^}]+)}") {
                local ++`var'_pages
            }
            file read `fh' line
        }
        file close `fh'
    }

    * Dynamic page numbering
    local page_start = 3
    local cumulative_pages = `page_start'
    
    foreach var of local files {
        * Get proper variable name for TOC
        if "`var'" == "nGDP" local varname "Nominal GDP"
        else if "`var'" == "rGDP" local varname "Real GDP"
		else if "`var'" == "rcons" local varname "Real consumption"
        else if "`var'" == "cons" local varname "Consumption"
		else if "`var'" == "cons_GDP" local varname "Consumption to GDP"
        else if "`var'" == "inv" local varname "Gross capital formation"
        else if "`var'" == "inv_GDP" local varname "Gross capital formation to GDP"
		else if "`var'" == "finv" local varname "Gross fixed capital formation"
		else if "`var'" == "finv_GDP" local varname "Gross fixed capital formation to GDP"
        else if "`var'" == "pop" local varname "Population"
        else if "`var'" == "exports_GDP" local varname "Exports to GDP"
        else if "`var'" == "imports_GDP" local varname "Imports to GDP"
		else if "`var'" == "exports" local varname "Exports"
        else if "`var'" == "imports" local varname "Imports"
        else if "`var'" == "CA_GDP" local varname "Current account"
        else if "`var'" == "USDfx" local varname "USD exchange rate"
        else if "`var'" == "REER" local varname "Real effective exchange rate"
        else if "`var'" == "govtax" local varname "Government tax revenue"
        else if "`var'" == "govtax_GDP" local varname "Government tax revenue to GDP"
		else if "`var'" == "govexp" local varname "Government expenditure"
		else if "`var'" == "govexp_GDP" local varname "Government expenditure to GDP"
        else if "`var'" == "govdef_GDP" local varname "Government deficit"
        else if "`var'" == "govdebt_GDP" local varname "Government debt"
        else if "`var'" == "govrev" local varname "Government revenue"
		else if "`var'" == "govrev_GDP" local varname "Government revenue to GDP"
        else if "`var'" == "M0" local varname "Money supply (M0)"
        else if "`var'" == "M1" local varname "Money supply (M1)"
        else if "`var'" == "M2" local varname "Money supply (M2)"
        else if "`var'" == "M3" local varname "Money supply (M3)"
		else if "`var'" == "M4" local varname "Money supply (M4)"
        else if "`var'" == "cbrate" local varname "Central bank policy rate"
        else if "`var'" == "strate" local varname "Short-term interest rate"
        else if "`var'" == "ltrate" local varname "Long-term interest rate"
        else if "`var'" == "CPI" local varname "Consumer prices index"
        else if "`var'" == "HPI" local varname "House prices index"
        else if "`var'" == "infl" local varname "Inflation"
        else if "`var'" == "unemp" local varname "Unemployment"
        
        file write mastertex "{\large\bfseries\hyperref[`var'-toc]{`varname'}} & {\large\bfseries\hyperref[`var'-toc]{`cumulative_pages'}} \\" _n
        local cumulative_pages = `cumulative_pages' + ``var'_pages' + 1
    }

    file write mastertex "{\large\bfseries\hyperref[references]{References}} & {\large\bfseries\hyperref[references]{`ref_page'}} \\" _n
    file write mastertex "\end{longtable}" _n
    file write mastertex "\end{center}" _n
    file write mastertex "\pagestyle{empty}" _n
    file write mastertex "\pagestyle{mainStyle}" _n

    * Process each input file
    foreach var of local files {
        * Get proper variable name
        if "`var'" == "nGDP" local varname "Nominal GDP"
        else if "`var'" == "rGDP" local varname "Real GDP"
		else if "`var'" == "rcons" local varname "Real consumption"
        else if "`var'" == "cons" local varname "Consumption"
		else if "`var'" == "cons_GDP" local varname "Consumption to GDP"
        else if "`var'" == "inv" local varname "Gross capital formation"
        else if "`var'" == "inv_GDP" local varname "Gross capital formation to GDP"
		else if "`var'" == "finv" local varname "Gross fixed capital formation"
		else if "`var'" == "finv_GDP" local varname "Gross fixed capital formation to GDP"
        else if "`var'" == "pop" local varname "Population"
        else if "`var'" == "exports_GDP" local varname "Exports to GDP"
        else if "`var'" == "imports_GDP" local varname "Imports to GDP"
		else if "`var'" == "exports" local varname "Exports"
        else if "`var'" == "imports" local varname "Imports"
        else if "`var'" == "CA_GDP" local varname "Current account"
        else if "`var'" == "USDfx" local varname "USD exchange rate"
        else if "`var'" == "REER" local varname "Real effective exchange rate"
        else if "`var'" == "govtax" local varname "Government tax revenue"
        else if "`var'" == "govtax_GDP" local varname "Government tax revenue to GDP"
		else if "`var'" == "govexp" local varname "Government expenditure"
		else if "`var'" == "govexp_GDP" local varname "Government expenditure to GDP"
        else if "`var'" == "govdef_GDP" local varname "Government deficit"
        else if "`var'" == "govdebt_GDP" local varname "Government debt"
        else if "`var'" == "govrev" local varname "Government revenue"
		else if "`var'" == "govrev_GDP" local varname "Government revenue to GDP"
        else if "`var'" == "M0" local varname "Money supply (M0)"
        else if "`var'" == "M1" local varname "Money supply (M1)"
        else if "`var'" == "M2" local varname "Money supply (M2)"
        else if "`var'" == "M3" local varname "Money supply (M3)"
		else if "`var'" == "M4" local varname "Money supply (M4)"
        else if "`var'" == "cbrate" local varname "Central bank policy rate"
        else if "`var'" == "strate" local varname "Short-term interest rate"
        else if "`var'" == "ltrate" local varname "Long-term interest rate"
        else if "`var'" == "CPI" local varname "Consumer prices index"
        else if "`var'" == "HPI" local varname "House prices index"
        else if "`var'" == "infl" local varname "Inflation"
        else if "`var'" == "unemp" local varname "Unemployment"
        
        * Create section TOC
        file write mastertex "\clearpage" _n
        file write mastertex "\pagestyle{empty}" _n
        file write mastertex "\hypersetup{colorlinks=true,linkcolor=blue,linktoc=all}" _n
        file write mastertex "\phantomsection" _n
        file write mastertex "\label{`var'-toc}" _n
        file write mastertex "\vspace*{2cm}" _n  
        file write mastertex "\begin{center}" _n
        file write mastertex "{\Large\bfseries\hyperref[main-toc]{`varname'}}" _n
        file write mastertex "\end{center}" _n
        file write mastertex "\vspace{1cm}" _n
        
        * Create custom entry format for section TOC
        file write mastertex "\begin{center}" _n
        file write mastertex "\renewcommand{\arraystretch}{1.5}" _n
        file write mastertex "\begin{longtable}{p{\dimexpr\textwidth-1cm\relax}r}" _n

        * Read and process input file
        tempname fh
        file open `fh' using "$doc/`var'.tex", read
        
        * First pass: Extract country names for TOC
        file read `fh' line
        while r(eof) == 0 {
            if regexm(`"`line'"', "\\addcontentsline{toc}{section}{([^}]+)}") {
                local country = regexs(1)
                if "`country'" != "References" {
                    file write mastertex "\bfseries\hyperref[`var'-`country']{`country'} & \bfseries\hyperref[`var'-`country']{\pageref{`var'-`country'}} \\" _n
                }
            }
            file read `fh' line
        }
        
        file write mastertex "\end{longtable}" _n
        file write mastertex "\end{center}" _n

        * Switch to section-specific page style
        file write mastertex "\pagestyle{`var'Style}" _n

        * Reset file handle for second pass
        file close `fh'
        file open `fh' using "$doc/`var'.tex", read

        * Second pass: Extract content
        local capture 0
        file read `fh' line
        while r(eof) == 0 {
            if regexm(`"`line'"', "\\begin{document}") {
                local capture 1
            }
            else if regexm(`"`line'"', "\\phantomsection.*References") | ///
                    regexm(`"`line'"', "\\addcontentsline{toc}{section}{References}") {
                local capture 0
            }
            else if `capture' == 1 {
                if !regexm(`"`line'"', "\\(title|date|maketitle|tableofcontents|thispagestyle|clearpage)") {
                    if regexm(`"`line'"', "\\addcontentsline{toc}{section}{([^}]+)}") {
                        local country = regexs(1)
                        if "`country'" != "References" {
                            file write mastertex "\phantomsection" _n
                            file write mastertex "\label{`var'-`country'}" _n
                        }
                    }
                    file write mastertex `"`line'"' _n
                }
            }
            file read `fh' line
        }
        file close `fh'
    }

    * Add references section
    file write mastertex "\clearpage" _n
    file write mastertex "\pagestyle{mainStyle}" _n
    file write mastertex "\phantomsection" _n
    file write mastertex "\label{references}" _n
    file write mastertex "\begin{center}" _n
    file write mastertex "{\Large\bfseries References}" _n
    file write mastertex "\end{center}" _n
    file write mastertex "\small" _n
    file write mastertex "\bibliographystyle{plainnat}" _n
    file write mastertex "\bibliography{bib}" _n
    
    * Close document
    file write mastertex "\end{document}" _n
    file close mastertex
end

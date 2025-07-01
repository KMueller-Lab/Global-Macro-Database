********************************************************************************
* The macroeconomic impact of climate change: global vs. local temperature
* Bilal and Känzig (2024)
* This file reproduces the main time series local projection (Figure 3) in the paper 
********************************************************************************

* settings
clear 
set more off 

* graphstyle
grstyle init
grstyle set grid
grstyle set linewidth 0.3pt: major_grid 
grstyle set margin 0.01cm: twoway 
global grfont "P052"
graph set window fontface $grfont // latex font
global mblue "0 114 189"
global mred "217 83 25"
global morange "237 177 32"
global mdred "162 20 47"
global mpurple "126 47 142"
global mgreen "119 172 48"

* working directory (make sure to run code in code folder)
* cd " "

* options
global savefigs 1    /* 1: save to disk, 0: don't save */
global verb qui      /* leave empty if you want to display regression results */

global figpath = "figures\" 

global shockname fe2s /* fe2s: 2-step ahead forecast error, fe1s: 1-step ahead forecast error */
		
********************************************************************************
* 1. Effect of global GDP on global temperature: Local projections
********************************************************************************

use "data\micc_data.dta", clear

* sample
keep if year >= 1960
keep if year <= 2019 

* specs for local projection
local p = 2          // p = number of lags 
local ps = 2         // p = number of lags for shock
local horizon = 10   // Impulse horizon
local estdiff = 2    // 0: level, 1: differences, 2: cumulative

local CI1 = 0.1    	  // Confidence level 1
local CI2 = 0.32	  // Confidence level 2
local z1 = abs(invnormal(`CI1'/2))  
local z2 = abs(invnormal(`CI2'/2))

local detrtype $shockname

local shock gtmp_noaa_aw_dt`detrtype'
local vars lnrgdppc_world_pwt gtmp_noaa_aw 
local varsnames " "World real GDP" "Global temperature"  " 
local labels " "Percent" "°C" "

local cntrls L(0/2).(recessiondates) 
// local cntrls "" // modified by YT

local savefigs = $savefigs    
local verb $verb

gen t = _n 
gen h = t - 1 // h is the horizon for the irfs 

local ivar = 1
foreach var in `vars' { 
		
	* preallocate 
	qui gen b`var' = .
	qui gen up90b`var' = .
	qui gen lo90b`var' = .
	qui gen up68b`var' = .
	qui gen lo68b`var' = .

	if `estdiff' > 0 {
		g d`var' = `var' - L.`var'
	}

	forvalues i = 0/`horizon' {

		local iname `i'
		gen d`iname'`var' = F`i'.`var' - L.`var' 
		
		if `estdiff' == 0 {
			`verb' reg F(`i').`var' L(0/`ps').`shock' L(1/`p').`var' `cntrls', r 
		}
		else if `estdiff' == 1 {
			`verb' reg F(`i').d`var' L(0/`ps').`shock' L(1/`p').d`var' `cntrls', r 
		}
		else if `estdiff' == 2 {
			`verb' reg d`iname'`var' L(0/`ps').`shock' L(1/`p').d`var' `cntrls', r 
		}
		
		gen b`var'h`iname' = _b[`shock']

		gen se`var'h`iname' = _se[`shock']

		qui replace b`var' = b`var'h`iname' if h==`i'
		qui replace up90b`var' = b`var'h`iname' + `z1'*se`var'h`iname' if h==`i'
		qui replace lo90b`var' = b`var'h`iname' - `z1'*se`var'h`iname' if h==`i'
		qui replace up68b`var' = b`var'h`iname' + `z2'*se`var'h`iname' if h==`i'
		qui replace lo68b`var' = b`var'h`iname' - `z2'*se`var'h`iname' if h==`i'
		
	}

	cap g zero = 0
	local varname : word `ivar' of `varsnames'
	local labname : word `ivar' of `labels'
	tw (rarea up90b`var' lo90b`var' h, fcolor("$mblue%15") lwidth(none)) ///
		(rarea up68b`var' lo68b`var' h, fcolor("$mblue%40") lwidth(none)) ///
		(scatter b`var' h, c(l) clp(l) ms(i ) clc(black) mc(black) clw(medthick)) ///
		(line zero h, lc(black) clw(vvthin)) if h<=`horizon', ///
		title("`varname'", size(medlarge) col(black) margin(b=2)) xtitle("Years", margin(t=3) size(medlarge)) ///
		ytitle("`labname'", margin(r=3) size(medlarge))   ///
		xlabel(0(2)`horizon') ///
		plotregion(fcolor(white) lcolor(black) lwidth(medium) lalign(outside) ilalign(outside)) ///
		graphregion(color(white) lwidth(large)) bgcolor(white) legend(off) name("irfgs_`var'_ts", replace) ///
		ysize(4) xsize(5.5) scale(1.2) //
		if `savefigs' == 1 {
			graph export "${figpath}\irfgs_`var'_ts.pdf", fontface($grfont) replace
		}
	local ivar = `ivar'+1
}


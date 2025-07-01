
* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* GENERATE PLOTS FOR SECTION 4
* 
* Author:
* Chenzi Xu
* University of California, Berkeley
*
* Last Editor:
* Yachi Tu
* University of California, Berkeley
*
* Created: 2025-01-15
* Last updated: 2025-01-15
*
* ==============================================================================

/* This do-file produces the final plots

Plots contain:

	- {Rep5} 						Replication of BK figure 5, only with rGDP_new 
	- {Rep5-1850} 					Rep of BK Figure 5, 1850-2019, rGDP_new, X = LandOcean_Air_Shock
	- {Rep5-1750} 					Rep of BK Figure 5, 1750-2019, rGDP_new, X = Land_Shock
	- {Rep5-JST-1850} 				Figure 5 under JST seperation, 1850-2019, plot in one combined plot.
	- {GovDebt-GDP-gbl/lcl}			Effect of Temp shock on goverment debt to gdp ratio
	- {GovDebt pre/post war}		Effect of ... on government debt ratio, split between pre-post war period
	- {Tshock-AcCrisis-gbl/lcl} 	Effect of Temp shock on Banking Crisis: Cumulative Banking Crisis, BK_global shock/Local shock
	- {Crisis-rGDP} 				Banking Crisis shock on country-level rGDP, 1750-2019, plot the 4 types of lag controls together.
	- {Tshock-AcRun-gbl/lcl}		Effect of Temp shock on Bank Runs
	- {BankRun-rGDP}				BankRun shock on country-level rGDP.

*/


	
*===============================================================================
* Define the path	
*===============================================================================

* define all the working paths
	cap cd "$GMP/code"
	do "2_Define_Path"

* define folder for plot output
	global folder = "$Result"
	

*===============================================================================
* Erase the folders 
*===============================================================================
if "`c(os)'" == "Windows" {
	shell del /Q "$Result"
	shell del /Q "$temp"
}

else {
	shell rm /Q "$Result"
	shell rm /Q "$temp"
}
	
	

*===============================================================================
* Specify the plots
*===============================================================================
{
** General Settings
	global maxhS = 10			// the short horizon of LP
	global maxhL = 50			// the long horizon of LP (only for the fig "{Crisis-rGDP}")
	
	local CI1 = 0.1    	  		// Confidence level 1
	global z1 = abs(invnormal(`CI1'/2))  
	
	*** Common specification under all regs.
	global BKcrisis_Fill0 = 0 	// 0: NOT filling the missing BankingCrisis dummy with zero; 1: fill with zero
	global FE id
	global weight unweight
	global xlags 2 		// add two lags of temp shock as control
	global MaxYear = 2019


	
** Figure 5 replication and time extension
{
** settings 
	global Rep5_maxh		${maxhS}	// specify the horizon to generate, maxS or maxL
	global Rep5_depvar 		ln_rGDP_pcpt_new
	global Rep5_ylaglist 	2			// add two lags of D_`LHS' as control

**{Rep5}
	local fig = "Rep5"
	global `fig'_MinYear	1950
	global `fig'_TempShocks BK_global_tempshock TempShock_III_2_2 // type of global temperature shock: temp shock imported from BK rep package
	global `fig'_controls 	g_rGDP_world_new recessiondates
	global `fig'_cntrls 	L(1/2).g_rGDP_world_new L(0/2).(recessiondates) // Other controls

**{Rep5-1850} 
	local fig = "Rep5_1850"
	global `fig'_MinYear	1850
	global `fig'_TempShocks LandOcean_Air_Shock_2_2 TempShock_III_2_2 // type of global temperature shock: Land Ocean Air shock (starts from 1850)
	global `fig'_controls 	g_rGDP_world_new 
	global  `fig'_cntrls 	L(1/2).g_rGDP_world_new // controls here are "other controls", don't involve lag of temp shocks.	
	
**{Rep5-1750}
	local fig = "Rep5_1750"
	global `fig'_MinYear	1850
	global `fig'_TempShocks Land_Shock_2_2 TempShock_III_2_2 // type of global temperature shock: Land shock (starts from 1750)
	global `fig'_controls 	g_rGDP_world_new 
	local  `fig'_cntrls 	L(1/2).g_rGDP_world_new // controls here are "other controls", don't involve lag of temp shocks.
}
*

**{Rep5-JST-1850}
{
	local fig = "Rep5_JST"
	global Have_Fullsample 	1	// 0: only comparizon between JST and non-JST; 1: additional full-sample result
	global `fig'_maxh 	 	$maxhL
	global `fig'_MinYear 	1850
	global `fig'_TempShocks LandOcean_Air_Shock_2_2 
	global `fig'_ylaglist	2
	global `fig'_controls 	g_rGDP_world_new JST	// JST: the 0-1 dummy for JST status, used to split sample.
	global  `fig'_cntrls L(1/2).g_rGDP_world_new 	// controls here are "other controls", don't involve lag of temp shocks
}
	
	
**{GovDebt-GDP}
{
	local fig = "GovDebt_GDP"
	global `fig'_maxh		$maxhS
	global `fig'_MinYear	1950
	global `fig'_depvar 	ln_govdebt_GDP 		 	
	global `fig'_TempShocks BK_global_tempshock TempShock_III_2_2
	global `fig'_ylaglist  	2
	global `fig'_controls 	g_rGDP_world_new recessiondates
	global  `fig'_cntrls 	L(1/2).g_rGDP_world_new L(0/2).(recessiondates)
}	


**{GovDebt-GDP-pre/post war}
{
	local fig = "GovDebt_GDP_wwii"
	global `fig'_maxh		$maxhS
	global `fig'_MinYear	1850
	global `fig'_depvar 	ln_govdebt_GDP 		 	
	global `fig'_TempShocks LandOcean_Air_Shock TempShock_III_2_2
	global `fig'_ylaglist  	2
	global `fig'_controls 	g_rGDP_world_new 
	local  `fig'_cntrls 	L(1/2).g_rGDP_world_new 
}

	
**{Tshock-AcCrisis}
{
	local fig = "Temp_AcCrisis"
	global `fig'_maxh		$maxhS
	global `fig'_MinYear	1950
	global `fig'_depvar		Ac_BankingCrisis // Cumulative Banking Crisis (0-1 dummy)
	global `fig'_TempShocks BK_global_tempshock TempShock_III_2_2	
	global `fig'_ylaglist  	2 						
	global `fig'_controls 	g_rGDP_world_new
	local  `fig'_cntrls 	L(1/2).g_rGDP_world_new
}
	
	
**{Crisis-rGDP}
{
	local fig = "Crisis_rGDP"
	global `fig'_maxh		$maxhL
	global `fig'_balanced 	0 1		// 0: unbalanced is okay; 1: balanced (all samples can be used for 50-horizon est.)
	global `fig'_MinYear	1750
	global `fig'_depvar 	ln_rGDP_pcpt_new   // ln_rGDP_pcpt or ln_rGDP_pcpt_pwt
	global `fig'_TempShocks BankingCrisis
	global `fig'_ylaglist  	5 10 25
	global `fig'_controls 	g_rGDP_world_new
	global `fig'_cntrls 		L(1/2).g_rGDP_world_new // controls here are "other controls", don't involve lag of temp shocks.
}


**{Tshock-AcRun}
{
	local fig = "Temp_AcRun"
	global `fig'_maxh		$maxhS
	global `fig'_MinYear	1850
	global `fig'_depvar		Ac_BankRun // Cumulative Banking Crisis (0-1 dummy)
	global `fig'_TempShocks LandOcean_Air_Shock TempShock_III_2_2	
	global `fig'_ylaglist  	2				
	global `fig'_controls 	g_rGDP_world_new
	local  `fig'_cntrls 	L(1/2).g_rGDP_world_new
}

	
**{BankRun-rGDP}
{
	local fig = "BankRun_rGDP"
	global `fig'_maxh		$maxhL
	global `fig'_balanced 	0 1		// 0: unbalanced is okay; 1: balanced (all samples can be used for 50-horizon est.)
	global `fig'_MinYear	1750
	global `fig'_depvar 	ln_rGDP_pcpt_new   // ln_rGDP_pcpt or ln_rGDP_pcpt_pwt
	global `fig'_TempShocks BankRun
	global `fig'_ylaglist  	5 10 25
	global `fig'_controls 	g_rGDP_world_new
	global `fig'_cntrls 		L(1/2).g_rGDP_world_new // controls here are "other controls", don't involve lag of temp shocks.
}

	
}
*

* Specify the figures needed in this version
global CurrentFigures ""Rep5_1850", "Rep5_JST", "Crisis_rGDP", "BankRun_rGDP", "Crisis_rGDP_balanced", "BankRun_rGDP_balanced""

program define savefig
    // Declare the program to accept arguments
    args figurename
    
    // Check if figurename is one of the specified names
    if inlist(`"`figurename'"', ${CurrentFigures}) {
        graph export "$Result/`figurename'.png", replace width(4000) height(2400)
    }
    else {
        graph export "$ArchiveResult/`figurename'.png", replace width(4000) height(2400)
    }
end







*===============================================================================
* Data setup
*===============================================================================

* Run the 2_ExtractTemperature.R before the following do-files. 

qui do "$GMP/code/3_temperature_shock_construction"
qui do "$GMP/code/4_LPdata_construction"



*===============================================================================
* Create Plots
*===============================================================================

* {Rep5 & extension}------------------------------------------------------------
{
qui {	
foreach fig in "Rep5" "Rep5_1850" "Rep5_1750" {
	local area = 0	// 1: global; 2: local 
	
foreach Tempshock of global `fig'_TempShocks {	// #1 = global; #2 = local
	local area = `area' + 1


** SET PARAMETERS 
{	
	loc maxh 	 	${Rep5_maxh}
	loc ylaglist 	${Rep5_ylaglist}
	loc xlags		${xlags}

	* List of dependent variables 
	loc dv 			${Rep5_depvar}

	* List of independent variables
	loc predictors 	`Tempshock'
	loc RHS `predictors' ${`fig'_controls} ${FE} ${weight}

	* List of placeholder variables 
	loc placeh_str depvar pred 
	loc placeh_num N h beta se ul ll ylags xlags
}
*End para


** SET UP DATASET 
{	
	* Open estimation file 
	use ISO3 year `dv' `RHS' using "$temp/TempShock_forLPs", clear
	keep if year >= ${`fig'_MinYear} & year <= ${MaxYear}
	
	* Add placeholder variables
	foreach var in `placeh_num' { 
		gen `var' = . 
		}
	foreach var in `placeh_str' { 
		gen `var' = "" 
		}

	* Make changes in and lags of dependent and independent variables over time 
	forvalues h = 0/`maxh' {
		gen FD`h'_`dv' = F`h'.`dv' - L.`dv'	// for LHS
	}
	gen D_`dv' = D.`dv' // for RHS lag controls
	
	* Save estimation file 
	save "$temp/est", replace 

}
*End dataset


** ESTIMATE REGRESSIONS 
{
	*** Loop over lag lengths 
	foreach ylags in `ylaglist' {	
		di in red "fig = `fig', y = `dv', lag = `ylags'"
		
	qui {
		* Open estimation file 
		use "$temp/est", clear 
				
		* Loop over horizons 
		forvalues h = 0 / `maxh' {			
			** Add one to `h' such that rows = horizon + 1
			loc row = `h' + 1 
			
			** Estimate regression 
			reghdfe FD`h'_`dv'  `predictors' ///
						L(1/`xlags').`predictors' L(1/`ylags').D_`dv' ${`fig'_cntrls} ///
						[aw = ${weight}] ///
						, absorb(${FE})
						
			** Store estimates in placeholder variables 
				replace depvar	= "`dv'"										in `row'
				replace pred	= "`predictors'"								in `row'
				replace h 		= `h' 											in `row'
				replace beta	= _b[`predictors'] 								in `row'
				replace se		= _se[`predictors'] 							in `row'
				replace ul 		= _b[`predictors'] + ${z1} * _se[`predictors'] 	in `row'
				replace ll 		= _b[`predictors'] - ${z1} * _se[`predictors'] 	in `row'
				replace ylags	= `ylags'										in `row'
				replace N		= e(N)											in `row'
									
			}
			* next hoizon h
				
		* Only keep estimates 
		keep `placeh_num' `placeh_str' // these are lists
		keep if _n <= `maxh' + 1 
				
		* Save temporary file 
		save "$temp/est_`predictors'_`dv'_`ylags'", replace 
	}
	*End quiet
			
}
*End of ylag loops
				
}
*End reg

			
** STACK RESULTS DATASETS 
{
* Make empty dataset 
	clear 
	foreach var in `placeh_num' { 
		gen `var' = .
		}
	foreach var in `placeh_str' { 
		gen `var' = "" 
		}
	save "$temp/est_area`area'_fulldata", replace emptyok

* Loop over dependent variables 
	* Loop over lag lengths 
	foreach ylags in `ylaglist' {	
		* Stack 
		append using "$temp/est_`predictors'_`dv'_`ylags'"
		save "$temp/est_area`area'_fulldata", replace 
	}
	*End ylags
}
*End stacking

}
*Next tempshock

** PLOT	
{	
	*** merge the global and local shocks
	use "$temp/est_area2_fulldata", clear // local as master
	append using "$temp/est_area1_fulldata", gen(shock_global)	// merge in the global
	label values shock_global .	// the shock_global = 1 are global shock
	save "$temp/Result", replace
	
	*** determine the range of y
	qui summ ll
	local minval = r(min)
	qui summ ul
	local maxval = max(r(max), 1)	// ensure that y=0 is in the range
	
	#delimit ;
		twoway	(rarea ul ll h if shock_global == 1, color(blue%10) yaxis(1))
				(rarea ul ll h if shock_global == 0, color(red%10) yaxis(1))
				(connected beta h if shock_global == 1, color(blue) lpattern(solid) msymbol(o) yaxis(1))
				(connected beta h if shock_global == 0, color(red) lpattern(solid) msymbol(o) yaxis(1)),

				graphregion(color(white)) 
				plotregion(color(white))          
				yline(0, lcolor(black) lpattern(solid) lwidth(thin)) 
				yscale(range(`minval' `maxval'))
				xtitle("Years after shock")
				ytitle("Percent")
				ylabel(#6, format(%9.0f) angle(0))            
				legend(order(3 "Global temperature shock" 4 "Local temperature shock") position(6) row(1))
				;
		#delimit cr
		
	* Export with higher resolution
	** Change the plot name if needed
	if `maxh' == 50 {
		local fig = "`fig'_h50"
	}
	savefig `fig'				
}
*End plot

}
*Next `fig'

}
*End qui
}
*
	
	
* {Rep5 JST seperation}---------------------------------------------------------
{
qui{

loc fig = "Rep5_JST"
forvalues isJST = 0(1)2 { // 0: non-JST countries; 1: JST countries; 2: full-sample
	
** SET PARAMETERS 
{	
	loc maxh 		${`fig'_maxh}
	loc ylaglist 	${`fig'_ylaglist}
	loc xlags		${xlags}

	* List of dependent variables 
	loc dv 			${Rep5_depvar}

	* List of independent variables
	loc Tempshock	${`fig'_TempShocks} 
	loc predictors 	`Tempshock'
	loc RHS `predictors' ${`fig'_controls} ${FE} ${weight}

	* List of placeholder variables 
	loc placeh_str depvar pred 
	loc placeh_num N h beta se ul ll ylags xlags
}
*End para


** SET UP DATASET 
{	
	* Open estimation file 
	use ISO3 year `dv' `RHS' using "$temp/TempShock_forLPs", clear
	keep if year >= ${`fig'_MinYear} & year <= ${MaxYear}
	
	if `isJST' != 2 {
		keep if JST == `isJST'	// seperate between JST and non-JST countries; if isJST == 2 then keep full-sample
	}
	
	* Add placeholder variables
	foreach var in `placeh_num' { 
		gen `var' = . 
		}
	foreach var in `placeh_str' { 
		gen `var' = "" 
		}

	* Make changes in and lags of dependent and independent variables over time 
	forvalues h = 0/`maxh' {
		gen FD`h'_`dv' = F`h'.`dv' - L.`dv'	// for LHS
	}
	gen D_`dv' = D.`dv' // for RHS lag controls
	
	* Save estimation file 
	save "$temp/est", replace 

}
*End dataset


** ESTIMATE REGRESSIONS 
{
	*** Loop over lag lengths 
	foreach ylags in `ylaglist' {	
		di in red "fig = `fig'-JST`isJST', y = `dv', lag = `ylags'"
		
	qui {
		* Open estimation file 
		use "$temp/est", clear 
				
		* Loop over horizons 
		forvalues h = 0 / `maxh' {			
			** Add one to `h' such that rows = horizon + 1
			loc row = `h' + 1 
			
			** Estimate regression 
			reghdfe FD`h'_`dv'  `predictors' ///
						L(1/`xlags').`predictors' L(1/`ylags').D_`dv' ${`fig'_cntrls} ///
						[aw = ${weight}] ///
						, absorb(${FE})
						
			** Store estimates in placeholder variables 
				replace depvar	= "`dv'"										in `row'
				replace pred	= "`predictors'"								in `row'
				replace h 		= `h' 											in `row'
				replace beta	= _b[`predictors'] 								in `row'
				replace se		= _se[`predictors'] 							in `row'
				replace ul 		= _b[`predictors'] + ${z1} * _se[`predictors'] 	in `row'
				replace ll 		= _b[`predictors'] - ${z1} * _se[`predictors'] 	in `row'
				replace ylags	= `ylags'										in `row'
				replace N		= e(N)											in `row'
									
			}
			* next hoizon h
				
		* Only keep estimates 
		keep `placeh_num' `placeh_str' // these are lists
		keep if _n <= `maxh' + 1 
				
		* Save temporary file 
		save "$temp/est_`predictors'_`dv'_`ylags'", replace 
	}
	*End quiet
			
}
*End of ylag loops
				
}
*End reg

			
** STACK RESULTS DATASETS 
{
* Make empty dataset 
	clear 
	foreach var in `placeh_num' { 
		gen `var' = .
		}
	foreach var in `placeh_str' { 
		gen `var' = "" 
		}
	save "$temp/est_`Tempshock'_fulldata", replace emptyok

* Loop over dependent variables 
	* Loop over lag lengths 
	foreach ylags in `ylaglist' {	
		* Stack 
		append using "$temp/est_`predictors'_`dv'_`ylags'"
		save "$temp/est_`Tempshock'_fulldata", replace 
	}
	*End ylags
	
	save "$temp/est_`Tempshock'_fulldata_JST`isJST'", replace
}
*End stacking
	
}
*Next JST


** PLOT
{	
	use "$temp/est_${`fig'_TempShocks}_fulldata_JST0", clear
	append using "$temp/est_${`fig'_TempShocks}_fulldata_JST1", gen(JST)
	label values JST .	// the JST = 1 are the advanced countries est.
	append using "$temp/est_${`fig'_TempShocks}_fulldata_JST2"
		replace JST = 2 if missing(JST)	// the JST = 2 are full-sample est.

	save "$temp/Result", replace
	
	*** two types of plot
	// no need for full-sample benchmark 
	if ${Have_Fullsample} == 0 { 
	#delimit ;
		twoway	(rarea ul ll h if JST == 0, color(blue%10) yaxis(1))
				(rarea ul ll h if JST == 1, color(red%10) yaxis(1))
				(connected beta h if JST == 0, color(blue) lpattern(solid) msymbol(o) yaxis(1))
				(connected beta h if JST == 1, color(red) lpattern(solid) msymbol(o) yaxis(1)),

				graphregion(color(white)) 
				plotregion(color(white))          
				yline(0, lcolor(black) lpattern(solid) lwidth(thin)) 
				xtitle("Years after shock") 
				ytitle("Percent")
				ylabel(#6, format(%9.0f) angle(0))            
				legend(order(3 "non-JST countries" 4 "JST countries") position(6) row(1))
				;
		#delimit cr		
	}
	
	// need full-sample benchmark 	
	else { 
	#delimit ;
		twoway	(rarea ul ll h if JST == 0, color(blue%10) yaxis(1))
				(rarea ul ll h if JST == 1, color(red%10) yaxis(1))
				(rarea ul ll h if JST == 2, color(green%10) yaxis(1))

				(connected beta h if JST == 0, color(blue) lpattern(solid) msymbol(o) yaxis(1))
				(connected beta h if JST == 1, color(red) lpattern(solid) msymbol(o) yaxis(1))
				(connected beta h if JST == 2, color(green) lpattern(solid) msymbol(o) yaxis(1)),
				
				graphregion(color(white)) 
				plotregion(color(white))          
				yline(0, lcolor(black) lpattern(solid) lwidth(thin)) 
				xtitle("Years after shock") 
				ytitle("Percent")
				ylabel(#6, format(%9.0f) angle(0))            
				legend(order(4 "non-JST countries" 5 "JST countries" 6 "Full sample") position(6) row(1))
				;
		#delimit cr		
	}
	
	
	* Export with higher resolution
	** Change the plot name if needed
	if $Have_Fullsample == 1 {
		local fig = "`fig'_fullsample"
	}
	
	if `maxh' == 50 {
		local fig = "`fig'_h50"
	}
	savefig `fig'
		
}
*End plot

}
*End qui

}
*


* {GovDebt-GDP-gbl/lcl}---------------------------------------------------------
{
qui{
local fig = "GovDebt_GDP"	
local area = 0	// 1: global; 2: local
 
foreach Tempshock of global `fig'_TempShocks {	// #1 = global; #2 = local
	local area = `area' + 1
	
** SET PARAMETERS 
{	
	loc maxh 		${`fig'_maxh}
	loc ylaglist 	${`fig'_ylaglist}
	loc xlags		${xlags}

	* List of dependent variables 
	loc dv 			${`fig'_depvar}

	* List of independent variables
	loc predictors 	`Tempshock'
	loc RHS 		`predictors' ${`fig'_controls} ${FE} ${weight}

	* List of placeholder variables 
	loc placeh_str depvar pred 
	loc placeh_num N h beta se ul ll ylags xlags
}
*End para


** SET UP DATASET 
{	
	* Open estimation file 
	use ISO3 year `dv' `RHS' using "$temp/TempShock_forLPs", clear
	keep if (year >= ${`fig'_MinYear}) & (year <= ${MaxYear})
	xtset id year
	
		
	* Add placeholder variables
	foreach var in `placeh_num' { 
		gen `var' = . 
		}
	foreach var in `placeh_str' { 
		gen `var' = "" 
		}

	* Make changes in and lags of dependent and independent variables over time
	forvalues h = 0/`maxh' {
		gen FD`h'_`dv' = F`h'.`dv' - L.`dv'	// for LHS
	}
	gen D_`dv' = D.`dv' // for RHS lag controls
	
	* Save estimation file 
	save "$temp/est", replace 

}
*End dataset


** ESTIMATE REGRESSIONS 
{
	*** Loop over lag lengths 
	foreach ylags in `ylaglist' {	
		di in red "fig = `fig', y = `dv', lag = `ylags'"
		
	qui {
		* Open estimation file 
		use "$temp/est", clear 
				
		* Loop over horizons 
		forvalues h = 0 / `maxh' {			
			** Add one to `h' such that rows = horizon + 1
			loc row = `h' + 1 
			
			** Estimate regression 
			reghdfe FD`h'_`dv'  `predictors' ///
						L(1/`xlags').`predictors' L(1/`ylags').D_`dv' ${`fig'_cntrls} ///
						[aw = ${weight}] ///
						, absorb(${FE})
							
						
			** Store estimates in placeholder variables 
				replace depvar	= "`dv'"										in `row'
				replace pred	= "`predictors'"								in `row'
				replace h 		= `h' 											in `row'
				replace beta	= _b[`predictors'] 								in `row'
				replace se		= _se[`predictors'] 							in `row'
				replace ul 		= _b[`predictors'] + ${z1} * _se[`predictors'] 	in `row'
				replace ll 		= _b[`predictors'] - ${z1} * _se[`predictors'] 	in `row'
				replace ylags	= `ylags'										in `row'
				replace N		= e(N)											in `row'
									
			}
			* next hoizon h
				
		* Only keep estimates 
		keep `placeh_num' `placeh_str' // these are lists
		keep if _n <= `maxh' + 1 
				
		* Save temporary file 
		save "$temp/est_`predictors'_`dv'_`ylags'", replace 
	}
	*End quiet
}
*End of ylag loops		
}
*End reg

			
** STACK RESULTS DATASETS 
{
* Make empty dataset 
	clear 
	foreach var in `placeh_num' { 
		gen `var' = .
		}
	foreach var in `placeh_str' { 
		gen `var' = "" 
		}
	save "$temp/est_`Tempshock'_fulldata", replace emptyok

* Loop over dependent variables 
	* Loop over lag lengths 
	foreach ylags in `ylaglist' {	
		* Stack 
		append using "$temp/est_`predictors'_`dv'_`ylags'"
		save "$temp/est_area`area'_fulldata", replace 
	}
	*End ylags
	
}
*End stacking

}
*Next tempshock

** PLOT	
{	
	use "$temp/est_area2_fulldata", clear
	append using "$temp/est_area1_fulldata", gen(shock_global)
	label values shock_global .	// the shock_area = 1 are global shock
	save "$temp/Result", replace
	
	#delimit ;
		twoway	(rarea ul ll h if shock_global == 1, color(blue%10) yaxis(1))
				(rarea ul ll h if shock_global ==0, color(red%10) yaxis(1))
				(connected beta h if shock_global == 1, color(blue) lpattern(solid) msymbol(o) yaxis(1))
				(connected beta h if shock_global == 0, color(red) lpattern(solid) msymbol(o) yaxis(1)),

				graphregion(color(white)) 
				plotregion(color(white))  
				xtitle("Years after shock") 
				ytitle("Percent")
				ylabel(#6, format(%9.0f) angle(0))            
				yline(0, lcolor(black) lpattern(solid) lwidth(thin)) 
				legend(order(3 "Global temperature shock" 4 "Local temperature shock") position(6) row(1))
				;
		#delimit cr
		
	* Export with higher resolution
	** Change the plot name if needed
	if `maxh' == 50 {
		local fig = "`fig'_h50"
	}

	savefig `fig'				
}
*End plot


}
*End qui
}
*


* {GovDebt-GDP-pre/post wars}---------------------------------------------------
{
qui{
local fig = "GovDebt_GDP_wwii"	
local area = 0	// 1: global; 2: local
 
foreach Tempshock of global `fig'_TempShocks {	// #1 = global; #2 = local
	local area = `area' + 1
	
** SET PARAMETERS 
{	
	loc maxh 		${`fig'_maxh}
	loc ylaglist 	${`fig'_ylaglist}
	loc xlags		${xlags}

	* List of dependent variables 
	loc dv 			${`fig'_depvar}

	* List of independent variables
	loc predictors 	`Tempshock'
	loc RHS 		`predictors' ${`fig'_controls} ${FE} ${weight}

	* List of placeholder variables 
	loc placeh_str depvar pred 
	loc placeh_num N h beta se ul ll ylags xlags
}
*End para


// split between pre and post war
forvalues warstatus = 0/1 { // 0: pre-war; 1: post-war

** SET UP DATASET 
{	
	* Open estimation file 
	use ISO3 year `dv' `RHS' using "$temp/TempShock_forLPs", clear
	gen Postwwii = (year > 1945)
	keep if (year >= ${`fig'_MinYear}) & (year <= ${MaxYear})
	keep if Postwwii == `warstatus'
	
	xtset id year
		
	* Add placeholder variables
	foreach var in `placeh_num' { 
		gen `var' = . 
		}
	foreach var in `placeh_str' { 
		gen `var' = "" 
		}

	* Make changes in and lags of dependent and independent variables over time
	forvalues h = 0/`maxh' {
		gen FD`h'_`dv' = F`h'.`dv' - L.`dv'	// for LHS
	}
	gen D_`dv' = D.`dv' // for RHS lag controls
	
	* Save estimation file 
	save "$temp/est", replace 

}
*End dataset


** ESTIMATE REGRESSIONS 
{
	*** Loop over lag lengths 
	foreach ylags in `ylaglist' {	
		di in red "fig = `fig', y = `dv', lag = `ylags'"
		
	qui {
		* Open estimation file 
		use "$temp/est", clear 
				
		* Loop over horizons 
		forvalues h = 0 / `maxh' {			
			** Add one to `h' such that rows = horizon + 1
			loc row = `h' + 1 
			
			** Estimate regression 
			reghdfe FD`h'_`dv'  `predictors' ///
						L(1/`xlags').`predictors' L(1/`ylags').D_`dv' ${`fig'_cntrls} ///
						[aw = ${weight}] ///
						, absorb(${FE})
							
						
			** Store estimates in placeholder variables 
				replace depvar	= "`dv'"										in `row'
				replace pred	= "`predictors'"								in `row'
				replace h 		= `h' 											in `row'
				replace beta	= _b[`predictors'] 								in `row'
				replace se		= _se[`predictors'] 							in `row'
				replace ul 		= _b[`predictors'] + ${z1} * _se[`predictors'] 	in `row'
				replace ll 		= _b[`predictors'] - ${z1} * _se[`predictors'] 	in `row'
				replace ylags	= `ylags'										in `row'
				replace N		= e(N)											in `row'
									
			}
			* next hoizon h
				
		* Only keep estimates 
		keep `placeh_num' `placeh_str' // these are lists
		keep if _n <= `maxh' + 1 
				
		* Save temporary file 
		save "$temp/est_`predictors'_`dv'_`ylags'", replace 
	}
	*End quiet
}
*End of ylag loops		
}
*End reg

			
** STACK RESULTS DATASETS 
{
* Make empty dataset 
	clear 
	foreach var in `placeh_num' { 
		gen `var' = .
		}
	foreach var in `placeh_str' { 
		gen `var' = "" 
		}
	save "$temp/est_`Tempshock'_fulldata", replace emptyok

* Loop over dependent variables 
	* Loop over lag lengths 
	foreach ylags in `ylaglist' {	
		* Stack 
		append using "$temp/est_`predictors'_`dv'_`ylags'"
		save "$temp/est_area`area'_fulldata", replace 
	}
	*End ylags
	
	save "$temp/est_area`area'_fulldata_war`warstatus'", replace
	
}
*End stacking

}
*Next war status

}
*Next tempshock



** PLOT	
{	
// merge same-period results (under gbl and lcl shock)
forvalues warstatus = 0/1 {
	use "$temp/est_area2_fulldata_war`warstatus'", clear
	append using "$temp/est_area1_fulldata_war`warstatus'", gen(shock_global)
	label values shock_global .	// the shock_area = 1 are global shock
	save "$temp/Result_war`warstatus'", replace
}
// merge two periods
	use "$temp/Result_war0", clear
	append using "$temp/Result_war1", gen(Postwwii)
	label values Postwwii . // 1: year > 1945 
	
	save "$temp/Result", replace
	
	#delimit ;
		twoway	(rarea ul ll h if shock_global == 1, color(blue%10) yaxis(1))
				(rarea ul ll h if shock_global ==0, color(red%10) yaxis(1))
				(connected beta h if shock_global == 1, color(blue) lpattern(solid) msymbol(o) yaxis(1))
				(connected beta h if shock_global == 0, color(red) lpattern(solid) msymbol(o) yaxis(1)),
				
				by(Postwwii,
				graphregion(color(white)) 
				plotregion(color(white))  
				legend(position(6))
				note("")
				)
				xtitle("Years after shock") 
				ytitle("Percent")
				ylabel(#6, format(%9.0f) angle(0))            
				yline(0, lcolor(black) lpattern(solid) lwidth(thin)) 
				legend(order(3 "Global temperature shock" 4 "Local temperature shock") row(1))
				;
		#delimit cr
		
	* Export with higher resolution
	** Change the plot name if needed
	if `maxh' == 50 {
		local fig = "`fig'_h50"
	}

	savefig `fig'				
}
*End plot


}
*End qui
}
*


* {Tshock-AcCrisis-gbl/lcl}-----------------------------------------------------
{
qui{
	
	
local fig = "Temp_AcCrisis"
local area = 0	// 1: global; 2: local
 
foreach Tempshock of global `fig'_TempShocks {	// #1 = global; #2 = local
	local area = `area' + 1
		
** SET PARAMETERS 
{	
	loc maxh 		${`fig'_maxh}
	loc ylaglist 	${`fig'_ylaglist}
	loc xlags		${xlags}

	* List of dependent variables 
	loc dv 			${`fig'_depvar}

	* List of independent variables
	loc predictors 	`Tempshock'
	loc RHS `predictors' ${`fig'_controls} ${FE} ${weight}

	* List of placeholder variables 
	loc placeh_str depvar pred 
	loc placeh_num N h beta se ul ll ylags xlags
}
*End para


** SET UP DATASET 
{	
	* Open estimation file 
	use ISO3 year BankingCrisis `RHS' using "$temp/TempShock_forLPs", clear
	keep if year >= ${`fig'_MinYear} & year <= ${MaxYear}
	xtset id year
	
		
	* Add placeholder variables
	foreach var in `placeh_num' { 
		gen `var' = . 
		}
	foreach var in `placeh_str' { 
		gen `var' = "" 
		}

	* Make changes in and lags of dependent and independent variables over time
	** LHS n-years-forward Banking Crisis
	forvalues h = 0 / `maxh' {
			gen F_BankingCrisis_`h' = F`h'.BankingCrisis	// YT: changing the sequence of the name so as to ensure all the F vals have the same prefix. 
		}
	
	** LHS cumulative Banking Crisis
	forval h = 0/`maxh' {
		egen Ac_BankingCrisis_`h' = rowmax(F_BankingCrisis_0 - F_BankingCrisis_`h')
		
		// assign missing values manually, as rowmax() would defaultly fill the missing values with zero.
		egen missing_check = rowmiss(F_BankingCrisis_0 - F_BankingCrisis_`h')
		replace Ac_BankingCrisis_`h' = . if missing_check > 0 
		drop missing_check
	}

	
	* Save estimation file 
	save "$temp/est", replace 

}
*End dataset


** ESTIMATE REGRESSIONS 
{
	*** Loop over lag lengths 
	foreach ylags in `ylaglist' {	
		di in red "fig = `fig', y = `dv', lag = `ylags'"
		
	qui {
		* Open estimation file 
		use "$temp/est", clear 
				
		* Loop over horizons 
		forvalues h = 0 / `maxh' {			
			** Add one to `h' such that rows = horizon + 1
			loc row = `h' + 1 
			
			** Estimate regression						
			reghdfe `dv'_`h'  `predictors' ///
					L(1/`xlags').`predictors' L(1/`ylags').BankingCrisis ${`fig'_cntrls} ///
					[aw = ${weight}] ///
					, absorb(${FE})
							
						
			** Store estimates in placeholder variables 
				replace depvar	= "`dv'"										in `row'
				replace pred	= "`predictors'"								in `row'
				replace h 		= `h' 											in `row'
				replace beta	= _b[`predictors'] 								in `row'
				replace se		= _se[`predictors'] 							in `row'
				replace ul 		= _b[`predictors'] + ${z1} * _se[`predictors'] 	in `row'
				replace ll 		= _b[`predictors'] - ${z1} * _se[`predictors'] 	in `row'
				replace ylags	= `ylags'										in `row'
				replace N		= e(N)											in `row'
									
			}
			* next hoizon h
				
		* Only keep estimates 
		keep `placeh_num' `placeh_str' // these are lists
		keep if _n <= `maxh' + 1 
				
		* Save temporary file 
		save "$temp/est_`predictors'_`dv'_`ylags'", replace 
	}
	*End quiet
}
*End of ylag loops		
}
*End reg

			
** STACK RESULTS DATASETS 
{
* Make empty dataset 
	clear 
	foreach var in `placeh_num' { 
		gen `var' = .
		}
	foreach var in `placeh_str' { 
		gen `var' = "" 
		}
	save "$temp/est_`Tempshock'_fulldata", replace emptyok

* Loop over dependent variables 
	* Loop over lag lengths 
	foreach ylags in `ylaglist' {	
		* Stack 
		append using "$temp/est_`predictors'_`dv'_`ylags'"
		save "$temp/est_area`area'_fulldata", replace 
	}
	*End ylags
	
}
*End stacking

}
*Next tempshock

** PLOT	
{	
	use "$temp/est_area2_fulldata", clear
	append using "$temp/est_area1_fulldata", gen(shock_global)
	label values shock_global .	// the shock_area = 1 are global shock
	save "$temp/Result", replace
	
	#delimit ;
		twoway	(rarea ul ll h if shock_global == 1, color(blue%10) yaxis(1))
				(rarea ul ll h if shock_global ==0, color(red%10) yaxis(1))
				(connected beta h if shock_global == 1, color(blue) lpattern(solid) msymbol(o) yaxis(1))
				(connected beta h if shock_global == 0, color(red) lpattern(solid) msymbol(o) yaxis(1)),

				graphregion(color(white)) 
				plotregion(color(white))
				yline(0, lcolor(black) lpattern(solid) lwidth(thin)) 
				xtitle("Years after shock") 
				ytitle("Change in Probability")
				ylabel(#6, format(%9.2f) angle(0))            
				legend(order(3 "Global temperature shock" 4 "Local temperature shock") position(6) row(1))
				;
		#delimit cr
		
	* Export with higher resolution
	** Change the plot name if needed
	if `maxh' == 50 {
		local fig = "`fig'_h50"
	}
	savefig `fig'				
}
*End plot


}
*End qui
}
*


* {Crisis-rGDP}-----------------------------------------------------------------
{
	
qui{
local fig = "Crisis_rGDP"

** SET PARAMETERS 
{	
	loc maxh 		${`fig'_maxh}	// only this plot uses the 50-year horizon
	loc ylaglist 	${`fig'_ylaglist}
	loc xlags		${xlags}

	* List of dependent variables 
	loc dv 			${`fig'_depvar}

	* List of independent variables
	loc Tempshock	${`fig'_TempShocks} 
	loc predictors 	`Tempshock'
	loc RHS `predictors' ${`fig'_controls} ${FE} ${weight}

	* List of placeholder variables 
	loc placeh_str depvar pred 
	loc placeh_num N h beta se ul ll ylags xlags
}
*End para


** SET UP DATASET 
foreach balanced of global `fig'_balanced {
{	
	* Open estimation file 
	use ISO3 year `dv' `RHS' using "$temp/TempShock_forLPs", clear
	keep if year >= ${`fig'_MinYear} & year <= ${MaxYear}
		
	* Add placeholder variables
	foreach var in `placeh_num' { 
		gen `var' = . 
		}
	foreach var in `placeh_str' { 
		gen `var' = "" 
		}

	* Make changes in and lags of dependent and independent variables over time 
	forvalues h = 0/`maxh' {
		gen FD`h'_`dv' = F`h'.`dv' - L.`dv'	// for LHS
	}
	gen D_`dv' = D.`dv' // for RHS lag controls
	
	
	* Restrict to a balanced dataset
	if `balanced' == 1 {
		egen nmiss = rmiss(FD*_`dv') 	// count the number of missing values in the FD* series
		keep if nmiss == 0				// only keep observations with no missing values across all the FD variables
		drop nmiss		
	}
	
	* Save estimation file 
	save "$temp/est", replace 

}
*End dataset


** ESTIMATE REGRESSIONS 
{
	*** Loop over lag lengths 
	foreach ylags in `ylaglist' {	
		di in red "fig = `fig', y = `dv', lag = `ylags'"
		
	qui {
		* Open estimation file 
		use "$temp/est", clear 
				
		* Loop over horizons 
		forvalues h = 0 / `maxh' {			
			** Add one to `h' such that rows = horizon + 1
			loc row = `h' + 1 
			
			** Estimate regression 
			reghdfe FD`h'_`dv'  `predictors' ///
						L(1/`xlags').`predictors' L(1/`ylags').D_`dv' ${`fig'_cntrls} ///
						[aw = ${weight}] ///
						, absorb(${FE})
						
			** Store estimates in placeholder variables 
				replace depvar	= "`dv'"										in `row'
				replace pred	= "`predictors'"								in `row'
				replace h 		= `h' 											in `row'
				replace beta	= _b[`predictors'] 								in `row'
				replace se		= _se[`predictors'] 							in `row'
				replace ul 		= _b[`predictors'] + ${z1} * _se[`predictors'] 	in `row'
				replace ll 		= _b[`predictors'] - ${z1} * _se[`predictors'] 	in `row'
				replace ylags	= `ylags'										in `row'
				replace N		= e(N)											in `row'
									
			}
			* next hoizon h
				
		* Only keep estimates 
		keep `placeh_num' `placeh_str' // these are lists
		keep if _n <= `maxh' + 1 
				
		* Save temporary file 
		save "$temp/est_`predictors'_`dv'_`ylags'", replace 
	}
	*End quiet
			
}
*End of ylag loops
				
}
*End reg


** STACK RESULTS DATASETS 
{
* Make empty dataset 
	clear 
	foreach var in `placeh_num' { 
		gen `var' = .
		}
	foreach var in `placeh_str' { 
		gen `var' = "" 
		}
	save "$temp/est_`Tempshock'_fulldata", replace emptyok

* Loop over dependent variables 
	* Loop over lag lengths 
	foreach ylags in `ylaglist' {	
		* Stack 
		append using "$temp/est_`predictors'_`dv'_`ylags'"
		save "$temp/est_`Tempshock'_fulldata", replace 
	}
	*End ylags
}
*End stacking


** PLOT	
{	
	tokenize ${`fig'_ylaglist}
	
	use "$temp/est_`Tempshock'_fulldata", clear
	
	#delimit ;
	twoway  (rarea ul ll h if ylags == `1', color(navy%10))
			(rarea ul ll h if ylags == `2', color(maroon%10))
			(rarea ul ll h if ylags == `3', color(forest_green%10))
			
			(connected beta h if ylags == `1', color(navy) lpattern(solid) msymbol(o))
			(connected beta h if ylags == `2', color(maroon) lpattern(solid) msymbol(o))
			(connected beta h if ylags == `3', color(forest_green) lpattern(solid) msymbol(o))
			
			, yline(0, lcolor(black) lpattern(solid) lwidth(thin))    
			xtitle("Years after shock") 
			ytitle("Percent")
			xlabel(0(5)${maxhL}) 
			ylabel(#6, format(%9.0f) angle(0))            
			legend(order(4 "y lag = `1'" 5 "y lag = `2'" 6 "y lag = `3'") position(6) row(1))
			;
	#delimit cr
	
	* Export with higher resolution
	if `balanced' == 1 {
		local fig = "`fig'_balanced"
	}
	savefig `fig'				
}
*End plot

}
*next balanced

}
*End quiet

}
*


* {Tshock-AcRun-gbl/lcl}-----------------------------------------------------
{
qui{
	
	
local fig = "Temp_AcRun"
local area = 0	// 1: global; 2: local
 
foreach Tempshock of global `fig'_TempShocks {	// #1 = global; #2 = local
	local area = `area' + 1
		
** SET PARAMETERS 
{	
	loc maxh 		${`fig'_maxh}
	loc ylaglist 	${`fig'_ylaglist}
	loc xlags		${xlags}

	* List of dependent variables 
	loc dv 			${`fig'_depvar}

	* List of independent variables
	loc predictors 	`Tempshock'
	loc RHS `predictors' ${`fig'_controls} ${FE} ${weight}

	* List of placeholder variables 
	loc placeh_str depvar pred 
	loc placeh_num N h beta se ul ll ylags xlags
}
*End para


** SET UP DATASET 
{	
	* Open estimation file 
	use ISO3 year BankRun `RHS' using "$temp/TempShock_forLPs", clear
	keep if year >= ${`fig'_MinYear} & year <= ${MaxYear}
	xtset id year
	
		
	* Add placeholder variables
	foreach var in `placeh_num' { 
		gen `var' = . 
		}
	foreach var in `placeh_str' { 
		gen `var' = "" 
		}

	* Make changes in and lags of dependent and independent variables over time
	** LHS n-years-forward Banking Crisis
	forvalues h = 0 / `maxh' {
			gen F_BankRun_`h' = F`h'.BankRun	// YT: changing the sequence of the name so as to ensure all the F vals have the same prefix. 
		}
	
	** LHS cumulative Banking Crisis
	forval h = 0 / `maxh' {
		egen Ac_BankRun_`h' = rowmax(F_BankRun_0 - F_BankRun_`h')
		
		// assign missing values manually, as rowmax() would defaultly fill the missing values with zero.
		egen missing_check = rowmiss(F_BankRun_0 - F_BankRun_`h')
		replace Ac_BankRun_`h' = . if missing_check > 0 
		drop missing_check
	}

	
	* Save estimation file 
	save "$temp/est", replace 

}
*End dataset


** ESTIMATE REGRESSIONS 
{
	*** Loop over lag lengths 
	foreach ylags in `ylaglist' {	
		di in red "fig = `fig', y = `dv', lag = `ylags'"
		
	qui {
		* Open estimation file 
		use "$temp/est", clear 
				
		* Loop over horizons 
		forvalues h = 0 / `maxh' {			
			** Add one to `h' such that rows = horizon + 1
			loc row = `h' + 1 
			
			** Estimate regression						
			reghdfe `dv'_`h'  `predictors' ///
					L(1/`xlags').`predictors' L(1/`ylags').BankRun ${`fig'_cntrls} ///
					[aw = ${weight}] ///
					, absorb(${FE})
							
						
			** Store estimates in placeholder variables 
				replace depvar	= "`dv'"										in `row'
				replace pred	= "`predictors'"								in `row'
				replace h 		= `h' 											in `row'
				replace beta	= _b[`predictors'] 								in `row'
				replace se		= _se[`predictors'] 							in `row'
				replace ul 		= _b[`predictors'] + ${z1} * _se[`predictors'] 	in `row'
				replace ll 		= _b[`predictors'] - ${z1} * _se[`predictors'] 	in `row'
				replace ylags	= `ylags'										in `row'
				replace N		= e(N)											in `row'
									
			}
			* next hoizon h
				
		* Only keep estimates 
		keep `placeh_num' `placeh_str' // these are lists
		keep if _n <= `maxh' + 1 
				
		* Save temporary file 
		save "$temp/est_`predictors'_`dv'_`ylags'", replace 
	}
	*End quiet
}
*End of ylag loops		
}
*End reg

			
** STACK RESULTS DATASETS 
{
* Make empty dataset 
	clear 
	foreach var in `placeh_num' { 
		gen `var' = .
		}
	foreach var in `placeh_str' { 
		gen `var' = "" 
		}
	save "$temp/est_`Tempshock'_fulldata", replace emptyok

* Loop over dependent variables 
	* Loop over lag lengths 
	foreach ylags in `ylaglist' {	
		* Stack 
		append using "$temp/est_`predictors'_`dv'_`ylags'"
		save "$temp/est_area`area'_fulldata", replace 
	}
	*End ylags
	
}
*End stacking

}
*Next tempshock

** PLOT	
{	
	use "$temp/est_area2_fulldata", clear
	append using "$temp/est_area1_fulldata", gen(shock_global)
	label values shock_global .	// the shock_area = 1 are global shock
	save "$temp/Result", replace
	
	#delimit ;
		twoway	(rarea ul ll h if shock_global == 1, color(blue%10) yaxis(1))
				(rarea ul ll h if shock_global ==0, color(red%10) yaxis(1))
				(connected beta h if shock_global == 1, color(blue) lpattern(solid) msymbol(o) yaxis(1))
				(connected beta h if shock_global == 0, color(red) lpattern(solid) msymbol(o) yaxis(1)),
				
				legend(order(3 "Global temperature shock" 4 "Local temperature shock") position(6) row(1))
				graphregion(color(white)) 
				plotregion(color(white))
				yline(0, lcolor(black) lpattern(solid) lwidth(thin)) 
				xtitle("Years after shock") 
				ytitle("Change in Probability")
				ylabel(#6, format(%9.2f) angle(0))     
				;
		#delimit cr
		
	* Export with higher resolution
	** Change the plot name if needed
	if `maxh' == 50 {
		local fig = "`fig'_h50"
	}
	savefig `fig'				
}
*End plot


}
*End qui
}
*


* {BankRun-rGDP}-----------------------------------------------------------------
{
	
qui{
local fig = "BankRun_rGDP"

** SET PARAMETERS 
{	
	loc maxh 		${`fig'_maxh}	// only this plot uses the 50-year horizon
	loc ylaglist 	${`fig'_ylaglist}
	loc xlags		${xlags}

	* List of dependent variables 
	loc dv 			${`fig'_depvar}

	* List of independent variables
	loc Tempshock	${`fig'_TempShocks} 
	loc predictors 	`Tempshock'
	loc RHS `predictors' ${`fig'_controls} ${FE} ${weight}

	* List of placeholder variables 
	loc placeh_str depvar pred 
	loc placeh_num N h beta se ul ll ylags xlags
}
*End para


** SET UP DATASET 
foreach balanced of global `fig'_balanced {
{	
	* Open estimation file 
	use ISO3 year `dv' `RHS' using "$temp/TempShock_forLPs", clear
	keep if year >= ${`fig'_MinYear} & year <= ${MaxYear}
		
	* Add placeholder variables
	foreach var in `placeh_num' { 
		gen `var' = . 
		}
	foreach var in `placeh_str' { 
		gen `var' = "" 
		}

	* Make changes in and lags of dependent and independent variables over time 
	forvalues h = 0/`maxh' {
		gen FD`h'_`dv' = F`h'.`dv' - L.`dv'	// for LHS
	}
	gen D_`dv' = D.`dv' // for RHS lag controls
	
	
	* Restrict to a balanced dataset
	if `balanced' == 1 {
		egen nmiss = rmiss(FD*_`dv') 	// count the number of missing values in the FD* series
		keep if nmiss == 0				// only keep observations with no missing values across all the FD variables
		drop nmiss		
	}
	
	* Save estimation file 
	save "$temp/est", replace 

}
*End dataset


** ESTIMATE REGRESSIONS 
{
	*** Loop over lag lengths 
	foreach ylags in `ylaglist' {	
		di in red "fig = `fig', y = `dv', lag = `ylags'"
		
	qui {
		* Open estimation file 
		use "$temp/est", clear 
				
		* Loop over horizons 
		forvalues h = 0 / `maxh' {			
			** Add one to `h' such that rows = horizon + 1
			loc row = `h' + 1 
			
			** Estimate regression 
			reghdfe FD`h'_`dv'  `predictors' ///
						L(1/`xlags').`predictors' L(1/`ylags').D_`dv' ${`fig'_cntrls} ///
						[aw = ${weight}] ///
						, absorb(${FE})
						
			** Store estimates in placeholder variables 
				replace depvar	= "`dv'"										in `row'
				replace pred	= "`predictors'"								in `row'
				replace h 		= `h' 											in `row'
				replace beta	= _b[`predictors'] 								in `row'
				replace se		= _se[`predictors'] 							in `row'
				replace ul 		= _b[`predictors'] + ${z1} * _se[`predictors'] 	in `row'
				replace ll 		= _b[`predictors'] - ${z1} * _se[`predictors'] 	in `row'
				replace ylags	= `ylags'										in `row'
				replace N		= e(N)											in `row'
									
			}
			* next hoizon h
				
		* Only keep estimates 
		keep `placeh_num' `placeh_str' // these are lists
		keep if _n <= `maxh' + 1 
				
		* Save temporary file 
		save "$temp/est_`predictors'_`dv'_`ylags'", replace 
	}
	*End quiet
			
}
*End of ylag loops
				
}
*End reg


** STACK RESULTS DATASETS 
{
* Make empty dataset 
	clear 
	foreach var in `placeh_num' { 
		gen `var' = .
		}
	foreach var in `placeh_str' { 
		gen `var' = "" 
		}
	save "$temp/est_`Tempshock'_fulldata", replace emptyok

* Loop over dependent variables 
	* Loop over lag lengths 
	foreach ylags in `ylaglist' {	
		* Stack 
		append using "$temp/est_`predictors'_`dv'_`ylags'"
		save "$temp/est_`Tempshock'_fulldata", replace 
	}
	*End ylags
}
*End stacking


** PLOT	
{	
	tokenize ${`fig'_ylaglist}
	
	use "$temp/est_`Tempshock'_fulldata", clear
	
	#delimit ;
	twoway  (rarea ul ll h if ylags == `1', color(navy%10))
			(rarea ul ll h if ylags == `2', color(maroon%10))
			(rarea ul ll h if ylags == `3', color(forest_green%10))
			
			(connected beta h if ylags == `1', color(navy) lpattern(solid) msymbol(o))
			(connected beta h if ylags == `2', color(maroon) lpattern(solid) msymbol(o))
			(connected beta h if ylags == `3', color(forest_green) lpattern(solid) msymbol(o))
			
			, yline(0, lcolor(black) lpattern(solid) lwidth(thin))    
			xtitle("Years after shock") 
			ytitle("Percent")
			xlabel(0(5)${maxhL}) 
			ylabel(#6, format(%9.0f) angle(0))            
			legend(order(4 "y lag = `1'" 5 "y lag = `2'" 6 "y lag = `3'") position(6) row(1))
			;
	#delimit cr
	
	* Export with higher resolution
	if `balanced' == 1 {
		local fig = "`fig'_balanced"
	}
	savefig `fig'				
}
*End plot

}
*next balanced

}
*End quiet

}
*



* clear all the temp files
if "`c(os)'" == "Windows" {
	shell del /Q "$temp"
}

else {
	shell rm /Q "$temp"
}

	
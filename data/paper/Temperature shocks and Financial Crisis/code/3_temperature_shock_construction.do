
* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCT GLOBAL AND LOCAL TEMPERATURE SHOCK
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

/*
This file generate the global and local temperature shocks using Hamilton filter. 

Before running, ensure that the DTA files of temperature data are ready in these two folders: 
	1) data/Berkeley Earth/country-by-country-DTA
	2) data/Berkeley Earth/global-DTA
	
If not, run the R file 1_ExtractTemperature.R to extract data.

*/


	
*===============================================================================
* Hamilton filter GLOBAL temperature shock
*===============================================================================
{	
clear
tempfile Tempshock
save `Tempshock', replace emptyok	

* gen the year
	local ThisYear = year(date(c(current_date), "DMY"))
	set obs `=`ThisYear'-1750' 
	gen Year = 1750 + _n - 1


* merge in global temp data
	merge 1:1 Year using "$GlobalTempData/summ1750", keepusing(Annual_Anomaly) nogen
	merge 1:1 Year using "$GlobalTempData/summ1850", keepusing(Annual_Anomaly_*) nogen 

	rename 	(Annual_Anomaly Annual_Anomaly_Air 	Annual_Anomaly_Water	Year) ///
			(Land 			LandOcean_Air 		LandOcean_Water			year)
	
	
* Hamilton filter
{
	tsset year
		
	// specify the horrizon and lags (different groups for robustness check)
	local H = 2
	local L = 2
	
	foreach var in Land LandOcean_Air LandOcean_Water {
		reg `var' L(`H'/`=`H' + `L'').`var'
		predict `var'_Shock_`H'_`L', residuals
	}
}
}
	save "$temp/GlobalTempshock_Types", replace
*

*===============================================================================
* Hamilton filter LOCAL temperature shock
*===============================================================================
{
clear
tempfile Tempshock
save `Tempshock', replace emptyok	


* Loop for all the countries, stack in the same dta
{
	local filelist: dir "$TemperatureData" files "*_TAVG_Trend.dta"
	foreach file of local filelist {
	* Import the data
		local countryname = substr("`file'", 1, strlen("`file'") - 15)
		use Year Month Anomaly ISO3 using "$TemperatureData/`countryname'_TAVG_Trend", clear
		tempfile country_TempShock
		save `country_TempShock', replace
		
	* Append to the accumulated dta
		use `Tempshock', clear
		append using `country_TempShock'
		save `TempShock', replace
		}

		rename Year year
}

	
* Hamilton Filter
	// Convert: month -> year using year average
	gegen temp_ano_year_III = mean(Anomaly), by(ISO3 year)
	keep ISO3 year temp_ano_year_III
	duplicates drop
	
	egen id = group(ISO3)
	xtset id year
		
	// specify the horrizon and lags (different groups for robustness check)
		forval H = 1/3 {
		forval L = 1/3 {
			reg temp_ano_year_III L(`H'/`=`H' + `L'').temp_ano_year_III
			predict TempShock_III_`H'_`L', residuals
		}	
		}
	drop id	
}
	save "$temp/Tempshock_Types", replace
*

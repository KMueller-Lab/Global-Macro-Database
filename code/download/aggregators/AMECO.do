* ==============================================================================
* GLOBAL CREDIT DATABASE
* by Karsten Müller, Ziliang Chen, and Mohamed Lehbib
* ==============================================================================
* DOWNLOAD DATA FROM AMECO
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-11-06
*
* Description: 
* This stata script downloads data from AMECO 
* 
* ==============================================================================

* Run the master file
do "code/0_master.do"

cap {

clear 
* Define output file name 
global output "${data_raw}\aggregators\AMECO\AMECO"


* Create the temporary file to save the dataset 
clear 
tempfile temp_master
save `temp_master', replace emptyok

* First batch
local databases NPTN ZUTN ZCPIH ZCPIX UCNT UITT UIGT USGN USNN UVGD UXGS UMGS UUTG URTG UTTT UDGGL

foreach database of local databases {
	
	qui readhtmltable "https://ec.europa.eu/economy_finance/ameco/wq/series?fullVariable=1.0.0.0.`database'&defaultCountries=1&Yearorder=ASC", varnames
	qui count 
	if r(N) > 0 {
		
		* Display results
		di "Data added for `database'"
		qui missings dropvars, force
		* Reshape
		qui greshape long _, i(Country Label Unit) j(year) string
		
		* Add code column
		qui gen code = "`database'"
		local database value
		ren _ `database'
		
		* Append
		qui append using `temp_master'
		qui save `temp_master', replace
		
		
	}
	else {
		di "No data for `database'"
	}	
	
}


* Second batch
local databases ILN ISN OMGS OMSN OMGN OXGS OXSN OXGN OVGD OIGT OITT OCNT OCCG OCTH
foreach database of local databases {
	
	qui readhtmltable "https://ec.europa.eu/economy_finance/ameco/wq/series?fullVariable=1.1.0.0.`database'&defaultCountries=1&Yearorder=ASC", varnames
		qui count 
		if r(N) > 0 {
			

			* Display results
			di "Data added for `database'"
			qui missings dropvars, force
			
			* Reshape
			qui greshape long _, i(Country Label Unit) j(year) string
			
			* Add code column
			qui gen code = "`database'"
			local database value
			ren _ `database'

			
			* Append
			qui append using `temp_master'
			qui save `temp_master', replace
			
			
		}
		else {
			di "No data for `database'"
		}	
}

* Save download date 
gmdsavedate, source(AMECO)

* Save
savedelta ${output}, id(year code Country)

}

* Create the log
clear
set obs 1
gen variable = "AMECO"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save
save "$data_temp/download_log/AMECO_log.dta", replace

 * ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD DATA FROM WEO
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2025-09-20
*
* Description: 
* This Stata script downloads the World Economic Outlook data from the IMF
*
* Data source: IMF API
* ==============================================================================


do "code/0_master.do"

cap {

global output "${data_raw}/aggregators/IMF/IMF_WEO"
cd "$output"

global Rterm_path "/usr/local/bin/R"
global Rterm_options "--vanilla --slave"

rsource, terminator(END)


library(rsdmx)
library(tidyverse)
library(haven)


flowref <- 'IMF.RES,WEO'
filter <- '..A'

# Use dsd = TRUE to include series-level attributes like ESTIMATES_START_AFTER
# This attribute indicates the year after which data is forecast (not actual)
dataset1 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter,
                     dsd        = TRUE)

# Convert to dataframe with labels to get all attributes
df1 <- as.data.frame(dataset1, labels = TRUE)

# The ESTIMATES_START_AFTER column will be included if available
# This indicates the last year of actual data (values after this are forecasts)
write_csv(df1, "IMF_WEO.csv")

q()  

END


cd "$path"

* Save download date 
gmdsavedate, source(IMF_WEO)

}

* Create the log
clear
set obs 1
gen variable = "IMF_WEO"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save
save "$data_temp/download_log/IMF_WEO_log.dta", replace


/* Run the master file: Previous iteration code
do "code/0_master.do"

cap {


global output "${data_raw}/aggregators/IMF/IMF_IFS/IMF_IFS"


* Make empty file 
clear 
tempfile temp_master
save `temp_master', replace emptyok

* Store the variable codes in a local
local codes NGDP_XDC ENDA_XDC_USD_RATE EREER_IX FPOLM_PA BCAXF_BP6_USD LP_PE_NUM LUR_PT ///
			BGS_BP6_USD NFI_XDC NI_XDC NM_XDC NX_XDC NC_XDC  PCPI_IX PCPI_PC_CP_A_PT  ///
			EDNE_USD_XDC_RATE NGDP_R_XDC NC_R_XDC FITB_PA FIGB_PA

* Loop over all the codes
foreach code of local codes {
	di "Downloading `code'"
	local url "http://dataservices.imf.org/REST/SDMX_XML.svc/CompactData/IFS/A..`code'."
	cap copy "`url'" "imf_cp.csv", replace
	cap import delimited "imf_cp.csv", clear
	
	* Extract data from XML
	if _rc == 0 {
		qui keep v1
		* First, let's clean up the data
		qui replace v1 = strtrim(v1)

		* Create variables to store the extracted data
		qui gen date = ""
		qui gen value = ""
		qui gen ISO2 = ""
		qui gen indicator = ""
		qui gen unit_mult = ""

		* Extract country (REF_AREA) 
		qui replace ISO2 = regexs(1) if regexm(v1, `"REF_AREA="([A-Z0-9_]+)""')

		* Extract indicator 
		qui replace indicator = regexs(1) if regexm(v1, `"INDICATOR="([A-Z0-9_]+)""')

		* Extract date 
		qui replace date = regexs(1) if regexm(v1, `"TIME_PERIOD="([0-9]{4}-[0-9]{2}|[0-9]{4}-Q[1-4]|[0-9]{4})""')

		* Extract value 
		qui replace value = regexs(1) if regexm(v1, `"OBS_VALUE="([-0-9\.]+)""')
		
		* Extract unit multiplier 
		qui replace unit_mult = regexs(1) if regexm(v1, `"UNIT_MULT="([-0-9\.]+)""')

		* Fill down metadata
		foreach var of varlist unit_mult ISO2 indicator {
			qui replace `var' = `var'[_n-1] if `var' == ""
		}
		qui keep date value indicator ISO2 unit_mult
		sort ISO2 indicator date 
		
		* Extract country name
		qui merge m:1 ISO2 using $isomapping, keepus(ISO3) nogen

		* Append
		qui append using `temp_master'
		qui save `temp_master', replace 
	}
	
	else {
		di "`code' of doesn't have data"
	}

}

* Drop regional aggregates 
drop if regexm(ISO2, "([-0-9\.]+)")

* Fix ISO3 codes 
replace ISO3 = "SUN" if ISO2 == "SUH"
replace ISO3 = "YUG" if ISO2 == "YUC"
replace ISO3 = "CSK" if ISO2 == "CSH"
 

* Drop empty rows 
drop if date == ""
drop ISO2

* Save download date 
gmdsavedate, source(IMF_IFS)

* Save
savedelta ${output}, id(date ISO3 indicator)




}

* Create the log
clear
set obs 1
gen variable = "IMF_IFS"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save
save "$data_temp/download_log/IMF_IFS_log.dta", replace

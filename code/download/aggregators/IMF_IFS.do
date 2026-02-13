* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD DATA FROM IMF
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-04-09
*
* Description: 
* This Stata script downloads various macroeconomic variables from the IMF API
* 
* Data source: IMF API
* ==============================================================================


do "code/0_master.do"

cap {


global output "${data_raw}/aggregators/IMF/IMF_IFS"
cd "$output"

global Rterm_path "/usr/local/bin/R"
global Rterm_options "--vanilla --slave"

rsource, terminator(END)


library(rsdmx)
library(tidyverse)
library(haven)

# nGDP and rGDP
flowref <- 'IMF.STA,ANEA'
filter <- '.B1GQ..XDC.A'

dataset1 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter)

df1 <- as.data.frame(dataset1)

filter2 <- '.P51G.V.XDC.A'
dataset2 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter2)
df2 <- as.data.frame(dataset2)

filter3 <- '.P5.V.XDC.A'
dataset3 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter3)
df3 <- as.data.frame(dataset3)

filter4 <- '.P7.V.XDC.A'
dataset4 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter4)
df4 <- as.data.frame(dataset4)

filter5 <- '.P6.V.XDC.A'
dataset5 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter5)
df5 <- as.data.frame(dataset5)

filter6 <- '.P3.V.XDC.A'
dataset6 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter6)
df6 <- as.data.frame(dataset6)




# Exchange_rate
flowref <- 'IMF.STA,ER'
filter1 <- '.USD_XDC.EOP_RT.A'
dataset1 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter1)
df7 <- as.data.frame(dataset1)


# REER
flowref <- 'IMF.STA,EER'
filter <- '.REER_IX_RY2010_ACW_RCPI.A'

dataset1 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter)

df8 <- as.data.frame(dataset1)



# CPI
# Standard reference period (2010=100), Index
flowref <- 'IMF.STA,CPI'
filter <- '.CPI._T.SRP_IX.A'

dataset1 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter)

df9 <- as.data.frame(dataset1)

# Standard reference period (2010=100), Period average, Period-over-period percent change
filter2 <- '.CPI._T.SRP_POP_PCH_PA_PT.A'
dataset2 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter2)
df10 <- as.data.frame(dataset2)


# Interest rate
flowref <- 'IMF.STA,MFS_IR'
filter <- '.S13BOND_RT_PT_A_PT.A'

dataset1 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter)

df11 <- as.data.frame(dataset1)

filter2 <- '.GSTBILY_RT_PT_A_PT.A'
dataset2 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter2)
df12 <- as.data.frame(dataset2)

filter3 <- '.MFS166_RT_PT_A_PT.A'
dataset3 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter3)
df13 <- as.data.frame(dataset3)

filter3 <- '.DISR_RT_PT_A_PT.A'
dataset3 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter3)
df14 <- as.data.frame(dataset3)

# Balance of Payments
flowref <- 'IMF.STA,BOP'
filter <- '.NETCD_T.CAB..A'

dataset1 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter)

df15 <- as.data.frame(dataset1)

#Unemployment
flowref <- 'IMF.STA,LS'
filter <- '.U.PT.A'

dataset1 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter)

df16 <- as.data.frame(dataset1)

#Monetary aggregates
flowref <- 'IMF.STA,MFS_MA'
filter <- '...A'

dataset1 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter)

df17 <- as.data.frame(dataset1)
combined_df <- bind_rows(df1, df2, df3, df4, df5, df6, df7, df8, df9, df10, df11, df12, df13, df14, df15, df16, df17)
write_csv(combined_df, "IMF_IFS.csv")


q()  

END


cd "$path"

* Save download date 
gmdsavedate, source(IMF_IFS)
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

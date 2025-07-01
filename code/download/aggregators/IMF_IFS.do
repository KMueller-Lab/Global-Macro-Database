* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Ziliang Chen, and Mohamed Lehbib
* ==============================================================================
* DOWNLOAD INTERNATIONAL FINANCIAL STATISTICS (IFS) DATA FROM IMF
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-04-09
*
* Description: 
* This Stata script downloads various macroeconomic variables from the IMF using the DBnomics API
*
* This code downloads:
* Variable Descriptions
* (1)  NGDP_XDC          ---- Gross Domestic Product, Nominal, Domestic Currency
* (2)  NGDP_R_XDC        ---- Gross Domestic Product, Real, Domestic Currency
* (3)  ENDA_XDC_USD_RATE ---- USD Rate, Period Average
* (4)  EREER_IX          ---- Exchange Rates, Real Effective Exchange Rate based on Consumer Price Index, Index
* (5)  FPOLM_PA          ---- Financial, Interest Rates, Monetary Policy-Related Interest Rate, Percent per annum
* (6)  BCAXF_BP6_USD     ---- Balance of Payments, Supplementary Items, Current Account, Net (excluding exceptional financing), US Dollars
* (7)  LP_PE_NUM         ---- Population, Persons, Number of
* (8)  LUR_PT            ---- Labor Markets, Unemployment Rate, Percent
* (9)  BGS_BP6_USD       ---- Balance of Payments, Current Account, Goods and Services, Net, US Dollars
* (10) NFI_XDC           ---- Gross Fixed Capital Formation, Nominal, Domestic Currency
* (11) NI_XDC            ---- Gross Capital Formation, Nominal, Domestic Currency
* (12) NM_XDC            ---- Imports of Goods and Services, Nominal, Domestic Currency
* (13) NX_XDC            ---- Exports of Goods and Services, Nominal, Domestic Currency
* (14) NC_XDC            ---- Final Consumption Expenditure, Nominal, Domestic Currency
* (15) PCPI_IX           ---- Prices, Consumer Price Index, All items, Index
* (16) PCPI_PC_CP_A_PT   ---- Prices, Consumer Price Index, All items, Percentage change, Corresponding period previous year, Percent
* (17) NGDP_D_IX         ---- Gross Domestic Product, Deflator, Index
* (28) EDNE_USD_XDC_RATE ---- Exchange Rates, US Dollar per Domestic Currency, End of Period
* Data source:
* DBnomics API
* 
* Last downloaded:
* 2024-07-19
*
* =========================================================

global output "${data_raw}/aggregators/IMF/IMF_IFS"


* Make empty file 
clear 
tempfile temp_master
save `temp_master', replace emptyok



* Get the codes 
local codes NGDP_XDC ENDA_XDC_USD_RATE EREER_IX FPOLM_PA BCAXF_BP6_USD LP_PE_NUM LUR_PT BGS_BP6_USD NFI_XDC NI_XDC NM_XDC NX_XDC NC_XDC  PCPI_IX PCPI_PC_CP_A_PT EDNE_USD_XDC_RATE NGDP_R_XDC NC_R_XDC FITB_PA FIGB_PA

* Loop over all the codes
foreach code of local codes {
	di "Downloading `code'"
	local url "http://dataservices.imf.org/REST/SDMX_XML.svc/CompactData/IFS/A..`code'."
	cap copy "`url'" "imf_cp.csv", replace
	cap import delimited "imf_cp.csv", clear
	
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


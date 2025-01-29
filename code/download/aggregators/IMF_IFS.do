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

* Extracting the country's names for the loop
dbnomics data, pr(IMF) d(IFS) clear

* Drop regional aggregates from the countries list
drop if regexm(value, "[0-9]") & dimensions == "REF_AREA"
drop if seriescount == . & dimensions == "REF_AREA"

* Download data for each country and append only for Real GDP 
glevelsof values if dimensions == "REF_AREA", local(countries) clean
foreach country in `countries' {
	
	di "Downloading data for `country'"

	* Define variables to be downloaded
	local variables NGDP_R_XDC NC_R_XDC

	* Loop over all variables starting with the second, download data, and append to master file
	foreach var of local variables {
		
		di "Downloading data for `var'"
		
		* Get data from dbnomics 
		cap dbnomics import, provider(IMF) dataset(IFS) FREQ(A) INDICATOR(`var') REF_AREA(`country') clear
		
		* Display an error-value when the country has no data
		if _rc == 0 {
			di as error "Country `country' has no data for the variable `var'"
		}
		
		* Change every column size to the length of the largest row
		qui ds, has(type string)
		foreach var in `r(varlist)' {
			qui replace `var' = strtrim(`var')
			qui gen length = strlen(`var')
			qui su length
			qui recast str`r(max)' `var', force
			qui drop length
		}

		* If variable is a string, replace "NA" and destring 
		cap ds value, has(type numeric)
		if _rc != 111 {
			if "`r(varlist)'" != "value" {
			replace value = "" if value == "NA"
			destring value period, replace
			}
		}
		
		
		
		* Append and save 
		qui append using `temp_master'
		qui save `temp_master', replace
	}
}



* Download other variables
local variables NGDP_XDC  ENDA_XDC_USD_RATE EREER_IX FPOLM_PA BCAXF_BP6_USD LP_PE_NUM LUR_PT BGS_BP6_USD NFI_XDC NI_XDC NM_XDC NX_XDC NC_XDC  PCPI_IX PCPI_PC_CP_A_PT EDNE_USD_XDC_RATE
foreach var of local variables {
		
		di "Downloading data for `var'"
		
		* Get data from dbnomics 
		dbnomics import, provider(IMF) dataset(IFS) FREQ(A) INDICATOR(`var') clear
		
		* Change every column size to the length of the largest row
		qui ds, has(type string)
		foreach var in `r(varlist)' {
			qui replace `var' = strtrim(`var')
			qui gen length = strlen(`var')
			qui su length
			qui recast str`r(max)' `var', force
			qui drop length
		}

		* If variable is a string, replace "NA" and destring 
		cap ds value, has(type numeric)
		if _rc != 111 {
			if "`r(varlist)'" != "value" {
			replace value = "" if value == "NA"
			destring value period, replace
			}
		}
		
		* Append and save 
		qui append using `temp_master'
		qui save `temp_master', replace
}



* Only keep relevant information
replace indicator = "NGDP_R_XDC" if strpos(series_name, "Gross Domestic Product, Real")
replace indicator = "NC_R_XDC" if strpos(series_name, "Final Consumption Expenditure, Real")
replace ref_area = REF_AREA if ref_area == ""
keep period value indicator ref_area series_name

* Assert that country and year uniquely identify observations
isid ref_area period indicator


* Save download date 
gmdsavedate, source(IMF_IFS)

* Save
savedelta ${output}, id(period ref_area indicator)


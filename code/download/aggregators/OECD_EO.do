* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Last Editor:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-05-14
* Last updated: 2024-06-05
*
* Description: 
* This Stata script downloads relevant variable from the OECD Economic outlook publication using DBnomics API
* 
* Input: NA 
*
* Output: A structured dataset containing relevant economic variables from the OECD, organized by country and time period.
*
* Data source:
* Organisation for Economic Co-operation and Development
* 
* Last downloaded:
* 2024-06-05
*
* ==============================================================================

clear

* Define output file name 
global output "${data_raw}\aggregators\OECD\OECD_EO"

* Create master tempfile to store all the datasets
tempfile temp_master
save `temp_master', replace emptyok

* Nominal GDP in LCU
dbnomics import, provider(OECD) dataset(EO) FREQUENCY(A) VARIABLE(GDP) clear
destring value, replace 
tempfile temp_nGDP
save `temp_nGDP', replace emptyok
append using `temp_master'
save `temp_master', replace

* Real GDP
dbnomics import, provider(OECD) dataset(EO) FREQUENCY(A) VARIABLE(GDPV) clear
destring value, replace 
tempfile temp_rGDP
save `temp_rGDP', replace emptyok
append using `temp_master'
save `temp_master', replace

* CPI
dbnomics import, provider(OECD) dataset(EO) FREQUENCY(A) VARIABLE(CPIH) clear
tempfile temp_CPI
save `temp_CPI', replace emptyok
append using `temp_master'
save `temp_master', replace

* Total population
dbnomics import, provider(OECD) dataset(EO) FREQUENCY(A) VARIABLE(POP) clear
destring value, replace 
tempfile temp_POP
save `temp_POP', replace emptyok
append using `temp_master'
save `temp_master', replace

* Total gross fixed capital formation
dbnomics import, provider(OECD) dataset(EO) FREQUENCY(A) VARIABLE(IT) clear
destring value, replace 
tempfile temp_IT
save `temp_IT', replace emptyok
append using `temp_master'
save `temp_master', replace

* Private final consumption expenditure, nominal value, GDP expenditure approach
dbnomics import, provider(OECD) dataset(EO) FREQUENCY(A) VARIABLE(CP) clear
destring value, replace 
tempfile temp_cons_HH
save `temp_cons_HH', replace emptyok
append using `temp_master'
save `temp_master', replace

* Government final consumption expenditure, nominal value, GDP expenditure approach
dbnomics import, provider(OECD) dataset(EO) FREQUENCY(A) VARIABLE(CG) clear
destring value, replace 
tempfile temp_cons_gov
save `temp_cons_gov', replace emptyok
append using `temp_master'
save `temp_master', replace

* Exports in LCU
dbnomics import, provider(OECD) dataset(EO) FREQUENCY(A) VARIABLE(XGS) clear
destring value, replace 
tempfile temp_XGS
save `temp_XGS', replace emptyok
append using `temp_master'
save `temp_master', replace

* Exports in LCU
dbnomics import, provider(OECD) dataset(EO) FREQUENCY(A) VARIABLE(XGSD) clear
destring value, replace 
tempfile temp_XGSD
save `temp_XGS', replace emptyok
append using `temp_master'
save `temp_master', replace

* Imports in LCU
dbnomics import, provider(OECD) dataset(EO) FREQUENCY(A) VARIABLE(MGS) clear
destring value, replace 
tempfile temp_MGS
save `temp_MGS', replace emptyok
append using `temp_master'
save `temp_master', replace

* Imports in USD
dbnomics import, provider(OECD) dataset(EO) FREQUENCY(A) VARIABLE(MGSD) clear
destring value, replace 
tempfile temp_MGSD
save `temp_MGS', replace emptyok
append using `temp_master'
save `temp_master', replace

* Exchange rate, USD per national currency
dbnomics import, provider(OECD) dataset(EO) FREQUENCY(A) VARIABLE(EXCH) clear
destring value, replace 
tempfile temp_EXCH
save `temp_EXCH', replace emptyok
append using `temp_master'
save `temp_master', replace

* Real effective exchange rate
dbnomics import, provider(OECD) dataset(EO) FREQUENCY(A) VARIABLE(EXCHER) clear
destring value, replace 
tempfile temp_EXCHER
save `temp_EXCHER', replace emptyok
append using `temp_master'
save `temp_master', replace

* Current account balance as a percentage of GDP
dbnomics import, provider(OECD) dataset(EO) FREQUENCY(A) VARIABLE(CBGDPR) clear
destring value, replace 
tempfile temp_CBGDPR
save `temp_CBGDPR', replace emptyok
append using `temp_master'
save `temp_master', replace

* General government gross financial liabilities as a percentage of GDP (govdebt_GDP)
dbnomics import, provider(OECD) dataset(EO) FREQUENCY(A) VARIABLE(GGFLQ) clear
destring value, replace 
tempfile temp_GGFLQ
save `temp_GGFLQ', replace emptyok
append using `temp_master'
save `temp_master', replace

* Short-term interest rate
dbnomics import, provider(OECD) dataset(EO) FREQUENCY(A) VARIABLE(IRS) clear
destring value, replace 
tempfile temp_IRS
save `temp_IRS', replace emptyok
append using `temp_master'
save `temp_master', replace

* Central bank key interest rate
dbnomics import, provider(OECD) dataset(EO) FREQUENCY(A) VARIABLE(IRCB) clear
replace value = "" if value == "NA"
destring value, replace
tempfile temp_IRCB
save `temp_IRCB', replace emptyok
append using `temp_master'
save `temp_master', replace

* Unemployment rate
dbnomics import, provider(OECD) dataset(EO) FREQUENCY(A) VARIABLE(UNR) clear
destring value, replace 
tempfile temp_UNR
save `temp_UNR', replace emptyok
append using `temp_master'
save `temp_master', replace

* Harmonised headline inflation
dbnomics import, pr(OECD) dataset(EO) FREQUENCY(A) VARIABLE(CPIH_YTYPCT) clear
destring value, replace 
tempfile temp_infl
save `temp_infl', replace emptyok
append using `temp_master'
save `temp_master', replace

* Gross capital formation, total, nominal value
dbnomics import, pr(OECD) dataset(EO) FREQUENCY(A) VARIABLE(ITISK) clear
destring value, replace 
tempfile temp_inv
save `temp_inv', replace emptyok
append using `temp_master'
replace FREQUENCY = variable
drop variable
ren FREQUENCY indicator
save `temp_master', replace

* Total expenditure of general government, percentage of GDP
dbnomics import, pr(OECD) dataset(NAAG) INDICATOR(TES13S) clear
destring value, replace 
tempfile temp_govexp_gdp
save `temp_govexp_gdp', replace emptyok
append using `temp_master'
save `temp_master', replace

* Total general government (GG) revenue, percentage of GDP
dbnomics import, pr(OECD) dataset(NAAG) INDICATOR(TRS13S) clear
destring value, replace 
tempfile temp_REVENUE_GDP
save `temp_REVENUE_GDP', replace emptyok
append using `temp_master'
save `temp_master', replace

* Total taxes, percentage of GDP
dbnomics import, pr(OECD) dataset(NAAG) INDICATOR(D2D5D91RS13S) clear
destring value, replace 
tempfile temp_TAXES_GDP
save `temp_TAXES_GDP', replace emptyok
append using `temp_master'
save `temp_master', replace

* Net lending/net borrowing, General government, percentage of GDP
dbnomics import, pr(OECD) dataset(NAAG) INDICATOR(B9S13S) clear
destring value, replace 
tempfile temp_DEFICIT_GDP
save `temp_DEFICIT_GDP', replace emptyok
append using `temp_master'

* Save download date 
gmdsavedate, source(OECD_EO)

* Save
savedelta ${output}, id(period location series_code dataset_code)

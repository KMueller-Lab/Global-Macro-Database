* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD DATA FROM AFRICAN DEVELOPMENT BANK
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-22
*
* Description: 
* This Stata script downloads economic data from the African Development Bank
*
* Data source:
* DBnomics API
*
* ==============================================================================

* ==============================================================================
* 	INITIAL SET-UP
* ==============================================================================

clear
global output "${data_raw}\aggregators\AFDB\AFDB"

* Create a temporary file where to save the datasets.
tempfile temp_master
save `temp_master', replace emptyok

* ==============================================================================
* 	MONETARY AGGREGATE (M1)
* ==============================================================================

* Download and save
dbnomics import, pr(AFDB) d(bbkawjf) indicator(FM.LBL.MONY.CN) clear

* Save
append using `temp_master'
save `temp_master', replace


* ==============================================================================
* 	GDP (national currency)
* ==============================================================================

* Download and save
dbnomics import, pr(AFDB) d(bbkawjf) indicator(NY.GDP.MKTP.CN) clear
replace value = "" if value == "NA"
destring value, replace

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 	MONETARY AGGREGATE (M2)
* ==============================================================================

* Download and save
dbnomics import, pr(AFDB) d(bbkawjf) indicator(FM.LBL.MQMY.CN) clear

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 	Tax Revenue
* ==============================================================================
* Download and save
dbnomics import, pr(AFDB) d(bbkawjf) indicator(GC.REV.TAX.GD.CN) clear

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 	Central government, total revenue and grants  (% of GDP)
* ==============================================================================
* Download and save
dbnomics import, pr(AFDB) d(bbkawjf) indicator(GC.REV.TOTL.GD.ZS) clear

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 	Central government, total revenue and grants 
* ==============================================================================
* Download and save
dbnomics import, pr(AFDB) d(bbkawjf) indicator(GC.REV.TOTL.GD.CN) clear

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 	Central government, total expenditure and net lending  (% of GDP)
* ==============================================================================
* Download and save
dbnomics import, pr(AFDB) d(bbkawjf) indicator(GC.XPN.TOTL.GD.ZS) clear

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 	Central government, total expenditure and net lending
* ==============================================================================
* Download and save
dbnomics import, pr(AFDB) d(bbkawjf) indicator(GC.XPN.TOTL.GD.CN) clear

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 	Central government, Fiscal Balance (% of GDP)
* ==============================================================================
* Download and save
dbnomics import, pr(AFDB) d(bbkawjf) indicator(GC.BAL.CASH.GD.ZS) clear

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 	Central government, Fiscal Balance (% of GDP)
* ==============================================================================
* Download and save
dbnomics import, pr(AFDB) d(bbkawjf) indicator(GC.BAL.CASH.GD.CN) clear

* Save
append using `temp_master'
save `temp_master', replace


* ==============================================================================
* 	Unemployment rate, (aged 15 over) (%)
* ==============================================================================

* Download and save
dbnomics import, pr(AFDB) d(bbkawjf) indicator(SL.TLF.15UP.UEM) clear

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 	Total Employment, Population ('000)
* ==============================================================================

* Download and save
dbnomics import, pr(AFDB) d(bbkawjf) indicator(LM.POP.EPP.TOT) clear

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 	Output
* ==============================================================================
* Save download date 
gmdsavedate, source(AFDB)

* Save
savedelta ${output}, id(period country series_code)

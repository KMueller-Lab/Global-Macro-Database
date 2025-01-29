* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Description: 
* This Stata script reads in and clean historical debt statistics from Carmen Reinhart webiste
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 16-06-2024 
*
* URL: https://carmenreinhart.com/debt-to-gdp-ratios/
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
* Clear panel
clear

* Define input and output files
global input "${data_raw}/aggregators/RR/RR_debt.xlsx"
global output "${data_clean}/aggregators/RR/RR_debt.dta"
* ==============================================================================
* 	PROCESS
* ==============================================================================
import excel using "$input", clear first

* Destring
destring govdebt_GDP, replace
drop D E

* Rename
ren govdebt_GDP RR_debt_govdebt_GDP

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace

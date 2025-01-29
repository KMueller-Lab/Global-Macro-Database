* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-10-17
*
* Description: 
* This Stata script cleans data on banking crises from Reinhart and Rogoff (2009).
*
* ==============================================================================
*
* ==============================================================================
*			SET UP
* ==============================================================================

clear
global input "${data_raw}/aggregators/RR/Reinhart-Rogoff.xlsx"
global output "${data_clean}/aggregators/RR/RR"

* ==============================================================================
* Clean data 
* ==============================================================================



* Open
import excel "$input", clear first
drop in 1

* Only keep relevant columns, rename 
keep CC3 Country Year BankingCrisis Domestic_Debt_In_Default SOVEREIGNEXTERNALDEBT1DEFAU SOVEREIGNEXTERNALDEBT2DEFAU CurrencyCrises
ren (CC3 Country Year BankingCrisis Domestic_Debt_In_Default SOVEREIGNEXTERNALDEBT1DEFAU SOVEREIGNEXTERNALDEBT2DEFAU CurrencyCrises) (ISO3 country_name year RR_crisisB RR_crisisDD RR_crisisED1 RR_crisisED2 RR_crisisC)

* Clean 
foreach var in RR_crisisB RR_crisisDD RR_crisisED1 RR_crisisED2 RR_crisisC {
	
	* Clean variables 
	replace `var' = "" if `var' == "n/a"
	replace `var' = "1" if `var' == "2"
	replace `var' = "1" if regexm(`var',"Hyperinflation")
	destring `var', replace

	* Only keep first of several consecutive years of crisis 
	sort ISO3 year 
	gen begin = 0 if `var'!=.
	bysort ISO3: replace begin = 1 if `var' == 1 & ( `var'!= `var'[_n-1] | (_n == 1) )
	drop `var'
	ren begin `var'
	
}

* Clean ISO 3 code 
replace ISO3 = trim(ISO3)

* Drop
drop country_name
* ==============================================================================
* 	Output
* ==============================================================================

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace

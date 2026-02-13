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
* URL (Inflation data, chapter 5, table 5.4): https://carmenreinhart.com/this-time-is-different/ 
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
* Clear panel
clear

* Define input and output files
global crises "${data_raw}/aggregators/RR/Reinhart-Rogoff.xlsx"
global debt "${data_raw}/aggregators/RR/RR_debt.xlsx"
global infl 	"${data_raw}/aggregators/RR/RR_infl.xlsx" 
global output "${data_clean}/aggregators/RR/RR.dta"
* ==============================================================================
* 	PROCESS
* ==============================================================================
import excel using "$debt", clear first

* Destring
destring govdebt_GDP, replace

* Add general and central government based on the note 
gen RR_gen_govdebt_GDP = govdebt_GDP if D == "gen"
gen RR_cgovdebt_GDP = govdebt_GDP if D == ""

* Keep 
keep ISO3 year RR*

* Save 
tempfile temp_master
save `temp_master', replace

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open
import excel using "$infl", sheet("Inflation_1800_2014") clear cellrange(B5:DN223)

* Drop documentation and empty columns
drop Q R S T U W Y AM AN AO AP AQ AS AU BO BP BQ BR BS BU BW CQ CR CS CT CU CW CY DC DD DE DF DG DI DK V Z AR AV BT BX CV CZ DH DL DJ BV AT X CX

* Rename
qui ds B, not
foreach var in `r(varlist)'{
	local newname = `var'[1] + " " + `var'[2] + " " + `var'[3]
	cap ren `var' `newname'
}
ren (B E F M AB AH AL AW BM BN CD CE CG DB DN Morrocco Korea Russia) (year CAF CIV ZAF HKG MMR THA AUT TUR GBR CRI DOM SLV USA NZL MAR KOR RUS)
drop in 1/4

* Reshape
qui ds year, not
foreach var in `r(varlist)'{
	ren `var' RR_infl`var'
}
greshape long RR_infl, i(year) j(countryname) string

* Get ISO3 codes 
merge m:1 countryname using $isomapping, keepus(ISO3) keep(1 3)
replace ISO3 = countryname if _merge == 1

* Drop 
drop countryname _merge

* Destring
destring year RR_infl, replace

* Merge 
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
* Clean data 
* ==============================================================================

* Open
import excel "$crises", clear first
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

* Merge 
merge 1:1 ISO3 year using `temp_master', nogen

* Drop data for Hungary in 1946
replace RR_infl = . if year == 1946

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

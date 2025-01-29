* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* Clean West African economic data from BCEAO (Banque Communaute Economique Afrique de L'Ouest)
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-15
*
* Description: 
* This Stata script downloads economic data for West African currency union members
*
* Methodology used to construct monetary aggregates follows that of the region's central bank.
* C.f: https://www.bceao.int/sites/default/files/2017-12/bulletin_de_statistiques_monetaires_et_financieres_-_septembre_2005.pdf
* ==============================================================================
*
* ==============================================================================
*			SET UP
* ==============================================================================

clear
global input "${data_raw}/aggregators/BCEAO/BCEAO"
global rates "${data_raw}/aggregators/BCEAO/rates"
global output "${data_clean}/aggregators/BCEAO/BCEAO"

* ==============================================================================
* Clean data 
* ==============================================================================

* Open
use "${input}", clear

* Drop regional aggregate
drop if strpos(series_name, "UMOA")

* Drop missing values
drop if value == "NA"

* Extract countries' ISO3 codes
gen ISO3 = ""
replace ISO3 = "CIV" if strpos(series_name, "COTE D'IVOIRE")
replace ISO3 = "SEN" if strpos(series_name, "SENEGAL")
replace ISO3 = "MLI" if strpos(series_name, "MALI")
replace ISO3 = "NER" if strpos(series_name, "NIGER")
replace ISO3 = "BEN" if strpos(series_name, "BENIN")
replace ISO3 = "BFA" if strpos(series_name, "BURKINA FASO")
replace ISO3 = "GNB" if strpos(series_name, "GUINEE BISSAU")
replace ISO3 = "TGO" if strpos(series_name, "TOGO")

* Clean the sereis_name column
replace series_name = trim(substr(series_name, strpos(series_name, "–") + 4, .))
replace series_name = trim(subinstr(series_name, ".", "", .))

* Extract indicator
gen indicator = ""

* Extract real GDP indicator
replace indicator = "rGDP" if label == "SR1015A0BQ" & dataset_code == "PIBC" // PRODUIT INTERIEUR BRUT (PIB): PIB ET SES EMPLOIS A PRIX CONSTANT Base 100 =2008 (en milliards de FCFA)
replace indicator = "inv" 	   if label == "SR1037A0BP" & dataset_code == "IMECO" // Investissement (en milliards de F CFA)

* Drop all other constant variables
drop if indicator == "" & dataset_code == "PIBC"
drop if indicator == "" & dataset_code == "IMECO"

* Extract indicators for the rest of the data
replace indicator = "nGDP" 	if label == "SR1015A0BP" // PIB nominal (en milliards de FCFA) 
replace indicator = "cons" 		if label == "SR1016A0BP" // CONSOMMATION FINALE
replace indicator = "finv" 		if label == "SR1019A0BP" // FORMATION BRUTE DU CAPITAL FIXE (FBCF)
replace indicator = "exports" 	if label == "SR1023A0BP" // EXPORTATIONS DE BIENS ET SERVICES N F
replace indicator = "imports" 	if label == "SR1024A0BP" // IMPORTATIONS DE BIENS ET SERVICES N F
replace indicator = "CPI" 		if label == "SR3017A0BP" // INDICE DES PRIX A LA CONSOMMATION ANNUEL: Ensemble
replace indicator = "govrev" 	if label == "FP1001A0AP" // Recettes totales et dons (R1)
replace indicator = "govtax" 	if label == "FP1004A0AP" // Recettes fiscales
replace indicator = "govexp" 	if label == "FP1023A0AP" // Depenses totales et prets nets (D1)
replace indicator = "govdef"	if label == "FP1042A0AP" // Solde budgetaire global, hors dons (base engagement) (R2 - D1)
replace indicator = "M0_bis" 	if label == "SF1270A0AP" // Circulation fiduciaire
replace indicator = "M0" 		if label == "SF1400A0AP" // Circulation fiduciaire (Same as the previous, different dataset)
replace indicator = "M1_2" 		if label == "SF1271A0AP" // Depots en CCP
replace indicator = "M1_3" 		if label == "SF1272A0AP" // Depots en CNE
replace indicator = "M1_4" 		if label == "SF1284A0AP" // Depots a vue en banque
replace indicator = "M2_1" 		if label == "SF1285A0AP" // Depots a terme en banque
replace indicator = "M1" 		if label == "SF1408A0AP" // Agregats de Monnaie - M1
replace indicator = "M2" 		if label == "SF1412A0AP" // Agregats de Monnaie - M2
replace indicator = "CA"   	if label == "SE1007A0AP" // 3BALANCE DES BIENS ET SERVICES

* Keep relevant columns and rows
keep period value ISO3 indicator
drop if indicator == ""

* Reshape
greshape wide value, i(ISO3 period) j(indicator)

* Rename
ren value* * 
ren period year

* Destring
ds ISO3, not
destring `r(varlist)', replace

* Calculate current account balance and monetary aggregates based on their components
replace M1_3 = 0 if M1_3 == . // The reason for this is to ensure the components sum up without being affected by M1_3 missing values.
gen M1_bis = M0_bis + M1_2 + M1_3 + M1_4 // Methodology used follows the region's central bank in constructing monetary aggregates. Refer to Link in description.
gen M2_bis = M1_bis + M2_1

* Drop 
drop M0_* M1_* M2_*

* Convert units
qui ds ISO3 year CPI CA, not
foreach var in `r(varlist)'{
	qui replace `var' = `var' * 1000
}

* Investment is negative for Mali and Niger
replace inv = . if inv < 0

* Scale by GDP
qui gen CA_GDP = CA/nGDP  * 100
qui gen govdef_GDP = govdef / nGDP * 100
qui gen govexp_GDP = govexp / nGDP * 100
qui gen govtax_GDP = govtax / nGDP * 100
qui gen govrev_GDP = govrev / nGDP * 100

* Derive inflation rate
sort ISO3 year
encode ISO3, gen(id)
xtset id year
by id: gen infl = (CPI - L.CPI) / L.CPI * 100 if L.CPI != .
drop id

* Save
tempfile temp_master
save `temp_master', replace

* ==============================================================================
* 	Add rates data
* ==============================================================================

import excel using "$rates", clear first

* Add country names
gen BEN = TESC
gen BFA = TESC
gen CIV = TESC
gen NER = TESC
gen SEN = TESC
gen MLI = TESC
gen TGO = TESC
gen GNB = TESC

* Keep only relevant variables
drop TPEN TESC TINB P_*

* Extract dates
gen year = substr(Périodes, 1, 4)
gen quarter = substr(Périodes, -1, 1)
drop Périodes

* Destring
destring *, replace

* Reshape
qui ds year quarter, not
foreach var in `r(varlist)'{
	ren `var' cbrate`var'
}
greshape long cbrate, i(year quarter) j(ISO3) string

* Keep end-of-year values
sort ISO3 year quarter
by ISO3 year: keep if _n == _N
drop quarter

* Guinee-Bissau joined BCEAO zone only in 1997
replace cbrate = . if ISO3 == "GNB" & year < 1997

* Merge
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* Add ratios to gdp variables
gen cons_GDP    = (cons / nGDP) * 100
gen imports_GDP = (imports / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100
gen finv_GDP    = (finv / nGDP) * 100
gen inv_GDP     = (inv / nGDP) * 100


* ==============================================================================
* 	Output
* ==============================================================================
* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	ren `var' BCEAO_`var'
}

* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace

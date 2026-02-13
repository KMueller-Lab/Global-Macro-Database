* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* ADD INCOME CLASSIFICATION BY THE WORLD BANK
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2025-12-11
*
* Data source: WORLD BANK
* URL: https://datahelpdesk.worldbank.org/knowledgebase/articles/906519-world-bank-country-and-lending-groups
* ==============================================================================

* ==============================================================================
* SET UP
* ==============================================================================

* IMPORT THE FILE 
import excel using "$data_raw/aggregators/WB/WB_classification.xlsx", first clear 

* Keep 
keep Code Income

* Rename 
ren (Code Income) (ISO3 income_group)

* Drop empty rows
drop in 219/l

* Drop Channel Islands 
drop if ISO3 == "CHI"

* Save 
save "$data_helper/WB_income_groups", replace



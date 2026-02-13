* ==============================================================================
* CREATE DERIVED VARIABLES 
* ==============================================================================
* Version
local version $current_version

* ==============================================================================
* CENTRAL GOVERNMENT FINANCES 
* ==============================================================================
* Central government revenue 
use "$data_final/chainlinked_cgovrev_GDP", clear 
keep ISO3 year cgovrev_GDP source 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen cgovrev = (cgovrev_GDP * nGDP) / 100
replace source = "Derived using data on central government revenue to GDP from " + source + " and the spliced GDP"
save "$data_final/chainlinked_cgovrev", replace
export delimited using "$data_distr/cgovrev_`version'.csv", replace datafmt 

* Central government expenditure 
use "$data_final/chainlinked_cgovexp_GDP", clear 
keep ISO3 year cgovexp_GDP source 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen cgovexp = (cgovexp_GDP * nGDP) / 100
replace source = "Derived using data on central government expenditure to GDP from " + source + " and the spliced GDP"
save "$data_final/chainlinked_cgovexp", replace
export delimited using "$data_distr/cgovexp_`version'.csv", replace datafmt

* Central government tax revenue 
use "$data_final/chainlinked_cgovtax_GDP", clear 
keep ISO3 year cgovtax_GDP source 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen cgovtax = (cgovtax_GDP * nGDP) / 100
replace source = "Derived using data on central government tax revenue to GDP from " + source + " and the spliced GDP"
save "$data_final/chainlinked_cgovtax", replace
export delimited using "$data_distr/cgovtax_`version'.csv", replace datafmt

* Central government debt  
use "$data_final/chainlinked_cgovdebt_GDP", clear 
keep ISO3 year cgovdebt_GDP source 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen cgovdebt = (cgovdebt_GDP * nGDP) / 100
replace source = "Derived using data on central government debt to GDP from " + source + " and the spliced GDP"
save "$data_final/chainlinked_cgovdebt", replace
export delimited using "$data_distr/cgovdebt_`version'.csv", replace datafmt

* Central government deficit
use "$data_final/chainlinked_cgovdef_GDP", clear 
keep ISO3 year cgovdef_GDP source 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen cgovdef = (cgovdef_GDP * nGDP) / 100
replace source = "Derived using data on central government deficit to GDP from " + source + " and the spliced GDP"
save "$data_final/chainlinked_cgovdef", replace
export delimited using "$data_distr/cgovdef_`version'.csv", replace datafmt

* ==============================================================================
* GENERAL GOVERNMENT FINANCES 
* ==============================================================================
* General government revenue 
use "$data_final/chainlinked_gen_govrev_GDP", clear 
keep ISO3 year gen_govrev_GDP source 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen gen_govrev = (gen_govrev_GDP * nGDP) / 100
replace source = "Derived using data on general government revenue to GDP from " + source + " and the spliced GDP"
save "$data_final/chainlinked_gen_govrev", replace
export delimited using "$data_distr/gen_govrev_`version'.csv", replace datafmt

* General government expenditure 
use "$data_final/chainlinked_gen_govexp_GDP", clear 
keep ISO3 year gen_govexp_GDP source 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen gen_govexp = (gen_govexp_GDP * nGDP) / 100
replace source = "Derived using data on general government expenditure to GDP from " + source + " and the spliced GDP"
save "$data_final/chainlinked_gen_govexp", replace
export delimited using "$data_distr/gen_govexp_`version'.csv", replace datafmt

* General government tax revenue 
use "$data_final/chainlinked_gen_govtax_GDP", clear 
keep ISO3 year gen_govtax_GDP source 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen gen_govtax = (gen_govtax_GDP * nGDP) / 100
replace source = "Derived using data on general government tax revenue to GDP from " + source + " and the spliced GDP"
save "$data_final/chainlinked_gen_govtax", replace
export delimited using "$data_distr/gen_govtax_`version'.csv", replace datafmt

* General government debt  
use "$data_final/chainlinked_gen_govdebt_GDP", clear 
keep ISO3 year gen_govdebt_GDP source 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen gen_govdebt = (gen_govdebt_GDP * nGDP) / 100
replace source = "Derived using data on general government debt to GDP from " + source + " and the spliced GDP"
save "$data_final/chainlinked_gen_govdebt", replace
export delimited using "$data_distr/gen_govdebt_`version'.csv", replace datafmt

* General government deficit
use "$data_final/chainlinked_gen_govdef_GDP", clear 
keep ISO3 year gen_govdef_GDP source 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen gen_govdef = (gen_govdef_GDP * nGDP) / 100
replace source = "Derived using data on general government deficit to GDP from " + source + " and the spliced GDP"
save "$data_final/chainlinked_gen_govdef", replace
export delimited using "$data_distr/gen_govdef_`version'.csv", replace datafmt

* ==============================================================================
* CONSOLIDATED GOVERNMENT VARIABLE TO GDP RATIO
* ==============================================================================
* Government revenue to GDP ratio
use "$data_final/chainlinked_gen_govrev_GDP", clear 
keep ISO3 year gen_govrev_GDP
merge 1:1 ISO3 year using "$data_final/chainlinked_cgovrev_GDP", keepus(cgovrev) nogen
merge 1:1 ISO3 year using "$data_temp/blank_panel", nogen
ren cgovrev_GDP c_govrev_GDP
splice, priority(gen c) generate(govrev_GDP) varname(govrev_GDP) method("none") base_year(2019) save("NO")
keep ISO3 year govrev_GDP 
gen source = "Derived using spliced data on general government revenue to GDP and central government revenue to GDP"
save "$data_final/chainlinked_govrev_GDP", replace
export delimited using "$data_distr/govrev_`version'.csv", replace datafmt

* Government deficit to GDP ratio
use "$data_final/chainlinked_gen_govdef_GDP", clear 
keep ISO3 year gen_govdef_GDP
merge 1:1 ISO3 year using "$data_final/chainlinked_cgovdef_GDP", keepus(cgovdef) nogen
merge 1:1 ISO3 year using "$data_temp/blank_panel", nogen
ren cgovdef_GDP c_govdef_GDP
splice, priority(gen c) generate(govdef_GDP) varname(govdef_GDP) method("none") base_year(2019) save("NO")
keep ISO3 year govdef_GDP 
gen source = "Derived using spliced data on general government deficit to GDP and central government revenue to GDP"
save "$data_final/chainlinked_govdef_GDP", replace
export delimited using "$data_distr/govdef_`version'.csv", replace datafmt

* Government expenditure to GDP ratio 
use "$data_final/chainlinked_gen_govexp_GDP", clear 
keep ISO3 year gen_govexp_GDP
merge 1:1 ISO3 year using "$data_final/chainlinked_cgovexp_GDP", keepus(cgovexp) nogen
merge 1:1 ISO3 year using "$data_temp/blank_panel", nogen
ren cgovexp_GDP c_govexp_GDP
qui splice, priority(gen c) generate(govexp_GDP) varname(govexp_GDP) method("none") base_year(2019) save("NO")
keep ISO3 year govexp_GDP 
gen source = "Derived using spliced data on general government expenditure to GDP and central government revenue to GDP"
save "$data_final/chainlinked_govexp_GDP", replace
export delimited using "$data_distr/govexp_`version'.csv", replace datafmt

* Government debt to GDP ratio 
use "$data_final/chainlinked_gen_govdebt_GDP", clear 
keep ISO3 year gen_govdebt_GDP
merge 1:1 ISO3 year using "$data_final/chainlinked_cgovdebt_GDP", keepus(cgovdebt) nogen
merge 1:1 ISO3 year using "$data_temp/blank_panel", nogen
ren cgovdebt_GDP c_govdebt_GDP
qui splice, priority(gen c) generate(govdebt_GDP) varname(govdebt_GDP) method("none") base_year(2019) save("NO")
keep ISO3 year govdebt_GDP 
gen source = "Derived using spliced data on general government debt to GDP and central government debt to GDP"
save "$data_final/chainlinked_govdebt_GDP", replace
export delimited using "$data_distr/govdebt_`version'.csv", replace datafmt

* Government tax to GDP ratio 
use "$data_final/chainlinked_gen_govtax_GDP", clear 
keep ISO3 year gen_govtax_GDP
merge 1:1 ISO3 year using "$data_final/chainlinked_cgovtax_GDP", keepus(cgovtax) nogen
merge 1:1 ISO3 year using "$data_temp/blank_panel", nogen
ren cgovtax_GDP c_govtax_GDP
qui splice, priority(gen c) generate(govtax_GDP) varname(govtax_GDP) method("none") base_year(2019) save("NO")
keep ISO3 year govtax_GDP 
gen source = "Derived using spliced data on general government tax to GDP and central government revenue to GDP"
save "$data_final/chainlinked_govtax_GDP", replace
export delimited using "$data_distr/govtax_`version'.csv", replace datafmt

* ==============================================================================
* CONSOLIDATED GOVERNMENT FINANCES LEVELS
* ==============================================================================
* General government revenue 
use "$data_final/chainlinked_govrev_GDP", clear 
keep ISO3 year govrev_GDP 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen govrev = (govrev_GDP * nGDP) / 100
gen source = "Derived using data on general government revenue to GDP and central government and the spliced GDP."
save "$data_final/chainlinked_govrev", replace
export delimited using "$data_distr/govrev_`version'.csv", replace datafmt

* General government expenditure 
use "$data_final/chainlinked_govexp_GDP", clear 
keep ISO3 year govexp_GDP 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen govexp = (govexp_GDP * nGDP) / 100
gen source = "Derived using data on general government expenditure to GDP and central government and the spliced GDP."
save "$data_final/chainlinked_govexp", replace
export delimited using "$data_distr/govexp_`version'.csv", replace datafmt

* General government tax revenue 
use "$data_final/chainlinked_govtax_GDP", clear 
keep ISO3 year govtax_GDP 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen govtax = (govtax_GDP * nGDP) / 100
gen source = "Derived using data on general government tax revenue to GDP and central government and the spliced GDP."
save "$data_final/chainlinked_govtax", replace
export delimited using "$data_distr/govtax_`version'.csv", replace datafmt

* General government debt  
use "$data_final/chainlinked_govdebt_GDP", clear 
keep ISO3 year govdebt_GDP 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen govdebt = (govdebt_GDP * nGDP) / 100
gen source = "Derived using data on general government debt to GDP and central government and the spliced GDP."
save "$data_final/chainlinked_govdebt", replace
export delimited using "$data_distr/govdebt_`version'.csv", replace datafmt


* General government deficit
use "$data_final/chainlinked_govdef_GDP", clear 
keep ISO3 year govdef_GDP 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen govdef = (govdef_GDP * nGDP) / 100
gen source = "Derived using data on general government deficit to GDP and central government and the spliced GDP."
save "$data_final/chainlinked_govdef", replace
export delimited using "$data_distr/govdef_`version'.csv", replace datafmt


* ==============================================================================
* VARIABLES IN LEVELS AND IN CAPITA 
* ==============================================================================

* Current account balance 
use "$data_final/chainlinked_CA_GDP", clear 
keep ISO3 year CA_GDP source 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen CA = (CA_GDP * nGDP) / 100
replace source = "Derived using data on current account balance to GDP from " + source + " and the spliced GDP"
save "$data_final/chainlinked_CA", replace
export delimited using "$data_distr/CA_`version'.csv", replace datafmt

* Real GDP per capita 
use "$data_final/chainlinked_rGDP", clear 
keep ISO3 year rGDP source 
merge 1:1 ISO3 year using "$data_final/chainlinked_pop", keepus(pop) keep(3) nogen
gen rGDP_pc = rGDP / pop
replace source = "Derived using data on real GDP from " + source + " and the spliced population"
save "$data_final/chainlinked_rGDP_pc", replace
export delimited using "$data_distr/rGDP_pc_`version'.csv", replace datafmt

* Deflator 
use "$data_final/chainlinked_nGDP", clear 
keep ISO3 year nGDP source
ren source source_nGDP
merge 1:1 ISO3 year using "$data_final/chainlinked_rGDP", keepus(rGDP source) keep(3) nogen
gen deflator = nGDP / rGDP
ren source source_rGDP
gen source = "Derived using data on nominal GDP from " + source_nGDP + " and the spliced real GDP with data from " + source_rGDP
drop source_nGDP source_rGDP
save "$data_final/chainlinked_deflator", replace
export delimited using "$data_distr/deflator_`version'.csv", replace datafmt


* ==============================================================================
* VARIABLES IN USD 
* ==============================================================================
* Nominal GDP in USD 
use "$data_final/chainlinked_nGDP", clear 
keep ISO3 year nGDP source 
merge 1:1 ISO3 year using "$data_final/chainlinked_USDfx", keepus(USDfx) keep(3) nogen
gen nGDP_USD = (nGDP / USDfx)
replace source = "Derived using data on nominal GDP from " + source + " and the spliced USD exchange rate"
save "$data_final/chainlinked_nGDP_USD", replace
export delimited using "$data_distr/nGDP_USD_`version'.csv", replace datafmt

* Exports in USD 
use "$data_final/chainlinked_exports", clear 
keep ISO3 year exports source 
merge 1:1 ISO3 year using "$data_final/chainlinked_USDfx", keepus(USDfx) keep(3) nogen
gen exports_USD = (exports / USDfx)
replace source = "Derived using data on exports from " + source + " and the spliced USD exchange rate"
save "$data_final/chainlinked_exports_USD", replace
export delimited using "$data_distr/exports_USD_`version'.csv", replace datafmt

* Imports in USD 
use "$data_final/chainlinked_imports", clear 
keep ISO3 year imports source 
merge 1:1 ISO3 year using "$data_final/chainlinked_USDfx", keepus(USDfx) keep(3) nogen
gen imports_USD = (imports / USDfx)
replace source = "Derived using data on imports from " + source + " and the spliced USD exchange rate"
save "$data_final/chainlinked_imports_USD", replace
export delimited using "$data_distr/imports_USD_`version'.csv", replace datafmt

* CA in USD 
use "$data_final/chainlinked_CA", clear 
keep ISO3 year CA source 
merge 1:1 ISO3 year using "$data_final/chainlinked_USDfx", keepus(USDfx) keep(3) nogen
gen CA_USD = (CA / USDfx)
replace source = "Derived using data on CA from " + source + " and the spliced USD exchange rate"
save "$data_final/chainlinked_CA_USD", replace
export delimited using "$data_distr/CA_USD_`version'.csv", replace datafmt

* Investment in USD 
use "$data_final/chainlinked_inv", clear 
keep ISO3 year inv source 
merge 1:1 ISO3 year using "$data_final/chainlinked_USDfx", keepus(USDfx) keep(3) nogen
gen inv_USD = (inv / USDfx)
replace source = "Derived using data on investment from " + source + " and the spliced USD exchange rate"
save "$data_final/chainlinked_inv_USD", replace
export delimited using "$data_distr/inv_USD_`version'.csv", replace datafmt

* Fixed investment in USD 
use "$data_final/chainlinked_finv", clear 
keep ISO3 year finv source 
merge 1:1 ISO3 year using "$data_final/chainlinked_USDfx", keepus(USDfx) keep(3) nogen
gen finv_USD = (finv / USDfx)
replace source = "Derived using data on fixed investment from " + source + " and the spliced USD exchange rate"
save "$data_final/chainlinked_finv_USD", replace
export delimited using "$data_distr/finv_USD_`version'.csv", replace datafmt

* Consumption in USD 
use "$data_final/chainlinked_cons", clear 
keep ISO3 year cons source 
merge 1:1 ISO3 year using "$data_final/chainlinked_USDfx", keepus(USDfx) keep(3) nogen
gen cons_USD = (cons / USDfx)
replace source = "Derived using data on consumption from " + source + " and the spliced USD exchange rate"
save "$data_final/chainlinked_cons_USD", replace
export delimited using "$data_distr/cons_USD_`version'.csv", replace datafmt

* Real GDP per capita in USD 
use "$data_final/chainlinked_rGDP_USD", clear 
keep ISO3 year rGDP_USD 
merge 1:1 ISO3 year using "$data_final/chainlinked_pop", keepus(pop) keep(3) nogen
gen rGDP_pc_USD = (rGDP_USD / pop)
gen source = "Derived using data on real GDP in USD and the spliced population series"
save "$data_final/chainlinked_rGDP_pc_USD", replace
export delimited using "$data_distr/rGDP_pc_USD_`version'.csv", replace datafmt

* ==============================================================================
* VARIABLES IN GDP 
* ==============================================================================

* Exports in GDP 
use "$data_final/chainlinked_exports", clear 
keep ISO3 year exports source 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen exports_GDP = (exports / nGDP)
replace source = "Derived using data on exports from " + source + " and the spliced GDP"
save "$data_final/chainlinked_exports_GDP", replace
export delimited using "$data_distr/exports_GDP_`version'.csv", replace datafmt

* Imports in GDP 
use "$data_final/chainlinked_imports", clear 
keep ISO3 year imports source 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen imports_GDP = (imports / nGDP)
replace source = "Derived using data on imports from " + source + " and the spliced GDP"
save "$data_final/chainlinked_imports_GDP", replace
export delimited using "$data_distr/imports_GDP_`version'.csv", replace datafmt

* Investment in GDP 
use "$data_final/chainlinked_inv", clear 
keep ISO3 year inv source 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen inv_GDP = (inv / nGDP)
replace source = "Derived using data on investment from " + source + " and the spliced GDP"
save "$data_final/chainlinked_inv_GDP", replace 
export delimited using "$data_distr/inv_GDP_`version'.csv", replace datafmt
* Fixed investment in GDP 
use "$data_final/chainlinked_finv", clear 
keep ISO3 year finv source 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen finv_GDP = (finv / nGDP)
replace source = "Derived using data on fixed investment from " + source + " and the spliced GDP"
save "$data_final/chainlinked_finv_GDP", replace
export delimited using "$data_distr/finv_GDP_`version'.csv", replace datafmt
* Consumption in GDP 
use "$data_final/chainlinked_cons", clear 
keep ISO3 year cons source 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", keepus(nGDP) keep(3) nogen
gen cons_GDP = (cons / nGDP)
replace source = "Derived using data on consumption from " + source + " and the spliced GDP"
save "$data_final/chainlinked_cons_GDP", replace
export delimited using "$data_distr/cons_GDP_`version'.csv", replace datafmt

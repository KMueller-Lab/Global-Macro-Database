* This file create a list of variables

import delimited using "$data_helper/sources.csv", clear bindquote(strict) varnames(1)
bys source_abbr: keep if _n == 1
gen source_name = "" 
order source_name
replace source_name = source_abbr if !strpos(data_clean, "country_level")
replace source_name = "CS" + substr(source_abbr, -1, 1) + "_" + substr(source_abbr, 1, 3) if strpos(data_clean, "country_level")
keep source_name 
export delimited using "$data_helper/source_list.csv", replace 



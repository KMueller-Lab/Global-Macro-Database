* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD UN DATA
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-05-14d
*
* Description: 
* This Stata script downloads UN DATA
* 
* Data source:
* UN DATA
* 
* ==============================================================================
  
* Define output file name 
global output "${data_raw}\aggregators\UN\UN"

* Download the GDP data
import delimited "https://data.un.org/_Docs/SYB/CSV/SYB66_230_202310_GDP%20and%20GDP%20Per%20Capita.csv", clear varnames(2)
tempfile temp_master
save `temp_master', replace

import delimited "https://data.un.org/_Docs/SYB/CSV/SYB66_1_202310_Population,%20Surface%20Area%20and%20Density.csv", clear varnames(2)
append using `temp_master'

* Rename the v2 column as country
ren v2 country

* Assert that country and year uniquely identify observations
isid country series year

* Save download date 
gmdsavedate, source(UN)

* Save
savedelta ${output}, id(country year series)

* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN Real EXCHANGE RATE DATA FROM Bruegel
* 
* Description: 
* This stata script cleans on real exchange rates from Bruegel.
*
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-05-05
*
* URL: https://www.bruegel.org/publications/datasets/real-effective-exchange-
*rates-for-178-countries-a-new-database (Archived: 2024-09-25)
* ==============================================================================

* ==============================================================================
* SET UP
* ==============================================================================

* Clear data 
clear 

* Define input and output files 
global input "${data_raw}/aggregators/Bruegel/Bruegel_reer.xls"
global output "${data_clean}/aggregators/Bruegel/Bruegel.dta"

* ==============================================================================
* PROCESS DATA
* ==============================================================================

* Open file
import excel using "${input}", clear sheet(REER_ANNUAL_65)

* Rename
ren A year
ds year, not
foreach var in `r(varlist)' {
    local newname = `var'[1]
    ren `var' `newname'
}
drop in 1

* Reshape 
drop if year == ""
greshape long REER_65_, i(year) j(country) string

* Convert ISO2 to ISO3
ren country ISO2
drop if ISO2 == "EA"
replace ISO2 = "RS" if ISO2 == "SQ" // Serbia
merge m:1 ISO2 using ${isomapping}, nogen assert(2 3) keep(3) keepusing(ISO3)
drop ISO2

* Rename
ren REER_65_ BRUEGEL_REER

* Destring
destring year BRUEGEL_REER, replace

* Sort
sort ISO3 year

* Rebase to 2010
bysort ISO3: egen REER_2010 = mean(BRUEGEL_REER) if year == 2010
bysort ISO3: egen REER_2010_all = mean(REER_2010)
gen BRUEGEL_REER_2010 = (BRUEGEL_REER * 100) / REER_2010_all
drop REER_2010 REER_2010_all BRUEGEL_REER

* Rename 
ren BRUEGEL_REER_2010 BRUEGEL_REER

* Rebase to 2010
replace BRUEGEL_REER = 100 if ISO3 == "ARG" & year == 2010 // Value equal to 99.99999, we could also format the number 
replace BRUEGEL_REER = 100 if ISO3 == "TKM" & year == 2010 // Value equal to 99.99999, we could also format the number 

* ==============================================================================
* OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid year ISO3 

* Save
save "${output}", replace

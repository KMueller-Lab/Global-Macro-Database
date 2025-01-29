* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Description: 
* This Stata script opens and cleans historical macroeconomic data on Latin 
* American countries from the MOXLAD Latin American Economic History Database.
*
* Author:
* Karsten Müller
* National University of Singapore
* 
* Created: 2024-09-25
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================


* Clear data 
clear

* Define input and output files
global input "${data_raw}/aggregators/MOXLAD/MOxLAD-2023-10-21_04-43.xls"
global output "${data_clean}/aggregators/MOXLAD/MOXLAD"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open  
import excel using "${input}", clear 

* Drop last row
drop in 145

* Reshape 
ds A, not
greshape gather `r(varlist)', by(A) values(temp) 

* Assign description to variables 
gen desc = ""
unique _key
forval num = 1/`r(unique)' {
	local key = _key[`num']
	local val = temp[`num']
	replace desc = "`val'" if _key == "`key'"
}

* Only keep relevant rows 
drop if inlist(A,"Years","Title","Unit")
drop _key 
ren A year 
destring year, replace 

* Get values 
destring temp, replace 

* Get country and variable names 
gen countryname = substr(desc,1,strpos(desc,"-")-1)
gen varname = substr(desc,strpos(desc,"-")+1,strlen(desc))
replace varname = "MOXLAD_CPI" if varname == "IPC_IPC"
replace varname = "MOXLAD_deflator" if varname == "CCN_DEF_1970"
replace varname = "MOXLAD_nGDP" if varname == "CCN_PBI_C"
replace varname = "MOXLAD_pop" if varname == "POB_POB"
replace varname = "MOXLAD_USDfx" if varname == "CCN_TCN_LCU"

* Keep relevant variables only, reshape 
drop if inlist(varname,"CCN_DEF_1970","CCN_DEF_1970_UML")
drop desc 

* Make ISO codes 
kountry countryname, from(other) stuck
assert _ISO3N_ != .
ren _ISO3N_ iso3n 
kountry iso3n, from(iso3n) to(iso3c)
ren _ISO3C_ ISO3 
drop iso3n countryname

* Reshape wide 
greshape wide temp, i(ISO3 year) j(varname)
ren temp* *

* Convert pop to million 
replace MOXLAD_pop = MOXLAD_pop / 1000 

* Fix exchange rate  and unit issues

* Argentina
replace MOXLAD_USDfx =  MOXLAD_USDfx / 10000 if year <= 1991 & ISO3 == "ARG"
replace MOXLAD_USDfx =  MOXLAD_USDfx / 1000  if year <= 1984 & ISO3 == "ARG"
replace MOXLAD_USDfx =  MOXLAD_USDfx / 10000 if year <= 1982 & ISO3 == "ARG"
replace MOXLAD_USDfx =  MOXLAD_USDfx / 100 	 if year <= 1969 & ISO3 == "ARG"
replace MOXLAD_nGDP  =  MOXLAD_nGDP / 10000	 if year <= 1991 & ISO3 == "ARG" 
replace MOXLAD_nGDP  =  MOXLAD_nGDP / 1000	 if year <= 1984 & ISO3 == "ARG" 
replace MOXLAD_nGDP  =  MOXLAD_nGDP / 10000  if year <= 1982 & ISO3 == "ARG" 
replace MOXLAD_nGDP  =  MOXLAD_nGDP / 100 	 if year <= 1969 & ISO3 == "ARG" 


* Brazil
replace MOXLAD_USDfx =  MOXLAD_USDfx / 2750  if year <= 1994 & ISO3 == "BRA"
replace MOXLAD_USDfx =  MOXLAD_USDfx / 1000  if year <= 1993 & ISO3 == "BRA"
replace MOXLAD_USDfx =  MOXLAD_USDfx / 1000  if year <= 1988 & ISO3 == "BRA"
replace MOXLAD_USDfx =  MOXLAD_USDfx / 1000  if year <= 1985 & ISO3 == "BRA"
replace MOXLAD_USDfx =  MOXLAD_USDfx / 1000  if year <= 1966 & ISO3 == "BRA"
replace MOXLAD_nGDP  =  MOXLAD_nGDP  / 2750  if year <= 1994 & ISO3 == "BRA"
replace MOXLAD_nGDP  =  MOXLAD_nGDP  / 1000  if year <= 1993 & ISO3 == "BRA"
replace MOXLAD_nGDP  =  MOXLAD_nGDP  / 1000  if year <= 1988 & ISO3 == "BRA"
replace MOXLAD_nGDP  =  MOXLAD_nGDP  / 1000  if year <= 1985 & ISO3 == "BRA"
replace MOXLAD_nGDP  =  MOXLAD_nGDP  / 1000  if year <= 1966 & ISO3 == "BRA"

* Chile 
replace MOXLAD_USDfx =  MOXLAD_USDfx / 1000 if year <= 1975 & ISO3 == "CHL" 

* Mexico
replace MOXLAD_USDfx =  MOXLAD_USDfx / 1000 if year <= 1992 & ISO3 == "MEX"

* Peru
replace MOXLAD_USDfx =  MOXLAD_USDfx / 1000000  if year <= 1990 & ISO3 == "PER"
replace MOXLAD_USDfx =  MOXLAD_USDfx / 1000 	if year <= 1984 & ISO3 == "PER"
replace MOXLAD_nGDP  =  MOXLAD_nGDP * (10^-6)   if year <= 1990 & ISO3 == "PER"
replace MOXLAD_nGDP  =  MOXLAD_nGDP * (10^-3)   if year <= 1984 & ISO3 == "PER"


* Bolivia
replace MOXLAD_USDfx =  MOXLAD_USDfx / 1000000   if year <= 1984 & ISO3 == "BOL"
replace MOXLAD_USDfx =  MOXLAD_USDfx / 1000   if year <= 1962 & ISO3 == "BOL"
replace MOXLAD_nGDP  =  MOXLAD_nGDP   / 1000000  if year <= 1984 & ISO3 == "BOL"
replace MOXLAD_nGDP  =  MOXLAD_nGDP   / 1000 	 if year <= 1962 & ISO3 == "BOL"

* Venezuela
replace MOXLAD_USDfx =  MOXLAD_USDfx / 1000      if ISO3 == "VEN"
replace MOXLAD_nGDP  =  MOXLAD_nGDP   * (10^-14) if ISO3 == "VEN"

* Uruguay
replace MOXLAD_USDfx =  MOXLAD_USDfx / 1000     if year <= 1993 & ISO3 == "URY"
replace MOXLAD_USDfx =  MOXLAD_USDfx / 1000 	if year <= 1974 & ISO3 == "URY"
replace MOXLAD_nGDP  =  MOXLAD_nGDP   * (10^-3) if year <= 1993 & ISO3 == "URY" 
replace MOXLAD_nGDP  =  MOXLAD_nGDP   * (10^-3) if year <= 1974 & ISO3 == "URY" 
replace MOXLAD_USDfx =  .				        if year == 1959 & ISO3 == "URY"  // Value probably wrong

* Nicaragua
replace MOXLAD_USDfx =  MOXLAD_USDfx / 5000000 if year <= 1990 & ISO3 == "NIC"
replace MOXLAD_USDfx =  MOXLAD_USDfx / 1000	   if year <= 1988 & ISO3 == "NIC"
replace MOXLAD_USDfx =  MOXLAD_USDfx / 12.5    if year <= 1912 & ISO3 == "NIC"
replace MOXLAD_nGDP  =  MOXLAD_nGDP / 5000     if year <= 1990 & ISO3 == "NIC"
replace MOXLAD_nGDP  =  MOXLAD_nGDP / 1000 	   if year == 1989 & ISO3 == "NIC"
replace MOXLAD_nGDP  =  MOXLAD_nGDP / 1000	   if year <= 1988 & ISO3 == "NIC"
replace MOXLAD_nGDP  =  MOXLAD_nGDP / 12.5	   if year <= 1912 & ISO3 == "NIC"
replace MOXLAD_nGDP  =  MOXLAD_nGDP / 100	   if year <= 1986 & ISO3 == "NIC" 
replace MOXLAD_nGDP  =  MOXLAD_nGDP / 10	   if ISO3 == "NIC" & inrange(year, 1969, 1972)

* Paraguay
replace MOXLAD_USDfx =  MOXLAD_USDfx / 0.0175 if year <= 1919 & ISO3 == "PRY"
replace MOXLAD_USDfx =  MOXLAD_USDfx / 100 	  if year <= 1942 & ISO3 == "PRY"

* Chile 
replace MOXLAD_nGDP =  MOXLAD_nGDP / 1000 if year <= 1975 & ISO3 == "CHL"
replace MOXLAD_nGDP =  MOXLAD_nGDP / 1000 if year <= 1959 & ISO3 == "CHL"
replace MOXLAD_USDfx =  MOXLAD_USDfx / 1000 if year <= 1959 & ISO3 == "CHL"

* El Salvador
replace MOXLAD_nGDP = MOXLAD_nGDP / 8.75  if ISO3 == "SLV"

* Mexico 
replace MOXLAD_nGDP = MOXLAD_nGDP / 1000  if ISO3 == "MEX" & year < 1993

* Ecuador
replace MOXLAD_nGDP = MOXLAD_nGDP * (10^-3) if ISO3 == "ECU"

* Haiti (Probably wrong exchange rate values)
replace MOXLAD_USDfx = . if year <= 1921 & ISO3 == "HTI"

* Keep relevant, save
keep ISO3 year MOXLAD_* 

* Rebase the CPI to 2000
sort ISO3 year
bysort ISO3: egen CPI_2000 = mean(MOXLAD_CPI) if year == 2000
bysort ISO3: egen CPI_2000_all = mean(CPI_2000)
replace MOXLAD_CPI = (MOXLAD_CPI * 100) / CPI_2000_all

* Drop
drop CPI_2000 CPI_2000_all

* Derive inflation rate
sort ISO3 year
encode ISO3, gen(id)
xtset id year
by id: gen MOXLAD_infl = (MOXLAD_CPI - L.MOXLAD_CPI) / L.MOXLAD_CPI * 100  if L.MOXLAD_CPI != .
drop id

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Check for duplicates
isid year ISO3

* Order
order ISO3 year

* Save
save "${output}", replace


* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and clean historical data for Canada
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2025-06-28
*
* URL: https://onlinelibrary.wiley.com/doi/abs/10.1111/caje.12618
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
* Clear
clear
global input "${data_raw}/country_level/CAN_2"
global output "${data_clean}/country_level/CAN_2"

* ===============================================================================
*	PROCESS
* ===============================================================================

* Open
import delimited using "${input}", clear 

* Extract the year 
gen year = substr(date, 1, 4)
gen qrtr = substr(date, 6, 2)

* Keep needed columns 
keep real_c real_i real_exp real_imp real_gdp c_price i_price exp_price imp_price gdp_price_ind unemp_can m3 m2p m_base1 g_avg_10p tbill_3m usdcad_new cpi_all_can nhouse_p_can year qrtr

* Destring 
destring *, ignore("NA") replace

* Derive nominal values 
gen cons = real_c * c_price / 100
gen finv = real_i * i_price / 100
gen exports = real_exp * exp_price / 100
gen imports = real_imp * imp_price / 100
gen nGDP = real_gdp * gdp_price_ind / 100

* Drop real variabels 
drop real_c real_i real_exp real_imp *price*

* Rename
ren(real_gdp unemp_can m3 m2p m_base1 g_avg_10p tbill_3m usdcad_new cpi_all_can nhouse_p_can) (rGDP unemp M3 M2 M1 ltrate strate USDfx CPI HPI)

* Keep yearly values:
bys year (qrtr): keep if _n == _N
drop qrtr

* Add data identifier
ren * CS2_*

* Add ISO3 
gen ISO3 = "CAN"
ren CS2_year year

* ===============================================================================
* 	Output
* ===============================================================================

* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace

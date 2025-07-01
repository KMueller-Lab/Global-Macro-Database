

* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCT DATASET FOR LOCAL PROJECTIONS
* 
* Author:
* Chenzi Xu
* University of California, Berkeley
*
* Last Editor:
* Yachi Tu
* University of California, Berkeley
*
* Created: 2025-01-15
* Last updated: 2025-01-15
*
* ==============================================================================



*===============================================================================
* Data setup
*===============================================================================
{	
* Merge the temperature and GMP 	
	** adjust the Penn World Table data
	use "$data/pwt1001", clear
	cap rename (countrycode pop) (ISO3 pop_pwt)
	save "$data/pwt1001_adj", replace
	
	** PWT country list 
	keep ISO3
	duplicates drop
	save "$data/pwt1001_countries", replace
	

	
* JST advanced country list
	use "$data/JSTdatasetR6", replace
	keep iso
	duplicates drop
	rename iso ISO3
	gen JST = 1
	save "$data/JST_countrylist", replace
	
	
* Merge the data sources
	use "$data/data_final", clear
	
	// year-country
	merge 1:1 ISO3 year using "$data/GMP_2024_11", nogen keepusing(BankingCrisis)	// merge in the country population data
	merge 1:1 ISO3 year using "$data/chainlinked_rGDP_USD", nogen
	merge 1:1 ISO3 year using "$data/pwt1001_adj", nogen keepusing(rgdp* pop* xr pl*)
	merge 1:1 ISO3 year using "$temp/Tempshock_Types", nogen keepusing(TempShock_*)
	merge 1:1 ISO3 year using "$data/JKMS_bank_runs", nogen keepusing(JKMS_narr_run JKMS_narr_run_idiosync)
	
	// country
	merge m:1 ISO3 using "$data/pwt1001_countries", keepusing(ISO3)
		keep if _m == 3	// only keep countries in PWT table
		drop _m
	merge m:1 ISO3 using "$data/JST_countrylist", nogen
		replace JST = 0 if missing(JST)
		
	// year
	merge m:1 year using "$temp/GlobalTempshock_Types", nogen keepusing(*_Shock_*)	
	merge m:1 year using "$BK\data\micc_data", nogen keepusing(gtmp_noaa_aw_dtfe2s lnrgdppc_world_pwt recessiondates)	// the BK data, for reference	
	
	egen id = group(ISO3)
	
	
	** rename the BK variable
	rename (gtmp_noaa_aw_dtfe2s lnrgdppc_world_pwt JKMS_narr_run JKMS_narr_run_idiosync) (BK_global_tempshock ln_rGDP_pcpt_world_BK BankRun BankRun_idio)
	
	
* Fill the missing value in BankingCrisis
	if ${BKcrisis_Fill0} == 1 {
		replace BankingCrisis = 0 if missing(BankingCrisis)
	}
	
* Fill the missing value in BankRun
	replace BankRun = 0 if missing(BankRun)

* real GDP data
	** Two versions of real GDP data
	gen rGDP_pwt = rgdpna 		// Penn world table data
	gen rGDP_new = rGDP_USD 	// GMD data
	
	** Gen rGDP per capita (country and world avg.)
	gegen pop_world = sum(pop), by(year)
		foreach version in new pwt {
		// country panel	
		gen rGDP_pcpt_`version' = rGDP_`version'/pop
		
		// world
		gegen rGDP_world_`version' = sum(rGDP_`version'), by(year)
		gen ln_rGDP_world_`version' = log(rGDP_world_`version')
		gen rGDP_pcpt_world_`version' = rGDP_world_`version' / pop_world
	
		xtset id year
		gen g_rGDP_world_`version' = D.ln_rGDP_world_`version'
		
		// gen log
		gen ln_rGDP_pcpt_`version' = log(rGDP_pcpt_`version') * 100
		gen ln_rGDP_pcpt_world_`version' = log(rGDP_pcpt_world_`version')*100
		}
	
* Gen fake FE, weight
	gen unweight = 1
	gen noFE = 1
	
	
* Gen GFC
	gegen N_BankingCrisis = sum(BankingCrisis), by(year)
	gen is_adv = 1 if inlist(ISO3, "USA","DEU","GBR","FRA","JPN")
	gen adv_BankingCrisis = BankingCrisis * is_adv
	gegen N_advNBcrisis = sum(adv_BankingCrisis), by(year)
	gen GFC = (N_BankingCrisis > 0)
	drop adv_BankingCrisis is_adv
	
* Gen yearly global banking crisis index
	** 1) number of crisis (the N_BankingCrisis)
	** 2) Share of crisis
	gen rgdp_w = rGDP_new / rGDP_world_new
	gegen Share_BankingCrisis = sum(rgdp_w * BankingCrisis), by(year)
	
	
* Gen Government debt to GDP log (for growth)
	gen ln_govdebt_GDP = log(govdebt_GDP)*100

	save "$temp/TempShock_forLPs", replace
}	
*


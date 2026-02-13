* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* A PROGRAM TO REBASE INDEX OR FIXED PRICE VARIABLES: HPI, CPI, REER, rGDP
* 
* This function rebases HPI, CPI, REER, and rGDP variables to the global $base_year.
* - CPI, HPI, REER: Rebased to index = 100 at base year
* - rGDP: Rebased using nGDP if available (rGDP = nGDP * rGDP_index / 100)
*         If nGDP is not available, rGDP is not rebased.
*
* If a country doesn't have data in $base_year, it uses the most recent 
* available year and adds a note using gmdaddnote_source.
*
* Created: 
* 2025-12-29
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Example: gmd_rebase AMF
* ==============================================================================

cap program drop gmd_rebase
program define gmd_rebase

    * Add arguments - source is required
    syntax anything

    * Parse arguments
    tokenize `anything'
    local source `1'
    
    * Define the list of variables to rebase (index = 100 at base year)
    local index_vars "HPI CPI REER"
    
    * Check if required base variables exist
    cap confirm variable ISO3 year
    if _rc != 0 {
        di as err "Variables ISO3 and year are required"
        exit 498
    }
    
    * =========================================================================
    * REBASE INDEX VARIABLES (CPI, HPI) - Result is index with base year = 100
    * =========================================================================
    foreach varname of local index_vars {
        
        * Check if the variable exists (with source prefix)
        cap confirm variable `source'_`varname'
        if _rc != 0 {
            * Variable doesn't exist, skip to next
            continue
        }
        
        di as text "Rebasing `source'_`varname' to base year $base_year (index = 100)"
        
        * Create rebased variable using bysort method
        qui bysort ISO3: egen `varname'_base = mean(`source'_`varname') if year == $base_year
        qui bysort ISO3: egen `varname'_base_all = mean(`varname'_base)
        qui gen `varname'_rebased = (`source'_`varname' * 100) / `varname'_base_all
        
        * For countries with no data in base year, find the most recent year and add note
        qui levelsof ISO3 if `varname'_base_all == . & `source'_`varname' != ., local(missing_countries) clean
        
        foreach country of local missing_countries {
            * Find the most recent year with data for this country
            qui su year if ISO3 == "`country'" & `source'_`varname' != ., meanonly
            local most_recent_year = r(max) - 1
            
            * Get the base value from the most recent year
            qui su `source'_`varname' if year == `most_recent_year' & ISO3 == "`country'", meanonly
            local alt_base_value = r(mean)
            
            * Rebase using the alternative base year
            qui replace `varname'_rebased = (`source'_`varname' * 100) / `alt_base_value' if ISO3 == "`country'"
            
            * Add a note documenting the alternative base year
            gmdaddnote_source `source' "Rebased to `most_recent_year' because `country' doesn't have data in $base_year." `varname'
            
            di as text "  Note: `country' rebased to `most_recent_year' (no data in $base_year)"
        }
        
        * Replace original variable with rebased values
        qui drop `source'_`varname'
        qui ren `varname'_rebased `source'_`varname'
        qui drop `varname'_base `varname'_base_all
        
        * Sort
        sort ISO3 year
        
        * Assert that the base year value is 100 (round to avoid floating point issues)
        qui count if year == $base_year & `source'_`varname' != .
        if r(N) > 0 {
            cap assert round(`source'_`varname', 1) == 100 if year == $base_year & `source'_`varname' != .
            if _rc != 0 {
                di as err "Warning: `source'_`varname' is not equal to 100 in base year $base_year for some countries"
            }
        }
    }
    
    * =========================================================================
    * REBASE rGDP - Only if nGDP exists (rGDP = nGDP * rGDP_index / 100)
    * =========================================================================
    
    * Check if rGDP variable exists
    cap confirm variable `source'_rGDP
    if _rc == 0 {
        
        * Check if nGDP variable exists
        cap confirm variable `source'_nGDP
        if _rc == 0 {
            
            di as text "Rebasing `source'_rGDP to base year $base_year using nGDP"
            
            * Create index first using bysort method
            qui bysort ISO3: egen rGDP_base = mean(`source'_rGDP) if year == $base_year
            qui bysort ISO3: egen rGDP_base_all = mean(rGDP_base)
			
			* Create rebased rGDP using nGDP: rGDP = nGDP * rGDP_index / 100
			qui bysort ISO3: egen nGDP_base = mean(`source'_nGDP) if year == $base_year
			qui bysort ISO3: egen nGDP_base_all = mean(nGDP_base) 
			
            * Create index (base year = 100)
            qui gen rGDP_index = (`source'_rGDP * 100) / rGDP_base_all
            
            * Create rebased rGDP using nGDP: rGDP = nGDP * rGDP_index / 100
            qui gen rGDP_rebased = (nGDP_base_all * rGDP_index) / 100
            
            * For countries with no data in base year, find the most recent year and add note
            qui levelsof ISO3 if rGDP_base_all == . & `source'_rGDP != . & `source'_nGDP != ., local(missing_countries) clean
            
            foreach country of local missing_countries {
                * Find the most recent year with data for this country
				qui su year if ISO3 == "`country'" & `source'_rGDP != . & `source'_nGDP != .
				local most_recent_year = r(max) - 1
				
				* Get the base value from the most recent year
				qui replace rGDP_base = `source'_rGDP if year == `most_recent_year' & ISO3 == "`country'"
				qui su rGDP_base, meanonly
				qui replace rGDP_base_all = r(mean) if ISO3 == "`country'"
				
				* Create index using alternative base year
				qui replace nGDP_base = `source'_nGDP if year == `most_recent_year' & ISO3 == "`country'"
				qui su nGDP_base, meanonly
				qui replace nGDP_base_all = r(mean) if ISO3 == "`country'"
				
				* Rebased rGDP using nGDP and alternative index
				qui replace rGDP_index = (`source'_rGDP * 100) / rGDP_base_all if ISO3 == "`country'"
				qui replace rGDP_rebased = (nGDP_base_all * rGDP_index) / 100 if ISO3 == "`country'"
				
				* Add a note documenting the alternative base year
				gmdaddnote_source `source' "Rebased to `most_recent_year' because `country' doesn't have data in $base_year." `source'_rGDP
				di as text "  Note: `country' rebased to `most_recent_year' (no data in $base_year)"
            }
            
            * Replace original variable with rebased values
            qui drop `source'_rGDP
            qui ren rGDP_rebased `source'_rGDP
            qui drop *GDP_base *GDP_base_all rGDP_index 
            
            * Sort
            sort ISO3 year
            
            * Assert that nGDP == rGDP in base year (round to avoid floating point issues)
            qui count if year == $base_year & `source'_rGDP != . & `source'_nGDP != .
            if r(N) > 0 {
				qui gen nGDPratio = round(`source'_nGDP / `source'_rGDP , 0.1)
                cap assert nGDPratio == 1 if year == $base_year & `source'_rGDP != . & `source'_nGDP != .
                if _rc != 0 {
                    di as err "Warning: `source'_rGDP is not equal to `source'_nGDP in base year $base_year for some countries"
                }
				else {
					qui drop nGDPratio
				}
            }
        }
        else {
            di as text "Skipping `source'_rGDP rebasing: `source'_nGDP not available"
        }
    }
    
    di as text "Rebasing complete."
end

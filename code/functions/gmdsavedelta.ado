* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CALCULATE AND SAVE DELTA FILES FOR EFFICIENT STORAGE
* 
* Description: 
* This Stata program calculates the delta of the current dataframe and its 
* originally downloaded version, saves the delta, and creates a combined dataset 
* for downstream use.
*
* Created: 
* 2024-09-24
*
* Author:
* Karsten Müller
* National University of Singapore
*
* ==============================================================================

capture program drop savedelta
program define savedelta
syntax anything, id(string)
    * Make sure input does not include ".dta"
    if regexm("`anything'",".dta") {
        di as err "Input should not include .dta ending."
        exit 198
    }
    
    * Validate ID variable exists
    capture confirm variable `id'
    if _rc {
        di as error "ID variable `id' not found in dataset"
        exit 111
    }
    
    * Save temporary file of current data
    qui tempfile new 
    qui save `new'
    
    * Get folder path and ensure Versions subfolder exists
    * Handle both forward and backward slashes
    local anything = subinstr("`anything'","\","/",.)
    loc folder = substr("`anything'",1,strrpos("`anything'","/")-1)
    capture mkdir "`folder'/Versions"
    
    * Check if the target file exists
    capture confirm file "`anything'.dta"
    if _rc == 0 {
        qui use `anything', clear 
        * Merge in new data 
        merge 1:1 `id' using `new', update replace 
        
        * Drop unchanged data points already in the data 
        qui drop if inlist(_merge,1,3)
        
        * Check if there is any change in the dataset (new or revised data)
        qui count 
        
        * If there is no new data relative to the existing dataset, break and 
        * report that, given there is nothing else to do
        if `r(N)' == 0 {
            noisily di as err "No new data relative to existing version, not saved."
            qui use `new', clear 
        }
        * If there is new data, continue with the remaining code
        if `r(N)' > 0 {
            * Classify delta, i.e. new data not yet stored
            qui gen version_delta = ""    
            qui replace version_delta = "New data"         if inlist(_merge,2,4)
            qui replace version_delta = "Revised data"    if _merge == 5
            qui drop _merge 
            
            * Save delta version
            loc date = date(c(current_date),"DMY")
            loc dataset = substr("`anything'",strrpos("`anything'","/") + 1,strlen("`anything'"))
            loc date = string(yofd(`date'))+"_"+string(month(`date'))+"_"+string(day(`date'))
            loc filename = "`folder'/Versions/`dataset'_`date'"
            
            qui save `filename', replace 
            
            * Re-open combined dataset and merge new data
            qui use `anything', clear 
            qui merge 1:1 `id' using `new', update replace nogen
            cap drop version_delta  /* Ensure version_delta is not in main dataset */
            qui save `anything', replace 
            
            noisily di "Delta version saved as `filename'"
        }
    }
    else {
        noisily di "No existing dataset found. Creating new file."
        
        * Save initial version in Versions folder
        loc dataset = substr("`anything'",strrpos("`anything'","/") + 1,strlen("`anything'"))
        loc date = date(c(current_date),"DMY")
        loc date = string(yofd(`date'))+"_"+string(month(`date'))+"_"+string(day(`date'))
        loc filename = "`folder'/Versions/`dataset'_`date'"
        
        * Add version_delta variable for version file only
        preserve
        qui gen version_delta = "Initial version"
        qui save `filename', replace
        restore
        
        * Save main file without version_delta
        qui save `anything', replace
        
        noisily di "Initial version saved as `filename'"
    }
end
* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* MASTER DO FILE 
* 
* Intended to be run using Stata 18.
* 
* Author:
* Karsten Müller
* National University of Singapore
*
* Last Editor:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-01-05
* Last updated: 2024-04-23
*
* ==============================================================================
* Toggle options 
* 
* Turn these options on with a "1" or off with a "0", depending on what you 
* actually want to run.
* ==============================================================================
macro drop _all
global erase		0	// Careful!
global download 	0
global clean		0
global combine		0
global output_data	0
global document 	0
global paper		1
global packages 	0


* ==============================================================================
* Prepare folder paths and define programs 
* ==============================================================================

* Set path folder
if "`c(username)'"=="lehbib"{
	global path "C:/Users/lehbib/Documents/Github/Global-Macro-Project"
}

if "`c(username)'"=="kmueller"{
	global path "C:/Users/kmueller/Desktop/GitHub/Global-Macro-Project"
}

*if "`c(username)'"=="kmueller"{
*	global path "C:/Users/kmueller/Desktop/GitHub/Global-Macro-Project"
*	global dropbox "C:/Users/kmueller/Müller Lab Dropbox/Karsten Müller/Global-Macro-Project"
*}

if "`c(username)'"=="simonchen"{
	global path "/Users/simonchen/Documents/GitHub/Global-Macro-Project"
}

if "`c(username)'"=="coden"{
	global path "C:\Users\coden\OneDrive\Documents\GitHub\Global-Macro-Project"
}

if "`c(username)'"=="Kororinpa"{
	global path "D:/Singapore Management University/Research assistant/NUS/Global-Macro-Project"
}

if "`c(username)'"=="yaqi"{
	global path "D:\Dropbox\Yaqi_misc\GMP_LPs\github_repository\Global-Macro-Project"
}

* Set sub-paths
global data_raw 		"$path/data/raw"
global data_clean		"$path/data/clean"
global data_final		"$path/data/final"
global data_distr		"$path/data/distribute"

global data_helper		"$path/data/helpers"
global data_temp		"$path/data/tempfiles"

global code				"$path/code"
global code_functions	"$path/code/functions"
global code_initialize	"$path/code/initialize"
global code_download 	"$path/code/download"
global code_clean		"$path/code/clean"
global code_merge		"$path/code/merge"
global code_combine		"$path/code/combine"
global code_paper		"$path/code/paper"
global code_doc			"$path/code/documentation"

global doc				"$path/output/doc"
global graphs			"$path/output/graphs"
global tables			"$path/output/tables"
global numbers			"$path/output/numbers"


* ==============================================================================
* Define key inputs that are needed throughout the code 
* ==============================================================================

* Set minimum and maximum date 
glo currdate = yofd(date(c(current_date),"DMY")) 
glo maxdate= $currdate + 10 // Current year + 10 years
glo mindate = 0

* Make version 
glo yearmonth = string(yofd(date(c(current_date),"DMY")))+"_"+string(month(date(c(current_date),"DMY")))

* Unique identifiers in final dataset 
glo ident "ISO3 year"

* List of variables needed for documentation
glo docvars "SOURCE SOURCE_ABBR URL DOWNLOAD_DATE INPUT"

* List of countries
glo isomapping "$data_helper/countrylist"

* List of variables 
glo varlist "nGDP_LCU pop CPI rCONS_LCU"

* Euro irrevocable exhange rate
glo eur_fx "$data_helper/EUR_irrevocable_FX"

* List of sources

* Define maximum deviation of ratio variables; if the difference in overlapping 
* data is larger than this, we apply a ratio-splicing adjustment. This is 
* currently not used but might be in future iterations.
*glo rate_ratio "0.20" // 20% deviation allowed


* ==============================================================================
* Load all programs required for running the database 
* ==============================================================================


* Define and download programs 
if $packages == 1 {
foreach pack in gtools egenmore dbnomics moss libjson spmap reghdfe geo2xy heatplot mplotoffset sparkline splitvallabels wbopendata nicelabels{
	cap ssc install `pack' 
}

cap net install grc1leg,from(http://www.stata.com/users/vwiggins/)
cap net install filelist.pkg
cap net install missings.pkg
cap net install kountry.pkg
cap net install unique.pkg
cap net install mylabels.pkg
}



* Define and load custom scripts 
filelist, directory($code_functions)
drop if regexm(dirname,"Archive")
drop if regexm(filename,".DS_Store")
gen combined = dirname + "/" + filename
levelsof combined if substr(filename, -3, 3) == ".do", loc(functions) 
di `functions'

foreach f of loc functions {
	do `f'
}

* ==============================================================================
* Initialize the database 
* ==============================================================================

* Erase everything if specified 
  if $erase == 1 {
    if "`c(os)'" == "Windows" {
        foreach dir in "$data_clean" "$data_final" "$data_distr" "$data_temp" {
            !del /s /q "`dir'\*.dta"
        }
    }
    else {
        foreach dir in "$data_clean" "$data_final" "$data_distr" "$data_temp" {
            !rm -rf "`dir'"/"*.dta"
        }
    }
	do "$code/initialize/1_make_download_dates.do"
	
	* Make blank panel that will be filled in for final dataset 
	do "$code/initialize/2_make_blank_panel.do" 

	* Make the notes file
	save "$data_temp/notes", replace
	
}

* Make blank panel that will be filled in for final dataset 
do "$code/initialize/2_make_blank_panel.do" 

* Validate inputs
do "$code/initialize/3_validate_inputs.do"


* Delete all stswp files
if "`c(os)'" == "Windows" {
        shell del "*.stswp" /q /s
    }
else {
	shell find . -name "*.stswp" -type f -delete
	
}


* ==============================================================================
* Automatic updates of the raw data 
* ==============================================================================

if $download == 1 {

	* Get a list of all code files for downloading
	filelist, directory($code_download)
	drop if regexm(filename,".DS_Store")
	gen combined = dirname + "/" + filename
	levelsof combined, loc(download_files)

	* Run files 
	foreach f of loc download_files {
		qui do `f'
		di as txt "File `f' ran with success"
	}
}

* ==============================================================================
* Cleaning the raw data
* ==============================================================================

if $clean == 1 {

	* Get a list of all code files for cleaning the data 
	filelist, directory($code_clean) 
	drop if regexm(filename,".DS_Store")
	gen order = cond(regexm(dirname,"aggregators/Mitchell"),1,2)
	sort order // Sort helper files for processing Mitchell/IHS data first
	gen combined = dirname + "/" + filename
	sort filename
	keep if order == 1
	levelsof combined if order == 1, clean loc(mitchell_files)
	
	* Run files 
	foreach f of loc mitchell_files {
		qui do `f'
		di as txt "File `f' ran with success"
	}
	
	filelist, directory($code_clean) 
	drop if regexm(filename,".DS_Store")
	gen order = cond(regexm(dirname,"aggregators/Mitchell"),1,2)
	sort order // Sort helper files for processing Mitchell/IHS data first
	gen combined = dirname + "/" + filename
	levelsof combined if order == 2, clean loc(rest_files)
	
	* Run files 
	foreach f of loc rest_files {
		do `f'
	}
}

* ==============================================================================
* Merge and combine together the cleaned data
* ==============================================================================
	
if $combine == 1 {

	* Merge data 
	do "$code_merge/1_merge_clean_data"

	* Validate outputs 
	do "$code_merge/2_validate_outputs"
	
	* Make the notes file
	do "$code/initialize/4_make_sources_dataset.do"

	* Get a list of all code files for combining the data
	filelist, directory($code_combine) 
	drop if regexm(filename,".DS_Store")
	gen combined = dirname + "/" + filename
	levelsof combined, loc(combine_files)

	* Run files 
	foreach f of loc combine_files {
		do `f'
	}
}


* ==============================================================================
* Produce technical documentation
* ==============================================================================

if $document == 1 {

	filelist, directory($code_doc)
	drop if regexm(filename,".DS_Store")
	gen combined = dirname + "/" + filename
	levelsof combined, loc(doc_files)

	* Run files (Only one file)
	foreach f of loc doc_files {
	di as txt "Running `f'"
	qui do `f'
	di as txt "File `f' ran with success"
	}
}

* ==============================================================================
* Output the data 
* ==============================================================================

if $output_data == 1 {
	
	do "$code_merge/3_data_final" 

}

* ==============================================================================
* Produce outputs for paper
* ==============================================================================

if $paper == 1 {

	* Get a list of all code files used for producing exhibits in the paper 
	filelist, directory($code_paper) 
	drop if regexm(filename,".DS_Store")
	gen combined = dirname + "/" + filename
	levelsof combined, loc(paper_files)

	* Run files 
	foreach f of loc paper_files {
		qui do `f'
	}

}

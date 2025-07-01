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
global paper		0
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

if "`c(username)'"=="kmueller"{
	global path "C:\Users\kmueller\Documents\GitHub\Global-Macro-Project" // Home laptop
}

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

* List of countries
glo isomapping "$data_helper/countrylist"

* Euro irrevocable exhange rate
glo eur_fx "$data_helper/EUR_irrevocable_FX"

* Determine current version
local current_date = date(c(current_date), "DMY")
local current_year = year(date(c(current_date), "DMY"))
local current_month = month(date(c(current_date), "DMY"))

* Create current version as the year_month
local month = `current_month'- 1

if strlen("`month'") == 1 {
	global current_version "`current_year'_0`month'"
}
else {
	global current_version "`current_year'_`month'"
}
di "$current_version"
global current_year `current_year'

* ==============================================================================
* Load all programs required for running the database 
* ==============================================================================


* Define and download programs 
if $packages == 1 {
foreach pack in gtools egenmore dbnomics moss libjson spmap reghdfe geo2xy heatplot mplotoffset sparkline splitvallabels wbopendata nicelabels filelist missings kountry unique mylabels distinct {
	cap ssc install `pack' 
}

	cap net install grc1leg,from(http://www.stata.com/users/vwiggins/)
}


* Define and load custom scripts 
filelist, directory($code_functions)
drop if regexm(dirname,"Archive")
gen combined = dirname + "/" + filename
levelsof combined if substr(filename, -3, 3) == "ado", loc(functions) 
foreach f of loc functions {
	qui do `f'
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
	qui keep if year == 1

	* Make the notes file
	save "$data_temp/notes", replace
	
}

* Make blank panel that will be filled in for final dataset 
do "$code/initialize/2_make_blank_panel.do" 



* Validate inputs
*do "$code/initialize/3_validate_inputs.do"


* Delete all stswp files
if "`c(os)'" == "Windows" {
        shell del "*.stswp" /q /s
    }
else {
	shell find . -name "*.stswp" -type f -delete
	shell find . -name "*.DS_Store" -type f -delete
	
}


* ==============================================================================
* Automatic updates of the raw data 
* ==============================================================================

if $download == 1 {

	* Get a list of all code files for downloading
	filelist, directory($code_download)
	gen combined = dirname + "/" + filename
	levelsof combined, loc(download_files)

	* Run files 
	foreach f of loc download_files {
		cap do `f'
		if _rc == 0 {
			di as txt "File `f' ran with success"
		}
		else {
			di as txt "File `f' has an error"
		}
	}
}

* ==============================================================================
* Cleaning the raw data
* ==============================================================================
* Define and load custom scripts 
filelist, directory($code_functions)
drop if regexm(dirname,"Archive")
gen combined = dirname + "/" + filename
levelsof combined if substr(filename, -3, 3) == "ado", loc(functions) 

foreach f of loc functions {
	do "`f'"
}

if $clean == 1 {
	
	* Make blank panel that will be filled in for final dataset 
	do "$code/initialize/2_make_blank_panel.do" 
	qui keep if year == 1

	* Make the notes file
	save "$data_temp/notes", replace
	
	* Get a list of all Mitchell files for cleaning the data 
	filelist, directory($code_clean) 
	gen order = cond(regexm(dirname,"aggregators/Mitchell"),1,2)
	sort order // Sort helper files for processing Mitchell/IHS data first
	gen combined = dirname + "/" + filename
	sort filename
	levelsof combined if order == 1, clean loc(rest_files)
	
	* Run files 
	foreach f of loc rest_files {
		di "Running `f'"
		qui do `f'
	}
	
	* Get a list of the rest of the files
	filelist, directory($code_clean) 
	gen order = cond(regexm(dirname,"aggregators/Mitchell"),1,2)
	sort order // Sort helper files for processing Mitchell/IHS data first
	gen combined = dirname + "/" + filename
	sort dirname filename
	levelsof combined if order == 2, clean loc(rest_files)
	
	* Run files 
	foreach f of loc rest_files {
		di "Running `f'"
		qui do `f'
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
	
	* Drop files in the archive file
	drop if strpos(dirname, "Archive") | filename == "run_input_variables.do"
	
	* Run the intermediate input variables first 
	preserve 
	di "Running intermediate files"
	cap do "$code_combine/run_input_variables.do"
	if _rc == 0 {
		di "Intermediate files run with success"
	}
	else {
		di as err "Error in running intermediate files"
		exit 198
	}
	restore 
	
	* Run the rest of the combine files
	gen combined = dirname + "/" + filename
	levelsof combined, loc(combine_files)

	* Run files 
	foreach f of loc combine_files {
		di "Running `f'"
		qui do `f' 
		
	}
}


* ==============================================================================
* Produce technical documentation
* ==============================================================================

if $document == 1 {

	filelist, directory($code_doc)
	drop if regexm(filename,)
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
	do "$code_merge/5_create_csv.do" 
	do "$code_merge/4_create_excel.do" 
}

* ==============================================================================
* Produce outputs for paper
* ==============================================================================

if $paper == 1 {

	* Get a list of all code files used for producing exhibits in the paper 
	filelist, directory($code_paper) 
	gen combined = dirname + "/" + filename
	levelsof combined, loc(paper_files)

	* Run files 
	foreach f of loc paper_files {
		di "Running `f'"
		qui do `f'
	}

}

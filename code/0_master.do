* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* SET UP THE GLOBAL DIRECTORIES
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Description: file needed to set up the directories necessary for running programs at once.
* Created: 2025-08-08
*
* ==============================================================================
* Toggle options 
* 
* Turn these options on with a "1" or off with a "0", depending on what you 
* actually want to run.
* ==============================================================================
* ==============================================================================
* Prepare folder paths and define programs 
* ==============================================================================

global document 	1	// Produce and compile the documentation

* ==============================================================================
* Make all global variables into 1 if we are updating the database
* ==============================================================================

* Set path folder
if "`c(username)'"=="lehbib"{
	global path "C:/Users/lehbib/Documents/Github/Global-Macro-Project"
}

if "`c(username)'"=="mohamedlehbib"{
	global path "/Users/mohamedlehbib/Downloads/GitHub/Global-Macro-Database-Internal"
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

* Add the base year for real GDP and indices 
global base_year 2015

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

* Docvars 
glo docvars "$data_helper/docvars.csv"

* Determine current version
local current_date = date(c(current_date), "DMY")
local current_year = year(date(c(current_date), "DMY"))
local current_month = month(date(c(current_date), "DMY"))

* Create current version as the year_month
local month = `current_month'

if strlen("`month'") == 1 {
	global current_version "`current_year'_0`month'"
}
else {
	global current_version "`current_year'_`month'"
}
di "$current_version"
global current_year `current_year'

* Delete all stswp files
if "`c(os)'" == "Windows" {
        shell del "*.stswp" /q /s
    }
else {
	shell find . -name "*.stswp" -type f -delete
	shell find . -name "*.DS_Store" -type f -delete
	
}

* ==============================================================================
* Load all programs required for running the database 
* ==============================================================================

* Define and load custom scripts 
filelist, directory($code_functions)
drop if regexm(dirname,"Archive")
gen combined = dirname + "/" + filename
qui levelsof combined if substr(filename, -3, 3) == "ado", loc(functions) 
foreach f of loc functions {
	qui do `f'
}

* Create the slack webhook global
qui do "$path/env_vars.do"


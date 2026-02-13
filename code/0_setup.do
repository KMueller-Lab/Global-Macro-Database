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
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-01-05
* Last updated: 2025-08-08
*
* ==============================================================================
* Toggle options
*
* Turn these options on with a "1" or off with a "0", depending on what you 
* actually want to run.
* ==============================================================================



clear all   // clear everything and start from scratch



* --- Safety Log Start ---
capture log close safety_log  // Close any open/stuck logs from previous runs to prevent errors
log using "setup_secure.log", replace text name(safety_log) // start logging to filename_secure.log + assign a specific i>
* Now, we have ensured we always have a log notwthstanding what stata generated
* ------------------------


* >>> CONFIGURATION START
global release		0   // Only before quarterly update
global erase		0	// Careful: removes all the processed data
global download		0   // Run the download files
global clean		0   // Run the clean files
global mitchell		0   // Run clean files for Mitchell (takes long)
global combine		0	// Run the combine files
global document		0	// Produce and compile the documentation

global output_data	0   // Produce the data outputs; mask the data and then produce final combined dataframe of all the data
global paper		0   // Prepare the paper exhibits
global packages		0   // Check if the package exists; 1 only the first time, i.e. just once to download all packages
global github		0	// Push the changes to Github
global check		0   // Check the log
* <<< CONFIGURATION END

* ==============================================================================
* Prepare folder paths and define programs
* ==============================================================================

* Set path folder
if "`c(username)'" == "ubuntu" {
    // the actual path on our EC2 machine.
    global path "/home/ubuntu/GMD/repositories/Global-Macro-Database-Internal"
    global website "/home/ubuntu/GMD/repositories/Global-Macro-Database-Website"
    global main_repo "/home/ubuntu/GMD/repositories/Global-Macro-Database"
    global package_repo "/home/ubuntu/GMD/repositories/Global-Macro-Project-Stata"
}
else if "`c(username)'"=="lehbib"{
	global path "C:/Users/lehbib/Documents/Github/Global-Macro-Project"
}
else if "`c(username)'"=="mohamedlehbib"{
	global path "/Users/mohamedlehbib/Downloads/GitHub/Global-Macro-Database-Internal"
	global website "/Users/mohamedlehbib/Downloads/GitHub/Global-Macro-Database-Website"
	global main_repo "/Users/mohamedlehbib/Downloads/GitHub/Global-Macro-Database"
	global package_repo "/Users/mohamedlehbib/Downloads/GitHub/Global-Macro-Project-Stata"
}
else if "`c(username)'"=="kmueller"{
	global path "C:/Users/kmueller/Desktop/GitHub/Global-Macro-Project"
}
else if "`c(username)'"=="kmueller"{
	global path "C:\Users\kmueller\Documents\GitHub\Global-Macro-Project" // Home laptop
}
else if "`c(username)'"=="simonchen"{
	global path "/Users/simonchen/Documents/GitHub/Global-Macro-Project"
}
else if "`c(username)'"=="coden"{
	global path "C:\Users\coden\OneDrive\Documents\GitHub\Global-Macro-Project"
}
else if "`c(username)'"=="Kororinpa"{
	global path "D:/Singapore Management University/Research assistant/NUS/Global-Macro-Project"
}
else if "`c(username)'"=="yaqi"{
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
global current_year `current_year'

* Add the base year for real GDP and indices
global base_year 2015

* Delete all stswp files
if "`c(os)'" == "Windows" {
        shell del "*.stswp" /q /s
    }
else {
	shell find . -name "*.stswp" -type f -delete
	shell find . -name "*.DS_Store" -type f -delete

}

* Create the slack webhook global
qui do "$path/env_vars.do"
cd "$path"

timer clear
timer on 1

* ==============================================================================
* Load all programs required for running the database
* ==============================================================================

* Define and download programs
if $packages == 1 {
	foreach pack in gtools egenmore dbnomics moss libjson spmap reghdfe geo2xy heatplot mplotoffset sparkline splitvallabels wbopendata nicelabels filelist missings kountry unique mylabels distinct palettes colrspace {
	* Install only missing packages
	cap which `pack'
	if _rc != 0 {
		* Install the package
		ssc install `pack'
		}
	else {
		* Already installed
		di "The package `pack' is already installed"
		}
	}

	* Install grc1leg package
	cap which grc1leg
	if _rc != 0 {
		net install grc1leg,from(http://www.stata.com/users/vwiggins/)
	}

	* Install readhtmltable
	cap which readhtmltable
	if _rc != 0 {
		net install readhtml, from(https://ssc.wisc.edu/sscc/stata/)
	}
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

    * Erase the raw data files
	if "`c(os)'" == "Windows" {
    foreach dir in "$data_clean" "$data_final" "$data_distr" "$data_temp" "$doc" {
        !del /s /q "`dir'\*.dta"
        !del /s /q "`dir'\*.tex"
        !del /s /q "`dir'\*.pdf"
    }
}
	else {
    foreach dir in "$data_clean" "$data_final" "$data_distr" "$data_temp" "$doc" {
        !find "`dir'" -type f -name "*.dta" -delete
        !find "`dir'" -type f -name "*.tex" -delete
        !find "`dir'" -type f -name "*.pdf" -delete
    }
}

	do "$code/initialize/1_make_download_dates.do"

	* Make blank panel that will be filled in for final dataset
	qui do "$code/initialize/2_make_blank_panel.do"
	qui keep if year == 1

	* Make the notes file
	save "$data_temp/notes", replace

	* Make the notes_source file
	qui do "$code/initialize/4_make_sources_dataset.do"

	* Create the dataset needed for the anchor year recording
	clear

	set obs 1
	gen variable = ""
	gen ISO3 = ""
	gen anchor_year = ""
	gen method = ""
	save "$data_temp/anchor_year_record", replace

}

* Make blank panel that will be filled in for final dataset
do "$code/initialize/2_make_blank_panel.do"

* Validate inputs
*do "$code/initialize/3_validate_inputs.do"

gmdslack, send("`c(username)': DEBUG: This message just confirms that the 0_setup.do was ran in GMD")

* ==============================================================================
* Automatic updates of the raw data
* ==============================================================================

if $download == 1 {

	* Send the message
	cap gmdslack, send("`c(username)': Running the download files")

	* Ensure download files consistency if there is no erase
	do "$code_initialize/5_assert_downloads"

	* Get a list of all code files for downloading
	filelist, directory($code_download)

	* Drop files in archive folders if any
	cap drop if strpos(dirname, "Archive")

	* Get filenames only for parallel execution
	keep filename
	cd $path
	qui levelsof filename, loc(download_files)
	file open myfile using "$path/vars_download.txt", write text replace
	foreach f of loc download_files {
		file write myfile "`f'" _n
	}
	file close myfile

	* Run all download files in parallel
	do "rp_download.do"

	* Create the final download log file
	clear
	tempfile log
	save `log', replace emptyok
	filelist, dir("$data_temp/download_log")
	qui gen name = dirname + "/" + filename
	qui levelsof name, local(files) clean
	foreach file of local files {
		qui use "`file'", clear
		append using `log'
		qui save `log', replace
	}

	use `log', clear

	* Send a message with all the files that did not run successfully
	levelsof variable if status == "Error", clean local(send)
	if r(r) > 0 {
		gmdslack, send("`c(username)': The following download files: `send', have errors. Exiting the process")
		exit 498
	}
	else {
		gmdslack, send("`c(username)': All download files ran successfully")
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
	qui do "`f'"
}

if $clean == 1 {

	gmdslack, send("`c(username)': Running the clean files")

	* Ensure clean files consistency
	do "$code_initialize/6_assert_clean"

	* Make blank panel that will be filled in for final dataset
	do "$code/initialize/2_make_blank_panel.do"

	qui keep if year == 1

	* Make the notes file
	save "$data_temp/notes", replace

	* Check if Mitchell files should be cleaned or not (takes long)
	if $mitchell == 1 {

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


	* Merge data
	do "$code_merge/1_merge_clean_data"

	gmdslack, send("`c(username)': All the clean files were ran")

}

* ==============================================================================
* Merge and combine together the cleaned data
* ==============================================================================

if $combine == 1 {

	gmdslack, send("`c(username)': Combining the data")


	* Ensure combine files consistency
	do "$code_initialize/7_assert_combine"

	* Validate outputs
	do "$code_merge/2_validate_outputs"

	* Make the notes file
	do "$code/initialize/4_make_sources_dataset.do"

	* Run the input variables file
	cap do "$code/combine/A_run_input_variables"
	if _rc != 0 {
		di as err "Input variables error"
	}


	* Get a list of all code files for combining the data
	filelist, directory($code_combine/Final_vars)

	* Drop files in the archive file
	drop if strpos(dirname, "Archive")

	* Run the rest of the combine files
	keep filename
	cd $path
	qui levelsof filename, loc(combine_files)
	file open myfile using "$path/vars.txt", write text replace
	foreach f of loc combine_files {
		file write myfile "`f'" _n
	}
	file close myfile

	* Run all combine files in Parallel
	do "rp.do"

	* Create the final log file
	clear
	tempfile log
	save `log', replace emptyok
	filelist, dir("$data_temp/combine_log")
	qui gen name = dirname + "/" + filename
	qui levelsof name, local(files) clean
	foreach file of local files {
		qui use "`file'", clear
		append using `log'
		qui save `log', replace
	}

	use `log', clear

	* Send a message with all the files that did not run successfully
	levelsof variable if status == "Error", clean local(send)
	if r(r) > 0 {
		gmdslack, send("`c(username)': The following files: `send', have errors. Exiting the process")
		*exit 498
	}
	else {
		gmdslack, send("`c(username)': All combine files ran successfully")
	}

	* List countries with too many source changes 
	*do "$functions/gmd_source_changes.do"

	* Derive the variables
	qui do "$code/derive_vars.do"

}



* ==============================================================================
* Output the data
* ==============================================================================

if $output_data == 1 {

	gmdslack, send("`c(username)': Creating the data output file")

	* Produce the data final in .dta format
	do "$code_merge/3_data_final"

	* Output the final and raw data in csv format
	do "$code_merge/4_create_csv.do"

	* Output the excel file
	do "$code_merge/5_create_excel.do"

	* Update the docvars with the base year
	import delimited using "$docvars", clear case(preserve)
	replace units = "index, $base_year = 100" if strpos(units, "index")
	export delimited using "$docvars", replace
}

* ==============================================================================
* Produce technical documentation
* ==============================================================================

if $document == 1 {

	gmdslack, send("`c(username)': Creating the technical documentation")

	filelist, directory($code_doc)
	gen combined = dirname + "/" + filename
	levelsof combined, loc(doc_files)

	* Run files (Only one file)
	foreach f of loc doc_files {
	di as txt "Running `f'"
	qui do `f'
	di as txt "File `f' ran with success"
	}

	gmdslack, send("`c(username)': All documentation files were produced")

}

* ==============================================================================
* Check against the log
* ==============================================================================

if $check == 1 {

	gmdslack, send("`c(username)': Ensuring data integrity using the log")

	* Produce all the potential errors
	do "$code/error_checking.do"

	* Recast
	recast str101 reason, force
	recast str30 variables, force

	* Check against the log (will break in case of new outliers)
	merge 1:1 ISO3 year variables using "$data_helper/data_log"

	* Assert all data points have been checked
	cap assert reviewer != "" & review == "Reviewed"

	if _rc == 0 {
		gmdslack, send("`c(username)': All the outliers are recorded and reviewed")
	}

	* Assert that the number of countries is complete
	do "$code_initialize/8_assert_correct_name"
	*do "$code_initialize/9_comprehensive_assertions"
}



* ==============================================================================
* Produce outputs for paper
* ==============================================================================

if $paper == 1 {

	* Get a list of all code files used for producing exhibits in the paper
	filelist, directory($code_paper) pat("*.do")
	gen combined = dirname + "/" + filename
	levelsof combined, loc(paper_files)

	* Run files
	foreach f of loc paper_files {
		di "Running `f'"
		qui do `f'
	}

}

* ==============================================================================
* Change the versions.csv file
* ==============================================================================
qui do "$path/env_vars.do"
if $release == 1 {

	gmdslack, send("`c(username)': Ensuring that a pull request was opened with the version file updated on the public branch")

	* Navigate to the directory
	cd $main_repo

	* Check if Release_$current_version branch exists
	local release_branch ""
	cap !git show-ref --verify --quiet refs/heads/`release_branch'
	if _rc == 0 {
		* Branch exists, switch to it
		cap !git checkout `release_branch'
		if _rc != 0 {
			gmdslack, send("`c(username)': Could not checkout branch `release_branch'")
			exit 498
		}

		* Import versions.csv and check if last row of first column equals current version
		qui import delimited "data/helpers/versions.csv", clear varnames(1)
		qui count
		local last_row = r(N)
		qui keep if _n == `last_row'
		levelsof v, local(last_version) clean
		if "`last_version'" == "$current_version" {
			gmdslack, send("`c(username)': Release branch `release_branch' is ready. Last row equals $current_version")
		}
		else {
			gmdslack, send("`c(username)': Last row in versions.csv (`last_version') does not match current version ($current_version)")
			exit 498
		}
	}
	else {
		* Branch doesn't exist
		gmdslack, send("`c(username)': Release branch `release_branch' does not exist")
	}

}

* ==============================================================================
* Push the changes to GitHub
* ==============================================================================
qui do "$path/env_vars.do"

* Push files to website repository
if $github == 1 {

	* Send message about website update
	cap gmdslack, send("`c(username)': Starting website repository update")

	* Navigate to website repository
	cd "$website"

	* Create new branch for current version
	local website_branch $branch
	cap !git checkout -b `website_branch'
	if _rc != 0 {
		* Branch might already exist, try to checkout existing branch
		cap !git checkout `website_branch'
		if _rc != 0 {
			cap gmdslack, send("`c(username)': ERROR - Could not create or checkout branch `website_branch' in website repo")
			exit 498
		}
	}

	* Get all files ending with current version from distribute folder
	qui filelist, dir("$data_distr")
	qui keep if regexm(filename, "_$current_version\.(csv|xlsx|dta)$")
	qui gen filepath = dirname + "/" + filename
	qui levelsof filepath, local(version_files) clean

	* Also get the main GMD files (without version numbers)
	qui filelist, dir("$data_distr")
	qui keep if regexm(filename, "^GMD\.(csv|xlsx|dta)$")
	qui gen filepath = dirname + "/" + filename
	qui levelsof filepath, local(gmd_files) clean

	* Combine both lists
	local all_files "`version_files' `gmd_files'"

	* Copy files to website docs folder
	local copy_count = 0
	foreach file of local all_files {
		local filename = regexr("`file'", ".*/", "")
		cap !cp "`file'" "docs/`filename'"
		if _rc == 0 {
			di "Copied `filename' to website docs folder"
			local copy_count = `copy_count' + 1
		}
		else {
			di "ERROR: Failed to copy `filename'"
		}
	}

	* Check if any files were copied
	if `copy_count' == 0 {
		cap gmdslack, send("`c(username)': WARNING - No files were copied to website docs folder")
	}
	else {
		di "Successfully copied `copy_count' files to website docs folder"
	}

	* Add and commit changes to website repo
	cap !git add docs/
	if _rc != 0 {
		cap gmdslack, send("`c(username)': ERROR - Failed to add files to git in website repo")
		exit 498
	}

	cap !git commit -m "Update data files for version $current_version"
	if _rc != 0 {
		cap gmdslack, send("`c(username)': ERROR - Failed to commit changes in website repo")
		exit 498
	}

	cap !git push -u origin `website_branch'
	if _rc != 0 {
		cap gmdslack, send("`c(username)': ERROR - Failed to push changes to website repo")
		exit 498
	}

	* ==============================================================================
	* Copy documentation PDF files
	* ==============================================================================

	* Copy country documentation PDFs
	use "$data_final/data_final", clear
	levelsof ISO3, local(countries) clean

	local country_copy_count = 0
	foreach country of local countries {
		local pdf_file = "`country'.pdf"
		cap !cp "$doc/`pdf_file'" "docs/files/documentations/countries/`pdf_file'"
		if _rc == 0 {
			di "Copied country documentation: `pdf_file'"
			local country_copy_count = `country_copy_count' + 1
		}
		else {
			di "WARNING: Could not copy country documentation: `pdf_file'"
		}
	}

	* Copy variable documentation PDFs
	import delimited using "$docvars", clear
	keep if documentation == "Yes"
	levelsof codes, local(variables) clean

	local variable_copy_count = 0
	foreach variable of local variables {
		local pdf_file = "`variable'.pdf"
		cap !cp "$doc/`pdf_file'" "docs/files/documentations/Variables/`pdf_file'"
		if _rc == 0 {
			di "Copied variable documentation: `pdf_file'"
			local variable_copy_count = `variable_copy_count' + 1
		}
		else {
			di "WARNING: Could not copy variable documentation: `pdf_file'"
		}
	}

	* Add and commit documentation changes
	cap !git add docs/files/documentations/
	if _rc == 0 {
		cap !git commit -m "Update documentation files for version $current_version"
		if _rc == 0 {
			cap !git push -u origin `website_branch'
			if _rc == 0 {
				di "Successfully updated documentation files"
			}
		}
	}

	* ==============================================================================
	* Copy documentation PDF files to data_distr folder
	* ==============================================================================

	* Create documentation directories in data_distr if they don't exist
	cap !mkdir -p "$data_distr/documentations/countries"
	cap !mkdir -p "$data_distr/documentations/Variables"

	* Copy country documentation PDFs to data_distr
	use "$data_final/data_final", clear
	levelsof ISO3, local(countries_distr) clean

	local country_distr_count = 0
	foreach country of local countries_distr {
		local pdf_file = "`country'.pdf"
		cap !cp "$doc/`pdf_file'" "$data_distr/documentations/countries/`pdf_file'"
		if _rc == 0 {
			di "Copied country documentation to data_distr: `pdf_file'"
			local country_distr_count = `country_distr_count' + 1
		}
		else {
			di "WARNING: Could not copy country documentation to data_distr: `pdf_file'"
		}
	}

	* Copy variable documentation PDFs to data_distr
	import delimited using "$docvars", clear
	keep if documentation == "Yes"
	levelsof codes, local(variables_distr) clean

	local variable_distr_count = 0
	foreach variable of local variables_distr {
		local pdf_file = "`variable'.pdf"
		cap !cp "$doc/`pdf_file'" "$data_distr/documentations/Variables/`pdf_file'"
		if _rc == 0 {
			di "Copied variable documentation to data_distr: `pdf_file'"
			local variable_distr_count = `variable_distr_count' + 1
		}
		else {
			di "WARNING: Could not copy variable documentation to data_distr: `pdf_file'"
		}
	}

	di "Successfully copied `country_distr_count' country and `variable_distr_count' variable documentation files to data_distr"

	* Send success message
	cap gmdslack, send("`c(username)': Website repository updated successfully with version $current_version files and documentation (Countries: `country_copy_count', Variables: `variable_copy_count')")


	* ==============================================================================
	* Copy Data to the package folder
	* ==============================================================================

	* Navigate to the package repository
	cd "$package_repo"

	* Send message about website update
	cap gmdslack, send("`c(username)': Adding data to the package folder")

	* Create new branch for current version
	local package_branch $branch
	cap !git checkout -b `package_branch'
	if _rc != 0 {
		* Branch might already exist, try to checkout existing branch
		cap !git checkout `package_branch'
		if _rc != 0 {
			cap gmdslack, send("`c(username)': ERROR - Could not create or checkout branch `package_branch' in package repo")
			exit 498
		}
	}

	* Get all files ending with current version from distribute folder
	qui filelist, dir("$data_distr")
	qui keep if regexm(filename, "_$current_version\.(csv|dta)$")
	qui gen filepath = dirname + "/" + filename
	qui levelsof filepath, local(version_files) clean

	* Also get the main GMD files (without version numbers)
	qui filelist, dir("$data_distr")
	qui keep if regexm(filename, "^GMD\.(csv|dta)$")
	qui gen filepath = dirname + "/" + filename
	qui levelsof filepath, local(gmd_files) clean

	* Combine both lists
	local all_files "`version_files' `gmd_files'"

	* Copy files to package data folder
	local copy_count = 0
	foreach file of local all_files {
		local filename = regexr("`file'", "./*/", "")
		cap !cp "`file'" "data/final/`filename'"
		if _rc == 0 {
			di "Copied `filename' to website docs folder"
			local copy_count = `copy_count' + 1
		}
		else {
			di "ERROR: Failed to copy `filename'"
		}
	}

	* Check if any files were copied
	if `copy_count' == 0 {
		cap gmdslack, send("`c(username)': WARNING - No files were copied to package repo")
	}
	else {
		di "Successfully copied `copy_count' files to website docs folder"
	}

	* Add and commit changes to website repo
	cap !git add data/final
	if _rc != 0 {
		cap gmdslack, send("`c(username)': ERROR - Failed to add files to git in package repo")
		exit 498
	}

	* Add the clean data to the folder
	qui filelist, dir("$data_clean") pat("*dta")
	qui gen filepath = dirname + "/" + filename
	qui levelsof filepath, local(version_files) clean

	* Copy files to package data folder
	local copy_count = 0
	foreach file of local all_files {
		local filename = regexr("`file'", ".*/", "")
		cap !cp "`file'" "data/final/`filename'"
		if _rc == 0 {
			di "Copied `filename' to website docs folder"
			local copy_count = `copy_count' + 1
		}
		else {
			di "ERROR: Failed to copy `filename'"
		}
	}

	* Check if any files were copied
	if `copy_count' == 0 {
		cap gmdslack, send("`c(username)': WARNING - No files were copied to package repo")
	}
	else {
		di "Successfully copied `copy_count' files to website docs folder"
	}

	* Add and commit changes to website repo
	cap !git add data/clean
	if _rc != 0 {
		cap gmdslack, send("`c(username)': ERROR - Failed to add files to git in package repo")
		exit 498
	}

	* Add the versions, bib, docvars, and isomapping files to the helpers folder
	cap !cp "$main_repo/data/helpers/versions.csv" "data/helpers/versions.csv"
	cap !cp "$isomapping" "data/helpers/countrylist.dta"
	cap !cp "$docvars" "data/helpers/docvars.csv"
	cap !cp "$doc/bib.bib" "bib.bib"
	cap !git add data/helpers
	if _rc != 0 {
		cap gmdslack, send("`c(username)': ERROR - Failed to add files to git in package repo")
		exit 498
	}


	cap !git commit -m "Update help files for version $current_version"
	if _rc != 0 {
		cap gmdslack, send("`c(username)': ERROR - Failed to commit changes in package repo")
		exit 498
	}

	cap !git push -u origin `package_branch'
	if _rc != 0 {
		cap gmdslack, send("`c(username)': ERROR - Failed to push changes to package repo")
		exit 498
	}

	* Now run the package setup files to test it and ensure it's working
	do "0_setup.do"

	* Navigate back to main repository
	cd "$path"
}



di "============================================================================"
timer off 1
timer list 1

* Calculate minutes and send Slack message
local elapsed_seconds = r(t1)
local elapsed_minutes = round(`elapsed_seconds' / 60, 0.1)
gmdslack, send("`c(username)': Database compiled in `elapsed_minutes' minutes")




* --- Safety Log End ---
log close safety_log  // Save and close the log

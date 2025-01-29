* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CREATE SOURCE DOWNLOAD LOG
* 
* Description: 
* This Stata program creates a blank dataset to track data sources and their
* download dates for documentation and version control purposes.
*
* Requirements:
* None - creates new tracking dataset
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 
* 2024-01-08
*
* ==============================================================================
* CREATE BLANK SOURCE TRACKING DATASET
* ==============================================================================

* Create empty dataset with required columns
clear
set obs 0
gen source_abbr = ""
gen download_date = ""

* Add labels
label var source_abbr "Source abbreviation"
label var download_date "Date of data download"

* Save in temp folder
save "$data_temp/download_dates", replace
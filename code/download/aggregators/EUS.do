* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* https://ec.europa.eu/eurostat/web/query-builder/tool
* 
* ==============================================================================

* Define output file name 
clear
global output "${data_raw}\aggregators\EUS"

* ==============================================================================
*   HICP
* ============================================================================== 

local url "https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/prc_hicp_aind/..CP00.?format=SDMX-CSV"

* Download the data using Stata's 'copy' command
cap copy "`url'" "eus_data.csv", replace

* Import the downloaded CSV file
import delimited "eus_data.csv", clear 

* Save 
save "$output/CPI.dta", replace
rm "eus_data.csv"

* ==============================================================================
*   House price index (2015 = 100) - annual data (prc_hpi_a)	
* ============================================================================== 

local url "https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/prc_hpi_a/A.TOTAL.I15_A_AVG.?format=SDMX-CSV"

* Download the data using Stata's 'copy' command
cap copy "`url'" "eus_data.csv", replace

* Import the downloaded CSV file
import delimited "eus_data.csv", clear 

* Save 
save "$output/HPI_A.dta", replace
rm "eus_data.csv"


* ==============================================================================
*   Unemployment
* ============================================================================== 

local url "https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/ESTAT/tipsun20/1.0/....?format=csvdata"

* Download the data using Stata's 'copy' command
cap copy "`url'" "eus_data.csv", replace

* Import the downloaded CSV file
import delimited "eus_data.csv", clear 

* Save 
save "$output/unemp.dta", replace
rm "eus_data.csv"


* ==============================================================================
*   Government bond yields, 10 years' maturity
* ============================================================================== 

local url "https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/irt_lt_gby10_a$defaultview/?format=SDMX-CSV"

* Download the data using Stata's 'copy' command
cap copy "`url'" "eus_data.csv", replace

* Import the downloaded CSV file
import delimited "eus_data.csv", clear 

* Save 
save "$output/ltrate_1.dta", replace
rm "eus_data.csv"


* ==============================================================================
*   Central government bond yields (Historical)
* ============================================================================== 

local url "https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/ESTAT/irt_h_cgby_a/1.0?format=csvdata"

* Download the data using Stata's 'copy' command
cap copy "`url'" "eus_data.csv", replace

* Import the downloaded CSV file
import delimited "eus_data.csv", clear 

* Save 
save "$output/ltrate_2.dta", replace
rm "eus_data.csv"

* ==============================================================================
*   Central government bond yields (Modern)
* ============================================================================== 

local url "https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/ESTAT/irt_lt_mcby_a$defaultview/1.0?format=csvdata"

* Download the data using Stata's 'copy' command
cap copy "`url'" "eus_data.csv", replace

* Import the downloaded CSV file
import delimited "eus_data.csv", clear 

* Save 
save "$output/ltrate_3.dta", replace
rm "eus_data.csv"


* ==============================================================================
*   Real Effective exchange rates indices 
* ============================================================================== 
local url "https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/ESTAT/tipser13/1.0/?format=csvdata"

* Download the data using Stata's 'copy' command
cap copy "`url'" "eus_data.csv", replace

* Import the downloaded CSV file
import delimited "eus_data.csv", clear 

* Save 
save "$output/EER.dta", replace
rm "eus_data.csv"

* ==============================================================================
*   Gross domestic product (GDP) and main components (output, expenditure and income) (nama_10_gdp) 
* ============================================================================== 

local url "https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/nama_10_gdp/A.CP_MNAC+CLV15_MNAC.B1GQ+P3+P5G+P51G+P6+P7.?format=SDMX-CSV"

* Download the data using Stata's 'copy' command
cap copy "`url'" "eus_data.csv", replace

* Import the downloaded CSV file
import delimited "eus_data.csv", clear 

* Save 
save "$output/NA_A.dta", replace
rm "eus_data.csv"

* ==============================================================================
*   Government revenue, expenditure and main aggregates (gov_10a_main) 
* ============================================================================== 

local url "https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/gov_10a_main/A.PC_GDP.S13+S1311.TE+B9+TR.?format=SDMX-CSV"

* Download the data using Stata's 'copy' command
cap copy "`url'" "eus_data.csv", replace

* Import the downloaded CSV file
import delimited "eus_data.csv", clear 

* Save 
save "$output/GFS_A.dta", replace
rm "eus_data.csv"

* ==============================================================================
*  Main national accounts tax aggregates (gov_10a_taxag)	
* ============================================================================== 

local url "https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/gov_10a_taxag/A.PC_GDP.S13+S1311.D2_D5_D91_D61_M_D995.?format=SDMX-CSV"

* Download the data using Stata's 'copy' command
cap copy "`url'" "eus_data.csv", replace

* Import the downloaded CSV file
import delimited "eus_data.csv", clear 

* Save 
save "$output/govtax.dta", replace
rm "eus_data.csv"

* Save download date 
gmdsavedate, source(EUS)


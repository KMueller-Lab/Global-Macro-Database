* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-05-21
*
* Description: 
* This Stata script downloads data from Eurostat.
*
* Data source: 
* Eurostat
* 
* ==============================================================================

* Define output file name 
clear
global output "${data_raw}\aggregators\EUS\EUS"


* Create master tempfile to store all the datasets
tempfile temp_master
save `temp_master', replace emptyok

* ==============================================================================
* Harmonized consumer price index, 2015=100
* ==============================================================================

dbnomics import, pr(Eurostat) dataset(ei_cphi_m) unit(HICP2015) indic(CP-HI00) clear
tostring period, replace
destring value, replace 
keep period value geo dataset_name series_code series_name
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Harmonized consumer price Growth rate (t/t-12)
* ==============================================================================
* Download
dbnomics import, pr(Eurostat) dataset(ei_cphi_m) unit(RT12) indic(CP-HI00) clear
tostring period, replace
destring value, replace 
keep period value geo dataset_name series_code series_name
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* House price index (2015 = 100) - quarterly data
* ==============================================================================
* Download
dbnomics import, pr(Eurostat) dataset(ei_hppi_q) unit(I15_NSA) clear
tostring period, replace
destring value, replace 
keep period value geo dataset_name series_code series_name
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Gross domestic product at market prices
* ==============================================================================
* Download
dbnomics import, pr(Eurostat) dataset(nama_10_gdp) na_item(B1GQ) unit(CP_MNAC) clear
tostring period, replace
destring value, replace 
keep period value geo dataset_name series_code series_name
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Gross domestic product at Chain linked volumes (2010)
* ==============================================================================
* Download
dbnomics import, pr(Eurostat) dataset(nama_10_gdp) na_item(B1GQ) unit(CLV10_MNAC) clear
tostring period, replace
destring value, replace 
keep period value geo dataset_name series_code series_name
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Final consumption expenditure
* ==============================================================================
* Download
dbnomics import, pr(Eurostat) dataset(nama_10_gdp) na_item(P3) unit(CP_MNAC) clear
tostring period, replace
destring value, replace 
keep period value geo dataset_name series_code series_name
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Gross capital formation
* ==============================================================================
* Download
dbnomics import, pr(Eurostat) dataset(nama_10_gdp) na_item(P5G) unit(CP_MNAC) clear
tostring period, replace
destring value, replace 
keep period value geo dataset_name series_code series_name
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Gross fixed capital formation
* ==============================================================================
* Download
dbnomics import, pr(Eurostat) dataset(nama_10_gdp) na_item(P51G) unit(CP_MNAC) clear
tostring period, replace
destring value, replace 
keep period value geo dataset_name series_code series_name
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Imports of goods and services
* ==============================================================================
* Download
dbnomics import, pr(Eurostat) dataset(nama_10_gdp) na_item(P7) unit(CP_MNAC) clear
tostring period, replace
destring value, replace 
keep period value geo dataset_name series_code series_name
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Exports of goods and services
* ==============================================================================
* Download
dbnomics import, pr(Eurostat) dataset(nama_10_gdp) na_item(P6) unit(CP_MNAC) clear
tostring period, replace
destring value, replace 
keep period value geo dataset_name series_code series_name
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Total general government revenue
* ==============================================================================
* Download
dbnomics import, pr(Eurostat) dataset(gov_10a_main) na_item(TR) unit(MIO_NAC) sector(S1311) clear
tostring period, replace
destring value, replace 
keep period value geo dataset_name series_code series_name
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Total general government expenditure
* ==============================================================================
* Download
dbnomics import, pr(Eurostat) dataset(gov_10a_main) na_item(TE) unit(MIO_NAC) sector(S1311) clear
tostring period, replace
destring value, replace 
keep period value geo dataset_name series_code series_name
append using `temp_master'
save `temp_master', replace


* ==============================================================================
* Total tax receipts
* ==============================================================================
* Download
dbnomics import, pr(Eurostat) dataset(gov_10a_taxag) na_item(D2_D5_D91_D61_M_D995) unit(MIO_NAC) sector(S1311) clear
tostring period, replace
destring value, replace 
keep period value geo dataset_name series_code series_name
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Net lending (+) /net borrowing (-) (% of GDP)
* ==============================================================================
* Download
dbnomics import, pr(Eurostat) dataset(gov_10a_main) na_item(B9) unit(PC_GDP) sector(S1311) clear
tostring period, replace
destring value, replace 
keep period value geo dataset_name series_code series_name
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Population
* ==============================================================================
* Download
dbnomics import, pr(Eurostat) dataset(demo_gind) indic_de(JAN) clear
tostring period, replace
destring value, replace 
keep period value geo dataset_name series_code series_name
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Interest rates - monthly data
* ==============================================================================
* Download
dbnomics import, pr(Eurostat) dataset(ei_mfir_m) indic(MF-3MI-RT) clear
tostring period, replace
replace value = "" if value == "NA"
destring value, replace 
keep period value geo dataset_name series_code series_name
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Unemployment rate - annual data
* ==============================================================================
* Download
dbnomics import, pr(Eurostat) dataset(tipsun20) age(Y15-74) clear
tostring period, replace
destring value, replace 
keep period value geo dataset_name series_code series_name
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Real effective exchange rate – index, 42 trading partners
* ==============================================================================
* Download
dbnomics import, pr(Eurostat) dataset(tipser13) clear
drop obs_flag
tostring period, replace
destring value, replace 
keep period value geo dataset_name series_code series_name
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* Save
* ==============================================================================
* Save download date 
gmdsavedate, source(EUS)

* Save 
savedelta ${output}, id(period geo series_code)

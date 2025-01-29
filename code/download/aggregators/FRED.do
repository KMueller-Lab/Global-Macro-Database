* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD FRED DATA
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-04-05
*
* Description: 
* This stata script downloads FRED data using FRED Stata API
*
* This code downloads:
* (1) GDPA: (nGDP_LCU)
* (2) GDPCA: Real Gross Domestic Product (rGDP_LCU)
* (3) A939RX0Q048SBEA: Real gross domestic product per capita (rGDP_LCU_pc)
* (4) FPCPITOTLZGUSA: Inflation, consumer prices for the United States (infl)
* (5) B230RC0A052NBEA: Population (pop)
* (7) A929RC1A027NBEA: Gross Saving (sav)
* (8) W006RC1Q027SBEA: Federal government current tax receipts (govtax)
* (9) W068RCQ027SBEA: Government total expenditures (govexp)
* (10) EXPGSA: Exports of Goods and Services (exports)
* (11) IMPGSA: Imports of Goods and Services (imports)
* (12) A124RC1A027NBEA: Balance on current account (CA)
* (13) GFDEGDQ188S: Federal Debt: Total Public Debt as Percent of Gross Domestic Product  (govdebt_GDP)
* (14) RIFSPFFNA: Federal Funds Effective Rate (cbrate)
* (15) FYFSGDA188S: Federal Surplus or Deficit [-] as Percent of Gross Domestic Product (govdef_GDP)
* (15) AFRECPT: Federal Government Current Receipts (govrev)
* (16) BOGMBASE: Monetary Base; Total (M0)
* (17) M1SL: (M1)
* (18) M2SL: (M2)
* (20) UNRATE: Unemployment Rate (unemp)
* (21) USSTHPI: All-Transactions House Price Index for the United States (HPI)
* (23) BOGZ1FL073161113Q: Interest Rates and Price Indexes; 10-Year Treasury Yield, Level (ltrate)
* (24) RIFSGFSM03NA:  3-Month Treasury Bill Secondary Market Rate, Discount Basis (strate)
* 
* Data source:
* FRED Stata API
* 
* ==============================================================================

* Define output file name 
global output "${data_raw}\country_level\USA_1"

* Set up the API
set fredkey "89273e52242ebc2717544dd6901d486a"
import fred GDPA GDPCA A939RX0Q048SBEA FPCPITOTLZGUSA B230RC0A052NBEA A929RC1A027NBEA W006RC1Q027SBEA W068RCQ027SBEA EXPGSA IMPGSA A124RC1A027NBEA GFDEGDQ188S RIFSPFFNA FYFSGDA188S AFRECPT BOGMBASE M1SL M2SL UNRATE USSTHPI BOGZ1FL073161113Q RIFSGFSM03NA, clear

* Save download date 
gmdsavedate, source(USA_1)

* Save
savedelta ${output}, id(datestr)

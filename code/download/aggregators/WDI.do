* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD WORLD BANK DATA VIA WBOPENDATA PACKAGE
* 
* Author:
* Karsten Müller
* National University of Singapore
* 
* Description: 
* This script downloads World Bank Data using the wbopendata package
* 
* Note:
* To install the package, use the command: ssc install wbopendata
*
* Variables code is available at:
* http://databank.worldbank.org/data/download/site-content/WDI_CETS.xls
*
* This code downloads:
* (1) NY.GDP.MKTP.CD
* (2) NY.GDP.MKTP.CN
* (3) NY.GDP.MKTP.KD
* (4) NY.GDP.MKTP.KN
* (5) NY.GDP.PCAP.KN
* (6) FP.CPI.TOTL
* (7) FP.CPI.TOTL.ZG
* (8) SP.POP.TOTL
* (9) NE.GDI.TOTL.CN
* (10) NE.GDI.FTOT.CN
* (11) NY.GNS.ICTR.CN
* (12) NE.CON.TOTL.CN
* (13) NE.EXP.GNFS.CN
* (14) NE.IMP.GNFS.CN
* (15) PA.NUS.FCRF
* (16) PX.REX.REER
* (17) BN.CAB.XOKA.GD.ZS
* (18) GC.TAX.TOTL.GD.ZS
* (19) GC.DOD.TOTL.CN
* (20) GC.XPN.TOTL.CN
* (21) GC.REV.XGRT.GD.ZS
*
* Data source:
* World Bank Data via the wbopendata package
* 
* ==============================================================================

* Define output files 
global output "${data_raw}\aggregators\WB\WDI"

wbopendata, indicator(NY.GDP.MKTP.CD; NY.GDP.MKTP.CN; NY.GDP.MKTP.KD; NY.GDP.MKTP.KN; NY.GDP.PCAP.KN; FP.CPI.TOTL; FP.CPI.TOTL.ZG; SP.POP.TOTL; NE.GDI.TOTL.CN; NE.GDI.FTOT.CN; NY.GNS.ICTR.CN; NE.CON.TOTL.CN; NE.CON.TOTL.KN; NE.EXP.GNFS.CN; NE.EXP.GNFS.CD; NE.IMP.GNFS.CN; NE.IMP.GNFS.CD; PA.NUS.FCRF; PX.REX.REER; BN.CAB.XOKA.GD.ZS; GC.TAX.TOTL.CN; GC.DOD.TOTL.CN; GC.XPN.TOTL.CN; GC.TAX.TOTL.GD.ZS; GC.REV.XGRT.GD.ZS; FM.LBL.BMNY.CN) clear

* Save download date 
gmdsavedate, source(WDI)

* Save the dataset
savedelta ${output}, id(countrycode indicatorcode) 

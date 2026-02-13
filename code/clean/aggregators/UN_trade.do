* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN TRADE ECONOMIC DATA FROM UN
* 
* Author:
* Shixuan Yuan
* National University of Singapore
*
* Created: 2025-06-20
*
* Description: 
* Script to process and output historical trade data from the UN 
*
* URL: https://unstats.un.org/unsd/trade/imts/Historical%20data%201900-1960.pdf
*
* Note: This data is extracted from the PDF above and saved in a csv file. 
* ==============================================================================

* ==============================================================================
*			SET UP
* ==============================================================================

* Clear data 
clear
* Define input and output files 
global input "${data_raw}/aggregators/UN_trade/UN_trade.csv"
global output "${data_clean}/aggregators/UN_trade/UN_trade"

* ==============================================================================
* 	PROCESS DATA
* ==============================================================================

* Open
import delimited using "$input", varnames(1) clear

* Rename
ren (country value) (countryname UN_trade_)

* Assign Belgium Luxembourg to Belgium 
replace countryname = "Belgium" if countryname == "Belgium-Luxembourg"

* Add ISO3
merge m:1 countryname using $isomapping, keepus(ISO3) assert(2 3) keep(3) nogen
drop countryname 

* United Kingdom export data is both exports and reexport, we are adding them together
bys ISO3 year -variable: replace variable = "re_exports" if ISO3 == "GBR" & variable == "exports" & _n == _N

* Reshape
greshape wide UN_trade_, i(year ISO3) j(variable)
ren UN_trade_* UN_trade_*_USD

* Add re-exports to exports 
replace UN_trade_exports_USD = UN_trade_exports_USD + UN_trade_re_exports_USD if UN_trade_re_exports_USD != .

* Drop re-exports
drop UN_trade_re_exports_USD


* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplciates
isid ISO3 year

* Save
save "${output}", replace




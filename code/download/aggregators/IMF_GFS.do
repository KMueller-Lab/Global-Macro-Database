* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, and Ziliang Chen
* ==============================================================================
* Download Government Finance Statistics (GFS) data from IMF 
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2025-09-20
*
* Description: 
* This Stata script downloads Government Finance Statistics from the IMF
*
* Data source: IMF API
* 
* ==============================================================================

* Run the master file
do "code/0_master.do"

cap {

global output "${data_raw}/aggregators/IMF/IMF_GFS"
cd "$output"

global Rterm_path "/usr/local/bin/R"
global Rterm_options "--vanilla --slave"

rsource, terminator(END)



library(rsdmx)
library(tidyverse)
library(haven)

# General government
# Government tax
flowref <- 'IMF.STA,GFS_SOO'
filter <- '.S13.G1.G11_T.POGDP_PT.A'

dataset1 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter)

df1 <- as.data.frame(dataset1)

filter2 <- '.S13.G1.G11_T.XDC.A'
dataset2 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter2)
df2 <- as.data.frame(dataset2)

# Revenue
filter3 <- '.S13.G1.G1_T.POGDP_PT.A'
dataset3 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter3)
df3 <- as.data.frame(dataset3)

filter4 <- '.S13.G1.G1_T.XDC.A'
dataset4 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter4)
df4 <- as.data.frame(dataset4)

# Expense
filter5 <- '.S13.G2M.G2_T.POGDP_PT.A'
dataset5 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter5)
df5 <- as.data.frame(dataset5)

filter6 <- '.S13.G2M.G2_T.XDC.A'
dataset6 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter6)
df6 <- as.data.frame(dataset6)

# GOV_DEF
filter7 <- '.S13.BI.GNLB_T.POGDP_PT.A'
dataset7 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter7)
df7 <- as.data.frame(dataset7)

filter8 <- '.S13.BI.GNLB_T.XDC.A'
dataset8 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter8)
df8 <- as.data.frame(dataset8)

combined_df_1 <- bind_rows(df1, df2, df3, df4, df5, df6, df7, df8)


# Central government
# Government tax
flowref <- 'IMF.STA,GFS_SOO'
filter <- '.S1311.G1.G11_T.POGDP_PT.A'

dataset1 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter)

df1 <- as.data.frame(dataset1)

filter2 <- '.S1311.G1.G11_T.XDC.A'
dataset2 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter2)
df2 <- as.data.frame(dataset2)

# Revenue
filter3 <- '.S1311.G1.G1_T.POGDP_PT.A'
dataset3 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter3)
df3 <- as.data.frame(dataset3)

filter4 <- '.S1311.G1.G1_T.XDC.A'
dataset4 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter4)
df4 <- as.data.frame(dataset4)

# Expense
filter5 <- '.S1311.G2M.G2_T.POGDP_PT.A'
dataset5 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter5)
df5 <- as.data.frame(dataset5)

filter6 <- '.S1311.G2M.G2_T.XDC.A'
dataset6 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter6)
df6 <- as.data.frame(dataset6)

# GOV_DEF
filter7 <- '.S1311.BI.GNLB_T.POGDP_PT.A'
dataset7 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter7)
df7 <- as.data.frame(dataset7)

filter8 <- '.S1311.BI.GNLB_T.XDC.A'
dataset8 <- readSDMX(providerId = 'IMF_DATA',
                     resource   = 'data',
                     flowRef    = flowref,
                     key        = filter8)
df8 <- as.data.frame(dataset8)

combined_df <- bind_rows(df1, df2, df3, df4, df5, df6, df7, df8, combined_df_1)

write_csv(combined_df, "IMF_GFS.csv")



q()  

END


cd "$path"


* Save download date 
gmdsavedate, source(IMF_GFS)


}


* Create the log
clear
set obs 1
gen variable = "IMF_GFS"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save
save "$data_temp/download_log/IMF_GFS_log.dta", replace

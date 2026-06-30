# The Global Macro Database
<a href="https://www.globalmacrodata.com" target="_blank" rel="noopener noreferrer">
    <img src="https://img.shields.io/badge/Website-Visit-blue?style=flat&logo=google-chrome" alt="Website Badge">
</a>

[Link to paper 📄](https://www.globalmacrodata.com/research-paper.html)



This repository complements our paper, **Müller, Xu, Lehbib, and Chen (2025)**, which introduces a panel dataset of **46 core macroeconomic variables (provided as 77 harmonized series) across 239 countries** from historical records beginning in the year **1086** until **2025**, including projections through the year **2030**.

## Version 2026_06 – Current

  ### Overview

  The 2026_06 quarterly update expands coverage with 39 new aggregator and country-level historical sources, improves our continuous automated error-monitoring system, resolves dozens of data-quality bugs, completes a comprehensive audit of the Mitchell historical statistics, and improves the Stata, R, and Python packages.

  ### New Sources

  This release adds 39 new sources, bringing the database to 160 sources in total. The additions are dominated by long-run country-level historical sources, complemented by several new cross-country aggregators. Highlights include:

  - **SECMCA historical statistics**: macroeconomic statistics from the Central American Monetary Council for Costa Rica, the Dominican Republic, Guatemala, Honduras, Nicaragua, and El Salvador (1960–2017).
  - **German historical sources**: Ritschl (2002) and Ritschl & Spoerer (1997), adding interwar and German Reich macroeconomic, fiscal, monetary, trade, price, population, and national-accounts series.
  - **International Historical Database (IHD)**: additional series with improved source splits and price mappings.
  - **Archivo de Historia Económica de México**: long-run Mexican national accounts, prices, money, and public finances (1876–2025).
  - **Ghana**: historical monetary, inflation, and output series from Ibrahim Abdulai's work on Ghana (1980–2017).
  - **Australia**: Foster's *Australian Economic Statistics* (1949/50–1994/95).
  - **Netherlands**: the Herengracht house-price index (1628–1973), one of the longest continuous real-estate price series available.
  - **Korea**: Open Fiscal Data from the Republic of Korea's Ministry of Economy and Finance.
  - **China**: Chinese national income estimates, 1661–1933.
  - **United Kingdom**: Feinstein's national income, expenditure, and output series (1855–1965), plus the Sefton-Weale balanced estimates of UK national income (1920–1990).
  - **Further country-level additions**: new or expanded sources for India, New Zealand, Spain, Sweden, Turkey, Japan, Russia, Israel, Bulgaria, Venezuela, and Italy.
  - **CEPII**: the CEPII trade-and-macro source has been refreshed and renamed from `CEPII_TRADHIST` to `CEPII`.

  ### Automated Error Monitoring

  This release expands our continuous error-monitoring system that scans the database for ratio discrepancies, unit breaks, and other anomalies, then routes each flagged case through an auto-triage workflow for review. The system has already identified and resolved dozens of data-quality issues and will keep running against future updates.

  ### Data Quality and Bug Fixes

  Driven by the new monitoring system and reports from GMD users, this release resolves dozens of bugs. The most important corrections fall into two groups:

  - **Units, scaling, and redenominations**: corrected unit-scale and currency-vintage issues across IMF IFS, IMF GFS, Andersson, Bordo monetary aggregates, Flora, the African Development Bank source, HFS, and UN data.
  - **Splicing and ratio consistency**: improved handling of gaps between sources, improved overlap handling, and corrected the US long-term interest-rate series.

  ### Mitchell Historical Audit

  We completed a comprehensive audit of the Mitchell International Historical Statistics, fixing issues and correcting the euro-cutoff handling for European government tax series.

  ### Package Updates

  The Stata, R, and Python packages have all been improved. The three distributions remain at full feature parity, so users have the same access to the combined database, underlying source data, and documentation regardless of language.

  ### Easy Access to Underlying Raw Data

  We have improved access to the underlying raw data, making it easier for users to download and analyze the original sources. Previously, the data was only available by downloading the Excel version of the database or using our Stata, R, or Python packages. From now on, users can simply indicate whether they want access to the underlying raw data on the download page, even where they download the csv or dta versions.

  ### Acknowledgements

  Thanks to everyone who reported issues and suggested improvements. Many fixes in this release came directly from user reports.

## Version 2026_03

  ### Overview

  This release adds eleven new data sources, introduces two new variables, improves the methodology for splicing government finance ratios, harmonizes all ratio variables, and updates the Python and R packages to full feature parity with the Stata package.

  ### New Sources

  We added eleven new sources to the database:

  - **COMECON**: The wiiw COMECON Dataset, covering economic time series for the command economies of Eastern Europe (1944–1994), including GDP, consumption, trade, government finance, monetary, and price data for nine countries.
  - **CogneauDupraz**: Colonial fiscal, GDP, trade, and population data for French colonies (1833–1962), covering Algeria, Tunisia, Morocco, Madagascar, Cameroon, and Togo.
  - **MAFHOLA**: The Monetary and Fiscal History of Latin America project, covering GDP, inflation, fiscal balances, government debt, exchange rates, and monetary base for eleven Latin American countries (1960–2017).
  - **Andersson**: Central government revenue data from Per F. Andersson, covering revenue and GDP for multiple countries from the 1800s onwards.
  - **CS1_BOL**: Historical real GDP for Bolivia from Herranz-Loncan & Peres-Cajias (2016), extending coverage back to the mid-nineteenth century (1846, 1890–2010).
  - **CS2_BOL**: Bolivian public finance data from Peres-Cajias (2014), covering central and general government revenue, expenditure, and tax ratios (1882–2010).
  - **CS1_PER**: Historical macroeconomic data from the Banco Central de Reserva del Peru, covering national accounts, prices, trade, monetary aggregates, and fiscal data for Peru (1922–2021).
  - **CS1_COL**: Historical series from Colombia's central bank, covering government finances, trade, current account, and monetary aggregates.
  - **CS1_HKG**: Historical data for Hong Kong including monetary aggregates, government finance, trade, GDP, exchange rates, and prices (1843–2002).
  - **CS2_AUT**: Long-run Austrian CPI series from Hubmann, Jobst & Maier (2020), covering 1800–2018.
  - **CS2_GBR**: UK historical public finances from HM Treasury, covering government revenue and expenditure.

  ### New Variables

  We introduced two new consumption variables: household consumption (`hcons`) and government consumption (`gcons`). These complement the existing total consumption (`cons`) variable and provide a finer decomposition of the expenditure side of GDP.

  ### Improved Government Finance Ratio Splicing

  We introduced a new methodology for combining government finance ratios (revenue, expenditure, tax, debt, and deficit as % of GDP). Previously, we spliced the underlying level series and then derived the ratios. We now splice the ratios directly, which avoids compounding errors that arise when the numerator and denominator are spliced separately with different chainlinking adjustments.

  ### Ratio Harmonization

  All ratio variables (e.g., `govdebt_GDP`, `exports_GDP`, `CA_GDP`) are now consistently expressed in percent, so that a value of 50 means 50% of GDP.

  ### Package Updates

  The Python and R packages have been updated to match the full functionality of the Stata package, including access to underlying source data and documentation features.

  ### Data Quality

  We incorporated feedback from GMD users and improved data quality across multiple variables and sources.


## Version 2026_01

### Overview

This release introduces significant enhancements to data accuracy and infrastructure. Key updates include a comprehensive revision of the real GDP series and the deployment of a fully automated, cloud-based data processing pipeline to ensure timely future updates.

### Real GDP Improvement

We have conducted a major review of the real GDP series. The data has been rigorously corrected and is now consistently rebased to the year 2015, ensuring greater comparability and accuracy across the dataset.

### Automated Pipeline

To improve long-term sustainability and data freshness, we have engineered a new automated pipeline. This system autonomously handles downloading, processing, and merging data from all sources in the cloud, streamlining the maintenance process and allowing for more frequent and reliable database updates.

### Stata Package & Documentation

We have launched a dedicated repository for the official Stata package, now available at [Global-Macro-Database-Stata](https://github.com/KMueller-Lab/Global-Macro-Database-Stata). Additionally, we have released a comprehensive companion paper, [Global_Macro_Database_Stata.pdf](https://github.com/KMueller-Lab/Global-Macro-Database-Stata/blob/main/Global_Macro_Database_Stata.pdf), which serves as a detailed guide to using the package effectively.

## Features

- **Unparalleled Coverage**: Combines data from **33 contemporary sources** (e.g., IMF, World Bank, OECD) and **127 historical datasets**, totaling **160 sources**.
- **Extensive Variables**: Covers national accounts, consumption, investment, trade, prices, government finances, interest rates, employment, and financial crises.
- **Transparent Source Prioritization**: Prioritizes country-specific sources over international aggregators to ensure both historical depth and accuracy.
- **Harmonized Data**: All data is cleaned, spliced, and chainlinked for consistent cross-country comparison.
- **Comprehensive Metadata**: Variable definitions follow SNA 2008 standards and are documented in the technical appendix.
- **Frequent Updates**: Quarterly releases with version control and changelogs.
- **Open Access & Tools**: Access data via web, Python, R, or Stata packages. All processing code is open source.

## Data Access

Download via Website

**Stata package:**

```stata
ssc install gmd
gmd rGDP, country(FRA)
```

**Python package:**

```bash
pip install global_macro_data
```

```python
from global_macro_data import gmd
df = gmd(version="2026_06", country=["USA", "CHN"], variables=["rGDP", "CPI"])
```

**R package:**

```R
install.packages("devtools")
devtools::install_github("KMueller-Lab/Global-Macro-Database-R")
library(globalmacrodata)
df <- gmd(version = "2026_06", country = c("USA", "CHN"), variables = c("rGDP", "CPI"))
```

## Release Schedule

| Release Date | Version  | Details         |
| ------------ | -------- | --------------- |
| 2025-01-30   | 2025\_01 | Initial release |
| 2025-03-31   | 2025\_03 | Legacy version  |
| 2025-06-30   | 2025\_06 | Legacy version  |
| 2025-08-23   | 2025\_08 | Legacy version (Patch) |
| 2025-09-30   | 2025\_09 | Legacy version  |
| 2025-12-31   | 2025\_12 | Legacy version  |
| 2026-01-25   | 2026\_01 | Legacy version (Patch) |
| 2026-03-31   | 2026\_03 | Legacy version  |
| 2026-06-30   | 2026\_06 | *Current Version*       |
| 2026-09-30   | 2026\_09 | *Planned*       |

---

## Release Note (2025_12)

### Overview

The 2025_12 version includes updated data as of December 2025 and introduces various important patches and improvements. We also rewrote the Stata package from scratch: get the new version by typing `ssc install gmd`. Lehbib and Müller (2025) provides more details.

### Improved Government Finance Statistics

We further improved the construction of combined government finance statistics. Relative to before, the combined time series are now mostly based on chain-linking ratios, with some exceptions, and we more commonly use a country-specific priority ordering of sources.

### Extended Technical Appendix

We considerably improved the technical appendix to enhance clarity and readability. Going forward, we will provide a dedicated technical appendix with each release.

### Major Update to Stata Package

We rewrote the Stata package from scratch to make it faster and added various new functionalities, including the ability to easily access all the (cleaned) data underlying the GMD. A new companion paper (Lehbib and Müller, 2025) now describes the package in detail.

### Bug Fixes

Thanks to the support of many GMD users, we were able to identify and fix many bugs. Noteworthy examples include real GDP per capita for Venezuela and the inflation rates of a few countries.

### New Variable

The GMD now includes the World Bank's income classification.

---

## Release Note (2025_09)

### Overview

Released September 30, 2025. This quarterly update introduces improved government finance statistics, streamlined source handling, a new outlier detection process, and numerous fixes and small improvements.

### Key changes 

#### Improved Government Finance Statistics
- Distinguishes between central and general government data
- Included in the GMD as separate series and consolidated aggregates

#### Improved Download Infrastructure
- Downloads now pull directly from IMF, Eurostat, OECD, and UN rather than dbnomics
- IMF downloads now use the newly released API (3.0)

#### Pipeline Improvements
- The GMD pipeline was overhauled
- Runtime improved by approximately 10x

#### New and Improved Sources
- Various IMF and OECD datasets are treated as a single "source" where appropriate
- Added historical monetary statistics for France and unemployment series from Eurostat

#### Automated Error Checking
- Automated checks now cover multiple error types across the dataset
- Suspicious values are manually reviewed and confirmed

#### Bug Fixes
- Thanks to many contributors, various small bugs were identified and fixed
- Corrected systematic mistakes identified in the World Bank's WDI and IMF's FPP data

---

## Citation

Please cite the dataset as:

```bibtex
@techreport{GMD2025,
  title = {The Global Macro Database: A New International Macroeconomic Dataset},
  author = {M{"u}ller, Karsten and Xu, Chenzi and Lehbib, Mohamed and Chen, Ziliang},
  institution = {National Bureau of Economic Research},
  type = {Working Paper},
  series = {Working Paper Series},
  number = {33714},
  year = {2025},
  month = {April},
  doi = {10.3386/w33714},
  URL = {http://www.nber.org/papers/w33714},
}
```

---

## Acknowledgments

The development of the Global Macro Database would not have been possible without the generous funding provided by the Singapore Ministry of Education (MOE) through the PYP grants (WBS A-0003319-01-00 and A-0003319-02-00), a Tier 1 grant (A-8001749- 00-00), and the NUS Risk Management Institute (A-8002360-00-00). This financial support laid the foundation for the successful completion of this extensive project.

## License

The Global Macro Database (GMD) is released under the **GMD Research Use Terms** (Version 1.0) — our own license for public-good data. It follows the spirit of CC BY-NC-SA 4.0, but where it differs, the Research Use Terms govern. The full terms are at [globalmacrodata.com/license.html](https://www.globalmacrodata.com/license.html).

**The short version** (a plain-English summary; the full Research Use Terms are what actually govern):

- **Free for research.** Universities, non-profits, students, teachers, journalists, individual researchers, and public-sector bodies (central banks, regulators, finance ministries, international organizations) — for papers, teaching, theses, reporting, non-commercial policy work, and personal learning.
- **Not for business.** Not for commercial use, or for use inside for-profit companies of any kind, even internally — including building it, in whole or in derived form, into any product, service, model, index, or paid report.
- **Cite it.** Always credit the GMD and its authors (see the Citation section above).
- **Do not re-host or rebadge it.** Do not republish the data on another website, API, platform, product, or under another name without explicit written approval — point people to [globalmacrodata.com](https://www.globalmacrodata.com) so they get the latest data and cite it. (You may include the specific data used in a paper in that paper's replication package, clearly labeled as coming from the GMD.)
- **Share alike.** If we allow you to build on it and share, keep these same terms.
- **As-is.** No warranty for correctness; we do our best to provide accurate data.

**Unsure, or need something else?** Treat your use as commercial and email kmueller@globalmacrodata.com.

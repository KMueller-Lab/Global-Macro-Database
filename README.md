# The Global Macro Database
<a href="https://www.globalmacrodata.com" target="_blank" rel="noopener noreferrer">
    <img src="https://img.shields.io/badge/Website-Visit-blue?style=flat&logo=google-chrome" alt="Website Badge">
</a>

[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

[Link to paper 📄](https://www.globalmacrodata.com/research-paper.html)



This repository complements our paper, **Müller, Xu, Lehbib, and Chen (2025)**, which introduces a panel dataset of **46 macroeconomic variables across 243 countries** from historical records beginning in the year **1086** until **2024**, including projections through the year **2030**.

## Version 2025_12 – current

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



## Features

- **Unparalleled Coverage**: Combines data from **32 contemporary sources** (e.g., IMF, World Bank, OECD) and **86 historical datasets**, totaling **118 sources**.
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
df = gmd(version="2025_09", country=["USA", "CHN"], variables=["rGDP", "CPI"])
```

**R package:**

```R
install.packages("devtools")
devtools::install_github("KMueller-Lab/Global-Macro-Database-R")
library(globalmacrodata)
df <- gmd(version = "2025_09", country = c("USA", "CHN"), variables = c("rGDP", "CPI"))
```

## Release Schedule

| Release Date | Version  | Details         |
| ------------ | -------- | --------------- |
| 2025-01-30   | 2025\_01 | Initial release |
| 2025-03-31   | 2025\_03 | Legacy version  |
| 2025-06-30   | 2025\_06 | Legacy version  |
| 2025-08-23   | 2025\_08 | Legacy version (Patch) |
| 2025-09-30   | 2025\_09 | Legacy version  |
| | | |
| 2025-12-31   | 2025\_12 | *Current version* |
| 2026-03-31   | 2026\_03 | *Planned*       |
| 2026-06-30   | 2026\_06 | *Planned*       |

---

## Release Note (2025\_09)

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

The Global Macro Database (GMD) is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License (CC BY-NC-SA 4.0) . This means that the dataset is freely available for research and educational purposes but may not be used commercially.

Under this license, users are free to:

- Share – copy and redistribute the material in any medium or format
- Adapt – remix, transform, and build upon the material
- These freedoms are granted under the following conditions:

   - Attribution – Appropriate credit must be given to the Global Macro Database (GMD), including a link to the license and indication of any changes made. Attribution must not imply endorsement.
   - NonCommercial – The material may not be used for commercial purposes.
   - ShareAlike – If you remix or build upon the material, you must distribute your contributions under the same license.

For licensing or usage inquiries, please contact us at hello@globalmacrodata.com.

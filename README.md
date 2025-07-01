# The Global Macro Database
<a href="https://www.globalmacrodata.com" target="_blank" rel="noopener noreferrer">
    <img src="https://img.shields.io/badge/Website-Visit-blue?style=flat&logo=google-chrome" alt="Website Badge">
</a>

[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

[Link to paper 📄](https://www.globalmacrodata.com/research-paper.html)



This repository complements our paper, **Müller, Xu, Lehbib, and Chen (2025)**, which introduces a panel dataset of **46 macroeconomic variables across 243 countries** from historical records beginning in the year **1086** until **2024**, including projections through the year **2030**.




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
net install gmd, from(http://www.globalmacrodata.com/package)
gmd rGDP, country(FRA)
```

**Python package:**

```bash
pip install global_macro_data
```

```python
from global_macro_data import gmd
df = gmd(version="2025_06", country=["USA", "CHN"], variables=["rGDP", "CPI"])
```

**R package:**

```R
install.packages("devtools")
devtools::install_github("KMueller-Lab/Global-Macro-Database-R")
library(globalmacrodata)
df <- gmd(version = "2025_06", country = c("USA", "CHN"), variables = c("rGDP", "CPI"))
```

## Release Schedule

| Release Date | Version  | Details         |
| ------------ | -------- | --------------- |
| 2025-01-30   | 2025\_01 | Initial release |
| 2025-04-01   | 2025\_03 | Legacy Version  |
| 2025-07-01   | 2025\_06 | Current Version |
| 2025-10-01   | 2025\_09 | *Planned*       |
| 2026-01-01   | 2025\_12 | *Planned*       |

---

## Release Note (2025\_06)

### Overview

Released June 30, 2025. This update brings improved inflation series, methodological refinements in government finance construction, six new historical sources, and enhanced priority logic across core variables.

### Key Changes

#### Inflation Data Patch

- Fixed issues caused by breaks in CPI series.
- Revised source priority list to incorporate new sources.

#### New Sources and Coverage

- Integrated six new datasets: `RR_infl`, `Clio`, `UN_trade`, `BEL_1`, `CAN_2`, and `KOR_2`.
- Revised source hierarchy for `nGDP`, `cons`, `inv`, `finv`, `imports`, and `exports`.

#### Government Finance Methodology

- Fiscal series (`govdebt`, `govdef`, `govexp`, `govrev`, `govtax`) are now derived from GDP ratios.
- Applied chainlinking to back out consistent level series.

#### Bug Fixes and Improvements

- Enhanced the robustness of the cleaning pipeline.
- Addressed inconsistencies across a few long-run sources.

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

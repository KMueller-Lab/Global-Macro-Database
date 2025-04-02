# The Global Macro Database
<a href="https://www.globalmacrodata.com" target="_blank" rel="noopener noreferrer">
    <img src="https://img.shields.io/badge/Website-Visit-blue?style=flat&logo=google-chrome" alt="Website Badge">
</a>

[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

[Link to paper 📄](https://www.globalmacrodata.com/research-paper.html)



This repository complements our paper, **Müller, Xu, Lehbib, and Chen (2025)**, which introduces a panel dataset of **46 macroeconomic variables across 243 countries** from historical records beginning in the year **1086** until **2024**, including projections through the year **2030**.




## Features

- **Unparalleled Coverage**: Combines data from **32 contemporary sources** (e.g., IMF, World Bank, OECD) with **81 historical datasets**.
- **Extensive Variables**: GDP, inflation, government finance, trade, employment, interest rates, and more.
- **Harmonized Data**: Resolves inconsistencies and splices all available data together.
- **Scheduled Updates**: Regular releases ensure data reliability.
- **Full Transparency**: All code is open source and available in this repository.
- **Accessible Formats**: Provided in `.dta`, `.csv`, `.xlsx`, and as a **Stata package**.

## Data access

<a href="https://www.globalmacrodata.com/data.html" target="_blank" rel="noopener noreferrer">Download via website</a>

**Stata package:**
```
net install gmd, from(http://www.globalmacrodata.com/package)
gmd rGDP, country(FRA)
```

## Release schedule 

| Release Date | Details         |
|--------------|-----------------|
| 2025-01-30   | Initial Release: 2025_01 |
| 2025-04-01   | Current Version: 2025_03         |
| 2025-07-01   | Version: 2025_06         |
| 2025-10-01   | Version: 2025_09         |
| 2026-01-01   | Version: 2025_12         |

---

## Release Note
📅 Released: March 31, 2025

### Overview
This release includes updated annual data, expanded historical coverage for key countries, resolved inconsistencies in past series, and introduces new ways to access the database through our Python, R, and Stata packages.

### Data Updates
All datasets have been updated to include the most recently published annual values as of the release date.

### Expanded Historical Coverage
New long-run series have been added for Argentina, Ireland, and Taiwan, enriching the database's historical scope.

### IMF WEO Treatment Refined
We now treat the IMF World Economic Outlook (WEO) as two distinct sources: one for historical values and one for forecasts. This allows for clearer documentation and improved management of discontinuities between past data and forward-looking projections.

### World Bank Data Prioritization
We have adjusted our source hierarchy to prioritize data from the World Development Indicators (WDI) over both editions of the IMF WEO. This change has resulted in some level adjustments, while maintaining stable trends. Correlation with previous versions remains high across variables—for example, nominal GDP retains a minimum correlation of 0.97 between the old and new series.

### Exchange Rate Coverage
Monaco has been added to the EUR_fx irrevocable exchange rate list with a fixed rate of 6.55, aligned with the French Franc, which served as the country’s de facto currency prior to euro adoption.

### Bug Fixes
Corrected inaccuracies in Australia’s long-run historical real GDP in USD figures.

### New Access Tools
- **Python and R packages**: We are excited to announce that our data can now also be easily accessed using our newly-released Python and R packages. See the Data page for setup instructions.
- **Official Stata package**: Now available through the SSC Archive. New function updated for downloading underlying raw data via the "raw" option when using a specific variable.

---

## Citation

To cite this dataset, please use the following reference:

```bibtex
@techreport{mueller2025global, 
    title = {The Global Macro Database: A New International Macroeconomic Dataset}, 
    author = {Müller, Karsten and Xu, Chenzi and Lehbib, Mohamed and Chen, Ziliang}, 
    year = {2025}, 
    type = {Working Paper}
}
```

## Acknowledgments

The development of the Global Macro Database would not have been possible without the generous funding provided by the Singapore Ministry of Education (MOE) through the PYP grants (WBS A-0003319-01-00 and A-0003319-02-00), a Tier 1 grant (A-8001749- 00-00), and the NUS Risk Management Institute (A-8002360-00-00). This financial support laid the foundation for the successful completion of this extensive project.

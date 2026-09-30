# The Global Macro Database

<sub>Commercial users: see the [World Economic Database](https://www.anansidata.com/products/wed) from our partners at Anansi Data Analytics.</sub>

<a href="https://www.globalmacrodata.com" target="_blank" rel="noopener noreferrer">
    <img src="https://img.shields.io/badge/Website-Visit-blue?style=flat&logo=google-chrome" alt="Website Badge">
</a>

[Link to paper 📄](https://www.globalmacrodata.com/research-paper.html)

This repository complements our paper, **Müller, Xu, Lehbib, and Chen (2025)**, which introduces a panel dataset of **46 core macroeconomic variables (provided as 77 harmonized series) across 239 countries** from historical records beginning in the year **1086** until **2025**, including projections through the year **2031**.

## Features

- **Coverage**: Combines **35 contemporary sources** (e.g., IMF, World Bank, OECD) and **132 historical datasets**, **167 sources** in total.
- **Variables**: National accounts, consumption, investment, trade, prices, government finances, interest rates, employment, and financial crises.
- **Source prioritization**: Country-specific sources take priority over international aggregators, for both historical depth and accuracy.
- **Harmonized data**: All data is cleaned, spliced, and chainlinked for consistent cross-country comparison.
- **Metadata**: Variable definitions follow SNA 2008 and are documented in the [technical appendix](https://gmd-releases.s3.ap-southeast-2.amazonaws.com/data/distribute/GMD_TA.pdf).
- **Quarterly releases**: Each release has a version number and release notes.
- **Access**: Download from the website, or load the data with the Python, R, Stata, MATLAB, or Julia packages.

## Data Access

Download the latest release in CSV, Stata, or Excel format from the [website](https://www.globalmacrodata.com/data.html).

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
df = gmd(version="2026_09", country=["USA", "CHN"], variables=["rGDP", "CPI"])
```

**R package:**

```R
install.packages("devtools")
devtools::install_github("KMueller-Lab/Global-Macro-Database-R")
library(globalmacrodata)
df <- gmd(version = "2026_09", country = c("USA", "CHN"), variables = c("rGDP", "CPI"))
```

**MATLAB and Julia:** see the [MATLAB](https://github.com/KMueller-Lab/Global-Macro-Database-Matlab) and [Julia](https://github.com/KMueller-Lab/Global-Macro-Database-Julia) packages.

## What this repository holds

- `data/helpers/versions.csv` lists every release. The packages read it to check for new versions.
- `data/helpers/release_notes/` holds the notes for each release.
- `code/`, `data/` (apart from `data/helpers/`), `output/` and `docs/` are from the first release (2025_01). They are kept as a replication archive and are not updated. Later releases are built with a separate pipeline that is not public.

Report data errors and package problems as [issues](https://github.com/KMueller-Lab/Global-Macro-Database/issues).

## Releases

We release a new version every quarter. The release schedule and the notes for all past releases are on the [releases page](https://www.globalmacrodata.com/releases.html) and under [GitHub Releases](https://github.com/KMueller-Lab/Global-Macro-Database/releases).

<!-- GMD:CURRENT_RELEASE:BEGIN -->
## Version 2026_09 – Current


### Overview

The 2026_09 release focuses on data quality and coverage. It corrects hundreds of errors in exchange rates, currency units, and government deficits, and adds seven sources, including historical estimates that extend GDP for Spain, Italy, and Portugal back to the fourteenth to sixteenth centuries.

### New Sources

This release adds seven sources, bringing the total to 167.

- **Prados de la Escosura, Álvarez-Nogal and Santiago-Caballero**: annual estimates for preindustrial Spain, 1277–1850, published by the Fundación Rafael del Pino. Spanish nominal GDP now begins in 1277 instead of 1827. Where the periods overlap, the source's real GDP and population are close to the series already in the database.
- **Malanima**: GDP for central and northern Italy, 1310–1913. Italian nominal and real GDP now begin in 1310 instead of 1861, and the consumer price index in 1310 instead of 1800.
- **Palma and Reis**: a reconstruction of Portuguese economic growth, 1527–1850. It adds real GDP for 1527–1850, nominal GDP for 1527–1826, population for 1527–1799, and consumer prices for 1527–1671, none of which were previously covered.
- **Sultan Nazrin Shah**: expenditure-based national accounts for Malaya, 1900–1939, published by the Economic History of Malaysia project. These are the database's first national accounts for Malaysia before independence: nominal and real GDP, household and government consumption, fixed investment, and inflation, as well as exports and imports for 1900–1911, which the trade sources did not cover.
- **Catão and Solomou**: trade-weighted real effective exchange rates for sixteen countries, 1870–1913. For Argentina, Brazil, Chile, China, India, Japan, Mexico, and the United States, these are the first real effective exchange rates before the First World War; for the other eight countries, they overlap with existing series.
- **Bank of Canada and Bank of England**: sovereign default dates for about 174 countries, 1960–2024, from the BoC–BoE Sovereign Default Database. They fill gaps in the sovereign debt crisis dates without replacing the existing ones.
- **Asian Development Bank**: an archived version of the Key Indicators Database, which keeps series that the current version no longer provides.

### Updated Sources

- **Laeven and Valencia**: banking crisis dates now come from the latest edition of the systemic banking crises database. It extends coverage from 2017 to 2025 and adds thirteen crises.

### Use with AI agents

The Global Macro Database can now be used directly from AI agents through the [Anansi MCP server](https://mcp.anansidata.com/), which works with any client that supports the Model Context Protocol. For coding agents such as Claude Code and Codex, the open-source [Anansi Data plugin](https://github.com/AnansiDataAnalytics/anansidata-agent-plugin) sets up the connection. After signing in with an Anansi account, an agent can search the series, retrieve observations with their sources, compare and rank countries, and analyse and plot the data.

### Package updates

The [Python](https://github.com/KMueller-Lab/Global-Macro-Database-Python), [R](https://github.com/KMueller-Lab/Global-Macro-Database-R), and [Stata](https://github.com/KMueller-Lab/Global-Macro-Database-Stata) packages have been updated.

### New packages: MATLAB and Julia

New packages load the GMD directly in [MATLAB](https://github.com/KMueller-Lab/Global-Macro-Database-Matlab) and [Julia](https://github.com/KMueller-Lab/Global-Macro-Database-Julia).

### Acknowledgements

We thank everyone who reported errors and suggested improvements.

<!-- GMD:CURRENT_RELEASE:END -->

## Citation

Please cite the dataset as:

```bibtex
@techreport{GMD2025,
  title = {The Global Macro Database: A New International Macroeconomic Dataset},
  author = {M{\"u}ller, Karsten and Xu, Chenzi and Lehbib, Mohamed and Chen, Ziliang},
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

## Acknowledgments

The development of the Global Macro Database would not have been possible without the generous funding provided by the Singapore Ministry of Education (MOE) through the PYP grants (WBS A-0003319-01-00 and A-0003319-02-00), a Tier 1 grant (A-8001749- 00-00), and the NUS Risk Management Institute (A-8002360-00-00). This financial support laid the foundation for the successful completion of this extensive project.

## License

The Global Macro Database (GMD) is released under the **GMD Research Use Terms** (Version 1.1), our own license for public-good data. It follows the spirit of CC BY-NC-SA 4.0. Where the two differ, the Research Use Terms govern. The full terms are in [LICENSE](LICENSE) and at [globalmacrodata.com/license.html](https://www.globalmacrodata.com/license.html).

**The short version** (a plain-English summary; the full Research Use Terms are what actually govern):

- **Free for academic use.** Students, faculty, and researchers at universities and academic research institutes, for research meant for publication, teaching, and theses.
- **Also free** for teachers (for the classroom) and non-profit organizations such as charities, foundations, and NGOs (for their non-commercial work).
- **Everyone else**, including companies, needs our written permission.
- **Not for products.** Do not build any part of it, even in derived form, into a product, service, model, index, or paid report.
- **Cite it.** Always credit the GMD and its authors (see Citation above).
- **Do not re-host or rebadge it.** Do not republish the data on another website, API, platform, product, or under another name without explicit, written approval; point people to [globalmacrodata.com](https://www.globalmacrodata.com) so they get the latest data and cite it. You may include the specific data used in a paper in that paper's replication package, clearly labeled as coming from the GMD.
- **Share alike.** If we allow you to build on it and share, keep these same terms.
- **As-is.** No warranty for correctness; we do our best to provide accurate data.

**Unsure whether your use is non-commercial?** Email kmueller@globalmacrodata.com.

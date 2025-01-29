{smcl}
{* *! version 1.0.0}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "GMD##syntax"}{...}
{viewerjumpto "Description" "GMD##description"}{...}
{viewerjumpto "Options" "GMD##options"}{...}
{viewerjumpto "Examples" "GMD##examples"}{...}
{title:Title}

{phang}
{bf:GMD} {hline 2} Download and analyze Global Macro Database with version control

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:GMD} [{it:varlist}] [{cmd:,} {cmdab:v:ersion(}{it:YYYY_QQ}{cmd:)} {cmdab:co:untry(}{it:string}{cmd:)}]

{marker description}{...}
{title:Description}

{pstd}
This command downloads and loads the Global Macro Database. Users can specify which version to load, 
which variables to keep, and filter for specific countries. The dataset is available in quarterly 
versions (YYYY_QQ format). Visit {browse "https://www.globalmacrodata.com/data.html"} 
to see available version dates. The command automatically clears any data in memory before loading.

{marker options}{...}
{title:Options}

{phang}
{cmd:version(}{it:YYYY_QQ}{cmd:)} specifies which version of the dataset to load (e.g., 2025_01).{p_end}
{pmore}
Visit {browse "https://www.globalmacrodata.com/data.html"} to see all available version dates.

{phang}
{cmd:country(}{it:string}{cmd:)} specifies a country to filter by using its ISO3 code 
(e.g., USA, GBR). Case-insensitive.{p_end}
{pmore}
Type {cmd:GMD isomapping} to see a list of valid country codes and their corresponding full names.

{marker arguments}{...}
{title:Arguments}

{phang}
{it:varlist} optional list of variables to keep in addition to ISO3 and year. If not specified, all variables are retained.

{marker examples}{...}
{title:Examples}

{phang}Load the latest version:{p_end}
{phang2}{cmd:. GMD}

{phang}Load a specific version, default is current:{p_end}
{phang2}{cmd:. GMD, version(2025_01)}

{phang}Load specific variables:{p_end}
{phang2}{cmd:. GMD nGDP pop}

{phang}Load data for a specific country:{p_end}
{phang2}{cmd:. GMD, country(SIN)}

{phang}View country codes and names:{p_end}
{phang2}{cmd:. GMD isomapping}

{phang}Combine options:{p_end}
{phang2}{cmd:. GMD nGDP pop, country(SIN) version(2025_01)}


{title:Author}

{pstd}
Mohamed Lehbib{break}
Email: {browse "mailto:lehbib@nus.edu.sg":lehbib@nus.edu.sg}{break}
Website: {browse "https://www.globalmacrodata.com":https://www.globalmacrodata.com}


{title:Citation}

{pstd}
To cite this dataset, please use:

{pstd}
Müller, Karsten, Chenzi Xu, Mohamed Lehbib, and Ziliang Chen. 2025.{break}
"The Global Macro Database: A New Historical Dataset of Macroeconomic Statistics."{break}
Working Paper.

{pstd}
BibTeX:

{pstd}
@techreport{mueller2025global,
    title = {The Global Macro Database: A New Historical Dataset of Macroeconomic Statistics},{break}
    author = {Müller, Karsten and Xu, Chenzi and Lehbib, Mohamed and Chen, Ziliang},{break}
    year = {2025},{break}
    type = {Working Paper}{break}
}
{txt}

{title:Version}

{pstd}
1.0.0

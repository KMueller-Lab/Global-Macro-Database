program define GMD
    version 14.0
    syntax [anything] [, COUntry(string) Version(string)]
    
    * Store country list
    local countrylist Afghanistan-AFG Albania-ALB Algeria-DZA "American Samoa-ASM" Andorra-AND Angola-AGO Anguilla-AIA Antarctica-ATA "Antigua and Barbuda-ATG" Argentina-ARG Armenia-ARM Aruba-ABW Australia-AUS Austria-AUT Azerbaijan-AZE Bahamas-BHS Bahrain-BHR Bangladesh-BGD Barbados-BRB Belarus-BLR Belgium-BEL Belize-BLZ Benin-BEN Bermuda-BMU Bhutan-BTN Bolivia-BOL "Bonaire, Sint Eustatius and Saba-BES" "Bosnia and Herzegovina-BIH" Botswana-BWA "Bouvet Island-BVT" Brazil-BRA "British Indian Ocean Territory-IOT" "British Virgin Islands-VGB" Brunei-BRN Bulgaria-BGR "Burkina Faso-BFA" Burundi-BDI Cambodia-KHM Cameroon-CMR Canada-CAN "Cape Verde-CPV" "Cayman Islands-CYM" "Central African Republic-CAF" Chad-TCD Chile-CHL China-CHN "Christmas Island-CXR" "Cocos (Keeling) Islands-CCK" Colombia-COL Comoros-COM "Cook Islands-COK" "Costa Rica-CRI" Croatia-HRV Cuba-CUB Curaçao-CUW Cyprus-CYP "Czech Republic-CZE" Czechoslovakia-CSK "Democratic Republic of Yemen-YMD" "Democratic Republic of the Congo-COD" Denmark-DNK Djibouti-DJI Dominica-DMA "Dominican Republic-DOM" Ecuador-ECU Egypt-EGY "El Salvador-SLV" "Equatorial Guinea-GNQ" Eritrea-ERI Estonia-EST Eswatini-SWZ Ethiopia-ETF "Falkland Islands-FLK" "Faroe Islands-FRO" Fiji-FJI Finland-FIN France-FRA "French Guiana-GUF" "French Polynesia-PYF" "French Southern Territories-ATF" Gabon-GAB Gambia-GMB Georgia-GEO "German Democratic Republic-DDR" Germany-DEU Ghana-GHA Gibraltar-GIB Greece-GRC Greenland-GRL Grenada-GRD Guadeloupe-GLP Guam-GUM Guatemala-GTM Guernsey-GGY Guinea-GIN "Guinea-Bissau-GNB" Guyana-GUY Haiti-HTI "Heard Island and McDonald Islands-HMD" "Holy See-VAT" Honduras-HND "Hong Kong-HKG" Hungary-HUN Iceland-ISL India-IND Indonesia-IDN Iran-IRN Iraq-IRQ Ireland-IRL "Isle of Man-IMN" Israel-ISR Italy-ITA "Ivory Coast-CIV" Jamaica-JAM Japan-JPN Jersey-JEY Jordan-JOR Kazakhstan-KAZ Kenya-KEN Kiribati-KIR Kosovo-XKX Kuwait-KWT Kyrgyzstan-KGZ Laos-LAO Latvia-LVA Lebanon-LBN Lesotho-LSO Liberia-LBR Libya-LBY Liechtenstein-LIE Lithuania-LTU Luxembourg-LUX Macau-MAC Macedonia-MKD Madagascar-MDG Malawi-MWI Malaysia-MYS Maldives-MDV Mali-MLI Malta-MLT "Marshall Islands-MHL" Martinique-MTQ Mauritania-MRT Mauritius-MUS Mayotte-MYT Mexico-MEX "Micronesia (Federated States of)-FSM" Moldova-MDA Monaco-MCO Mongolia-MNG Montenegro-MNE Montserrat-MSR Morocco-MAR Mozambique-MOZ Myanmar-MMR Namibia-NAM Nauru-NRU Nepal-NPL Netherlands-NLD "Netherlands Antilles-ANT" "New Caledonia-NCL" "New Zealand-NZL" Nicaragua-NIC Niger-NER Nigeria-NGA Niue-NIU "Norfolk Island-NFK" "North Korea-PRK" "Northern Mariana Islands-MNP" Norway-NOR Oman-OMN Pakistan-PAK Palau-PLW Palestine-PSE Panama-PAN "Papua New Guinea-PNG" Paraguay-PRY Peru-PER Philippines-PHL Pitcairn-PCN Poland-POL Portugal-PRT "Puerto Rico-PRI" Qatar-QAT "Republic of the Congo-COG" Romania-ROU "Russian Federation-RUS" Rwanda-RWA Réunion-REU "Saint Barthélemy-BLM" "Saint Helena, Ascension and Tristan da Cunha-SHN" "Saint Kitts and Nevis-KNA" "Saint Lucia-LCA" "Saint Martin-MAF" "Saint Pierre and Miquelon-SPM" "Saint Vincent and the Grenadines-VCT" Samoa-WSM "San Marino-SMR" "Sao Tome and Principe-STP" "Saudi Arabia-SAU" Senegal-SEN Serbia-SRB "Serbia and Montenegro-SCG" Seychelles-SYC "Sierra Leone-SLE" Singapore-SGP "Sint Maarten-SXM" Slovakia-SVK Slovenia-SVN "Solomon Islands-SLB" Somalia-SOM "South Africa-ZAF" "South Georgia and the South Sandwich Islands-SGS" "South Korea-KOR" "South Sudan-SSD" "Soviet Union-SUN" Spain-ESP "Sri Lanka-LKA" Sudan-SDN Suriname-SUR "Svalbard and Jan Mayen-SJM" Sweden-SWE Switzerland-CHE Syria-SYR Taiwan-TWN Tajikistan-TJK Tanzania-TZA Thailand-THA "Timor-Leste-TLS" Togo-TGO Tokelau-TKL Tonga-TON "Trinidad and Tobago-TTO" Tunisia-TUN Turkey-TUR Turkmenistan-TKM "Turks and Caicos Islands-TCA" Tuvalu-TUV "US Virgin Islands-VIR" Uganda-UGA Ukraine-UKR "United Arab Emirates-ARE" "United Kingdom-GBR" "United States-USA" "United States Minor Outlying Islands-UMI" Uruguay-URY Uzbekistan-UZB Vanuatu-VUT Venezuela-VEN Vietnam-VNM "Wallis and Futuna-WLF" "Western Sahara-ESH" Yemen-YEM Yugoslavia-YUG Zambia-ZMB Zimbabwe-ZWE "Åland Islands-ALA"
    
    * Base URLs for the data
    local base_url "https://kmueller-lab.github.io/Global-Macro-Database/files/gmd-package"
    
    * Display package information
    display as text "Global Macro Database by Müller et. al (2025)"
    display as text "Website: https://www.globalmacrodata.com/"
    display as text ""

   

    
      * Process version option
    if "`version'" != "" {
        * Handle current version explicitly
        if lower("`version'") == "current" {
            local data_url "`base_url'/GMD.dta"
        }
        * Validate version format (YYYY_QQ)
        else if !regexm("`version'", "^20[0-9]{2}_(0[1-4])$") {
            display as error "Error: Version must be either 'current' or in YYYY_QQ format (e.g., 2024_04)"
            exit 498
        }
        else {
            * Set URL for specific version
            local data_url "`base_url'/GMD_`version'.dta"
        }
    }
    else {
        * Default to current base URL
        local data_url "`base_url'/GMD.dta"
    }
    
    * If country specified, validate it against the list
    if "`country'" != "" {
        local country = upper("`country'")
        local valid = 0
        
        foreach pair of local countrylist {
            local ccode = substr("`pair'", -3, .)
            if "`country'" == "`ccode'" {
                local valid = 1
                continue, break
            }
        }
        
        if `valid' == 0 {
            display as error "Error: Invalid country code '`country'"
            display as text _newline "Available country codes:" _newline
            display as text "{hline 60}"
            display as text "Country" _col(50) "Code"
            display as text "{hline 60}"
            
            foreach pair of local countrylist {
                local ccode = "`pair'"
                display as text "`ccode'"
            }
            
            display as text "{hline 60}"
            exit 498
        }
    }
    
    * Always clear existing data
    clear
    
    * Load data based on whether variables are specified
    capture noisily {
        if "`anything'" == "" {
            use "`data_url'"
        }
        else {
            use ISO3 year countryname `anything' using "`data_url'"
        }
    }
    
    if _rc {
        if "`version'" != "" {
            display as error "Error: Version `version' not found"
        }
        else {
            display as error "Error: Unable to download current version"
        }
        display as text _newline "Please visit {browse https://www.globalmacrodata.com/data.html} to see available version dates"
        exit _rc
    }
    
    * If country specified, filter for that country
    if "`country'" != "" {
        quietly keep if ISO3 == "`country'"
        display as text "Filtered data for country: `country'"
    }
    
    * Display final dataset dimensions
    quietly: describe
    display as text "Final dataset: `r(N)' observations of `r(k)' variables"

     * Determine current version for display purposes only
    local current_date = date(c(current_date), "DMY")
    local current_year = year(date(c(current_date), "DMY"))
    local current_month = month(date(c(current_date), "DMY"))
    
    * Determine quarter based on current month (for display only)
    if `current_month' <= 3 {
        local quarter "01"
    }
    else if `current_month' <= 6 {
        local quarter "04"
    }
    else if `current_month' <= 9 {
        local quarter "07"
    }
    else {
        local quarter "10"
    }
    
    local current_version "`current_year'_`quarter'"
    
    * Display version information
    if "`version'" != "" {
        display as text "Version: `version'"
    }
    else {
        display as text "Version: `current_version'"
    }
end

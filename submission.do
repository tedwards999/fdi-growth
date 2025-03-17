
log close _all 

log using "/Users/thomasedwards/projects/econ3900_analysis/stata_assignment/thomas/files/project.log", replace 

******************************
*FDI Sectoral Split Data OECD*
******************************

// Clear existing data
clear all 

// Import the OECD FDI Data obtained using small python SDMX API call in oecd_extract.py
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/fdi_data/oecd_fdi.csv"

// Describe the data
describe 

// Rename the sector code string column
rename v18 sector_str

// Encode sector to a numeric value
encode sector_str, gen(sector_code)

// Keep only the columns of interest
keep time_period ref_area sector_code value

// Reshape the data, Sectors must be columns
reshape wide value, i(ref_area time_period) j(sector_code)

// Rename the columns
rename value1 primary_sector_fdi
rename value2 secondary_sector_fdi
rename value3 tertiary_sector_fdi
rename time_period year 
rename ref_area country_code

// Drop years from the distant past 
keep if year<=2019 

// Add an indicator to track the source of the data which will be used in regressions
gen source = "oecd"

// Bring the source field to the start of the dataset
order source

// Save the data
save oecd_fdi_split, replace

**********************************
*FDI Sectoral Split Data Non OECD*
**********************************

// Clear existing data 
clear all 

// Import the non-oecd data 
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/fdi_data/itc_fdi.csv"

// Adding country codes using https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3
gen country_code = country

// Other countries
replace country_code = "ARG" if country == "Argentina"
replace country_code = "ARM" if country == "Armenia, Republic of"
replace country_code = "BGD" if country == "Bangladesh"
replace country_code = "BRN" if country == "Brunei Darussalam"
replace country_code = "BGR" if country == "Bulgaria"
replace country_code = "CPV" if country == "Cabo Verde"
replace country_code = "KHM" if country == "Cambodia"
replace country_code = "CIV" if country == "Cote d'Ivoire"
replace country_code = "HRV" if country == "Croatia"
replace country_code = "CYP" if country == "Cyprus"
replace country_code = "GEO" if country == "Georgia"
replace country_code = "GHA" if country == "Ghana"
replace country_code = "GTM" if country == "Guatemala"
replace country_code = "HKG" if country == "China, P.R.: Hong Kong"
replace country_code = "IND" if country == "India"
replace country_code = "IDN" if country == "Indonesia"
replace country_code = "KAZ" if country == "Kazakhstan"
replace country_code = "KEN" if country == "Kenya"
replace country_code = "LAO" if country == "Lao People's Democratic Republic"
replace country_code = "MYS" if country == "Malaysia"
replace country_code = "MLT" if country == "Malta"
replace country_code = "MUS" if country == "Mauritius"
replace country_code = "MNG" if country == "Mongolia"
replace country_code = "MAR" if country == "Morocco"
replace country_code = "MOZ" if country == "Mozambique"
replace country_code = "MMR" if country == "Myanmar"
replace country_code = "OMN" if country == "Oman"
replace country_code = "PAK" if country == "Pakistan"
replace country_code = "PRY" if country == "Paraguay"
replace country_code = "ROU" if country == "Romania"
replace country_code = "RUS" if country == "Russian Federation"
replace country_code = "RWA" if country == "Rwanda"
replace country_code = "SGP" if country == "Singapore"
replace country_code = "TJK" if country == "Tajikistan"
replace country_code = "TZA" if country == "Tanzania"
replace country_code = "THA" if country == "Thailand"
replace country_code = "TUN" if country == "Tunisia"
replace country_code = "UGA" if country == "Uganda"
replace country_code = "URY" if country == "Uruguay"
replace country_code = "VNM" if country == "Vietnam"
replace country_code = "ZMB" if country == "Zambia"

// Keep only columns of interest 
keep date country_code primarysector secondarysector tertiarysector

// Bring country to the front 
order country_code 

// Bring date to the front 
order date 

// Add source 
gen source = "non_oecd"

// Rename columns 
rename date year
rename primarysector primary_sector_fdi
rename secondarysector secondary_sector_fdi
rename tertiarysector tertiary_sector_fdi

// Bring source to the front 
order source 

// Save the data
save non_oecd_fdi_split, replace

// Rename columns to match the oecd countries
append using oecd_fdi_split


// Multiply the values to get dollars
replace primary_sector_fdi = primary_sector_fdi * 1000000 
replace secondary_sector_fdi = secondary_sector_fdi * 1000000 
replace tertiary_sector_fdi = tertiary_sector_fdi * 1000000 


// Get the total FDI to compare with the world bank
gen sum_sectoral_fdi = primary_sector_fdi + secondary_sector_fdi + tertiary_sector_fdi

// Save the data
save combined_fdi_split, replace


**************************************************
*Total FDI needed to check Sectoral Split Numbers*
**************************************************

// Clear existing data from memory
clear all 

// Import the data
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/fdi_inflows_current_dollars/API_BX.KLT.DINV.CD.WD_DS2_en_csv_v2_7.csv", varnames(5) rowrange(5:) colrange(:68)

// Describe the data
describe

// Stata does not like integer column names 
local start_year = 1960
forvalues i = 5/68 {
    rename v`i' fdi`start_year'
    local start_year = `start_year' + 1
}

// Reshape the data
reshape long fdi, i(countryname countrycode indicatorname indicatorcode) j(year) 

// Drop years from the distant past 
keep if year>=2005

// Remove groupings and tiny countries
drop if countryname == "(French part)"
drop if countryname == "Africa Eastern and Southern"
drop if countryname == "Africa Western and Central"
drop if countryname == "Arab World"
drop if countryname == "Caribbean small states"
drop if countryname == "Central Europe and the Baltics"
drop if countryname == "countries: UN classification"
drop if countryname == "Early-demographic dividend"
drop if countryname == "East Asia & Pacific"
drop if countryname == "East Asia & Pacific (excluding high income)"
drop if countryname == "East Asia & Pacific (IDA & IBRD countries)"
drop if countryname == "Euro area"
drop if countryname == "Europe & Central Asia"
drop if countryname == "Europe & Central Asia (excluding high income)"
drop if countryname == "Europe & Central Asia (IDA & IBRD countries)"
drop if countryname == "European Union"
drop if countryname == "Fragile and conflict affected situations"
drop if countryname == "Heavily indebted poor countries (HIPC)"
drop if countryname == "High income"
drop if countryname == "IBRD only"
drop if countryname == "ica & the Caribbean (IDA & IBRD countries)"
drop if countryname == "IDA & IBRD total"
drop if countryname == "IDA blend"
drop if countryname == "IDA only"
drop if countryname == "IDA total"
drop if countryname == "Isle of Man"
drop if countryname == "Late-demographic dividend"
drop if countryname == "Latin America & Caribbean"
drop if countryname == "Latin America & Caribbean (excluding high income)"
drop if countryname == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if countryname == "Least developed"
drop if countryname == "Least developed countries: UN classification"
drop if countryname == "Low & middle income"
drop if countryname == "Low income"
drop if countryname == "Lower middle income"
drop if countryname == "Micronesia, Fed. Sts."
drop if countryname == "Middle East & North Africa"
drop if countryname == "Middle East & North Africa (excluding high income)"
drop if countryname == "Middle East & North Africa (IDA & IBRD countries)"
drop if countryname == "Middle income"
drop if countryname == "Northern Mariana Islands"
drop if countryname == "Not classified"
drop if countryname == "OECD members"
drop if countryname == "Other small states"
drop if countryname == "Other small states"
drop if countryname == "Pacific island small states"
drop if countryname == "Post-demographic dividend"
drop if countryname == "Pre-demographic dividend"
drop if countryname == "Small states"
drop if countryname == "South Asia"
drop if countryname == "South Asia (IDA & IBRD)"
drop if countryname == "Sub-Saharan Africa"
drop if countryname == "Sub-Saharan Africa (excluding high income)"
drop if countryname == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if countryname == "Upper middle income"
drop if countryname == "World"

// Drop redundant columns
drop indicatorname indicatorcode countryname 

// Rename Country Code
rename countrycode country_code

// No need to save just merge used for checking 
merge 1:1 country_code year using combined_fdi_split
drop _merge

// Keep only data points where comparison is possible 
keep if inlist(source,"oecd", "non_oecd")

*****************************
*Drop non sensible Countries*
*****************************

// Clear memory
clear all 

// Reopen our FDI split file 
use combined_fdi_split

// Drop non sensible countries that do not diretionally match the WB
drop if inlist(country_code, "LUX", "MUS", "MLT", "SVK", "TUR", "CRI", "GBR", "IND")

// Save the data
save combined_fdi_split, replace

*****************************************************
*Total GDP needed to calculate FDI Inflow Percentage*
*****************************************************

// Clear existing data from memory
clear all 

// Import the data
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/gdp_current_dollars/API_NY.GDP.MKTP.CD_DS2_en_csv_v2_88.csv", varnames(5) rowrange(5:) colrange(:68)

// Describe the data
describe

// Stata does not like integer column names 
local start_year = 1960
forvalues i = 5/68 {
    rename v`i' gdp`start_year'
    local start_year = `start_year' + 1
}

// Reshape the data
reshape long gdp, i(countryname countrycode indicatorname indicatorcode) j(year) 

// Drop years from the distant past 
keep if year>=2005

// Remove groupings and tiny countries
drop if countryname == "(French part)"
drop if countryname == "Africa Eastern and Southern"
drop if countryname == "Africa Western and Central"
drop if countryname == "Arab World"
drop if countryname == "Caribbean small states"
drop if countryname == "Central Europe and the Baltics"
drop if countryname == "countries: UN classification"
drop if countryname == "Early-demographic dividend"
drop if countryname == "East Asia & Pacific"
drop if countryname == "East Asia & Pacific (excluding high income)"
drop if countryname == "East Asia & Pacific (IDA & IBRD countries)"
drop if countryname == "Euro area"
drop if countryname == "Europe & Central Asia"
drop if countryname == "Europe & Central Asia (excluding high income)"
drop if countryname == "Europe & Central Asia (IDA & IBRD countries)"
drop if countryname == "European Union"
drop if countryname == "Fragile and conflict affected situations"
drop if countryname == "Heavily indebted poor countries (HIPC)"
drop if countryname == "High income"
drop if countryname == "IBRD only"
drop if countryname == "ica & the Caribbean (IDA & IBRD countries)"
drop if countryname == "IDA & IBRD total"
drop if countryname == "IDA blend"
drop if countryname == "IDA only"
drop if countryname == "IDA total"
drop if countryname == "Isle of Man"
drop if countryname == "Late-demographic dividend"
drop if countryname == "Latin America & Caribbean"
drop if countryname == "Latin America & Caribbean (excluding high income)"
drop if countryname == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if countryname == "Least developed"
drop if countryname == "Least developed countries: UN classification"
drop if countryname == "Low & middle income"
drop if countryname == "Low income"
drop if countryname == "Lower middle income"
drop if countryname == "Micronesia, Fed. Sts."
drop if countryname == "Middle East & North Africa"
drop if countryname == "Middle East & North Africa (excluding high income)"
drop if countryname == "Middle East & North Africa (IDA & IBRD countries)"
drop if countryname == "Middle income"
drop if countryname == "Northern Mariana Islands"
drop if countryname == "Not classified"
drop if countryname == "OECD members"
drop if countryname == "Other small states"
drop if countryname == "Other small states"
drop if countryname == "Pacific island small states"
drop if countryname == "Post-demographic dividend"
drop if countryname == "Pre-demographic dividend"
drop if countryname == "Small states"
drop if countryname == "South Asia"
drop if countryname == "South Asia (IDA & IBRD)"
drop if countryname == "Sub-Saharan Africa"
drop if countryname == "Sub-Saharan Africa (excluding high income)"
drop if countryname == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if countryname == "Upper middle income"
drop if countryname == "World"

// Drop redundant columns
drop indicatorname indicatorcode countryname 

// Rename the country code column 
rename countrycode country_code

// Save the dataset
save gdp_total, replace

// Reopen our Sectoral Data 
clear all 
use combined_fdi_split

// No need to save just merge used for checking 
merge 1:1 country_code year using gdp_total

// Drop the values that are only in the gdp data
keep if _merge != 2  

// Remove the column 
drop _merge

// Keep years after 2005
keep if year >= 2005

// Convert sectoral FDI into a percentage of GDP
replace primary_sector_fdi = primary_sector_fdi / gdp 
replace secondary_sector_fdi = secondary_sector_fdi / gdp 
replace tertiary_sector_fdi = tertiary_sector_fdi / gdp 

// Drop redundant columns 
drop gdp sum_sectoral_fdi gdp

// Save the cleaned dataset
save combined_fdi_split, replace

************
*Gini Index*
************

// Clear existing data from memory
clear all 

// Import the data
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/gini_index/API_SI.POV.GINI_DS2_en_csv_v2_53.csv", varnames(5) rowrange(5:) colrange(:68)

// Describe the data
describe

// Stata does not like integer column names 
local start_year = 1960
forvalues i = 5/68 {
    rename v`i' gini`start_year'
    local start_year = `start_year' + 1
}

// Reshape the data
reshape long gini, i(countryname countrycode indicatorname indicatorcode) j(year) 

// Drop redundant columns
drop indicatorname indicatorcode

// Drop redundant years  
keep if year>=2005
keep if year<=2019

// Remove groupings and tiny countries
drop if countryname == "(French part)"
drop if countryname == "Africa Eastern and Southern"
drop if countryname == "Africa Western and Central"
drop if countryname == "Arab World"
drop if countryname == "Caribbean small states"
drop if countryname == "Central Europe and the Baltics"
drop if countryname == "countries: UN classification"
drop if countryname == "Early-demographic dividend"
drop if countryname == "East Asia & Pacific"
drop if countryname == "East Asia & Pacific (excluding high income)"
drop if countryname == "East Asia & Pacific (IDA & IBRD countries)"
drop if countryname == "Euro area"
drop if countryname == "Europe & Central Asia"
drop if countryname == "Europe & Central Asia (excluding high income)"
drop if countryname == "Europe & Central Asia (IDA & IBRD countries)"
drop if countryname == "European Union"
drop if countryname == "Fragile and conflict affected situations"
drop if countryname == "Heavily indebted poor countries (HIPC)"
drop if countryname == "High income"
drop if countryname == "IBRD only"
drop if countryname == "ica & the Caribbean (IDA & IBRD countries)"
drop if countryname == "IDA & IBRD total"
drop if countryname == "IDA blend"
drop if countryname == "IDA only"
drop if countryname == "IDA total"
drop if countryname == "Isle of Man"
drop if countryname == "Late-demographic dividend"
drop if countryname == "Latin America & Caribbean"
drop if countryname == "Latin America & Caribbean (excluding high income)"
drop if countryname == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if countryname == "Least developed"
drop if countryname == "Least developed countries: UN classification"
drop if countryname == "Low & middle income"
drop if countryname == "Low income"
drop if countryname == "Lower middle income"
drop if countryname == "Micronesia, Fed. Sts."
drop if countryname == "Middle East & North Africa"
drop if countryname == "Middle East & North Africa (excluding high income)"
drop if countryname == "Middle East & North Africa (IDA & IBRD countries)"
drop if countryname == "Middle income"
drop if countryname == "Northern Mariana Islands"
drop if countryname == "Not classified"
drop if countryname == "OECD members"
drop if countryname == "Other small states"
drop if countryname == "Other small states"
drop if countryname == "Pacific island small states"
drop if countryname == "Post-demographic dividend"
drop if countryname == "Pre-demographic dividend"
drop if countryname == "Small states"
drop if countryname == "South Asia"
drop if countryname == "South Asia (IDA & IBRD)"
drop if countryname == "Sub-Saharan Africa"
drop if countryname == "Sub-Saharan Africa (excluding high income)"
drop if countryname == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if countryname == "Upper middle income"
drop if countryname == "World"

// Drop the countryname field
drop countryname
 
// Rename to enable joining
rename countrycode country_code

save gini, replace

*******************
*Tax Revenue % GDP*
*******************

// Clear existing data from memory
clear all 

// Import the data
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/tax_revenue_percentage_gdp/API_GC.TAX.TOTL.GD.ZS_DS2_en_csv_v2_2114.csv", varnames(5) rowrange(5:) colrange(:68)

// Describe the data
describe

// Stata does not like integer column names 
local start_year = 1960
forvalues i = 5/68 {
    rename v`i' tax_rev`start_year'
    local start_year = `start_year' + 1
}

// Reshape the data
reshape long tax_rev, i(countryname countrycode indicatorname indicatorcode) j(year) 

// Drop redundant columns
drop indicatorname indicatorcode

// Drop redundant years  
keep if year>=2005
keep if year<=2019

// Remove groupings and tiny countries
drop if countryname == "(French part)"
drop if countryname == "Africa Eastern and Southern"
drop if countryname == "Africa Western and Central"
drop if countryname == "Arab World"
drop if countryname == "Caribbean small states"
drop if countryname == "Central Europe and the Baltics"
drop if countryname == "countries: UN classification"
drop if countryname == "Early-demographic dividend"
drop if countryname == "East Asia & Pacific"
drop if countryname == "East Asia & Pacific (excluding high income)"
drop if countryname == "East Asia & Pacific (IDA & IBRD countries)"
drop if countryname == "Euro area"
drop if countryname == "Europe & Central Asia"
drop if countryname == "Europe & Central Asia (excluding high income)"
drop if countryname == "Europe & Central Asia (IDA & IBRD countries)"
drop if countryname == "European Union"
drop if countryname == "Fragile and conflict affected situations"
drop if countryname == "Heavily indebted poor countries (HIPC)"
drop if countryname == "High income"
drop if countryname == "IBRD only"
drop if countryname == "ica & the Caribbean (IDA & IBRD countries)"
drop if countryname == "IDA & IBRD total"
drop if countryname == "IDA blend"
drop if countryname == "IDA only"
drop if countryname == "IDA total"
drop if countryname == "Isle of Man"
drop if countryname == "Late-demographic dividend"
drop if countryname == "Latin America & Caribbean"
drop if countryname == "Latin America & Caribbean (excluding high income)"
drop if countryname == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if countryname == "Least developed"
drop if countryname == "Least developed countries: UN classification"
drop if countryname == "Low & middle income"
drop if countryname == "Low income"
drop if countryname == "Lower middle income"
drop if countryname == "Micronesia, Fed. Sts."
drop if countryname == "Middle East & North Africa"
drop if countryname == "Middle East & North Africa (excluding high income)"
drop if countryname == "Middle East & North Africa (IDA & IBRD countries)"
drop if countryname == "Middle income"
drop if countryname == "Northern Mariana Islands"
drop if countryname == "Not classified"
drop if countryname == "OECD members"
drop if countryname == "Other small states"
drop if countryname == "Other small states"
drop if countryname == "Pacific island small states"
drop if countryname == "Post-demographic dividend"
drop if countryname == "Pre-demographic dividend"
drop if countryname == "Small states"
drop if countryname == "South Asia"
drop if countryname == "South Asia (IDA & IBRD)"
drop if countryname == "Sub-Saharan Africa"
drop if countryname == "Sub-Saharan Africa (excluding high income)"
drop if countryname == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if countryname == "Upper middle income"
drop if countryname == "World"

// Drop the country name column
drop countryname 

// Rename to enable joining 
rename countrycode country_code

save tax_rev_perc, replace

***************
*Savings % GDP*
***************

// Clear existing data from memory
clear all 

// Import the data
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/gross_savings_percentage_gdp/API_NY.GNS.ICTR.ZS_DS2_en_csv_v2_400.csv", varnames(5) rowrange(5:) colrange(:68)

// Describe the data
describe

// Stata does not like integer column names 
local start_year = 1960
forvalues i = 5/68 {
    rename v`i' save_perc_gdp`start_year'
    local start_year = `start_year' + 1
}

// Reshape the data
reshape long save_perc_gdp, i(countryname countrycode indicatorname indicatorcode) j(year) 

// Drop redundant columns
drop indicatorname indicatorcode

// Drop redundant years  
keep if year>=2005
keep if year<=2019

// Remove groupings and tiny countries
drop if countryname == "(French part)"
drop if countryname == "Africa Eastern and Southern"
drop if countryname == "Africa Western and Central"
drop if countryname == "Arab World"
drop if countryname == "Caribbean small states"
drop if countryname == "Central Europe and the Baltics"
drop if countryname == "countries: UN classification"
drop if countryname == "Early-demographic dividend"
drop if countryname == "East Asia & Pacific"
drop if countryname == "East Asia & Pacific (excluding high income)"
drop if countryname == "East Asia & Pacific (IDA & IBRD countries)"
drop if countryname == "Euro area"
drop if countryname == "Europe & Central Asia"
drop if countryname == "Europe & Central Asia (excluding high income)"
drop if countryname == "Europe & Central Asia (IDA & IBRD countries)"
drop if countryname == "European Union"
drop if countryname == "Fragile and conflict affected situations"
drop if countryname == "Heavily indebted poor countries (HIPC)"
drop if countryname == "High income"
drop if countryname == "IBRD only"
drop if countryname == "ica & the Caribbean (IDA & IBRD countries)"
drop if countryname == "IDA & IBRD total"
drop if countryname == "IDA blend"
drop if countryname == "IDA only"
drop if countryname == "IDA total"
drop if countryname == "Isle of Man"
drop if countryname == "Late-demographic dividend"
drop if countryname == "Latin America & Caribbean"
drop if countryname == "Latin America & Caribbean (excluding high income)"
drop if countryname == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if countryname == "Least developed"
drop if countryname == "Least developed countries: UN classification"
drop if countryname == "Low & middle income"
drop if countryname == "Low income"
drop if countryname == "Lower middle income"
drop if countryname == "Micronesia, Fed. Sts."
drop if countryname == "Middle East & North Africa"
drop if countryname == "Middle East & North Africa (excluding high income)"
drop if countryname == "Middle East & North Africa (IDA & IBRD countries)"
drop if countryname == "Middle income"
drop if countryname == "Northern Mariana Islands"
drop if countryname == "Not classified"
drop if countryname == "OECD members"
drop if countryname == "Other small states"
drop if countryname == "Other small states"
drop if countryname == "Pacific island small states"
drop if countryname == "Post-demographic dividend"
drop if countryname == "Pre-demographic dividend"
drop if countryname == "Small states"
drop if countryname == "South Asia"
drop if countryname == "South Asia (IDA & IBRD)"
drop if countryname == "Sub-Saharan Africa"
drop if countryname == "Sub-Saharan Africa (excluding high income)"
drop if countryname == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if countryname == "Upper middle income"
drop if countryname == "World"

// Drop the country names 
drop countryname

// Rename to join later n 
rename countrycode country_code

save savings_perc, replace

********************
*Real Interest Rate*
********************

// Clear existing data from memory
clear all 

// Import the data
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/real_interest_rate_percentage/API_FR.INR.RINR_DS2_en_csv_v2_100.csv", varnames(5) rowrange(5:) colrange(:68)

// Describe the data
describe

// Stata does not like integer column names 
local start_year = 1960
forvalues i = 5/68 {
    rename v`i' interest_rate`start_year'
    local start_year = `start_year' + 1
}

// Reshape the data
reshape long interest_rate, i(countryname countrycode indicatorname indicatorcode) j(year) 

// Drop redundant columns
drop indicatorname indicatorcode

// Drop redundant years  
keep if year>=2005
keep if year<=2019

// Remove groupings and tiny countries
drop if countryname == "(French part)"
drop if countryname == "Africa Eastern and Southern"
drop if countryname == "Africa Western and Central"
drop if countryname == "Arab World"
drop if countryname == "Caribbean small states"
drop if countryname == "Central Europe and the Baltics"
drop if countryname == "countries: UN classification"
drop if countryname == "Early-demographic dividend"
drop if countryname == "East Asia & Pacific"
drop if countryname == "East Asia & Pacific (excluding high income)"
drop if countryname == "East Asia & Pacific (IDA & IBRD countries)"
drop if countryname == "Euro area"
drop if countryname == "Europe & Central Asia"
drop if countryname == "Europe & Central Asia (excluding high income)"
drop if countryname == "Europe & Central Asia (IDA & IBRD countries)"
drop if countryname == "European Union"
drop if countryname == "Fragile and conflict affected situations"
drop if countryname == "Heavily indebted poor countries (HIPC)"
drop if countryname == "High income"
drop if countryname == "IBRD only"
drop if countryname == "ica & the Caribbean (IDA & IBRD countries)"
drop if countryname == "IDA & IBRD total"
drop if countryname == "IDA blend"
drop if countryname == "IDA only"
drop if countryname == "IDA total"
drop if countryname == "Isle of Man"
drop if countryname == "Late-demographic dividend"
drop if countryname == "Latin America & Caribbean"
drop if countryname == "Latin America & Caribbean (excluding high income)"
drop if countryname == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if countryname == "Least developed"
drop if countryname == "Least developed countries: UN classification"
drop if countryname == "Low & middle income"
drop if countryname == "Low income"
drop if countryname == "Lower middle income"
drop if countryname == "Micronesia, Fed. Sts."
drop if countryname == "Middle East & North Africa"
drop if countryname == "Middle East & North Africa (excluding high income)"
drop if countryname == "Middle East & North Africa (IDA & IBRD countries)"
drop if countryname == "Middle income"
drop if countryname == "Northern Mariana Islands"
drop if countryname == "Not classified"
drop if countryname == "OECD members"
drop if countryname == "Other small states"
drop if countryname == "Other small states"
drop if countryname == "Pacific island small states"
drop if countryname == "Post-demographic dividend"
drop if countryname == "Pre-demographic dividend"
drop if countryname == "Small states"
drop if countryname == "South Asia"
drop if countryname == "South Asia (IDA & IBRD)"
drop if countryname == "Sub-Saharan Africa"
drop if countryname == "Sub-Saharan Africa (excluding high income)"
drop if countryname == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if countryname == "Upper middle income"
drop if countryname == "World"

// Drop the country names
drop countryname

// Rename for joining 
rename countrycode country_code

save interest_rate, replace

****************
*Inflation Rate*
****************

// Clear existing data from memory
clear all 

// Import the data
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/inflation_consumer_prices_annual_perc/API_FP.CPI.TOTL.ZG_DS2_en_csv_v2_59.csv", varnames(5) rowrange(5:) colrange(:68)

// Describe the data
describe

// Stata does not like integer column names 
local start_year = 1960
forvalues i = 5/68 {
    rename v`i' inflation`start_year'
    local start_year = `start_year' + 1
}

// Reshape the data
reshape long inflation, i(countryname countrycode indicatorname indicatorcode) j(year) 

// Drop redundant columns
drop indicatorname indicatorcode

// Drop redundant years  
keep if year>=2005
keep if year<=2019

// Remove groupings and tiny countries
drop if countryname == "(French part)"
drop if countryname == "Africa Eastern and Southern"
drop if countryname == "Africa Western and Central"
drop if countryname == "Arab World"
drop if countryname == "Caribbean small states"
drop if countryname == "Central Europe and the Baltics"
drop if countryname == "countries: UN classification"
drop if countryname == "Early-demographic dividend"
drop if countryname == "East Asia & Pacific"
drop if countryname == "East Asia & Pacific (excluding high income)"
drop if countryname == "East Asia & Pacific (IDA & IBRD countries)"
drop if countryname == "Euro area"
drop if countryname == "Europe & Central Asia"
drop if countryname == "Europe & Central Asia (excluding high income)"
drop if countryname == "Europe & Central Asia (IDA & IBRD countries)"
drop if countryname == "European Union"
drop if countryname == "Fragile and conflict affected situations"
drop if countryname == "Heavily indebted poor countries (HIPC)"
drop if countryname == "High income"
drop if countryname == "IBRD only"
drop if countryname == "ica & the Caribbean (IDA & IBRD countries)"
drop if countryname == "IDA & IBRD total"
drop if countryname == "IDA blend"
drop if countryname == "IDA only"
drop if countryname == "IDA total"
drop if countryname == "Isle of Man"
drop if countryname == "Late-demographic dividend"
drop if countryname == "Latin America & Caribbean"
drop if countryname == "Latin America & Caribbean (excluding high income)"
drop if countryname == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if countryname == "Least developed"
drop if countryname == "Least developed countries: UN classification"
drop if countryname == "Low & middle income"
drop if countryname == "Low income"
drop if countryname == "Lower middle income"
drop if countryname == "Micronesia, Fed. Sts."
drop if countryname == "Middle East & North Africa"
drop if countryname == "Middle East & North Africa (excluding high income)"
drop if countryname == "Middle East & North Africa (IDA & IBRD countries)"
drop if countryname == "Middle income"
drop if countryname == "Northern Mariana Islands"
drop if countryname == "Not classified"
drop if countryname == "OECD members"
drop if countryname == "Other small states"
drop if countryname == "Other small states"
drop if countryname == "Pacific island small states"
drop if countryname == "Post-demographic dividend"
drop if countryname == "Pre-demographic dividend"
drop if countryname == "Small states"
drop if countryname == "South Asia"
drop if countryname == "South Asia (IDA & IBRD)"
drop if countryname == "Sub-Saharan Africa"
drop if countryname == "Sub-Saharan Africa (excluding high income)"
drop if countryname == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if countryname == "Upper middle income"
drop if countryname == "World"

// Drop the countries 
drop countryname 

// Rename for joining
rename countrycode country_code

save inflation, replace

*********
*Exports*
*********

// Clear existing data from memory
clear all 

// Import the data
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/exports_percentage_gdp/API_NE.EXP.GNFS.ZS_DS2_en_csv_v2_60.csv", varnames(5) rowrange(5:) colrange(:68)

// Describe the data
describe

// Stata does not like integer column names 
local start_year = 1960
forvalues i = 5/68 {
    rename v`i' exports`start_year'
    local start_year = `start_year' + 1
}

// Reshape the data
reshape long exports, i(countryname countrycode indicatorname indicatorcode) j(year) 

// Drop redundant columns
drop indicatorname indicatorcode

// Drop redundant years  
keep if year>=2005
keep if year<=2019

// Remove groupings and tiny countries
drop if countryname == "(French part)"
drop if countryname == "Africa Eastern and Southern"
drop if countryname == "Africa Western and Central"
drop if countryname == "Arab World"
drop if countryname == "Caribbean small states"
drop if countryname == "Central Europe and the Baltics"
drop if countryname == "countries: UN classification"
drop if countryname == "Early-demographic dividend"
drop if countryname == "East Asia & Pacific"
drop if countryname == "East Asia & Pacific (excluding high income)"
drop if countryname == "East Asia & Pacific (IDA & IBRD countries)"
drop if countryname == "Euro area"
drop if countryname == "Europe & Central Asia"
drop if countryname == "Europe & Central Asia (excluding high income)"
drop if countryname == "Europe & Central Asia (IDA & IBRD countries)"
drop if countryname == "European Union"
drop if countryname == "Fragile and conflict affected situations"
drop if countryname == "Heavily indebted poor countries (HIPC)"
drop if countryname == "High income"
drop if countryname == "IBRD only"
drop if countryname == "ica & the Caribbean (IDA & IBRD countries)"
drop if countryname == "IDA & IBRD total"
drop if countryname == "IDA blend"
drop if countryname == "IDA only"
drop if countryname == "IDA total"
drop if countryname == "Isle of Man"
drop if countryname == "Late-demographic dividend"
drop if countryname == "Latin America & Caribbean"
drop if countryname == "Latin America & Caribbean (excluding high income)"
drop if countryname == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if countryname == "Least developed"
drop if countryname == "Least developed countries: UN classification"
drop if countryname == "Low & middle income"
drop if countryname == "Low income"
drop if countryname == "Lower middle income"
drop if countryname == "Micronesia, Fed. Sts."
drop if countryname == "Middle East & North Africa"
drop if countryname == "Middle East & North Africa (excluding high income)"
drop if countryname == "Middle East & North Africa (IDA & IBRD countries)"
drop if countryname == "Middle income"
drop if countryname == "Northern Mariana Islands"
drop if countryname == "Not classified"
drop if countryname == "OECD members"
drop if countryname == "Other small states"
drop if countryname == "Other small states"
drop if countryname == "Pacific island small states"
drop if countryname == "Post-demographic dividend"
drop if countryname == "Pre-demographic dividend"
drop if countryname == "Small states"
drop if countryname == "South Asia"
drop if countryname == "South Asia (IDA & IBRD)"
drop if countryname == "Sub-Saharan Africa"
drop if countryname == "Sub-Saharan Africa (excluding high income)"
drop if countryname == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if countryname == "Upper middle income"
drop if countryname == "World"

// Drop the country names
drop countryname 

// Rename for joining 
rename countrycode country_code

save exports, replace

*********
*Imports*
*********

// Clear existing data from memory
clear all 

// Import the data
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/imports_percentage_gdp/API_NE.IMP.GNFS.ZS_DS2_en_csv_v2_93.csv", varnames(5) rowrange(5:) colrange(:68)

// Describe the data
describe

// Stata does not like integer column names 
local start_year = 1960
forvalues i = 5/68 {
    rename v`i' imports`start_year'
    local start_year = `start_year' + 1
}

// Reshape the data
reshape long imports, i(countryname countrycode indicatorname indicatorcode) j(year) 

// Drop redundant columns
drop indicatorname indicatorcode

// Drop redundant years  
keep if year>=2005
keep if year<=2019

// Remove groupings and tiny countries
drop if countryname == "(French part)"
drop if countryname == "Africa Eastern and Southern"
drop if countryname == "Africa Western and Central"
drop if countryname == "Arab World"
drop if countryname == "Caribbean small states"
drop if countryname == "Central Europe and the Baltics"
drop if countryname == "countries: UN classification"
drop if countryname == "Early-demographic dividend"
drop if countryname == "East Asia & Pacific"
drop if countryname == "East Asia & Pacific (excluding high income)"
drop if countryname == "East Asia & Pacific (IDA & IBRD countries)"
drop if countryname == "Euro area"
drop if countryname == "Europe & Central Asia"
drop if countryname == "Europe & Central Asia (excluding high income)"
drop if countryname == "Europe & Central Asia (IDA & IBRD countries)"
drop if countryname == "European Union"
drop if countryname == "Fragile and conflict affected situations"
drop if countryname == "Heavily indebted poor countries (HIPC)"
drop if countryname == "High income"
drop if countryname == "IBRD only"
drop if countryname == "ica & the Caribbean (IDA & IBRD countries)"
drop if countryname == "IDA & IBRD total"
drop if countryname == "IDA blend"
drop if countryname == "IDA only"
drop if countryname == "IDA total"
drop if countryname == "Isle of Man"
drop if countryname == "Late-demographic dividend"
drop if countryname == "Latin America & Caribbean"
drop if countryname == "Latin America & Caribbean (excluding high income)"
drop if countryname == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if countryname == "Least developed"
drop if countryname == "Least developed countries: UN classification"
drop if countryname == "Low & middle income"
drop if countryname == "Low income"
drop if countryname == "Lower middle income"
drop if countryname == "Micronesia, Fed. Sts."
drop if countryname == "Middle East & North Africa"
drop if countryname == "Middle East & North Africa (excluding high income)"
drop if countryname == "Middle East & North Africa (IDA & IBRD countries)"
drop if countryname == "Middle income"
drop if countryname == "Northern Mariana Islands"
drop if countryname == "Not classified"
drop if countryname == "OECD members"
drop if countryname == "Other small states"
drop if countryname == "Other small states"
drop if countryname == "Pacific island small states"
drop if countryname == "Post-demographic dividend"
drop if countryname == "Pre-demographic dividend"
drop if countryname == "Small states"
drop if countryname == "South Asia"
drop if countryname == "South Asia (IDA & IBRD)"
drop if countryname == "Sub-Saharan Africa"
drop if countryname == "Sub-Saharan Africa (excluding high income)"
drop if countryname == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if countryname == "Upper middle income"
drop if countryname == "World"

// Drop the country names
drop countryname 

// Rename for joining 
rename countrycode country_code

save imports, replace

***********************
*Control of Corruption*
***********************

// Clear existing data from memory
clear all 

// Import the data
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/control_of_corruption_estimate/API_CC.EST_DS2_en_csv_v2_14238.csv", varnames(5) rowrange(5:) colrange(:68)

// Describe the data
describe

// Stata does not like integer column names 
local start_year = 1960
forvalues i = 5/68 {
    rename v`i' con_corruption`start_year'
    local start_year = `start_year' + 1
}

// Reshape the data
reshape long con_corruption, i(countryname countrycode indicatorname indicatorcode) j(year) 

// Drop redundant columns
drop indicatorname indicatorcode

// Drop redundant years  
keep if year>=2005
keep if year<=2019

// Remove groupings and tiny countries
drop if countryname == "(French part)"
drop if countryname == "Africa Eastern and Southern"
drop if countryname == "Africa Western and Central"
drop if countryname == "Arab World"
drop if countryname == "Caribbean small states"
drop if countryname == "Central Europe and the Baltics"
drop if countryname == "countries: UN classification"
drop if countryname == "Early-demographic dividend"
drop if countryname == "East Asia & Pacific"
drop if countryname == "East Asia & Pacific (excluding high income)"
drop if countryname == "East Asia & Pacific (IDA & IBRD countries)"
drop if countryname == "Euro area"
drop if countryname == "Europe & Central Asia"
drop if countryname == "Europe & Central Asia (excluding high income)"
drop if countryname == "Europe & Central Asia (IDA & IBRD countries)"
drop if countryname == "European Union"
drop if countryname == "Fragile and conflict affected situations"
drop if countryname == "Heavily indebted poor countries (HIPC)"
drop if countryname == "High income"
drop if countryname == "IBRD only"
drop if countryname == "ica & the Caribbean (IDA & IBRD countries)"
drop if countryname == "IDA & IBRD total"
drop if countryname == "IDA blend"
drop if countryname == "IDA only"
drop if countryname == "IDA total"
drop if countryname == "Isle of Man"
drop if countryname == "Late-demographic dividend"
drop if countryname == "Latin America & Caribbean"
drop if countryname == "Latin America & Caribbean (excluding high income)"
drop if countryname == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if countryname == "Least developed"
drop if countryname == "Least developed countries: UN classification"
drop if countryname == "Low & middle income"
drop if countryname == "Low income"
drop if countryname == "Lower middle income"
drop if countryname == "Micronesia, Fed. Sts."
drop if countryname == "Middle East & North Africa"
drop if countryname == "Middle East & North Africa (excluding high income)"
drop if countryname == "Middle East & North Africa (IDA & IBRD countries)"
drop if countryname == "Middle income"
drop if countryname == "Northern Mariana Islands"
drop if countryname == "Not classified"
drop if countryname == "OECD members"
drop if countryname == "Other small states"
drop if countryname == "Other small states"
drop if countryname == "Pacific island small states"
drop if countryname == "Post-demographic dividend"
drop if countryname == "Pre-demographic dividend"
drop if countryname == "Small states"
drop if countryname == "South Asia"
drop if countryname == "South Asia (IDA & IBRD)"
drop if countryname == "Sub-Saharan Africa"
drop if countryname == "Sub-Saharan Africa (excluding high income)"
drop if countryname == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if countryname == "Upper middle income"
drop if countryname == "World"

// Drop countries
drop countryname

// Rename for joining 
rename countrycode country_code

save control_corruption, replace

******************************
*Government Expenditure % GDP*
******************************

// Clear existing data from memory
clear all 

// Import the data
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/government_expenditure_perc_gdp/API_NE.CON.GOVT.ZS_DS2_en_csv_v2_14286.csv", varnames(5) rowrange(5:) colrange(:68)

// Describe the data
describe

// Stata does not like integer column names 
local start_year = 1960
forvalues i = 5/68 {
    rename v`i' gov_exp`start_year'
    local start_year = `start_year' + 1
}

// Reshape the data
reshape long gov_exp, i(countryname countrycode indicatorname indicatorcode) j(year) 

// Drop redundant columns
drop indicatorname indicatorcode

// Drop redundant years  
keep if year>=2005
keep if year<=2019

// Remove groupings and tiny countries
drop if countryname == "(French part)"
drop if countryname == "Africa Eastern and Southern"
drop if countryname == "Africa Western and Central"
drop if countryname == "Arab World"
drop if countryname == "Caribbean small states"
drop if countryname == "Central Europe and the Baltics"
drop if countryname == "countries: UN classification"
drop if countryname == "Early-demographic dividend"
drop if countryname == "East Asia & Pacific"
drop if countryname == "East Asia & Pacific (excluding high income)"
drop if countryname == "East Asia & Pacific (IDA & IBRD countries)"
drop if countryname == "Euro area"
drop if countryname == "Europe & Central Asia"
drop if countryname == "Europe & Central Asia (excluding high income)"
drop if countryname == "Europe & Central Asia (IDA & IBRD countries)"
drop if countryname == "European Union"
drop if countryname == "Fragile and conflict affected situations"
drop if countryname == "Heavily indebted poor countries (HIPC)"
drop if countryname == "High income"
drop if countryname == "IBRD only"
drop if countryname == "ica & the Caribbean (IDA & IBRD countries)"
drop if countryname == "IDA & IBRD total"
drop if countryname == "IDA blend"
drop if countryname == "IDA only"
drop if countryname == "IDA total"
drop if countryname == "Isle of Man"
drop if countryname == "Late-demographic dividend"
drop if countryname == "Latin America & Caribbean"
drop if countryname == "Latin America & Caribbean (excluding high income)"
drop if countryname == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if countryname == "Least developed"
drop if countryname == "Least developed countries: UN classification"
drop if countryname == "Low & middle income"
drop if countryname == "Low income"
drop if countryname == "Lower middle income"
drop if countryname == "Micronesia, Fed. Sts."
drop if countryname == "Middle East & North Africa"
drop if countryname == "Middle East & North Africa (excluding high income)"
drop if countryname == "Middle East & North Africa (IDA & IBRD countries)"
drop if countryname == "Middle income"
drop if countryname == "Northern Mariana Islands"
drop if countryname == "Not classified"
drop if countryname == "OECD members"
drop if countryname == "Other small states"
drop if countryname == "Other small states"
drop if countryname == "Pacific island small states"
drop if countryname == "Post-demographic dividend"
drop if countryname == "Pre-demographic dividend"
drop if countryname == "Small states"
drop if countryname == "South Asia"
drop if countryname == "South Asia (IDA & IBRD)"
drop if countryname == "Sub-Saharan Africa"
drop if countryname == "Sub-Saharan Africa (excluding high income)"
drop if countryname == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if countryname == "Upper middle income"
drop if countryname == "World"

// Drop the countries 
drop countryname

// Rename for joining 
rename countrycode country_code

save gov_expenditure, replace


********************************
*Central Government Debt to GDP*
********************************

// Clear existing data from memory
clear all 

// Import the data
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/central_government_debt_gdp/API_GC.DOD.TOTL.GD.ZS_DS2_en_csv_v2_2969.csv", varnames(5) rowrange(5:) colrange(:68)

// Describe the data
describe

// Stata does not like integer column names 
local start_year = 1960
forvalues i = 5/68 {
    rename v`i' cen_gov_debt`start_year'
    local start_year = `start_year' + 1
}

// Reshape the data
reshape long cen_gov_debt, i(countryname countrycode indicatorname indicatorcode) j(year) 

// Drop redundant columns
drop indicatorname indicatorcode

// Drop redundant years  
keep if year>=2005
keep if year<=2019

// Remove groupings and tiny countries
drop if countryname == "(French part)"
drop if countryname == "Africa Eastern and Southern"
drop if countryname == "Africa Western and Central"
drop if countryname == "Arab World"
drop if countryname == "Caribbean small states"
drop if countryname == "Central Europe and the Baltics"
drop if countryname == "countries: UN classification"
drop if countryname == "Early-demographic dividend"
drop if countryname == "East Asia & Pacific"
drop if countryname == "East Asia & Pacific (excluding high income)"
drop if countryname == "East Asia & Pacific (IDA & IBRD countries)"
drop if countryname == "Euro area"
drop if countryname == "Europe & Central Asia"
drop if countryname == "Europe & Central Asia (excluding high income)"
drop if countryname == "Europe & Central Asia (IDA & IBRD countries)"
drop if countryname == "European Union"
drop if countryname == "Fragile and conflict affected situations"
drop if countryname == "Heavily indebted poor countries (HIPC)"
drop if countryname == "High income"
drop if countryname == "IBRD only"
drop if countryname == "ica & the Caribbean (IDA & IBRD countries)"
drop if countryname == "IDA & IBRD total"
drop if countryname == "IDA blend"
drop if countryname == "IDA only"
drop if countryname == "IDA total"
drop if countryname == "Isle of Man"
drop if countryname == "Late-demographic dividend"
drop if countryname == "Latin America & Caribbean"
drop if countryname == "Latin America & Caribbean (excluding high income)"
drop if countryname == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if countryname == "Least developed"
drop if countryname == "Least developed countries: UN classification"
drop if countryname == "Low & middle income"
drop if countryname == "Low income"
drop if countryname == "Lower middle income"
drop if countryname == "Micronesia, Fed. Sts."
drop if countryname == "Middle East & North Africa"
drop if countryname == "Middle East & North Africa (excluding high income)"
drop if countryname == "Middle East & North Africa (IDA & IBRD countries)"
drop if countryname == "Middle income"
drop if countryname == "Northern Mariana Islands"
drop if countryname == "Not classified"
drop if countryname == "OECD members"
drop if countryname == "Other small states"
drop if countryname == "Other small states"
drop if countryname == "Pacific island small states"
drop if countryname == "Post-demographic dividend"
drop if countryname == "Pre-demographic dividend"
drop if countryname == "Small states"
drop if countryname == "South Asia"
drop if countryname == "South Asia (IDA & IBRD)"
drop if countryname == "Sub-Saharan Africa"
drop if countryname == "Sub-Saharan Africa (excluding high income)"
drop if countryname == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if countryname == "Upper middle income"
drop if countryname == "World"

// Remove countryname 
drop countryname 

// Rename for joining 
rename countrycode country_code

save cen_gov_debt, replace

********************************
*Current Account Balance to GDP*
********************************

// Clear existing data from memory
clear all 

// Import the data
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/current_account_balance_percentage_gdp/API_BN.CAB.XOKA.GD.ZS_DS2_en_csv_v2_84.csv", varnames(5) rowrange(5:) colrange(:68)

// Describe the data
describe

// Stata does not like integer column names 
local start_year = 1960
forvalues i = 5/68 {
    rename v`i' curr_acc_bal`start_year'
    local start_year = `start_year' + 1
}

// Reshape the data
reshape long curr_acc_bal, i(countryname countrycode indicatorname indicatorcode) j(year) 

// Drop redundant columns
drop indicatorname indicatorcode

// Drop redundant years  
keep if year>=2005
keep if year<=2019

// Remove groupings and tiny countries
drop if countryname == "(French part)"
drop if countryname == "Africa Eastern and Southern"
drop if countryname == "Africa Western and Central"
drop if countryname == "Arab World"
drop if countryname == "Caribbean small states"
drop if countryname == "Central Europe and the Baltics"
drop if countryname == "countries: UN classification"
drop if countryname == "Early-demographic dividend"
drop if countryname == "East Asia & Pacific"
drop if countryname == "East Asia & Pacific (excluding high income)"
drop if countryname == "East Asia & Pacific (IDA & IBRD countries)"
drop if countryname == "Euro area"
drop if countryname == "Europe & Central Asia"
drop if countryname == "Europe & Central Asia (excluding high income)"
drop if countryname == "Europe & Central Asia (IDA & IBRD countries)"
drop if countryname == "European Union"
drop if countryname == "Fragile and conflict affected situations"
drop if countryname == "Heavily indebted poor countries (HIPC)"
drop if countryname == "High income"
drop if countryname == "IBRD only"
drop if countryname == "ica & the Caribbean (IDA & IBRD countries)"
drop if countryname == "IDA & IBRD total"
drop if countryname == "IDA blend"
drop if countryname == "IDA only"
drop if countryname == "IDA total"
drop if countryname == "Isle of Man"
drop if countryname == "Late-demographic dividend"
drop if countryname == "Latin America & Caribbean"
drop if countryname == "Latin America & Caribbean (excluding high income)"
drop if countryname == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if countryname == "Least developed"
drop if countryname == "Least developed countries: UN classification"
drop if countryname == "Low & middle income"
drop if countryname == "Low income"
drop if countryname == "Lower middle income"
drop if countryname == "Micronesia, Fed. Sts."
drop if countryname == "Middle East & North Africa"
drop if countryname == "Middle East & North Africa (excluding high income)"
drop if countryname == "Middle East & North Africa (IDA & IBRD countries)"
drop if countryname == "Middle income"
drop if countryname == "Northern Mariana Islands"
drop if countryname == "Not classified"
drop if countryname == "OECD members"
drop if countryname == "Other small states"
drop if countryname == "Other small states"
drop if countryname == "Pacific island small states"
drop if countryname == "Post-demographic dividend"
drop if countryname == "Pre-demographic dividend"
drop if countryname == "Small states"
drop if countryname == "South Asia"
drop if countryname == "South Asia (IDA & IBRD)"
drop if countryname == "Sub-Saharan Africa"
drop if countryname == "Sub-Saharan Africa (excluding high income)"
drop if countryname == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if countryname == "Upper middle income"
drop if countryname == "World"

// Remove the country name column
drop countryname 

// Rename for joining 
rename countrycode country_code 

save curr_account_balance, replace

*****************************
*Stock Market Turnover Ratio*
*****************************

// Clear existing data from memory
clear all 

// Import the data
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/stocks_traded_turnover_ratio_perc/API_CM.MKT.TRNR_DS2_en_csv_v2_13795.csv", varnames(5) rowrange(5:) colrange(:68)

// Describe the data
describe

// Stata does not like integer column names 
local start_year = 1960
forvalues i = 5/68 {
    rename v`i' stock_market_tor`start_year'
    local start_year = `start_year' + 1
}

// Reshape the data
reshape long stock_market_tor, i(countryname countrycode indicatorname indicatorcode) j(year) 

// Drop redundant columns
drop indicatorname indicatorcode

// Drop redundant years  
keep if year>=2005
keep if year<=2019

// Remove groupings and tiny countries
drop if countryname == "(French part)"
drop if countryname == "Africa Eastern and Southern"
drop if countryname == "Africa Western and Central"
drop if countryname == "Arab World"
drop if countryname == "Caribbean small states"
drop if countryname == "Central Europe and the Baltics"
drop if countryname == "countries: UN classification"
drop if countryname == "Early-demographic dividend"
drop if countryname == "East Asia & Pacific"
drop if countryname == "East Asia & Pacific (excluding high income)"
drop if countryname == "East Asia & Pacific (IDA & IBRD countries)"
drop if countryname == "Euro area"
drop if countryname == "Europe & Central Asia"
drop if countryname == "Europe & Central Asia (excluding high income)"
drop if countryname == "Europe & Central Asia (IDA & IBRD countries)"
drop if countryname == "European Union"
drop if countryname == "Fragile and conflict affected situations"
drop if countryname == "Heavily indebted poor countries (HIPC)"
drop if countryname == "High income"
drop if countryname == "IBRD only"
drop if countryname == "ica & the Caribbean (IDA & IBRD countries)"
drop if countryname == "IDA & IBRD total"
drop if countryname == "IDA blend"
drop if countryname == "IDA only"
drop if countryname == "IDA total"
drop if countryname == "Isle of Man"
drop if countryname == "Late-demographic dividend"
drop if countryname == "Latin America & Caribbean"
drop if countryname == "Latin America & Caribbean (excluding high income)"
drop if countryname == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if countryname == "Least developed"
drop if countryname == "Least developed countries: UN classification"
drop if countryname == "Low & middle income"
drop if countryname == "Low income"
drop if countryname == "Lower middle income"
drop if countryname == "Micronesia, Fed. Sts."
drop if countryname == "Middle East & North Africa"
drop if countryname == "Middle East & North Africa (excluding high income)"
drop if countryname == "Middle East & North Africa (IDA & IBRD countries)"
drop if countryname == "Middle income"
drop if countryname == "Northern Mariana Islands"
drop if countryname == "Not classified"
drop if countryname == "OECD members"
drop if countryname == "Other small states"
drop if countryname == "Other small states"
drop if countryname == "Pacific island small states"
drop if countryname == "Post-demographic dividend"
drop if countryname == "Pre-demographic dividend"
drop if countryname == "Small states"
drop if countryname == "South Asia"
drop if countryname == "South Asia (IDA & IBRD)"
drop if countryname == "Sub-Saharan Africa"
drop if countryname == "Sub-Saharan Africa (excluding high income)"
drop if countryname == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if countryname == "Upper middle income"
drop if countryname == "World"

// Drop the countries 
drop countryname

// Rename for joining 
rename countrycode country_code

save stock_tor, replace

**********************
*Rule of Law Estimate*
**********************

// Clear existing data from memory
clear all 

// Import the data
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/rule_of_law_estimate/API_RL.EST_DS2_en_csv_v2_808.csv", varnames(5) rowrange(5:) colrange(:68)

// Describe the data
describe

// Stata does not like integer column names 
local start_year = 1960
forvalues i = 5/68 {
    rename v`i' rol_estimate`start_year'
    local start_year = `start_year' + 1
}

// Reshape the data
reshape long rol_estimate, i(countryname countrycode indicatorname indicatorcode) j(year) 

// Drop redundant columns
drop indicatorname indicatorcode

// Drop redundant years  
keep if year>=2005
keep if year<=2019

// Remove groupings and tiny countries
drop if countryname == "(French part)"
drop if countryname == "Africa Eastern and Southern"
drop if countryname == "Africa Western and Central"
drop if countryname == "Arab World"
drop if countryname == "Caribbean small states"
drop if countryname == "Central Europe and the Baltics"
drop if countryname == "countries: UN classification"
drop if countryname == "Early-demographic dividend"
drop if countryname == "East Asia & Pacific"
drop if countryname == "East Asia & Pacific (excluding high income)"
drop if countryname == "East Asia & Pacific (IDA & IBRD countries)"
drop if countryname == "Euro area"
drop if countryname == "Europe & Central Asia"
drop if countryname == "Europe & Central Asia (excluding high income)"
drop if countryname == "Europe & Central Asia (IDA & IBRD countries)"
drop if countryname == "European Union"
drop if countryname == "Fragile and conflict affected situations"
drop if countryname == "Heavily indebted poor countries (HIPC)"
drop if countryname == "High income"
drop if countryname == "IBRD only"
drop if countryname == "ica & the Caribbean (IDA & IBRD countries)"
drop if countryname == "IDA & IBRD total"
drop if countryname == "IDA blend"
drop if countryname == "IDA only"
drop if countryname == "IDA total"
drop if countryname == "Isle of Man"
drop if countryname == "Late-demographic dividend"
drop if countryname == "Latin America & Caribbean"
drop if countryname == "Latin America & Caribbean (excluding high income)"
drop if countryname == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if countryname == "Least developed"
drop if countryname == "Least developed countries: UN classification"
drop if countryname == "Low & middle income"
drop if countryname == "Low income"
drop if countryname == "Lower middle income"
drop if countryname == "Micronesia, Fed. Sts."
drop if countryname == "Middle East & North Africa"
drop if countryname == "Middle East & North Africa (excluding high income)"
drop if countryname == "Middle East & North Africa (IDA & IBRD countries)"
drop if countryname == "Middle income"
drop if countryname == "Northern Mariana Islands"
drop if countryname == "Not classified"
drop if countryname == "OECD members"
drop if countryname == "Other small states"
drop if countryname == "Other small states"
drop if countryname == "Pacific island small states"
drop if countryname == "Post-demographic dividend"
drop if countryname == "Pre-demographic dividend"
drop if countryname == "Small states"
drop if countryname == "South Asia"
drop if countryname == "South Asia (IDA & IBRD)"
drop if countryname == "Sub-Saharan Africa"
drop if countryname == "Sub-Saharan Africa (excluding high income)"
drop if countryname == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if countryname == "Upper middle income"
drop if countryname == "World"

// Drop the countries 
drop countryname 

// Rename for joining 
rename countrycode country_code

save rule_of_law, replace

*************************
*Gross Capital Formation*
*************************

// Clear existing data from memory
clear all 

// Import the data
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/gross_capital_formation_gdp/API_NE.GDI.TOTL.ZS_DS2_en_csv_v2_3422.csv", varnames(5) rowrange(5:) colrange(:68)

// Describe the data
describe

// Stata does not like integer column names 
local start_year = 1960
forvalues i = 5/68 {
    rename v`i' gcf`start_year'
    local start_year = `start_year' + 1
}

// Reshape the data
reshape long gcf, i(countryname countrycode indicatorname indicatorcode) j(year) 

// Drop redundant columns
drop indicatorname indicatorcode

// Drop redundant years  
keep if year>=2005
keep if year<=2019

// Remove groupings and tiny countries
drop if countryname == "(French part)"
drop if countryname == "Africa Eastern and Southern"
drop if countryname == "Africa Western and Central"
drop if countryname == "Arab World"
drop if countryname == "Caribbean small states"
drop if countryname == "Central Europe and the Baltics"
drop if countryname == "countries: UN classification"
drop if countryname == "Early-demographic dividend"
drop if countryname == "East Asia & Pacific"
drop if countryname == "East Asia & Pacific (excluding high income)"
drop if countryname == "East Asia & Pacific (IDA & IBRD countries)"
drop if countryname == "Euro area"
drop if countryname == "Europe & Central Asia"
drop if countryname == "Europe & Central Asia (excluding high income)"
drop if countryname == "Europe & Central Asia (IDA & IBRD countries)"
drop if countryname == "European Union"
drop if countryname == "Fragile and conflict affected situations"
drop if countryname == "Heavily indebted poor countries (HIPC)"
drop if countryname == "High income"
drop if countryname == "IBRD only"
drop if countryname == "ica & the Caribbean (IDA & IBRD countries)"
drop if countryname == "IDA & IBRD total"
drop if countryname == "IDA blend"
drop if countryname == "IDA only"
drop if countryname == "IDA total"
drop if countryname == "Isle of Man"
drop if countryname == "Late-demographic dividend"
drop if countryname == "Latin America & Caribbean"
drop if countryname == "Latin America & Caribbean (excluding high income)"
drop if countryname == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if countryname == "Least developed"
drop if countryname == "Least developed countries: UN classification"
drop if countryname == "Low & middle income"
drop if countryname == "Low income"
drop if countryname == "Lower middle income"
drop if countryname == "Micronesia, Fed. Sts."
drop if countryname == "Middle East & North Africa"
drop if countryname == "Middle East & North Africa (excluding high income)"
drop if countryname == "Middle East & North Africa (IDA & IBRD countries)"
drop if countryname == "Middle income"
drop if countryname == "Northern Mariana Islands"
drop if countryname == "Not classified"
drop if countryname == "OECD members"
drop if countryname == "Other small states"
drop if countryname == "Other small states"
drop if countryname == "Pacific island small states"
drop if countryname == "Post-demographic dividend"
drop if countryname == "Pre-demographic dividend"
drop if countryname == "Small states"
drop if countryname == "South Asia"
drop if countryname == "South Asia (IDA & IBRD)"
drop if countryname == "Sub-Saharan Africa"
drop if countryname == "Sub-Saharan Africa (excluding high income)"
drop if countryname == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if countryname == "Upper middle income"
drop if countryname == "World"

// Drop countries 
drop countryname 

// Rename for joining 
rename countrycode country_code

save gross_cap_form, replace

*************************************
*Government Expenditure on Education*
*************************************

// Clear existing data from memory
clear all 

// Import the data
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/government_expenditure_education/API_SE.XPD.TOTL.GD.ZS_DS2_en_csv_v2_49.csv", varnames(5) rowrange(5:) colrange(:68)

// Describe the data
describe

// Stata does not like integer column names 
local start_year = 1960
forvalues i = 5/68 {
    rename v`i' gov_exp_edu`start_year'
    local start_year = `start_year' + 1
}

// Reshape the data
reshape long gov_exp_edu, i(countryname countrycode indicatorname indicatorcode) j(year) 

// Drop redundant columns
drop indicatorname indicatorcode

// Drop redundant years  
keep if year>=2005
keep if year<=2019

// Remove groupings and tiny countries
drop if countryname == "(French part)"
drop if countryname == "Africa Eastern and Southern"
drop if countryname == "Africa Western and Central"
drop if countryname == "Arab World"
drop if countryname == "Caribbean small states"
drop if countryname == "Central Europe and the Baltics"
drop if countryname == "countries: UN classification"
drop if countryname == "Early-demographic dividend"
drop if countryname == "East Asia & Pacific"
drop if countryname == "East Asia & Pacific (excluding high income)"
drop if countryname == "East Asia & Pacific (IDA & IBRD countries)"
drop if countryname == "Euro area"
drop if countryname == "Europe & Central Asia"
drop if countryname == "Europe & Central Asia (excluding high income)"
drop if countryname == "Europe & Central Asia (IDA & IBRD countries)"
drop if countryname == "European Union"
drop if countryname == "Fragile and conflict affected situations"
drop if countryname == "Heavily indebted poor countries (HIPC)"
drop if countryname == "High income"
drop if countryname == "IBRD only"
drop if countryname == "ica & the Caribbean (IDA & IBRD countries)"
drop if countryname == "IDA & IBRD total"
drop if countryname == "IDA blend"
drop if countryname == "IDA only"
drop if countryname == "IDA total"
drop if countryname == "Isle of Man"
drop if countryname == "Late-demographic dividend"
drop if countryname == "Latin America & Caribbean"
drop if countryname == "Latin America & Caribbean (excluding high income)"
drop if countryname == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if countryname == "Least developed"
drop if countryname == "Least developed countries: UN classification"
drop if countryname == "Low & middle income"
drop if countryname == "Low income"
drop if countryname == "Lower middle income"
drop if countryname == "Micronesia, Fed. Sts."
drop if countryname == "Middle East & North Africa"
drop if countryname == "Middle East & North Africa (excluding high income)"
drop if countryname == "Middle East & North Africa (IDA & IBRD countries)"
drop if countryname == "Middle income"
drop if countryname == "Northern Mariana Islands"
drop if countryname == "Not classified"
drop if countryname == "OECD members"
drop if countryname == "Other small states"
drop if countryname == "Other small states"
drop if countryname == "Pacific island small states"
drop if countryname == "Post-demographic dividend"
drop if countryname == "Pre-demographic dividend"
drop if countryname == "Small states"
drop if countryname == "South Asia"
drop if countryname == "South Asia (IDA & IBRD)"
drop if countryname == "Sub-Saharan Africa"
drop if countryname == "Sub-Saharan Africa (excluding high income)"
drop if countryname == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if countryname == "Upper middle income"
drop if countryname == "World"

// Drop countrynames 
drop countryname

// Rename for joining 
rename countrycode country_code

save gov_exp_edu, replace

*******************
*Unemployment Rate*
*******************

// Clear existing data from memory
clear all 

// Import the data
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/unemployment_rate/SDG_0852_SEX_AGE_RT_A-20250208T2243.csv"

// Describe the data
describe

// Turn country names into country codes
replace ref_arealabel = "ABW" if ref_arealabel == "Aruba"
replace ref_arealabel = "AFG" if ref_arealabel == "Afghanistan"
replace ref_arealabel = "AGO" if ref_arealabel == "Angola"
replace ref_arealabel = "AIA" if ref_arealabel == "Anguilla"
replace ref_arealabel = "ALB" if ref_arealabel == "Albania"
replace ref_arealabel = "AND" if ref_arealabel == "Andorra"
replace ref_arealabel = "ANT" if ref_arealabel == "Netherlands Antilles"
replace ref_arealabel = "ARE" if ref_arealabel == "United Arab Emirates"
replace ref_arealabel = "ARG" if ref_arealabel == "Argentina"
replace ref_arealabel = "ARM" if ref_arealabel == "Armenia"
replace ref_arealabel = "ASM" if ref_arealabel == "American Samoa"
replace ref_arealabel = "ATF" if ref_arealabel == "French Southern Territories"
replace ref_arealabel = "ATG" if ref_arealabel == "Antigua and Barbuda"
replace ref_arealabel = "AUS" if ref_arealabel == "Australia"
replace ref_arealabel = "AUT" if ref_arealabel == "Austria"
replace ref_arealabel = "AZE" if ref_arealabel == "Azerbaijan"
replace ref_arealabel = "BDI" if ref_arealabel == "Burundi"
replace ref_arealabel = "BEL" if ref_arealabel == "Belgium"
replace ref_arealabel = "BEN" if ref_arealabel == "Benin"
replace ref_arealabel = "BES" if ref_arealabel == "Bonaire, Sint Eustatius and Saba"
replace ref_arealabel = "BFA" if ref_arealabel == "Burkina Faso"
replace ref_arealabel = "BGD" if ref_arealabel == "Bangladesh"
replace ref_arealabel = "BGR" if ref_arealabel == "Bulgaria"
replace ref_arealabel = "BHR" if ref_arealabel == "Bahrain"
replace ref_arealabel = "BHS" if ref_arealabel == "Bahamas"
replace ref_arealabel = "BIH" if ref_arealabel == "Bosnia and Herzegovina"
replace ref_arealabel = "BLR" if ref_arealabel == "Belarus"
replace ref_arealabel = "BLZ" if ref_arealabel == "Belize"
replace ref_arealabel = "BMU" if ref_arealabel == "Bermuda"
replace ref_arealabel = "BOL" if ref_arealabel == "Bolivia (Plurinational State of)"
replace ref_arealabel = "BRA" if ref_arealabel == "Brazil"
replace ref_arealabel = "BRB" if ref_arealabel == "Barbados"
replace ref_arealabel = "BRN" if ref_arealabel == "Brunei Darussalam"
replace ref_arealabel = "BTN" if ref_arealabel == "Bhutan"
replace ref_arealabel = "BVT" if ref_arealabel == "Bouvet Island"
replace ref_arealabel = "BWA" if ref_arealabel == "Botswana"
replace ref_arealabel = "CAF" if ref_arealabel == "Central African Republic"
replace ref_arealabel = "CAN" if ref_arealabel == "Canada"
replace ref_arealabel = "CCK" if ref_arealabel == "Cocos (Keeling) Islands"
replace ref_arealabel = "CHE" if ref_arealabel == "Switzerland"
replace ref_arealabel = "CHL" if ref_arealabel == "Chile"
replace ref_arealabel = "CHN" if ref_arealabel == "China"
replace ref_arealabel = "CIV" if ref_arealabel == "Côte d'Ivoire"
replace ref_arealabel = "CMR" if ref_arealabel == "Cameroon"
replace ref_arealabel = "COD" if ref_arealabel == "Congo, Democratic Republic of the"
replace ref_arealabel = "COG" if ref_arealabel == "Congo"
replace ref_arealabel = "COG" if ref_arealabel == "Congo, Republic of"
replace ref_arealabel = "COK" if ref_arealabel == "Cook Islands"
replace ref_arealabel = "COL" if ref_arealabel == "Colombia"
replace ref_arealabel = "COM" if ref_arealabel == "Comoros"
replace ref_arealabel = "CPV" if ref_arealabel == "Cabo Verde"
replace ref_arealabel = "CRI" if ref_arealabel == "Costa Rica"
replace ref_arealabel = "CUB" if ref_arealabel == "Cuba"
replace ref_arealabel = "CUW" if ref_arealabel == "Curaçao"
replace ref_arealabel = "CXR" if ref_arealabel == "Christmas Island"
replace ref_arealabel = "CYM" if ref_arealabel == "Cayman Islands"
replace ref_arealabel = "CYP" if ref_arealabel == "Cyprus"
replace ref_arealabel = "CZE" if ref_arealabel == "Czechia"
replace ref_arealabel = "DEU" if ref_arealabel == "Germany"
replace ref_arealabel = "DJI" if ref_arealabel == "Djibouti"
replace ref_arealabel = "DMA" if ref_arealabel == "Dominica"
replace ref_arealabel = "DNK" if ref_arealabel == "Denmark"
replace ref_arealabel = "DOM" if ref_arealabel == "Dominican Republic"
replace ref_arealabel = "DZA" if ref_arealabel == "Algeria"
replace ref_arealabel = "ECU" if ref_arealabel == "Ecuador"
replace ref_arealabel = "EGY" if ref_arealabel == "Egypt"
replace ref_arealabel = "ERI" if ref_arealabel == "Eritrea"
replace ref_arealabel = "ESH" if ref_arealabel == "Western Sahara"
replace ref_arealabel = "ESP" if ref_arealabel == "Spain"
replace ref_arealabel = "EST" if ref_arealabel == "Estonia"
replace ref_arealabel = "ETH" if ref_arealabel == "Ethiopia"
replace ref_arealabel = "FIN" if ref_arealabel == "Finland"
replace ref_arealabel = "FJI" if ref_arealabel == "Fiji"
replace ref_arealabel = "FLK" if ref_arealabel == "Falkland Islands, Malvinas"
replace ref_arealabel = "FRA" if ref_arealabel == "France"
replace ref_arealabel = "FRO" if ref_arealabel == "Faroe Islands"
replace ref_arealabel = "FSM" if ref_arealabel == "Micronesia (Federated States of)"
replace ref_arealabel = "GAB" if ref_arealabel == "Gabon"
replace ref_arealabel = "GBR" if ref_arealabel == "United Kingdom of Great Britain and Northern Ireland"
replace ref_arealabel = "GEO" if ref_arealabel == "Georgia"
replace ref_arealabel = "GGY" if ref_arealabel == "Guernsey"
replace ref_arealabel = "GHA" if ref_arealabel == "Ghana"
replace ref_arealabel = "GIB" if ref_arealabel == "Gibraltar"
replace ref_arealabel = "GIN" if ref_arealabel == "Guinea"
replace ref_arealabel = "GLP" if ref_arealabel == "Guadeloupe"
replace ref_arealabel = "GMB" if ref_arealabel == "Gambia"
replace ref_arealabel = "GNB" if ref_arealabel == "Guinea-Bissau"
replace ref_arealabel = "GNQ" if ref_arealabel == "Equatorial Guinea"
replace ref_arealabel = "GRC" if ref_arealabel == "Greece"
replace ref_arealabel = "GRD" if ref_arealabel == "Grenada"
replace ref_arealabel = "GRL" if ref_arealabel == "Greenland"
replace ref_arealabel = "GTM" if ref_arealabel == "Guatemala"
replace ref_arealabel = "GUF" if ref_arealabel == "Guiana, French"
replace ref_arealabel = "GUM" if ref_arealabel == "Guam"
replace ref_arealabel = "GUY" if ref_arealabel == "Guyana"
replace ref_arealabel = "HKG" if ref_arealabel == "Hong Kong, China"
replace ref_arealabel = "HMD" if ref_arealabel == "Heard Island and McDonald Islands"
replace ref_arealabel = "HND" if ref_arealabel == "Honduras"
replace ref_arealabel = "HRV" if ref_arealabel == "Croatia"
replace ref_arealabel = "HTI" if ref_arealabel == "Haiti"
replace ref_arealabel = "HUN" if ref_arealabel == "Hungary"
replace ref_arealabel = "IDN" if ref_arealabel == "Indonesia"
replace ref_arealabel = "IMN" if ref_arealabel == "Isle of Man"
replace ref_arealabel = "IND" if ref_arealabel == "India"
replace ref_arealabel = "IOT" if ref_arealabel == "British Indian Ocean Territory"
replace ref_arealabel = "IRL" if ref_arealabel == "Ireland"
replace ref_arealabel = "IRN" if ref_arealabel == "Iran (Islamic Republic of)"
replace ref_arealabel = "IRQ" if ref_arealabel == "Iraq"
replace ref_arealabel = "ISL" if ref_arealabel == "Iceland"
replace ref_arealabel = "ISR" if ref_arealabel == "Israel"
replace ref_arealabel = "ITA" if ref_arealabel == "Italy"
replace ref_arealabel = "JAM" if ref_arealabel == "Jamaica"
replace ref_arealabel = "JEY" if ref_arealabel == "Jersey"
replace ref_arealabel = "JOR" if ref_arealabel == "Jordan"
replace ref_arealabel = "JPN" if ref_arealabel == "Japan"
replace ref_arealabel = "KAZ" if ref_arealabel == "Kazakhstan"
replace ref_arealabel = "KEN" if ref_arealabel == "Kenya"
replace ref_arealabel = "KGZ" if ref_arealabel == "Kyrgyzstan"
replace ref_arealabel = "KHM" if ref_arealabel == "Cambodia"
replace ref_arealabel = "KIR" if ref_arealabel == "Kiribati"
replace ref_arealabel = "KNA" if ref_arealabel == "Saint Kitts and Nevis"
replace ref_arealabel = "KOR" if ref_arealabel == "Republic of Korea"
replace ref_arealabel = "KWT" if ref_arealabel == "Kuwait"
replace ref_arealabel = "LAO" if ref_arealabel == "Lao People's Democratic Republic"
replace ref_arealabel = "LBN" if ref_arealabel == "Lebanon"
replace ref_arealabel = "LBR" if ref_arealabel == "Liberia"
replace ref_arealabel = "LBY" if ref_arealabel == "Libya"
replace ref_arealabel = "LCA" if ref_arealabel == "Saint Lucia"
replace ref_arealabel = "LIE" if ref_arealabel == "Liechtenstein"
replace ref_arealabel = "LKA" if ref_arealabel == "Sri Lanka"
replace ref_arealabel = "LSO" if ref_arealabel == "Lesotho"
replace ref_arealabel = "LTU" if ref_arealabel == "Lithuania"
replace ref_arealabel = "LUX" if ref_arealabel == "Luxembourg"
replace ref_arealabel = "LVA" if ref_arealabel == "Latvia"
replace ref_arealabel = "MAC" if ref_arealabel == "Macao, China"
replace ref_arealabel = "MAR" if ref_arealabel == "Morocco"
replace ref_arealabel = "MCO" if ref_arealabel == "Monaco"
replace ref_arealabel = "MDA" if ref_arealabel == "Republic of Moldova"
replace ref_arealabel = "MDG" if ref_arealabel == "Madagascar"
replace ref_arealabel = "MDV" if ref_arealabel == "Maldives"
replace ref_arealabel = "MEX" if ref_arealabel == "Mexico"
replace ref_arealabel = "MHL" if ref_arealabel == "Marshall Islands"
replace ref_arealabel = "MHL" if ref_arealabel == "Marshall Islands, Republic of"
replace ref_arealabel = "MKD" if ref_arealabel == "North Macedonia"
replace ref_arealabel = "MLI" if ref_arealabel == "Mali"
replace ref_arealabel = "MLT" if ref_arealabel == "Malta"
replace ref_arealabel = "MMR" if ref_arealabel == "Myanmar"
replace ref_arealabel = "MNE" if ref_arealabel == "Montenegro"
replace ref_arealabel = "MNG" if ref_arealabel == "Mongolia"
replace ref_arealabel = "MNP" if ref_arealabel == "Northern Mariana Islands"
replace ref_arealabel = "MOZ" if ref_arealabel == "Mozambique"
replace ref_arealabel = "MRT" if ref_arealabel == "Mauritania"
replace ref_arealabel = "MSR" if ref_arealabel == "Montserrat"
replace ref_arealabel = "MTQ" if ref_arealabel == "Martinique"
replace ref_arealabel = "MUS" if ref_arealabel == "Mauritius"
replace ref_arealabel = "MWI" if ref_arealabel == "Malawi"
replace ref_arealabel = "MYS" if ref_arealabel == "Malaysia"
replace ref_arealabel = "MYT" if ref_arealabel == "Mayotte"
replace ref_arealabel = "NAM" if ref_arealabel == "Namibia"
replace ref_arealabel = "NCL" if ref_arealabel == "New Caledonia"
replace ref_arealabel = "NER" if ref_arealabel == "Niger"
replace ref_arealabel = "NFK" if ref_arealabel == "Norfolk Island"
replace ref_arealabel = "NGA" if ref_arealabel == "Nigeria"
replace ref_arealabel = "NIC" if ref_arealabel == "Nicaragua"
replace ref_arealabel = "NIU" if ref_arealabel == "Niue"
replace ref_arealabel = "NLD" if ref_arealabel == "Netherlands"
replace ref_arealabel = "NOR" if ref_arealabel == "Norway"
replace ref_arealabel = "NPL" if ref_arealabel == "Nepal"
replace ref_arealabel = "NRU" if ref_arealabel == "Nauru"
replace ref_arealabel = "NZL" if ref_arealabel == "New Zealand"
replace ref_arealabel = "OMN" if ref_arealabel == "Oman"
replace ref_arealabel = "PSE" if ref_arealabel == "Palestine, State of"
replace ref_arealabel = "PAK" if ref_arealabel == "Pakistan"
replace ref_arealabel = "PAN" if ref_arealabel == "Panama"
replace ref_arealabel = "PCN" if ref_arealabel == "Pitcairn Islands"
replace ref_arealabel = "PER" if ref_arealabel == "Peru"
replace ref_arealabel = "PHL" if ref_arealabel == "Philippines"
replace ref_arealabel = "PLW" if ref_arealabel == "Palau"
replace ref_arealabel = "PNG" if ref_arealabel == "Papua New Guinea"
replace ref_arealabel = "POL" if ref_arealabel == "Poland"
replace ref_arealabel = "PRI" if ref_arealabel == "Puerto Rico"
replace ref_arealabel = "PRK" if ref_arealabel == "Korea (the Democratic People's Republic of)"
replace ref_arealabel = "PRT" if ref_arealabel == "Portugal"
replace ref_arealabel = "PRY" if ref_arealabel == "Paraguay"
replace ref_arealabel = "PSE" if ref_arealabel == "West Bank and Gaza"
replace ref_arealabel = "PYF" if ref_arealabel == "French Polynesia"
replace ref_arealabel = "QAT" if ref_arealabel == "Qatar"
replace ref_arealabel = "REU" if ref_arealabel == "Réunion"
replace ref_arealabel = "ROU" if ref_arealabel == "Romania"
replace ref_arealabel = "RUS" if ref_arealabel == "Russian Federation"
replace ref_arealabel = "RWA" if ref_arealabel == "Rwanda"
replace ref_arealabel = "SAU" if ref_arealabel == "Saudi Arabia"
replace ref_arealabel = "SDN" if ref_arealabel == "Sudan"
replace ref_arealabel = "SEN" if ref_arealabel == "Senegal"
replace ref_arealabel = "SGP" if ref_arealabel == "Singapore"
replace ref_arealabel = "SGS" if ref_arealabel == "South Georgia and Sandwich Islands"
replace ref_arealabel = "SHN" if ref_arealabel == "Saint Helena"
replace ref_arealabel = "SLB" if ref_arealabel == "Solomon Islands"
replace ref_arealabel = "SLE" if ref_arealabel == "Sierra Leone"
replace ref_arealabel = "SLV" if ref_arealabel == "El Salvador"
replace ref_arealabel = "SMR" if ref_arealabel == "San Marino"
replace ref_arealabel = "SMR" if ref_arealabel == "San Marino"
replace ref_arealabel = "SOM" if ref_arealabel == "Somalia"
replace ref_arealabel = "SPM" if ref_arealabel == "Saint Pierre and Miquelon"
replace ref_arealabel = "SRB" if ref_arealabel == "Serbia"
replace ref_arealabel = "SSD" if ref_arealabel == "South Sudan"
replace ref_arealabel = "STP" if ref_arealabel == "Sao Tome and Principe"
replace ref_arealabel = "SUR" if ref_arealabel == "Suriname"
replace ref_arealabel = "SVK" if ref_arealabel == "Slovakia"
replace ref_arealabel = "SVN" if ref_arealabel == "Slovenia"
replace ref_arealabel = "SWE" if ref_arealabel == "Sweden"
replace ref_arealabel = "SWZ" if ref_arealabel == "Eswatini"
replace ref_arealabel = "SXM" if ref_arealabel == "Sint Maarten"
replace ref_arealabel = "SYC" if ref_arealabel == "Seychelles"
replace ref_arealabel = "SYR" if ref_arealabel == "Syrian Arab Republic"
replace ref_arealabel = "TCA" if ref_arealabel == "Turks and Caicos Islands"
replace ref_arealabel = "TCD" if ref_arealabel == "Chad"
replace ref_arealabel = "TGO" if ref_arealabel == "Togo"
replace ref_arealabel = "THA" if ref_arealabel == "Thailand"
replace ref_arealabel = "TJK" if ref_arealabel == "Tajikistan"
replace ref_arealabel = "TKL" if ref_arealabel == "Tokelau"
replace ref_arealabel = "TKM" if ref_arealabel == "Turkmenistan"
replace ref_arealabel = "TLS" if ref_arealabel == "Timor-Leste"
replace ref_arealabel = "TON" if ref_arealabel == "Tonga"
replace ref_arealabel = "TTO" if ref_arealabel == "Trinidad and Tobago"
replace ref_arealabel = "TUN" if ref_arealabel == "Tunisia"
replace ref_arealabel = "TUR" if ref_arealabel == "Türkiye"
replace ref_arealabel = "TUV" if ref_arealabel == "Tuvalu"
replace ref_arealabel = "TWN" if ref_arealabel == "Taiwan, China"
replace ref_arealabel = "TZA" if ref_arealabel == "Tanzania, United Republic of"
replace ref_arealabel = "UGA" if ref_arealabel == "Uganda"
replace ref_arealabel = "UKR" if ref_arealabel == "Ukraine"
replace ref_arealabel = "UMI" if ref_arealabel == "US Pacific Islands"
replace ref_arealabel = "UNK" if ref_arealabel == "Kosovo"
replace ref_arealabel = "URY" if ref_arealabel == "Uruguay"
replace ref_arealabel = "USA" if ref_arealabel == "United States of America"
replace ref_arealabel = "UZB" if ref_arealabel == "Uzbekistan"
replace ref_arealabel = "VAT" if ref_arealabel == "Vatican"
replace ref_arealabel = "VCT" if ref_arealabel == "Saint Vincent and the Grenadines"
replace ref_arealabel = "VEN" if ref_arealabel == "Venezuela (Bolivarian Republic of)"
replace ref_arealabel = "VGB" if ref_arealabel == "Virgin Islands, British"
replace ref_arealabel = "VIR" if ref_arealabel == "United States Virgin Islands"
replace ref_arealabel = "VNM" if ref_arealabel == "Viet Nam"
replace ref_arealabel = "VUT" if ref_arealabel == "Vanuatu"
replace ref_arealabel = "WLF" if ref_arealabel == "Wallis and Futuna"
replace ref_arealabel = "WSM" if ref_arealabel == "Samoa"
replace ref_arealabel = "YEM" if ref_arealabel == "Yemen"
replace ref_arealabel = "ZAF" if ref_arealabel == "South Africa"
replace ref_arealabel = "ZMB" if ref_arealabel == "Zambia"
replace ref_arealabel = "ZWE" if ref_arealabel == "Zimbabwe"

// We will specifically use the 25+ adults 
keep if classif1label == "Age (Youth, adults): 25+" 
keep if sexlabel == "Sex: Total"

// Get rid of non countries
gen str_len = strlen(ref_arealabel)  
keep if str_len == 3

// Keep only the columns of interest
keep ref_arealabel time obs_value

// Rename the columns
rename ref_arealabel country_code
rename time year 
rename obs_value unemployment_rate

save unemployment_rate, replace

*****************************************
*Number of listed companies per million *
*Remittance inflows to GDP              *
*Stock Market Total value traded to GDP *
*Bank deposits to GDP                   *
*Domestic credit to private sector      *
*****************************************

// Clear the system memory
clear all 

// Import the file containing financial variables
import excel "/Users/thomasedwards/projects/econ3900_analysis/new_data/financial_variables/20220909-global-financial-development-database.xlsx", sheet("Data - August 2022") firstrow

// Describe the data 
describe 

// Keep only the columns of interest 
keep iso3 year income om01 oi13 dm02 oi02 di05 di14

// Rename the columns to more sensible names
rename iso3 country_code 
rename om01 listed_per_million 
rename oi13 remittance_inflows
rename dm02 stock_market_value_traded 
rename oi02 bank_deposits_to_gdp
rename di05 liquid_liabilities
rename di14 dom_credit_to_private_sec

// Encode the income to a integer value
encode income, gen(income_level)

// Drop the redundant income variable
drop income 

// Keep only recent years
drop if year < 2005

save financial_variables, replace

*********************
*Productivity Growth*
*********************

// Clear the system memory
clear all 

// describe the data 
describe 

// Import the productivity data 
import delimited "/Users/thomasedwards/projects/econ3900_analysis/new_data/labour_productivity_growth/GDP_2HRW_NOC_NB_A-20250208T2305.csv"

keep ref_area time obs_value

// Turn country names into country codes
replace ref_arealabel = "ABW" if ref_arealabel == "Aruba"
replace ref_arealabel = "AFG" if ref_arealabel == "Afghanistan"
replace ref_arealabel = "AGO" if ref_arealabel == "Angola"
replace ref_arealabel = "AIA" if ref_arealabel == "Anguilla"
replace ref_arealabel = "ALB" if ref_arealabel == "Albania"
replace ref_arealabel = "AND" if ref_arealabel == "Andorra"
replace ref_arealabel = "ANT" if ref_arealabel == "Netherlands Antilles"
replace ref_arealabel = "ARE" if ref_arealabel == "United Arab Emirates"
replace ref_arealabel = "ARG" if ref_arealabel == "Argentina"
replace ref_arealabel = "ARM" if ref_arealabel == "Armenia"
replace ref_arealabel = "ASM" if ref_arealabel == "American Samoa"
replace ref_arealabel = "ATF" if ref_arealabel == "French Southern Territories"
replace ref_arealabel = "ATG" if ref_arealabel == "Antigua and Barbuda"
replace ref_arealabel = "AUS" if ref_arealabel == "Australia"
replace ref_arealabel = "AUT" if ref_arealabel == "Austria"
replace ref_arealabel = "AZE" if ref_arealabel == "Azerbaijan"
replace ref_arealabel = "BDI" if ref_arealabel == "Burundi"
replace ref_arealabel = "BEL" if ref_arealabel == "Belgium"
replace ref_arealabel = "BEN" if ref_arealabel == "Benin"
replace ref_arealabel = "BES" if ref_arealabel == "Bonaire, Sint Eustatius and Saba"
replace ref_arealabel = "BFA" if ref_arealabel == "Burkina Faso"
replace ref_arealabel = "BGD" if ref_arealabel == "Bangladesh"
replace ref_arealabel = "BGR" if ref_arealabel == "Bulgaria"
replace ref_arealabel = "BHR" if ref_arealabel == "Bahrain"
replace ref_arealabel = "BHS" if ref_arealabel == "Bahamas"
replace ref_arealabel = "BIH" if ref_arealabel == "Bosnia and Herzegovina"
replace ref_arealabel = "BLR" if ref_arealabel == "Belarus"
replace ref_arealabel = "BLZ" if ref_arealabel == "Belize"
replace ref_arealabel = "BMU" if ref_arealabel == "Bermuda"
replace ref_arealabel = "BOL" if ref_arealabel == "Bolivia (Plurinational State of)"
replace ref_arealabel = "BRA" if ref_arealabel == "Brazil"
replace ref_arealabel = "BRB" if ref_arealabel == "Barbados"
replace ref_arealabel = "BRN" if ref_arealabel == "Brunei Darussalam"
replace ref_arealabel = "BTN" if ref_arealabel == "Bhutan"
replace ref_arealabel = "BVT" if ref_arealabel == "Bouvet Island"
replace ref_arealabel = "BWA" if ref_arealabel == "Botswana"
replace ref_arealabel = "CAF" if ref_arealabel == "Central African Republic"
replace ref_arealabel = "CAN" if ref_arealabel == "Canada"
replace ref_arealabel = "CCK" if ref_arealabel == "Cocos (Keeling) Islands"
replace ref_arealabel = "CHE" if ref_arealabel == "Switzerland"
replace ref_arealabel = "CHL" if ref_arealabel == "Chile"
replace ref_arealabel = "CHN" if ref_arealabel == "China"
replace ref_arealabel = "CIV" if ref_arealabel == "Côte d'Ivoire"
replace ref_arealabel = "CMR" if ref_arealabel == "Cameroon"
replace ref_arealabel = "COD" if ref_arealabel == "Congo, Democratic Republic of the"
replace ref_arealabel = "COG" if ref_arealabel == "Congo"
replace ref_arealabel = "COG" if ref_arealabel == "Congo, Republic of"
replace ref_arealabel = "COK" if ref_arealabel == "Cook Islands"
replace ref_arealabel = "COL" if ref_arealabel == "Colombia"
replace ref_arealabel = "COM" if ref_arealabel == "Comoros"
replace ref_arealabel = "CPV" if ref_arealabel == "Cabo Verde"
replace ref_arealabel = "CRI" if ref_arealabel == "Costa Rica"
replace ref_arealabel = "CUB" if ref_arealabel == "Cuba"
replace ref_arealabel = "CUW" if ref_arealabel == "Curaçao"
replace ref_arealabel = "CXR" if ref_arealabel == "Christmas Island"
replace ref_arealabel = "CYM" if ref_arealabel == "Cayman Islands"
replace ref_arealabel = "CYP" if ref_arealabel == "Cyprus"
replace ref_arealabel = "CZE" if ref_arealabel == "Czechia"
replace ref_arealabel = "DEU" if ref_arealabel == "Germany"
replace ref_arealabel = "DJI" if ref_arealabel == "Djibouti"
replace ref_arealabel = "DMA" if ref_arealabel == "Dominica"
replace ref_arealabel = "DNK" if ref_arealabel == "Denmark"
replace ref_arealabel = "DOM" if ref_arealabel == "Dominican Republic"
replace ref_arealabel = "DZA" if ref_arealabel == "Algeria"
replace ref_arealabel = "ECU" if ref_arealabel == "Ecuador"
replace ref_arealabel = "EGY" if ref_arealabel == "Egypt"
replace ref_arealabel = "ERI" if ref_arealabel == "Eritrea"
replace ref_arealabel = "ESH" if ref_arealabel == "Western Sahara"
replace ref_arealabel = "ESP" if ref_arealabel == "Spain"
replace ref_arealabel = "EST" if ref_arealabel == "Estonia"
replace ref_arealabel = "ETH" if ref_arealabel == "Ethiopia"
replace ref_arealabel = "FIN" if ref_arealabel == "Finland"
replace ref_arealabel = "FJI" if ref_arealabel == "Fiji"
replace ref_arealabel = "FLK" if ref_arealabel == "Falkland Islands, Malvinas"
replace ref_arealabel = "FRA" if ref_arealabel == "France"
replace ref_arealabel = "FRO" if ref_arealabel == "Faroe Islands"
replace ref_arealabel = "FSM" if ref_arealabel == "Micronesia (Federated States of)"
replace ref_arealabel = "GAB" if ref_arealabel == "Gabon"
replace ref_arealabel = "GBR" if ref_arealabel == "United Kingdom of Great Britain and Northern Ireland"
replace ref_arealabel = "GEO" if ref_arealabel == "Georgia"
replace ref_arealabel = "GGY" if ref_arealabel == "Guernsey"
replace ref_arealabel = "GHA" if ref_arealabel == "Ghana"
replace ref_arealabel = "GIB" if ref_arealabel == "Gibraltar"
replace ref_arealabel = "GIN" if ref_arealabel == "Guinea"
replace ref_arealabel = "GLP" if ref_arealabel == "Guadeloupe"
replace ref_arealabel = "GMB" if ref_arealabel == "Gambia"
replace ref_arealabel = "GNB" if ref_arealabel == "Guinea-Bissau"
replace ref_arealabel = "GNQ" if ref_arealabel == "Equatorial Guinea"
replace ref_arealabel = "GRC" if ref_arealabel == "Greece"
replace ref_arealabel = "GRD" if ref_arealabel == "Grenada"
replace ref_arealabel = "GRL" if ref_arealabel == "Greenland"
replace ref_arealabel = "GTM" if ref_arealabel == "Guatemala"
replace ref_arealabel = "GUF" if ref_arealabel == "Guiana, French"
replace ref_arealabel = "GUM" if ref_arealabel == "Guam"
replace ref_arealabel = "GUY" if ref_arealabel == "Guyana"
replace ref_arealabel = "HKG" if ref_arealabel == "Hong Kong, China"
replace ref_arealabel = "HMD" if ref_arealabel == "Heard Island and McDonald Islands"
replace ref_arealabel = "HND" if ref_arealabel == "Honduras"
replace ref_arealabel = "HRV" if ref_arealabel == "Croatia"
replace ref_arealabel = "HTI" if ref_arealabel == "Haiti"
replace ref_arealabel = "HUN" if ref_arealabel == "Hungary"
replace ref_arealabel = "IDN" if ref_arealabel == "Indonesia"
replace ref_arealabel = "IMN" if ref_arealabel == "Isle of Man"
replace ref_arealabel = "IND" if ref_arealabel == "India"
replace ref_arealabel = "IOT" if ref_arealabel == "British Indian Ocean Territory"
replace ref_arealabel = "IRL" if ref_arealabel == "Ireland"
replace ref_arealabel = "IRN" if ref_arealabel == "Iran (Islamic Republic of)"
replace ref_arealabel = "IRQ" if ref_arealabel == "Iraq"
replace ref_arealabel = "ISL" if ref_arealabel == "Iceland"
replace ref_arealabel = "ISR" if ref_arealabel == "Israel"
replace ref_arealabel = "ITA" if ref_arealabel == "Italy"
replace ref_arealabel = "JAM" if ref_arealabel == "Jamaica"
replace ref_arealabel = "JEY" if ref_arealabel == "Jersey"
replace ref_arealabel = "JOR" if ref_arealabel == "Jordan"
replace ref_arealabel = "JPN" if ref_arealabel == "Japan"
replace ref_arealabel = "KAZ" if ref_arealabel == "Kazakhstan"
replace ref_arealabel = "KEN" if ref_arealabel == "Kenya"
replace ref_arealabel = "KGZ" if ref_arealabel == "Kyrgyzstan"
replace ref_arealabel = "KHM" if ref_arealabel == "Cambodia"
replace ref_arealabel = "KIR" if ref_arealabel == "Kiribati"
replace ref_arealabel = "KNA" if ref_arealabel == "Saint Kitts and Nevis"
replace ref_arealabel = "KOR" if ref_arealabel == "Republic of Korea"
replace ref_arealabel = "KWT" if ref_arealabel == "Kuwait"
replace ref_arealabel = "LAO" if ref_arealabel == "Lao People's Democratic Republic"
replace ref_arealabel = "LBN" if ref_arealabel == "Lebanon"
replace ref_arealabel = "LBR" if ref_arealabel == "Liberia"
replace ref_arealabel = "LBY" if ref_arealabel == "Libya"
replace ref_arealabel = "LCA" if ref_arealabel == "Saint Lucia"
replace ref_arealabel = "LIE" if ref_arealabel == "Liechtenstein"
replace ref_arealabel = "LKA" if ref_arealabel == "Sri Lanka"
replace ref_arealabel = "LSO" if ref_arealabel == "Lesotho"
replace ref_arealabel = "LTU" if ref_arealabel == "Lithuania"
replace ref_arealabel = "LUX" if ref_arealabel == "Luxembourg"
replace ref_arealabel = "LVA" if ref_arealabel == "Latvia"
replace ref_arealabel = "MAC" if ref_arealabel == "Macao, China"
replace ref_arealabel = "MAR" if ref_arealabel == "Morocco"
replace ref_arealabel = "MCO" if ref_arealabel == "Monaco"
replace ref_arealabel = "MDA" if ref_arealabel == "Republic of Moldova"
replace ref_arealabel = "MDG" if ref_arealabel == "Madagascar"
replace ref_arealabel = "MDV" if ref_arealabel == "Maldives"
replace ref_arealabel = "MEX" if ref_arealabel == "Mexico"
replace ref_arealabel = "MHL" if ref_arealabel == "Marshall Islands"
replace ref_arealabel = "MHL" if ref_arealabel == "Marshall Islands, Republic of"
replace ref_arealabel = "MKD" if ref_arealabel == "North Macedonia"
replace ref_arealabel = "MLI" if ref_arealabel == "Mali"
replace ref_arealabel = "MLT" if ref_arealabel == "Malta"
replace ref_arealabel = "MMR" if ref_arealabel == "Myanmar"
replace ref_arealabel = "MNE" if ref_arealabel == "Montenegro"
replace ref_arealabel = "MNG" if ref_arealabel == "Mongolia"
replace ref_arealabel = "MNP" if ref_arealabel == "Northern Mariana Islands"
replace ref_arealabel = "MOZ" if ref_arealabel == "Mozambique"
replace ref_arealabel = "MRT" if ref_arealabel == "Mauritania"
replace ref_arealabel = "MSR" if ref_arealabel == "Montserrat"
replace ref_arealabel = "MTQ" if ref_arealabel == "Martinique"
replace ref_arealabel = "MUS" if ref_arealabel == "Mauritius"
replace ref_arealabel = "MWI" if ref_arealabel == "Malawi"
replace ref_arealabel = "MYS" if ref_arealabel == "Malaysia"
replace ref_arealabel = "MYT" if ref_arealabel == "Mayotte"
replace ref_arealabel = "NAM" if ref_arealabel == "Namibia"
replace ref_arealabel = "NCL" if ref_arealabel == "New Caledonia"
replace ref_arealabel = "NER" if ref_arealabel == "Niger"
replace ref_arealabel = "NFK" if ref_arealabel == "Norfolk Island"
replace ref_arealabel = "NGA" if ref_arealabel == "Nigeria"
replace ref_arealabel = "NIC" if ref_arealabel == "Nicaragua"
replace ref_arealabel = "NIU" if ref_arealabel == "Niue"
replace ref_arealabel = "NLD" if ref_arealabel == "Netherlands"
replace ref_arealabel = "NOR" if ref_arealabel == "Norway"
replace ref_arealabel = "NPL" if ref_arealabel == "Nepal"
replace ref_arealabel = "NRU" if ref_arealabel == "Nauru"
replace ref_arealabel = "NZL" if ref_arealabel == "New Zealand"
replace ref_arealabel = "OMN" if ref_arealabel == "Oman"
replace ref_arealabel = "PSE" if ref_arealabel == "Occupied Palestinian Territory"
replace ref_arealabel = "PAK" if ref_arealabel == "Pakistan"
replace ref_arealabel = "PAN" if ref_arealabel == "Panama"
replace ref_arealabel = "PCN" if ref_arealabel == "Pitcairn Islands"
replace ref_arealabel = "PER" if ref_arealabel == "Peru"
replace ref_arealabel = "PHL" if ref_arealabel == "Philippines"
replace ref_arealabel = "PLW" if ref_arealabel == "Palau"
replace ref_arealabel = "PNG" if ref_arealabel == "Papua New Guinea"
replace ref_arealabel = "POL" if ref_arealabel == "Poland"
replace ref_arealabel = "PRI" if ref_arealabel == "Puerto Rico"
replace ref_arealabel = "PRK" if ref_arealabel == "Korea (the Democratic People's Republic of)"
replace ref_arealabel = "PRT" if ref_arealabel == "Portugal"
replace ref_arealabel = "PRY" if ref_arealabel == "Paraguay"
replace ref_arealabel = "PSE" if ref_arealabel == "West Bank and Gaza"
replace ref_arealabel = "PYF" if ref_arealabel == "French Polynesia"
replace ref_arealabel = "QAT" if ref_arealabel == "Qatar"
replace ref_arealabel = "REU" if ref_arealabel == "Réunion"
replace ref_arealabel = "ROU" if ref_arealabel == "Romania"
replace ref_arealabel = "RUS" if ref_arealabel == "Russian Federation"
replace ref_arealabel = "RWA" if ref_arealabel == "Rwanda"
replace ref_arealabel = "SAU" if ref_arealabel == "Saudi Arabia"
replace ref_arealabel = "SDN" if ref_arealabel == "Sudan"
replace ref_arealabel = "SEN" if ref_arealabel == "Senegal"
replace ref_arealabel = "SGP" if ref_arealabel == "Singapore"
replace ref_arealabel = "SGS" if ref_arealabel == "South Georgia and Sandwich Islands"
replace ref_arealabel = "SHN" if ref_arealabel == "Saint Helena"
replace ref_arealabel = "SLB" if ref_arealabel == "Solomon Islands"
replace ref_arealabel = "SLE" if ref_arealabel == "Sierra Leone"
replace ref_arealabel = "SLV" if ref_arealabel == "El Salvador"
replace ref_arealabel = "SMR" if ref_arealabel == "San Marino"
replace ref_arealabel = "SMR" if ref_arealabel == "San Marino"
replace ref_arealabel = "SOM" if ref_arealabel == "Somalia"
replace ref_arealabel = "SPM" if ref_arealabel == "Saint Pierre and Miquelon"
replace ref_arealabel = "SRB" if ref_arealabel == "Serbia"
replace ref_arealabel = "SSD" if ref_arealabel == "South Sudan"
replace ref_arealabel = "STP" if ref_arealabel == "Sao Tome and Principe"
replace ref_arealabel = "SUR" if ref_arealabel == "Suriname"
replace ref_arealabel = "SVK" if ref_arealabel == "Slovakia"
replace ref_arealabel = "SVN" if ref_arealabel == "Slovenia"
replace ref_arealabel = "SWE" if ref_arealabel == "Sweden"
replace ref_arealabel = "SWZ" if ref_arealabel == "Eswatini"
replace ref_arealabel = "SXM" if ref_arealabel == "Sint Maarten"
replace ref_arealabel = "SYC" if ref_arealabel == "Seychelles"
replace ref_arealabel = "SYR" if ref_arealabel == "Syrian Arab Republic"
replace ref_arealabel = "TCA" if ref_arealabel == "Turks and Caicos Islands"
replace ref_arealabel = "TCD" if ref_arealabel == "Chad"
replace ref_arealabel = "TGO" if ref_arealabel == "Togo"
replace ref_arealabel = "THA" if ref_arealabel == "Thailand"
replace ref_arealabel = "TJK" if ref_arealabel == "Tajikistan"
replace ref_arealabel = "TKL" if ref_arealabel == "Tokelau"
replace ref_arealabel = "TKM" if ref_arealabel == "Turkmenistan"
replace ref_arealabel = "TLS" if ref_arealabel == "Timor-Leste"
replace ref_arealabel = "TON" if ref_arealabel == "Tonga"
replace ref_arealabel = "TTO" if ref_arealabel == "Trinidad and Tobago"
replace ref_arealabel = "TUN" if ref_arealabel == "Tunisia"
replace ref_arealabel = "TUR" if ref_arealabel == "Türkiye"
replace ref_arealabel = "TUV" if ref_arealabel == "Tuvalu"
replace ref_arealabel = "TWN" if ref_arealabel == "Taiwan, China"
replace ref_arealabel = "TZA" if ref_arealabel == "Tanzania, United Republic of"
replace ref_arealabel = "UGA" if ref_arealabel == "Uganda"
replace ref_arealabel = "UKR" if ref_arealabel == "Ukraine"
replace ref_arealabel = "UMI" if ref_arealabel == "US Pacific Islands"
replace ref_arealabel = "UNK" if ref_arealabel == "Kosovo"
replace ref_arealabel = "URY" if ref_arealabel == "Uruguay"
replace ref_arealabel = "USA" if ref_arealabel == "United States of America"
replace ref_arealabel = "UZB" if ref_arealabel == "Uzbekistan"
replace ref_arealabel = "VAT" if ref_arealabel == "Vatican"
replace ref_arealabel = "VCT" if ref_arealabel == "Saint Vincent and the Grenadines"
replace ref_arealabel = "VEN" if ref_arealabel == "Venezuela (Bolivarian Republic of)"
replace ref_arealabel = "VGB" if ref_arealabel == "Virgin Islands, British"
replace ref_arealabel = "VIR" if ref_arealabel == "United States Virgin Islands"
replace ref_arealabel = "VNM" if ref_arealabel == "Viet Nam"
replace ref_arealabel = "VUT" if ref_arealabel == "Vanuatu"
replace ref_arealabel = "WLF" if ref_arealabel == "Wallis and Futuna"
replace ref_arealabel = "WSM" if ref_arealabel == "Samoa"
replace ref_arealabel = "YEM" if ref_arealabel == "Yemen"
replace ref_arealabel = "ZAF" if ref_arealabel == "South Africa"
replace ref_arealabel = "ZMB" if ref_arealabel == "Zambia"
replace ref_arealabel = "ZWE" if ref_arealabel == "Zimbabwe"

// Remove the Channel Islands
drop if ref_arealabel == "Channel Islands" 

// Calculate the log of productivity
gen logproductivity = ln(obs_value)

// Encode the countrycode
encode ref_arealabel, gen(countrycode)

// Get the lag of log productivity
xtset countrycode time 
bysort countrycode (time): gen lag_logproductivity=L.logproductivity

// Calculate the log difference 
gen prod_growth = logproductivity - lag_logproductivity

// Get rid of non countries
gen str_len = strlen(ref_arealabel)  
keep if str_len == 3

// Keep only the colulmns of interest 
keep ref_arealabel time prod_growth

// Rename the columns
rename ref_arealabel countrycode
rename time year 

// Rename for joining 
rename countrycode country_code

save lab_prod_growth, replace

*************************
* GDP Per Capita (Level)*
*************************

// Clear existing data from memory
clear all 

// Import the data
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/GDP Per Capita Level/API_NY.GDP.PCAP.CD_DS2_en_csv_v2_76317.csv", varnames(5) rowrange(5:) colrange(:68)

// Describe the data
describe

// Stata does not like integer column names 
local start_year = 1960
forvalues i = 5/68 {
    rename v`i' gdp_pc_level`start_year'
    local start_year = `start_year' + 1
}

// Reshape the data
reshape long gdp_pc_level, i(countryname countrycode indicatorname indicatorcode) j(year) 

// Drop redundant columns
drop indicatorname indicatorcode

// Drop redundant years  
keep if year>=2005
keep if year<=2019

// Remove groupings and tiny countries
drop if countryname == "(French part)"
drop if countryname == "Africa Eastern and Southern"
drop if countryname == "Africa Western and Central"
drop if countryname == "Arab World"
drop if countryname == "Caribbean small states"
drop if countryname == "Central Europe and the Baltics"
drop if countryname == "countries: UN classification"
drop if countryname == "Early-demographic dividend"
drop if countryname == "East Asia & Pacific"
drop if countryname == "East Asia & Pacific (excluding high income)"
drop if countryname == "East Asia & Pacific (IDA & IBRD countries)"
drop if countryname == "Euro area"
drop if countryname == "Europe & Central Asia"
drop if countryname == "Europe & Central Asia (excluding high income)"
drop if countryname == "Europe & Central Asia (IDA & IBRD countries)"
drop if countryname == "European Union"
drop if countryname == "Fragile and conflict affected situations"
drop if countryname == "Heavily indebted poor countries (HIPC)"
drop if countryname == "High income"
drop if countryname == "IBRD only"
drop if countryname == "ica & the Caribbean (IDA & IBRD countries)"
drop if countryname == "IDA & IBRD total"
drop if countryname == "IDA blend"
drop if countryname == "IDA only"
drop if countryname == "IDA total"
drop if countryname == "Isle of Man"
drop if countryname == "Late-demographic dividend"
drop if countryname == "Latin America & Caribbean"
drop if countryname == "Latin America & Caribbean (excluding high income)"
drop if countryname == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if countryname == "Least developed"
drop if countryname == "Least developed countries: UN classification"
drop if countryname == "Low & middle income"
drop if countryname == "Low income"
drop if countryname == "Lower middle income"
drop if countryname == "Micronesia, Fed. Sts."
drop if countryname == "Middle East & North Africa"
drop if countryname == "Middle East & North Africa (excluding high income)"
drop if countryname == "Middle East & North Africa (IDA & IBRD countries)"
drop if countryname == "Middle income"
drop if countryname == "Northern Mariana Islands"
drop if countryname == "Not classified"
drop if countryname == "OECD members"
drop if countryname == "Other small states"
drop if countryname == "Other small states"
drop if countryname == "Pacific island small states"
drop if countryname == "Post-demographic dividend"
drop if countryname == "Pre-demographic dividend"
drop if countryname == "Small states"
drop if countryname == "South Asia"
drop if countryname == "South Asia (IDA & IBRD)"
drop if countryname == "Sub-Saharan Africa"
drop if countryname == "Sub-Saharan Africa (excluding high income)"
drop if countryname == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if countryname == "Upper middle income"
drop if countryname == "World"

// Drop countries
drop countryname

// Rename for joining 
rename countrycode country_code

save gdp_pc_level, replace

*************************
*Human Development Index*
*************************

// Clear the system memory
clear all 

// Import the data 
import delimited "/Users/thomasedwards/projects/econ3900_analysis/new_data/human_development_index/HDR23-24_Composite_indices_complete_time_series.csv"

// Drop unnecessary columns 
keep iso3 country hdi_2005 hdi_2006 hdi_2007 hdi_2008 hdi_2009 hdi_2010 hdi_2011 hdi_2012 hdi_2013 hdi_2014 hdi_2015 hdi_2016 hdi_2016 hdi_2017 hdi_2019

// Reshape the data
reshape long hdi_, i(iso3 country) j(year) 

// Rename indicator 
rename hdi_ hdi_index

// Turn country names into country codes
replace country = "ABW" if country == "Aruba"
replace country = "AFG" if country == "Afghanistan"
replace country = "AGO" if country == "Angola"
replace country = "AIA" if country == "Anguilla"
replace country = "ALB" if country == "Albania"
replace country = "AND" if country == "Andorra"
replace country = "ANT" if country == "Netherlands Antilles"
replace country = "ARE" if country == "United Arab Emirates"
replace country = "ARG" if country == "Argentina"
replace country = "ARM" if country == "Armenia"
replace country = "ASM" if country == "American Samoa"
replace country = "ATF" if country == "French Southern Territories"
replace country = "ATG" if country == "Antigua and Barbuda"
replace country = "AUS" if country == "Australia"
replace country = "AUT" if country == "Austria"
replace country = "AZE" if country == "Azerbaijan"
replace country = "BDI" if country == "Burundi"
replace country = "BEL" if country == "Belgium"
replace country = "BEN" if country == "Benin"
replace country = "BES" if country == "Bonaire, Sint Eustatius and Saba"
replace country = "BFA" if country == "Burkina Faso"
replace country = "BGD" if country == "Bangladesh"
replace country = "BGR" if country == "Bulgaria"
replace country = "BHR" if country == "Bahrain"
replace country = "BHS" if country == "Bahamas"
replace country = "BIH" if country == "Bosnia and Herzegovina"
replace country = "BLR" if country == "Belarus"
replace country = "BLZ" if country == "Belize"
replace country = "BMU" if country == "Bermuda"
replace country = "BOL" if country == "Bolivia (Plurinational State of)"
replace country = "BRA" if country == "Brazil"
replace country = "BRB" if country == "Barbados"
replace country = "BRN" if country == "Brunei Darussalam"
replace country = "BTN" if country == "Bhutan"
replace country = "BVT" if country == "Bouvet Island"
replace country = "BWA" if country == "Botswana"
replace country = "CAF" if country == "Central African Republic"
replace country = "CAN" if country == "Canada"
replace country = "CCK" if country == "Cocos (Keeling) Islands"
replace country = "CHE" if country == "Switzerland"
replace country = "CHL" if country == "Chile"
replace country = "CHN" if country == "China"
replace country = "CIV" if country == "Côte d'Ivoire"
replace country = "CMR" if country == "Cameroon"
replace country = "COD" if country == "Congo (Democratic Republic of the)"
replace country = "COG" if country == "Congo"
replace country = "COG" if country == "Congo, Republic of"
replace country = "COK" if country == "Cook Islands"
replace country = "COL" if country == "Colombia"
replace country = "COM" if country == "Comoros"
replace country = "CPV" if country == "Cabo Verde"
replace country = "CRI" if country == "Costa Rica"
replace country = "CUB" if country == "Cuba"
replace country = "CUW" if country == "Curaçao"
replace country = "CXR" if country == "Christmas Island"
replace country = "CYM" if country == "Cayman Islands"
replace country = "CYP" if country == "Cyprus"
replace country = "CZE" if country == "Czechia"
replace country = "DEU" if country == "Germany"
replace country = "DJI" if country == "Djibouti"
replace country = "DMA" if country == "Dominica"
replace country = "DNK" if country == "Denmark"
replace country = "DOM" if country == "Dominican Republic"
replace country = "DZA" if country == "Algeria"
replace country = "ECU" if country == "Ecuador"
replace country = "EGY" if country == "Egypt"
replace country = "ERI" if country == "Eritrea"
replace country = "ESH" if country == "Western Sahara"
replace country = "ESP" if country == "Spain"
replace country = "EST" if country == "Estonia"
replace country = "ETH" if country == "Ethiopia"
replace country = "FIN" if country == "Finland"
replace country = "FJI" if country == "Fiji"
replace country = "FLK" if country == "Falkland Islands, Malvinas"
replace country = "FRA" if country == "France"
replace country = "FRO" if country == "Faroe Islands"
replace country = "FSM" if country == "Micronesia (Federated States of)"
replace country = "GAB" if country == "Gabon"
replace country = "GBR" if country == "United Kingdom"
replace country = "GEO" if country == "Georgia"
replace country = "GGY" if country == "Guernsey"
replace country = "GHA" if country == "Ghana"
replace country = "GIB" if country == "Gibraltar"
replace country = "GIN" if country == "Guinea"
replace country = "GLP" if country == "Guadeloupe"
replace country = "GMB" if country == "Gambia"
replace country = "GNB" if country == "Guinea-Bissau"
replace country = "GNQ" if country == "Equatorial Guinea"
replace country = "GRC" if country == "Greece"
replace country = "GRD" if country == "Grenada"
replace country = "GRL" if country == "Greenland"
replace country = "GTM" if country == "Guatemala"
replace country = "GUF" if country == "Guiana, French"
replace country = "GUM" if country == "Guam"
replace country = "GUY" if country == "Guyana"
replace country = "HKG" if country == "Hong Kong, China (SAR)"
replace country = "HMD" if country == "Heard Island and McDonald Islands"
replace country = "HND" if country == "Honduras"
replace country = "HRV" if country == "Croatia"
replace country = "HTI" if country == "Haiti"
replace country = "HUN" if country == "Hungary"
replace country = "IDN" if country == "Indonesia"
replace country = "IMN" if country == "Isle of Man"
replace country = "IND" if country == "India"
replace country = "IOT" if country == "British Indian Ocean Territory"
replace country = "IRL" if country == "Ireland"
replace country = "IRN" if country == "Iran (Islamic Republic of)"
replace country = "IRQ" if country == "Iraq"
replace country = "ISL" if country == "Iceland"
replace country = "ISR" if country == "Israel"
replace country = "ITA" if country == "Italy"
replace country = "JAM" if country == "Jamaica"
replace country = "JEY" if country == "Jersey"
replace country = "JOR" if country == "Jordan"
replace country = "JPN" if country == "Japan"
replace country = "KAZ" if country == "Kazakhstan"
replace country = "KEN" if country == "Kenya"
replace country = "KGZ" if country == "Kyrgyzstan"
replace country = "KHM" if country == "Cambodia"
replace country = "KIR" if country == "Kiribati"
replace country = "KNA" if country == "Saint Kitts and Nevis"
replace country = "KOR" if country == "Korea (Republic of)"
replace country = "KWT" if country == "Kuwait"
replace country = "LAO" if country == "Lao People's Democratic Republic"
replace country = "LBN" if country == "Lebanon"
replace country = "LBR" if country == "Liberia"
replace country = "LBY" if country == "Libya"
replace country = "LCA" if country == "Saint Lucia"
replace country = "LIE" if country == "Liechtenstein"
replace country = "LKA" if country == "Sri Lanka"
replace country = "LSO" if country == "Lesotho"
replace country = "LTU" if country == "Lithuania"
replace country = "LUX" if country == "Luxembourg"
replace country = "LVA" if country == "Latvia"
replace country = "MAC" if country == "Macao, China"
replace country = "MAR" if country == "Morocco"
replace country = "MCO" if country == "Monaco"
replace country = "MDA" if country == "Moldova (Republic of)"
replace country = "MDG" if country == "Madagascar"
replace country = "MDV" if country == "Maldives"
replace country = "MEX" if country == "Mexico"
replace country = "MHL" if country == "Marshall Islands"
replace country = "MHL" if country == "Marshall Islands, Republic of"
replace country = "MKD" if country == "North Macedonia"
replace country = "MLI" if country == "Mali"
replace country = "MLT" if country == "Malta"
replace country = "MMR" if country == "Myanmar"
replace country = "MNE" if country == "Montenegro"
replace country = "MNG" if country == "Mongolia"
replace country = "MNP" if country == "Northern Mariana Islands"
replace country = "MOZ" if country == "Mozambique"
replace country = "MRT" if country == "Mauritania"
replace country = "MSR" if country == "Montserrat"
replace country = "MTQ" if country == "Martinique"
replace country = "MUS" if country == "Mauritius"
replace country = "MWI" if country == "Malawi"
replace country = "MYS" if country == "Malaysia"
replace country = "MYT" if country == "Mayotte"
replace country = "NAM" if country == "Namibia"
replace country = "NCL" if country == "New Caledonia"
replace country = "NER" if country == "Niger"
replace country = "NFK" if country == "Norfolk Island"
replace country = "NGA" if country == "Nigeria"
replace country = "NIC" if country == "Nicaragua"
replace country = "NIU" if country == "Niue"
replace country = "NLD" if country == "Netherlands"
replace country = "NOR" if country == "Norway"
replace country = "NPL" if country == "Nepal"
replace country = "NRU" if country == "Nauru"
replace country = "NZL" if country == "New Zealand"
replace country = "OMN" if country == "Oman"
replace country = "PSE" if country == "Occupied Palestinian Territory"
replace country = "PAK" if country == "Pakistan"
replace country = "PAN" if country == "Panama"
replace country = "PCN" if country == "Pitcairn Islands"
replace country = "PER" if country == "Peru"
replace country = "PHL" if country == "Philippines"
replace country = "PLW" if country == "Palau"
replace country = "PNG" if country == "Papua New Guinea"
replace country = "POL" if country == "Poland"
replace country = "PRI" if country == "Puerto Rico"
replace country = "PRK" if country == "Korea (Democratic People's Rep. of)"
replace country = "PRT" if country == "Portugal"
replace country = "PRY" if country == "Paraguay"
replace country = "PSE" if country == "West Bank and Gaza"
replace country = "PYF" if country == "French Polynesia"
replace country = "QAT" if country == "Qatar"
replace country = "REU" if country == "Réunion"
replace country = "ROU" if country == "Romania"
replace country = "RUS" if country == "Russian Federation"
replace country = "RWA" if country == "Rwanda"
replace country = "SAU" if country == "Saudi Arabia"
replace country = "SDN" if country == "Sudan"
replace country = "SEN" if country == "Senegal"
replace country = "SGP" if country == "Singapore"
replace country = "SGS" if country == "South Georgia and Sandwich Islands"
replace country = "SHN" if country == "Saint Helena"
replace country = "SLB" if country == "Solomon Islands"
replace country = "SLE" if country == "Sierra Leone"
replace country = "SLV" if country == "El Salvador"
replace country = "SMR" if country == "San Marino"
replace country = "SMR" if country == "San Marino"
replace country = "SOM" if country == "Somalia"
replace country = "SPM" if country == "Saint Pierre and Miquelon"
replace country = "SRB" if country == "Serbia"
replace country = "SSD" if country == "South Sudan"
replace country = "STP" if country == "Sao Tome and Principe"
replace country = "SUR" if country == "Suriname"
replace country = "SVK" if country == "Slovakia"
replace country = "SVN" if country == "Slovenia"
replace country = "SWE" if country == "Sweden"
replace country = "SWZ" if country == "Eswatini (Kingdom of)"
replace country = "SXM" if country == "Sint Maarten"
replace country = "SYC" if country == "Seychelles"
replace country = "SYR" if country == "Syrian Arab Republic"
replace country = "TCA" if country == "Turks and Caicos Islands"
replace country = "TCD" if country == "Chad"
replace country = "TGO" if country == "Togo"
replace country = "THA" if country == "Thailand"
replace country = "TJK" if country == "Tajikistan"
replace country = "TKL" if country == "Tokelau"
replace country = "TKM" if country == "Turkmenistan"
replace country = "TLS" if country == "Timor-Leste"
replace country = "TON" if country == "Tonga"
replace country = "TTO" if country == "Trinidad and Tobago"
replace country = "TUN" if country == "Tanzania (United Republic of)"
replace country = "TUR" if country == "Türkiye"
replace country = "TUV" if country == "Tuvalu"
replace country = "TWN" if country == "Taiwan, China"
replace country = "TZA" if country == "Tanzania, United Republic of"
replace country = "UGA" if country == "Uganda"
replace country = "UKR" if country == "Ukraine"
replace country = "UMI" if country == "US Pacific Islands"
replace country = "UNK" if country == "Kosovo"
replace country = "URY" if country == "Uruguay"
replace country = "USA" if country == "United States"
replace country = "UZB" if country == "Uzbekistan"
replace country = "VAT" if country == "Vatican"
replace country = "VCT" if country == "Saint Vincent and the Grenadines"
replace country = "VEN" if country == "Venezuela (Bolivarian Republic of)"
replace country = "VGB" if country == "Virgin Islands, British"
replace country = "VIR" if country == "United States Virgin Islands"
replace country = "VNM" if country == "Viet Nam"
replace country = "VUT" if country == "Vanuatu"
replace country = "WLF" if country == "Wallis and Futuna"
replace country = "WSM" if country == "Samoa"
replace country = "YEM" if country == "Yemen"
replace country = "ZAF" if country == "South Africa"
replace country = "ZMB" if country == "Zambia"
replace country = "ZWE" if country == "Zimbabwe"

// Get rid of non countries
gen str_len = strlen(country)  
keep if str_len == 3
drop str_len

// Rename for joining 
rename iso3 country_code 

// Remove country 
drop country

save human_development_index, replace

******************
*Economic Freedom*
******************

// Clear system memory
clear all 

// Load the data 
import excel "/Users/thomasedwards/projects/econ3900_analysis/new_data/economic_freedom_index/efotw-2024-master-index-data-for-researchers-iso.xlsx", sheet("EFW Data 2024 Report") cellrange(A5:CL4791) firstrow

// Keep only the columns of interest 
keep Year ISOCode3 EconomicFreedomSummaryIndex

// Rename columns
rename Year year
rename ISOCode3 country_code 

save economic_freedom, replace 

*****************
*Economic Growth*
*****************

// Clear existing data from memory
clear all 

// Import the data
import delimited using "/Users/thomasedwards/projects/econ3900_analysis/new_data/gdp_growth_annual_percentage/API_NY.GDP.MKTP.KD.ZG_DS2_en_csv_v2_127.csv", varnames(5) rowrange(5:) colrange(:68)

// Describe the data
describe

// Stata does not like integer column names 
local start_year = 1960
forvalues i = 5/68 {
    rename v`i' gdp_growth`start_year'
    local start_year = `start_year' + 1
}

// Reshape the data
reshape long gdp_growth, i(countryname countrycode indicatorname indicatorcode) j(year) 

// Drop redundant columns
drop indicatorname indicatorcode

// Drop redundant years  
keep if year>=2005
keep if year<=2019

// Remove groupings and tiny countries
drop if countryname == "(French part)"
drop if countryname == "Africa Eastern and Southern"
drop if countryname == "Africa Western and Central"
drop if countryname == "Arab World"
drop if countryname == "Caribbean small states"
drop if countryname == "Central Europe and the Baltics"
drop if countryname == "countries: UN classification"
drop if countryname == "Early-demographic dividend"
drop if countryname == "East Asia & Pacific"
drop if countryname == "East Asia & Pacific (excluding high income)"
drop if countryname == "East Asia & Pacific (IDA & IBRD countries)"
drop if countryname == "Euro area"
drop if countryname == "Europe & Central Asia"
drop if countryname == "Europe & Central Asia (excluding high income)"
drop if countryname == "Europe & Central Asia (IDA & IBRD countries)"
drop if countryname == "European Union"
drop if countryname == "Fragile and conflict affected situations"
drop if countryname == "Heavily indebted poor countries (HIPC)"
drop if countryname == "High income"
drop if countryname == "IBRD only"
drop if countryname == "ica & the Caribbean (IDA & IBRD countries)"
drop if countryname == "IDA & IBRD total"
drop if countryname == "IDA blend"
drop if countryname == "IDA only"
drop if countryname == "IDA total"
drop if countryname == "Isle of Man"
drop if countryname == "Late-demographic dividend"
drop if countryname == "Latin America & Caribbean"
drop if countryname == "Latin America & Caribbean (excluding high income)"
drop if countryname == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if countryname == "Least developed"
drop if countryname == "Least developed countries: UN classification"
drop if countryname == "Low & middle income"
drop if countryname == "Low income"
drop if countryname == "Lower middle income"
drop if countryname == "Micronesia, Fed. Sts."
drop if countryname == "Middle East & North Africa"
drop if countryname == "Middle East & North Africa (excluding high income)"
drop if countryname == "Middle East & North Africa (IDA & IBRD countries)"
drop if countryname == "Middle income"
drop if countryname == "Northern Mariana Islands"
drop if countryname == "Not classified"
drop if countryname == "OECD members"
drop if countryname == "Other small states"
drop if countryname == "Other small states"
drop if countryname == "Pacific island small states"
drop if countryname == "Post-demographic dividend"
drop if countryname == "Pre-demographic dividend"
drop if countryname == "Small states"
drop if countryname == "South Asia"
drop if countryname == "South Asia (IDA & IBRD)"
drop if countryname == "Sub-Saharan Africa"
drop if countryname == "Sub-Saharan Africa (excluding high income)"
drop if countryname == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if countryname == "Upper middle income"
drop if countryname == "World"

// Drop countries
drop countryname

// Rename for joining 
rename countrycode country_code

save gdp_growth, replace


*****************
* Merge the data*
*****************

// Close the open dataset
clear all

// Merge everything
use combined_fdi_split
merge 1:1 country_code year using gini
keep if inlist(_merge,1 ,3)
drop _merge
merge 1:1 country_code year using tax_rev_perc
keep if inlist(_merge,1 ,3)
drop _merge 
merge 1:1 country_code year using savings_perc
keep if inlist(_merge,1 ,3)
drop _merge
merge 1:1 country_code year using interest_rate
keep if inlist(_merge,1 ,3)
drop _merge
merge 1:1 country_code year using inflation
keep if inlist(_merge,1 ,3)
drop _merge
merge 1:1 country_code year using exports
keep if inlist(_merge,1 ,3)
drop _merge
merge 1:1 country_code year using imports
keep if inlist(_merge,1 ,3)
drop _merge
merge 1:1 country_code year using control_corruption
keep if inlist(_merge,1 ,3)
drop _merge
merge 1:1 country_code year using gov_expenditure
keep if inlist(_merge,1 ,3)
drop _merge
merge 1:1 country_code year using cen_gov_debt
keep if inlist(_merge,1 ,3)
drop _merge
merge 1:1 country_code year using curr_account_balance
keep if inlist(_merge,1 ,3)
drop _merge
merge 1:1 country_code year using stock_tor
keep if inlist(_merge,1 ,3)
drop _merge
merge 1:1 country_code year using rule_of_law
keep if inlist(_merge,1 ,3)
drop _merge
merge 1:1 country_code year using gross_cap_form
keep if inlist(_merge,1 ,3)
drop _merge
merge 1:1 country_code year using gov_exp_edu
keep if inlist(_merge,1 ,3)
drop _merge
merge 1:1 country_code year using unemployment_rate
keep if inlist(_merge,1 ,3)
drop _merge
merge 1:1 country_code year using financial_variables
keep if inlist(_merge,1 ,3)
drop _merge
merge 1:1 country_code year using lab_prod_growth
keep if inlist(_merge,1 ,3)
drop _merge
merge 1:1 country_code year using human_development_index
keep if inlist(_merge,1 ,3)
drop _merge
merge 1:1 country_code year using economic_freedom
keep if inlist(_merge,1 ,3)
drop _merge
merge 1:1 country_code year using gdp_growth
keep if inlist(_merge,1 ,3)
drop _merge
merge 1:1 country_code year using gdp_pc_level
keep if inlist(_merge,1 ,3)
drop _merge

// // Keep only years of interest
// keep if year >= 2013
// keep if year <= 2019

save main, replace

***************************
*Handle the missing values*
***************************

// Clear memory
clear all 

// Use the main dataet created earlier
use main

vl create mainvars = (gdp_pc_level gdp_growth primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp gov_exp_edu cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows prod_growth hdi_index EconomicFreedomSummaryIndex)


// Fill backward
   foreach var of varlist $mainvars { 
	replace `var' = `var'[_n-1] if missing(`var')
 }
 
// Drop counties with too many missing data values
drop if country_code == "ARG"
drop if country_code == "ARM"
drop if country_code == "NZL"


save final_dataset, replace

****************************************************************************
*Regressions small number of countries large number of observations Version*
****************************************************************************

// Clear the memory 
clear all

// Load the dataset
use final_dataset

// Keep years after 2005
keep if year >= 2008

// Keep the countries with obervations from 2008
keep if inlist(country_code, "BGD", "BRN", "COL", "CPV", "EST", "FRA", "GEO", "GHA", "GTM") | inlist(country_code, "HUN", "IDN", "LTU", "LVA", "MEX", "MOZ", "MYS", "PAK", "PRT") | inlist(country_code, "PRY", "RWA", "SGP", "THA", "UGA")

************************
*Descriptive Statistics*
************************

// Visually inspect the statistics
summarize gdp_growth primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows prod_growth hdi_index EconomicFreedomSummaryIndex gdp_pc_level

// Create an Excel file
putexcel set "long_version_summary.xlsx", modify

// Write the stats to excel
local k = 1
foreach x in gdp_growth primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows prod_growth hdi_index EconomicFreedomSummaryIndex gdp_pc_level {
    sum `x'
   putexcel a`k' = "`x'"
   putexcel b`k' = `r(N)'
   putexcel c`k' = `r(mean)'
   putexcel d`k' = `r(sd)'
   putexcel e`k' = `r(min)'
   putexcel f`k' = `r(max)'
   local k = `k' + 1
}

// Save the excel File
putexcel save

// Run the correlation analysis
correlate gdp_growth primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows prod_growth hdi_index EconomicFreedomSummaryIndex gdp_pc_level

// List the output
return list
matrix list r(C)

// Save to excel for presentation in our paper
putexcel set "long_version_corr.xlsx", modify
putexcel A1=matrix(r(C)), names
putexcel save

***************************
* Regressions Wide Version* 
***************************

** Main Approach of interest

// Clear the memory 
clear all

// Load the dataset
use final_dataset

// Keep only years of interest
keep if year >= 2013
keep if year <= 2019

************************
*Descriptive Statistics*
************************

// Visually inspect the statistics
summarize gdp_growth primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows prod_growth hdi_index EconomicFreedomSummaryIndex gdp_pc_level

// Create an Excel file
putexcel set "wide_version_summary.xlsx", modify

// Write the stats to excel
local k = 1
foreach x in gdp_growth primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows prod_growth hdi_index EconomicFreedomSummaryIndex gdp_pc_level {
    sum `x'
   putexcel a`k' = "`x'"
   putexcel b`k' = `r(N)'
   putexcel c`k' = `r(mean)'
   putexcel d`k' = `r(sd)'
   putexcel e`k' = `r(min)'
   putexcel f`k' = `r(max)'
   local k = `k' + 1
}

// Save the excel File
putexcel save

// Run the correlation analysis
correlate gdp_growth primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows prod_growth hdi_index EconomicFreedomSummaryIndex gdp_pc_level

// List the output
return list
matrix list r(C)

// Save to excel for presentation in our paper
putexcel set "wide_version_corr.xlsx", modify
putexcel A1=matrix(r(C)), names
putexcel save

**********************************
* Dependent Variable = GDP GROWTH*
* All Countries Sectoral Split.  *
**********************************

// Clear the memory 
clear all

// Load the dataset
use final_dataset

// Keep only years of interest
keep if year >= 2013
keep if year <= 2019

// Set the Panel variables
encode country_code, gen(iso_id)
xtset iso_id year

// Pooled OLS
reg gdp_growth primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows prod_growth hdi_index EconomicFreedomSummaryIndex


// Pooled OLS with Economic Freedom Interaction Terms added 
reg gdp_growth primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows prod_growth hdi_index EconomicFreedomSummaryIndex c.primary_sector_fdi#c.EconomicFreedomSummaryIndex c.secondary_sector_fdi#c.EconomicFreedomSummaryIndex c.tertiary_sector_fdi#c.EconomicFreedomSummaryIndex

// We have heteroskedacticity in the residuals (null hypothesis of homoskedacticity rejected)
hettest primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows prod_growth hdi_index EconomicFreedomSummaryIndex c.primary_sector_fdi#c.EconomicFreedomSummaryIndex c.secondary_sector_fdi#c.EconomicFreedomSummaryIndex c.tertiary_sector_fdi#c.EconomicFreedomSummaryIndex

// Random effects model with interaction terms 
xtreg gdp_growth primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows prod_growth hdi_index EconomicFreedomSummaryIndex c.primary_sector_fdi#c.EconomicFreedomSummaryIndex c.secondary_sector_fdi#c.EconomicFreedomSummaryIndex c.tertiary_sector_fdi#c.EconomicFreedomSummaryIndex, re 

est sto re

// Legrange multiplier test - the random effects model seems like the better model
xttest0

// Fixed effects model with interaction terms 
xtreg gdp_growth primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows prod_growth hdi_index EconomicFreedomSummaryIndex c.primary_sector_fdi#c.EconomicFreedomSummaryIndex c.secondary_sector_fdi#c.EconomicFreedomSummaryIndex c.tertiary_sector_fdi#c.EconomicFreedomSummaryIndex, fe

//Store it in a variable
est sto fe

// Perform the hausman test - looks like the fixed effects model is superior - Hausman cannot use robust errors
hausman fe re

// Test for Auto Correlation
xtqptest

// Fixed effects model with interaction terms and robust standard errors
xtreg gdp_growth primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows prod_growth hdi_index EconomicFreedomSummaryIndex c.primary_sector_fdi#c.EconomicFreedomSummaryIndex c.secondary_sector_fdi#c.EconomicFreedomSummaryIndex c.tertiary_sector_fdi#c.EconomicFreedomSummaryIndex, fe vce(robust)

// Fixed effects model with interaction terms and robust standard errors + dropping imports, control of corruption, bank deposits and HDI
xtreg gdp_growth primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded remittance_inflows prod_growth EconomicFreedomSummaryIndex c.primary_sector_fdi#c.EconomicFreedomSummaryIndex c.secondary_sector_fdi#c.EconomicFreedomSummaryIndex c.tertiary_sector_fdi#c.EconomicFreedomSummaryIndex, fe vce(robust)


**********************************
* Dependent Variable = GDP LEVEL *
* All Countries Sectoral Split.  *
**********************************
// Clear the memory 
clear all

// Load the dataset
use final_dataset

// Keep only years of interest
keep if year >= 2013
keep if year <= 2019

// Set the Panel variables
encode country_code, gen(iso_id)
xtset iso_id year

// Pooled OLS
reg gdp_pc_level primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows prod_growth hdi_index EconomicFreedomSummaryIndex gdp_growth

// Pooled OLS with Economic Freedom Interaction Terms added 
reg gdp_pc_level primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows prod_growth hdi_index EconomicFreedomSummaryIndex c.primary_sector_fdi#c.EconomicFreedomSummaryIndex c.secondary_sector_fdi#c.EconomicFreedomSummaryIndex c.tertiary_sector_fdi#c.EconomicFreedomSummaryIndex gdp_growth

// We have heteroskedacticity in the residuals (null hypothesis of homoskedacticity rejected)
hettest primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows prod_growth hdi_index EconomicFreedomSummaryIndex c.primary_sector_fdi#c.EconomicFreedomSummaryIndex c.secondary_sector_fdi#c.EconomicFreedomSummaryIndex c.tertiary_sector_fdi#c.EconomicFreedomSummaryIndex gdp_growth

// Random effects model with interaction terms 
xtreg gdp_pc_level primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows prod_growth hdi_index EconomicFreedomSummaryIndex c.primary_sector_fdi#c.EconomicFreedomSummaryIndex c.secondary_sector_fdi#c.EconomicFreedomSummaryIndex c.tertiary_sector_fdi#c.EconomicFreedomSummaryIndex gdp_growth, re 

est sto re

// Legrange multiplier test - the random effects model seems like the better model
xttest0

// Fixed effects model with interaction terms 
xtreg gdp_pc_level primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows prod_growth hdi_index EconomicFreedomSummaryIndex c.primary_sector_fdi#c.EconomicFreedomSummaryIndex c.secondary_sector_fdi#c.EconomicFreedomSummaryIndex c.tertiary_sector_fdi#c.EconomicFreedomSummaryIndex gdp_growth, fe

//Store it in a variable
est sto fe

// Perform the hausman test - looks like the fixed effects model is superior - Hausman cannot use robust errors
hausman fe re

// Test for Auto Correlation
xtqptest

// Fixed effects model with interaction terms and robust standard errors
xtreg gdp_pc_level primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows prod_growth hdi_index EconomicFreedomSummaryIndex c.primary_sector_fdi#c.EconomicFreedomSummaryIndex c.secondary_sector_fdi#c.EconomicFreedomSummaryIndex c.tertiary_sector_fdi#c.EconomicFreedomSummaryIndex gdp_growth, fe vce(robust)

// Fixed effects model with interaction terms and robust standard errors + dropping imports, control of corruption, bank deposits and HDI
xtreg gdp_pc_level primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded remittance_inflows prod_growth EconomicFreedomSummaryIndex c.primary_sector_fdi#c.EconomicFreedomSummaryIndex c.secondary_sector_fdi#c.EconomicFreedomSummaryIndex c.tertiary_sector_fdi#c.EconomicFreedomSummaryIndex gdp_growth, fe vce(robust)


**************************************************
* Dependent Variable = LABOUR PRODUCTIVITY GROWTH*
* All Countries Sectoral Split.                  *
**************************************************
// Clear the memory 
clear all

// Load the dataset
use final_dataset

// Keep only years of interest
keep if year >= 2013
keep if year <= 2019

// Set the Panel variables
encode country_code, gen(iso_id)
xtset iso_id year

// Pooled OLS
reg prod_growth primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows hdi_index EconomicFreedomSummaryIndex gdp_growth

// Pooled OLS with Economic Freedom Interaction Terms added 
reg prod_growth primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows hdi_index EconomicFreedomSummaryIndex c.primary_sector_fdi#c.EconomicFreedomSummaryIndex c.secondary_sector_fdi#c.EconomicFreedomSummaryIndex c.tertiary_sector_fdi#c.EconomicFreedomSummaryIndex gdp_growth

// We have heteroskedacticity in the residuals (null hypothesis of homoskedacticity rejected)
hettest primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows hdi_index EconomicFreedomSummaryIndex c.primary_sector_fdi#c.EconomicFreedomSummaryIndex c.secondary_sector_fdi#c.EconomicFreedomSummaryIndex c.tertiary_sector_fdi#c.EconomicFreedomSummaryIndex gdp_growth

// Random effects model with interaction terms 
xtreg prod_growth primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows hdi_index EconomicFreedomSummaryIndex c.primary_sector_fdi#c.EconomicFreedomSummaryIndex c.secondary_sector_fdi#c.EconomicFreedomSummaryIndex c.tertiary_sector_fdi#c.EconomicFreedomSummaryIndex gdp_growth, re 

est sto re

// Legrange multiplier test - the random effects model seems like the better model
xttest0

// Fixed effects model with interaction terms 
xtreg prod_growth primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows hdi_index EconomicFreedomSummaryIndex c.primary_sector_fdi#c.EconomicFreedomSummaryIndex c.secondary_sector_fdi#c.EconomicFreedomSummaryIndex c.tertiary_sector_fdi#c.EconomicFreedomSummaryIndex gdp_growth, fe

//Store it in a variable
est sto fe

// Perform the hausman test - looks like the fixed effects model is superior - Hausman cannot use robust errors
hausman fe re

// Test for Auto Correlation
xtqptest

// Fixed effects model with interaction terms and robust standard errors
xtreg prod_growth primary_sector_fdi secondary_sector_fdi tertiary_sector_fdi gini tax_rev save_perc_gdp interest_rate inflation exports imports con_corruption gov_exp cen_gov_debt curr_acc_bal stock_market_tor rol_estimate gcf unemployment_rate liquid_liabilities dom_credit_to_private_sec stock_market_value_traded bank_deposits_to_gdp remittance_inflows hdi_index EconomicFreedomSummaryIndex c.primary_sector_fdi#c.EconomicFreedomSummaryIndex c.secondary_sector_fdi#c.EconomicFreedomSummaryIndex c.tertiary_sector_fdi#c.EconomicFreedomSummaryIndex gdp_growth, fe vce(robust)

// close the log
log close _all

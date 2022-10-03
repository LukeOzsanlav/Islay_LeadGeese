# Code and Data for 'Incidence of lead ingestion in managed goose populations and the efficacy of imposed restrictions on the use of lead shot'
🦆 🔫
This repository holds the data and code for a publication that is in review at *Ibis* entitled; 'Incidence of lead ingestion in managed goose populations and the efficacy of imposed restrictions on the use of lead shot'. The data and code provided here should allow anyone to recreate our analysis we outline in the paper. Simply download the repository, load the R project and then run the R scripts in numerical order.

![](https://img.shields.io/github/directory-file-count/LukeOzsanlav/Ibis_2022_lead)

_Authors_:

- Aimee Mcintosh <a itemprop="sameAs" content="https://orcid.org/0000-0002-4975-3682" href="https://orcid.org/0000-0002-4975-3682" target="orcid.widget" rel="me noopener noreferrer" style="vertical-align:top;"><img src="https://orcid.org/sites/default/files/images/orcid_16x16.png" alt="ORCID iD icon" style="width:1em;margin-right:.5em;"/></a>
- Luke Ozsanlav-Harris <a itemprop="sameAs" content="https://orcid.org/0000-0003-3889-6722" href="https://orcid.org/0000-0003-3889-6722" target="orcid.widget" rel="me noopener noreferrer" style="vertical-align:top;"><img src="https://orcid.org/sites/default/files/images/orcid_16x16.png" alt="ORCID iD icon" style="width:1em;margin-right:.5em;"/></a>
- Mark Taggart
- Jessica Shaw
- Geoff Hilton <a itemprop="sameAs" content="https://orcid.org/0000-0001-9062-3030" href="https://orcid.org/0000-0001-9062-3030" target="orcid.widget" rel="me noopener noreferrer" style="vertical-align:top;"><img src="https://orcid.org/sites/default/files/images/orcid_16x16.png" alt="ORCID iD icon" style="width:1em;margin-right:.5em;"/></a>
- Stuart Bearhop <a itemprop="sameAs" content="https://orcid.org/0000-0002-5864-0129" href="https://orcid.org/0000-0002-5864-0129" target="orcid.widget" rel="me noopener noreferrer" style="vertical-align:top;"><img src="https://orcid.org/sites/default/files/images/orcid_16x16.png" alt="ORCID iD icon" style="width:1em;margin-right:.5em;"/></a>


## Manuscript Status
*Reject and reubmit* received: 09/05/2022


## Code description
- `1- Add field codes to lead data.R`: Combine the the faecal lead measurments with the sampling locations

- `2- Calculate shooting intensity for sampling locations.R`: Calcualte the cumulaitve number of lead shots fired in a 1km buffer around the sampling location

- `3- Model variation in Pb.R`: Use a linear mixed model to explain varion in faecal lead of Barnacle geese *Branta leucopsis* and Greenalnd White-frotned Geese *Anser albifrons flavirostris* on Islay

- `4- Simulate retention times.R`: Adjust the prevelance of lead ingestion for retention times which are shorter than the entire wintering period. Accounts for error in retention time using by drawing 1000 random retention times from a poisson distribution

- `5- Simulate duplicate sampling.R`: Run a simulation to try and determine the number of duplicate samples collected in our faecal sampling

## Data description
- `Data/Field centroids.csv`: Centroid of each agriculatural field on Islay

- `Data/GBG sampling locations.csv`: The field code for each Barnacle Goose faecal sample

- `Data/GWfG sampling locations.csv`: The field code for each White-fronted Goose faecal sample

- `Data/Lead lab analysis.csv`: The faecal lead and aluminium levels from all samples 

- `Data/Shooting logs cleaned.csv`: Cleaned shootng logs with the location of each shooting event on Islay since 2005

- `Outputs/LeadData_with_FieldCodes.csv`: Data used in script 2. Lead faecal levels labelled with the field codes and locaiton

- `Outputs/LeadData_with_ShootingInt.csv`: Date used in script 3. Contains faecal lead amounts and all predictor variables, including AL and shooting intenisty around sampling locaiton

- `SpatialData/88090_ISLAY_GMS_FIELD_BOUNDARY`: Shapefile of every agricualtural field on Islay

- `SpatialData/RAMSAR_SCOTLAND_ESRI` Shapefile of all ramsar designated in Scotland

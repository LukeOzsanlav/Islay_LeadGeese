# Code and Data for 'Incidence of lead ingestion in managed goose populations and the efficacy of imposed restrictions on the use of lead shot' 🦆 🔫

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

*Major Revisions* received: 13/02/2023


## Code description
- `1- Add field codes to lead data.R`: Combine the the faecal lead measurements with the sampling locations

- `2- Calculate shooting intensity for sampling locations.R`: Calculate the cumulative number of lead shots fired in a 1km buffer around the sampling location

- `3- Model variation in Pb.R`: Use a linear mixed model to explain varion in faecal lead of Barnacle geese *Branta leucopsis* and Greenland White-frotned Geese *Anser albifrons flavirostris* on Islay

- `4- Simulate retention times.R`: Assess the winter long exposure of geese to lead shot ingestion by accounting for variability in shot retention time in the gizzard.

- `5- Simulate Pb Al soil ratios.R`: Validate interpretation of faecal sample analysis by determining variation of Al:Pb in soil samples from suitable sites across Scotland. 

- `6- Plots of shooting intensity over time.R`: Create figures 1 & 3 in the manuscript.

- `Additonal- Simulate duplicate sampling.R`: Run a simulation to determine the number of duplicate samples collected during our faecal sampling protocol

## Data description
- `Data/Field centroids.csv`: Centroid of each agricultural field on Islay

- `Data/GBG sampling locations.csv`: The field code for each Barnacle Goose faecal sample

- `Data/GWfG sampling locations.csv`: The field code for each White-fronted Goose faecal sample

- `Data/Lead lab analysis.csv`: The faecal lead and aluminium levels from all samples 

- `Data/Shooting logs cleaned.csv`: Cleaned shooting logs with the location of each shooting event on Islay since 2005

- `Outputs/LeadData_with_FieldCodes.csv`: Data used in script 2. Lead faecal levels labelled with the field codes and location

- `Outputs/LeadData_with_ShootingInt.csv`: Date used in script 3. Contains faecal lead amounts and all predictor variables, including AL and shooting intensity around sampling location

- `SpatialData/88090_ISLAY_GMS_FIELD_BOUNDARY`: Shapefile of every agricultural field on Islay

- `SpatialData/RAMSAR_SCOTLAND_ESRI` Shapefile of all ramsar designated in Scotland

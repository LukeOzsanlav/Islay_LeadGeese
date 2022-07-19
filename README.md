# Code and Data for 'Incidence of lead ingestion in managed goose populations and the efficacy of imposed restrictions on the use of lead shot'
This repository holds the code for a publication that is in review at *Ibis* entitled; 'Incidence of lead ingestion in managed goose populations and the efficacy of imposed restrictions on the use of lead shot'

![](https://img.shields.io/github/directory-file-count/LukeOzsanlav/Ibis_2022_lead)

_Authors_:

- Aimee Mcintosh 
- Luke Ozsanlav-Harris <a itemprop="sameAs" content="https://orcid.org/0000-0003-3889-6722" href="https://orcid.org/0000-0003-3889-6722" target="orcid.widget" rel="me noopener noreferrer" style="vertical-align:top;"><img src="https://orcid.org/sites/default/files/images/orcid_16x16.png" alt="ORCID iD icon" style="width:1em;margin-right:.5em;"/></a>
- Mark Taggart
- Jessica Shaw
- Geoff Hilton <a itemprop="sameAs" content="https://orcid.org/0000-0001-9062-3030" href="https://orcid.org/0000-0001-9062-3030" target="orcid.widget" rel="me noopener noreferrer" style="vertical-align:top;"><img src="https://orcid.org/sites/default/files/images/orcid_16x16.png" alt="ORCID iD icon" style="width:1em;margin-right:.5em;"/></a>
- Stuart Bearhop <a itemprop="sameAs" content="https://orcid.org/0000-0002-5864-0129" href="https://orcid.org/0000-0002-5864-0129" target="orcid.widget" rel="me noopener noreferrer" style="vertical-align:top;"><img src="https://orcid.org/sites/default/files/images/orcid_16x16.png" alt="ORCID iD icon" style="width:1em;margin-right:.5em;"/></a>


## Manuscript Status
*Reject and reubmit* received: 09/05/2022


## Code description
- `3) Model variation in Pb.R`: Use a linear mixed model to explain varion in faecal lead fro Barnacle geese *Branta leucopsis* and Greenalnd White-frotned Geese *Anser albifrons flavirostris* on Islay
- `4) Adjust lead prevelance for retention time`: adjust the prevelance of lead ingestion for retention time which are shorter than the entire wintering period. Accounts for error in retention time using by drawing retention times 1000 times from a poisson distribution

## Data description
- `Lead_with_ShootingIntensity.csv`: Date used in script 3). Contains faecal lead amounts and all predictor variables, including AL and shooting intenisty around sampling locaiton

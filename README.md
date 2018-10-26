# Pacific Salmon Survival

Jacobs-Peter-STAT6570-final-project.pdf: Final report describing analysis and results.

Below is a quick description of the data source, and then some additional information on other files included, and how you can run them.

pinkdata.csv (1207 rows): 

  The raw data. Each row is information for a yearly cycle of breeding for a given salmon population
  - Species: Species of the salmon population
  - Stock: Name of the salmon population
  - Region: The region in which the salmon population breeds
  - Latitude: Latitude for breeding location
  - Longitude: Longitude for breeding location
  - BY: Year for which this row represents information about the salmon population's breeding behavior
  - S: Number of Adults observed at the spawning site in the BY
  - R: Number of offspring from the spawning site in BY
    

IMPORTANT NOTICE #1
*******************
All code is in written in R. Before attempting to run the files described below, ensure that the following software is installed:
- JAGS
- rJAGS (R package)
- tidyverse (R package)
- stringr (R package)
- rjags (R package)
- ggplot2 (R package)
- gridExtra (R package
- ggmap [Only nescessary if you want to run EDA.R] (R package)

*******************

IMPORTANT NOTICE #2
*******************
After downloading the repository, any script included in this project can be run by setting the working directory to the location of the script. If something goes wrong [which it should not], please CLEAR your global environment and then run the script again.
*******************

IMPORTANT NOTICE #3
*******************
If you are in a pinch and want to quickly run the final model, simply set the working directory to the Models folder, and run mod3.R
*******************

IMPORTANT NOTICE #4
*******************
Please be aware that model 2 will take a while to run (More than 5 minutes). All other scripts run very quickly
*******************

The rest of this README describes the files/folders included in the zip

dataPrep.R: Takes the raw data set (pinkdata.csv), and adds some variables that are important for model building. This script saves a new dataset (auxPink.rds), that is used during model building.

EDA.R: Code for visualizations produced in the exploratory data analysis

JAGS (Folder): Contains the Jags code for models 1, 2, and 3

Models (Folder): Contains the r code for the 3 models. For models 1,2 and 3, the JAGS models are fit, and the trace plots for displayed. ONLY for model 3, (the final model), there exists additional analysis of the posterior samples included at the end of the file

## Citations and Credits

* Brigitte Dorner, Randall M. Peterman, and Zhenming Su.  Evaluation of performance ofalternative management models of pacific salmon (oncorhynchus spp.) in the presence ofclimatic change and outcome uncertainty using monte carlo simulations.Canadian Journal ofFisheries and Aquatic Sciences, 66(12):2199?2221, 2009.

* Thank you to Dr. Chkrebtii for giving permission to show this work to others 
    

    

    








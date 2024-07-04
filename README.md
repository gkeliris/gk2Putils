# gk2Putils
---
For formatting a markdown document check: (https://commonmark.org/help/)

---
## Setting up
### Installation
- fork the [gk2Putils](https://github.com/gkeliris/gk2Putils) repository
- [clone](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository) your **own** forked repository
- create a new branch to work with
    > git branch BRANCHNAME
- activate the branch by using checkout
    > git checkout BRANCHNAME
- make changes, add, and commit them to your branch 
    > git commit -a -m "TYPE COMMIT MESSAGE"
- push the branch to your own remote fork
    > git push --set-upstream origin BRANCHNAME
### Set the paths
If something changed on the data location then set the correct paths
- set the data path in **utils/setDataPath.m**
- set the session path in **utils/setSesPath.m**
- set the export path in **utils/setExportPath.m**

## Get started by selecting which dataset(s) to analyze:

1) make sure that the appropriate .csv file exists in the top dataPath folder (else create/update it)
2) run the gk_datasetQuery command to select one or more datasets. For example:
    > ds = gk_datasetQuery('week','w11','expID','contrast','mouseID','M19')
3) Perform analysis using the package.
    ### Example pipeline
- Get the tuned ROIs based on a critical p-value (ANOVA between responses to different conditions)
    > xpr = gk_getTunedROIs(ds,'F',2,2,0.001)

- Plot the continuous timecourse relative to stimulus
    > cell = xpr.tunedGlobalIDs(1)  
    > gk_plotStimNeuron(ds, cell)  

- Export tuned neurons in a PPT file 
    > gk_exp_plotTuning(ds,'F',2,2,'export',0.00001)  
    + The upper row of plots is using: **gk_plot_trials.m**  
    + The lower row of plots is using: **gk_plot_tuning.m**  <-- *Needs to be adjusted*

- Calculate the contrast response functions (single vs double NakaRushton)
    > CRF = gk_get_CRFs(xpr, cell)

- Fit a NakaRuston function
    > fit = gk_fitNakaRushton(CRF,1)

- Plot the CRF with fitted NakaRushton
    > gk_plotNakaRushton(fit)
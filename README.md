# gk2Putils
---
For formatting a markdown document check: (https://commonmark.org/help/)

---
## Setting up
- fork the [gk2Putils](https://github.com/gkeliris/gk2Putils) repository
- [clone](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository) your **own** forked repository
- create a new branch to work with
    > git branch BRANCHNAME
- activate the branch by using checkout
    > git checkout BRANCHNAME
- make changes, add, and commit them to your branch
    > git add .  
    > git commit -m "TYPE COMMIT MESSAGE"
- push the branch to your own remote fork
    > git push --set-upstream origin BRANCHNAME

## Get started by selecting which dataset(s) to analyze:
For this:
1) prepare/update a .csv file that contains information such as path of the raw datasets
2) 


## Functions for syncronization of stimulus to imaging
gk_readH5  
gk_getTimeStamps  
gk_getTimeStamps2P  
gk_getStimTimes  
gk_getStimTimesLRN  
gk_getStimFrameTimes  
gk_check_stimTiming  
gk_get_stimArtifact  

gk_plot_all_signals  




## Utilities
msubplot  
plotshaded  
shadedErrorBar  

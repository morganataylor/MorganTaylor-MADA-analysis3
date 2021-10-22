# Overview

This repository reflects the materials and methods used in the exercise assigned for Module 8 (Fitting Basic Statistical Models) in [MADA 2021](https://andreashandel.github.io/MADAcourse/Assessment_Basic_Models.html). 

# Pre-requisites

This repository is created from a template for a data analysis project using R, Rmarkdown (and variants, e.g. bookdown), Github and a reference manager that can handle bibtex. It is also assumed that you have a word processor installed (e.g. MS Word or [LibreOffice](https://www.libreoffice.org/)). You need that software stack to make use of this repository.

# Repository structure

* All data are in the subfolders inside the `data` folder.
* All code is in the `code` folder or subfolders.
* All results (figures, tables, computed values) are in `results` folder or subfolders.
* See the various `readme.md` files in those folders for some more information.

# Repository content 

* The original data is in the `raw_data` folder. 
* The `processing_code` folder contains an R script which load the raw data, perform a bit of cleaning, and save the result in the `processed_data` folder.
* The `analysis_code` folder contains three different codes to analyze the data. See the `readme.md` in the folder for more information.

# Data information

* The raw data for this exercise comes from the following citation:
McKay, Brian et al. (2020), Virulence-mediated infectiousness and activity trade-offs and their impact on transmission potential of patients infected with influenza, Dryad, Dataset, https://doi.org/10.5061/dryad.51c59zw4v.
* The data dictionary is included in this repository as well.
* This analysis focuses on two outcomes: body temperature (continuous) and nausea (categorical).



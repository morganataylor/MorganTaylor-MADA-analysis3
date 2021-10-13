# Overview

This repository reflects the materials and methods used in the exercise assigned for Module 8 (Fitting Basic Statistical Models) in [MADA 2021](https://andreashandel.github.io/MADAcourse/Assessment_Basic_Models.html). 

# Pre-requisites

This repository is created from a template for a data analysis project using R, Rmarkdown (and variants, e.g. bookdown), Github and a reference manager that can handle bibtex. It is also assumed that you have a word processor installed (e.g. MS Word or [LibreOffice](https://www.libreoffice.org/)). You need that software stack to make use of this repository and template.

# Repository structure

* All data goes into the subfolders inside the `data` folder.
* All code goes into the `code` folder or subfolders.
* All results (figures, tables, computed values) go into `results` folder or subfolders.
* All products (manuscripts, supplement, presentation slides, web apps, etc.) go into `products` subfolders.
* See the various `readme.md` files in those folders for some more information.

# Repository content 

* The original data is in the `raw_data` folder. 
* The `processing_code` folder contains R scripts which load the raw data, perform a bit of cleaning, and save the result in the `processed_data` folder.
* The `analysis_code` folder contains an R script which loads the processed data, fits a simple model, and produces a figure and some numeric output, which is saved in the `results` folder. It also contains an R script that conducts a brief exporatory data analysis.
* The remaining content is copied from the original templates as examples. Details as follows:
* The `products` folder contains an example `bibtex` and CSL style file for references. Those files are used by the example manuscript, poster and slides.
* The `poster` and `slides` folders contain very basic examples of posters and slides made with R Markdown. Note that especially for slides, there are many different formats. You might find a different format more suitable. Check the R Markdown documentation. 
* The  `manuscript` folder contains a template for a report written in Rmarkdown (bookdown, to be precise).

# Data information

* The raw data for this exercise comes from the following citation:
McKay, Brian et al. (2020), Virulence-mediated infectiousness and activity trade-offs and their impact on transmission potential of patients infected with influenza, Dryad, Dataset, https://doi.org/10.5061/dryad.51c59zw4v.
* The data dictionary is included in this repository as well.
* This analysis focuses on two outcomes: body temperature (continuous) and nausea (categorical).



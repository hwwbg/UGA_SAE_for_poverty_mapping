# Small Area Estimation Training for Poverty Mapping – Uganda
Entebbe, Uganda
Nov. 10 to Nov. 14, 2025

This repository accompanies a three-day **Small Area Estimation (SAE) Training** delivered to the Uganda Bureau of Statistics (UBOS). The training develops the analytical capacity needed to produce statistically robust district- and subcounty-level poverty and inequality estimates using modern SAE techniques.

The program is structured around the full SAE workflow—from data preparation to model estimation, diagnostics, and map production—using Stata and following the **World Bank (2022) Guidelines for Poverty Mapping**.

---

## 🎯 Training Objectives

Participants will acquire the skills to:

- **Understand core SAE methodologies**, including unit-level models (ELL, EB and CensusEB) and area-level models (Fay–Herriot), with emphasis on variance decomposition, transformation decisions, and uncertainty quantification.
- **Prepare, harmonize, and link** household survey data with census microdata, including construction of welfare aggregates, alignment of covariates, and validation of shared structures.
- **Estimate and evaluate** small-area poverty and inequality indicators using Stata-based workflows (`sae`, `fhsae`), including MSE estimation through parametric bootstrap and Monte Carlo approaches.
- **Generate, visualize, and interpret poverty maps**, explicitly incorporating uncertainty measures (e.g., MSE, RMSE, CV, confidence intervals).
- **Document methodological choices**, assess model assumptions, and communicate results consistent with statistical standards and World Bank guidelines.

---

## ✅ Expected Outcomes

By the end of the training, participants will be able to:

- Implement and validate both unit-level and area-level SAE models.
- Produce reliable district- and subcounty-level poverty estimates with defensible uncertainty metrics.
- Build reproducible workflows for SAE-based poverty mapping in Stata.
- Integrate SAE outputs into Uganda’s poverty monitoring systems and policy dialogue.

---

## STATA pakage installation
### gihub
````
net install github, from("https://haghish.github.io/github/")
````
### SAE
````
github install pcorralrodas/SAE-Stata-Package
````
### FHSAE
````
github install https://github.com/jpazvd/fhsae
````
## Contract
Haoyu Wu: <hwu4@worldbank.org>\
Kristina Noelle Vaughan: <kvaughan@worldbank.org>


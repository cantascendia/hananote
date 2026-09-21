---
name: pk-reference
description: Pharmacokinetics reference for estradiol simulator implementation
---

# PK Simulator Reference

## Key References
- estrannaise.js: https://github.com/WHSAH/estrannaise.js (3-compartment model + MCMC)
- TFS Injectable E2 Simulator: https://transfemscience.org/misc/injectable-e2-simulator/
- TFS Meta-Analysis: https://transfemscience.org/articles/injectable-e2-meta-analysis/

## Model Architecture (from estrannaise.js)
- Three-compartment pharmacokinetic model with decaying baseline
- MAP estimation + MCMC for parameter inference
- Baseline model: constant before administration → decaying exponential after
- Combined with 3-compartment PK model for full estradiol curve

## Supported Ester Types & Approximate Half-Lives
- Estradiol Valerate (EV) IM: absorption t½ ~1.5-2 days, elimination t½ ~3-5 days
- Estradiol Cypionate (EC) IM: elimination t½ ~8-10 days  
- Estradiol Enanthate (EEn) IM: sparse data, from Perlutal studies
- Estradiol Undecylate (EUn) IM: very sparse data (Vermeulen 1975, Geppert 1975)
- Oral estradiol: ~5% bioavailability due to first-pass, rapid absorption
- Sublingual: higher peak, shorter duration than oral
- Transdermal patch: zero-order absorption approximation
- Transdermal gel: similar to patch but higher absorption variability

## Implementation Notes for Dart Port
- Pure Dart computation, no external dependencies
- Run in Isolate for UI responsiveness
- Support steady-state (repeated doses) and arbitrary regimens
- Must include uncertainty visualization (confidence band)
- Prominent disclaimer: "Simulation only. Individual variation ±50%+. Use actual blood tests."

## WPATH/Endocrine Society Target Ranges
- E2: 100-200 pg/mL (some guidelines up to 300)
- Total T: <50 ng/dL
- Display as colored bands on simulation chart

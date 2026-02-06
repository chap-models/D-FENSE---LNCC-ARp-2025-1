# LNCC-ARp-2025-1

CHAP-compatible version of the LNCC AR(p) dengue forecast model, originally developed by **Americo Cunha Jr** (LNCC / UERJ) as part of the D-FENSE team for the [2nd Infodengue-Mosqlimate Dengue Challenge (IMDC) 2025](https://github.com/Mosqlimate-project/2nd_IMDC_sprint_results).

## Model Methodology

The model forecasts weekly dengue case counts using an autoregressive process of order *p* (default p=92, roughly two years of weekly data). It uses no climate covariates — predictions are based purely on disease case history.

**Training:**
1. Log2-transform the case counts (zeros replaced with 0.1)
2. Fit an AR(p) model to the zero-mean log2 signal using the modified covariance method
3. Estimate the prediction error standard deviation

**Prediction:**
1. Initialize the AR filter from the most recent historic data
2. Drive the filter forward with random noise (Monte Carlo simulation) to generate multiple possible future trajectories
3. Transform back from log2 space to case counts

## CHAP Compatibility

The original model was written in MATLAB as a single batch script processing per-state CSV files. To make it CHAP-compatible:

- **Split into train/predict entry points** as required by the CHAP model contract
- **Ported from MATLAB to GNU Octave** (runs in Docker via `gnuoctave/octave:9.2.0`, no license needed)
- **Adapted I/O** to read/write CHAP's standard CSV format (multi-location, `sample_0`..`sample_N` output columns)
- **SSA smoothing removed** since CHAP computes its own statistics from the raw sample trajectories
- **Hyperparameters exposed** as `user_options` (AR order `p` and number of MC samples `n_samples`)

The core AR model logic (coefficient estimation, Monte Carlo simulation, log2 transform) is preserved from the original.

## Repository Structure

```
MLproject              CHAP interface (entry points, user options, Docker image)
train.m                Training: fits AR(p) model per location
predict.m              Prediction: Monte Carlo forecast per location
armcov_octave.m        Modified covariance AR estimation (replaces MATLAB's armcov)
fillmissing_octave.m   Forward/backward fill for missing values
read_chap_csv.m        Read CHAP-format CSV
write_chap_csv.m       Write CHAP-format prediction CSV
read_model_config.m    Parse user options from CHAP config
isolated_run.m         Local testing helper
input/                 Sample data for testing
```

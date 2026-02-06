# LNCC-ARp-2025-1 (CHAP-Compatible)

CHAP-compatible version of the LNCC AR(p) dengue forecast model, originally developed for the 2nd Infodengue-Mosqlimate Dengue Challenge (IMDC) 2025.

## Original Model

- **Original source**: [Mosqlimate 2nd IMDC Sprint Results](https://github.com/Mosqlimate-project/2nd_IMDC_sprint_results)
- **Team**: D-FENSE
- **Author**: Americo Cunha Jr (LNCC / UERJ)
- **Language**: MATLAB
- **Method**: High-order AR(p) autoregressive model fitted to log2-transformed weekly dengue case counts using the modified covariance method, with Monte Carlo simulation for probabilistic forecasting. Uses no climate covariates -- predictions are based purely on disease case history.

## CHAP Adaptation

Runs on **GNU Octave 9.2.0** inside Docker (no MATLAB license required).

### Changes from Original

| # | Change | Why | Impact |
|---|--------|-----|--------|
| 1 | Split into `train.m` + `predict_chap.m` | CHAP requires separate train/predict entry points | None -- same logic |
| 2 | `armcov` replaced by `armcov_octave.m` | Octave has no `armcov`; implements same modified covariance algorithm | None -- identical math |
| 3 | `filter2(a,sig,'same')` replaced by `conv(sig(:)',a(:)','same')(:)` | Octave's `filter2` is 2D-only | None -- equivalent centered filtering |
| 4 | `readtable`/`writetable` replaced by custom CSV I/O | Octave compatibility | None |
| 5 | Single multi-location CSV instead of per-state files | CHAP data format | None -- data is identical |
| 6 | SSA smoothing removed | CHAP computes its own statistics from raw samples | Outputs are unsmoothed MC trajectories |
| 7 | Output: percentile bounds replaced by `sample_0`..`sample_N` columns | CHAP output contract | Different format, same underlying model |
| 8 | MC count: 10000 default reduced to 100 (configurable) | File size; CHAP convention | Configurable via `user_options` |
| 9 | Hardcoded EW indices removed | Dynamic forecast horizon from future_data CSV | More flexible |
| 10 | Plotting removed | CHAP handles visualization | None |
| 11 | Initial conditions recomputed at predict time from historic_data | More flexible; uses latest available data | Better than freezing at training time |
| 12 | Missing values handled by forward fill, backward fill, then zero | Original assumed complete data | Handles CHAP datasets with gaps |

### User Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `p` | integer | 92 | AR model order (should be > 52 for weekly seasonality) |
| `n_samples` | integer | 100 | Number of Monte Carlo samples |

## File Structure

| File | Purpose |
|------|---------|
| `MLproject` | CHAP interface definition |
| `train.m` | Training entry point |
| `predict.m` | Prediction entry point (`predict_chap` function) |
| `armcov_octave.m` | Modified covariance AR estimation |
| `read_chap_csv.m` | Read CHAP-format CSV |
| `write_chap_csv.m` | Write predictions CSV |
| `read_model_config.m` | Parse CHAP YAML config |
| `fillmissing_octave.m` | Forward/backward fill for missing values |
| `isolated_run.m` | Local testing helper |

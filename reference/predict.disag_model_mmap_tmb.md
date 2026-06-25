# Predict for Multi-Map Disaggregation Model fit with TMB

Predict for Multi-Map Disaggregation Model fit with TMB

## Usage

``` r
# S3 method for class 'disag_model_mmap_tmb'
predict(object, new_data = NULL, predict_iid = FALSE, N = 100, CI = 0.95, ...)
```

## Arguments

- object:

  A fitted disag_model_mmap_tmb object.

- new_data:

  Optionally, a new SpatRaster (or list of them) for prediction.

- predict_iid:

  Logical. If TRUE, include the polygon iid effect in predictions.

- N:

  Number of Monte Carlo draws for uncertainty estimation.

- CI:

  Credible interval level (default 0.95).

- ...:

  Further arguments.

## Value

An object of class \`disag_prediction_mmap\` (also a list) with: -
\`mean_prediction\`: a list containing time-layered \`SpatRaster\`s
named \`time\_\<time point\>\`: \`prediction\` (response-scale mean
prediction), \`field\` (spatial-field contribution, or \`NULL\` when no
field was fitted), \`iid\` (polygon IID contribution when requested and
supported, otherwise \`NULL\`), and \`covariates\` (covariate-only
linear predictor). - \`uncertainty_prediction\`: a list containing
\`realisations\`, a list of one \`SpatRaster\` stack per time point with
\`N\` Monte Carlo draws, and \`predictions_ci\`, a list with
time-layered \`SpatRaster\`s \`lower\` and \`upper\` containing
cell-wise credible bounds at level \`CI\`.

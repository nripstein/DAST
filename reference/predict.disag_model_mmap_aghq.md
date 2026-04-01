# Predict mean & credible intervals for AGHQ-fitted disaggregation model

Given a 'disag_model_mmap_aghq' object, draws from the AGHQ marginal,
builds per-cell posterior samples, and returns means and
credible-interval rasters.

## Usage

``` r
# S3 method for class 'disag_model_mmap_aghq'
predict(
  object,
  new_data = NULL,
  predict_iid = FALSE,
  N = 1000,
  CI = 0.95,
  verbose = FALSE,
  ...
)
```

## Arguments

- object:

  A 'disag_model_mmap_aghq' fit (from 'disag_model_mmap_aghq()').

- new_data:

  Optional covariates for prediction (see helper).

- predict_iid:

  Currently not implemented; must be FALSE.

- N:

  Number of marginal draws to sample (default 1000).

- CI:

  Credible-interval level in (0,1) (default 0.95).

- verbose:

  If TRUE, prints runtime in minutes.

- ...:

  Unused.

## Value

An object of class 'disag_prediction_mmap_aghq' containing: -
'mean_prediction': list of SpatRasters ('prediction', 'field',
'covariates'). - 'uncertainty_prediction': list with
'predictions_ci\$lower' & 'upper'.

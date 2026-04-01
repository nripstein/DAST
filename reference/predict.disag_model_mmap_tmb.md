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

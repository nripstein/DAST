# Predict mean for multi-map disaggregation (TMB)

Given a fitted TMB model object and optional new covariate data, compute
the mean‐only prediction (no uncertainty) for one raster.

## Usage

``` r
predict_model_mmap(
  model_output,
  new_data = NULL,
  predict_iid = FALSE,
  newdata = NULL
)
```

## Arguments

- model_output:

  A 'disag_model_mmap_tmb' model fit.

- new_data:

  Optional SpatRaster (or list) of new covariates.

- predict_iid:

  Logical; if TRUE, include the IID polygon effect.

## Value

A list with components: - prediction: SpatRaster of the mean prediction
on the response scale. - field: SpatRaster of the spatial field
component (or NULL). - iid: SpatRaster of the IID effect (or NULL). -
covariates: SpatRaster of the linear predictor from covariates only.

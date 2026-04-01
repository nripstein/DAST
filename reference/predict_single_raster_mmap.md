# Predict on a single raster for multi-map disaggregation (TMB)

Apply the linear predictor, add spatial field and IID components, then
transform via the link to return a SpatRaster prediction.

## Usage

``` r
predict_single_raster_mmap(model_parameters, objects, link_function)
```

## Arguments

- model_parameters:

  Named list of parameter vectors (split by name).

- objects:

  List from 'setup_objects_mmap' containing data and projectors.

- link_function:

  Character; one of 'identity', 'log', or 'logit'.

## Value

A list with components: - prediction: SpatRaster on the response
scale. - field: SpatRaster of field contribution (or NULL). - iid:
SpatRaster of IID contribution (or NULL). - covariates: SpatRaster of
the covariate linear predictor.

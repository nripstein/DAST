# Prediction guard for MCMC-fitted multi-map disaggregation models

Prediction is intentionally not implemented for MCMC fits. This method
provides a clear error directing users to the parameter-estimation
outputs.

## Usage

``` r
# S3 method for class 'disag_model_mmap_mcmc'
predict(object, ...)
```

## Arguments

- object:

  A fitted 'disag_model_mmap_mcmc' object.

- ...:

  Unused.

## Value

This function always errors.

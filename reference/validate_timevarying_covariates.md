# Validate covariate layer consistency across time

Validate covariate layer consistency across time

## Usage

``` r
validate_timevarying_covariates(
  covariate_rasters_list,
  time_varying_betas,
  where = "make_model_object_mmap()"
)
```

## Arguments

- covariate_rasters_list:

  list or NULL; each element is a multilayer raster/brick/spatRaster

- time_varying_betas:

  logical; when TRUE, enforce identical layer names and order across
  time

- where:

  character; caller label for clearer error messages

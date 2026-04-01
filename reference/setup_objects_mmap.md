# Prepare prediction objects for multi-map disaggregation (TMB)

Constructs the covariate rasters, field projector, and IID shapefile
objects needed by the single‐raster prediction routines.

## Usage

``` r
setup_objects_mmap(
  model_output,
  new_data = NULL,
  predict_iid = FALSE,
  time_index = NULL,
  use_training = FALSE
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

A list with elements: - covariates: SpatRaster of covariate layers. -
field_objects: list with 'coords' matrix and 'Amatrix' projector (or
NULL). - iid_objects: list with 'shapefile' and 'template' (or NULL).

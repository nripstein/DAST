# Construct design and projection matrices for prediction

Internal helper for 'predict.disag_model_mmap_aghq()'. Builds per-time
design matrices (with intercept), the SPDE projection matrix, and the
coordinate table for raster reconstruction.

## Usage

``` r
get_predict_matrices(
  data,
  new_data = NULL,
  expected_cov_names = NULL,
  time_varying_betas = FALSE
)
```

## Arguments

- data:

  A 'disag_data_mmap' object (from 'prepare_data_mmap()').

- new_data:

  Optional new covariate data: - a single 'SpatRaster' (recycled across
  all times), or - a list of length 'length(data\$time_points)' of
  'SpatRaster' objects.

- expected_cov_names:

  Character vector of training covariate names (order matters). If
  length 0, predictions are intercept-only regardless of provided
  rasters.

- time_varying_betas:

  Logical; used for clearer error messages when aligning layers.

## Value

A list with elements: - 'X_list': list of design matrices (each n_cells
× p, with "Intercept"). - 'A': SPDE projection matrix (n_cells ×
n_knots). - 'coords': data.frame of x/y coordinates for each cell.

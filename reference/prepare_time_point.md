# Process a single time point for prepare_data_mmap()

Internal helper called by 'prepare_data_mmap()'. For time index 't',
it: 1. Validates the polygon sf and rasters. 2. Handles NAs in the
response. 3. Builds or validates the aggregation raster. 4. Extracts and
merges covariate + aggregation pixel data. 5. Computes coordinates for
mesh fitting and for prediction. 6. Computes the start/end pixel indices
per polygon.

## Usage

``` r
prepare_time_point(
  t,
  poly_sf,
  cov_rasters,
  agg_raster,
  id_var,
  response_var,
  sample_size_var,
  na_action,
  categorical_schema
)
```

## Arguments

- t:

  Integer time-point index (used for messaging).

- poly_sf:

  An 'sf' polygon object for time 't'.

- cov_rasters:

  A 'SpatRaster' of covariates for time 't', or NULL.

- agg_raster:

  A 'SpatRaster' of aggregation weights for time 't', or NULL.

- id_var:

  Name of the polygon ID column.

- response_var:

  Name of the response column.

- sample_size_var:

  Name of the sample-size column, or NULL.

- na_action:

  Logical; if TRUE, drop/impute NAs instead of erroring.

- categorical_schema:

  Internal schema from 'build_categorical_schema()'.

## Value

A list with elements: - 'poly_data': data.frame of polygon-level info
(incl. 'poly_local_id' & 'time'). - 'cov_data': data.frame of
pixel-level covariates + 'poly_local_id' + 'time' + 'cell'. -
'agg_pixels': numeric vector of aggregation weights per pixel. -
'coords_fit': coords for mesh-building (only used pixels). -
'coords_pred': coords for full-extent prediction. - 'start_end_index':
integer matrix of 0-indexed start/end for each polygon.

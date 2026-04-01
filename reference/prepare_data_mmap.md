# Prepare multi-map disaggregation data

Given lists of polygon sf's, covariate rasters, and aggregation rasters,
combines them into a single 'disag_data_mmap' object ready for model
fitting.

## Usage

``` r
prepare_data_mmap(
  polygon_shapefile_list,
  covariate_rasters_list = NULL,
  aggregation_rasters_list = NULL,
  id_var = "area_id",
  response_var = "response",
  categorical_covariate_baselines = NULL,
  sample_size_var = NULL,
  mesh_args = NULL,
  na_action = FALSE,
  make_mesh = TRUE,
  verbose = FALSE
)
```

## Arguments

- polygon_shapefile_list:

  List of 'sf' polygon objects, one per time point.

- covariate_rasters_list:

  Optional list of 'SpatRaster' stacks; may be NULL.

- aggregation_rasters_list:

  Optional list of 'SpatRaster'; if NULL, uses uniform counts.

- id_var:

  Name of the polygon ID column in each 'sf'.

- response_var:

  Name of the response column.

- categorical_covariate_baselines:

  Named list; names are categorical raster layers and values are
  baseline levels to drop (either level labels or numeric codes).

- sample_size_var:

  Name of the sample-size column (for binomial models); may be NULL.

- mesh_args:

  Passed to 'build_mesh()'.

- na_action:

  Logical; if TRUE, drop or impute NAs instead of stopping.

- make_mesh:

  Logical; if TRUE, build the spatial mesh over all polygons.

- verbose:

  Logical; if TRUE, print timing info.

## Value

An object of class 'disag_data_mmap' with components including -
'polygon_data', 'covariate_data', 'aggregation_pixels', … -
'categorical_covariate_baselines' (normalized baseline labels) -
'categorical_covariate_schema' (internal encoding schema used for
fit/predict consistency)

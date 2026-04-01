# Detect if a raster layer is categorical

Determines if a raster layer should be treated as categorical based on
multiple criteria: 1. Explicit definition in
categorical_covariate_baselines 2. Presence of defined levels in the
raster 3. Small number of unique values

## Usage

``` r
is_categorical_layer(
  raster_layer,
  layer_name,
  categorical_baselines = NULL,
  max_categories = 10
)
```

## Arguments

- raster_layer:

  A SpatRaster layer to check

- layer_name:

  The name of the layer

- categorical_baselines:

  Named list of categorical baselines from disag_data_mmap

- max_categories:

  Maximum number of unique values to consider categorical (default = 10)

## Value

Logical indicating if the layer should be treated as categorical

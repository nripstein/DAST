# Plot a single covariate raster

Renders one layer of the covariate raster stack, preserving the raster's
CRS, and coloring by value with a Viridis scale. Automatically detects
and handles categorical covariates with appropriate discrete color
scales.

## Usage

``` r
plot_covariate_raster(disag_data, covariate = 1, time = 1, max_categories = 10)
```

## Arguments

- disag_data:

  A 'disag_data_mmap' object.

- covariate:

  Integer index or name of the covariate layer.

- time:

  Integer time-slice (default = 1).

- max_categories:

  Maximum number of unique values to consider categorical (default =
  10).

## Value

A ggplot2 object.

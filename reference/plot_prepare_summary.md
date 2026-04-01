# Visual summary plot of prepared data

Combines polygons, aggregation raster, mesh, and (if present) a
covariate into a 2×2 grid.

## Usage

``` r
plot_prepare_summary(disag_data, covariate = 1, time = 1, max_categories = 10)
```

## Arguments

- disag_data:

  A \`disag_data_mmap\` object.

- covariate:

  Integer or name of the covariate to display (default = 1).

- time:

  Integer time‐slice (default = 1).

- max_categories:

  Maximum number of unique values to consider categorical (default =
  10).

## Value

A ggdraw object (from cowplot) which can be printed.

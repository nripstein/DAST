# Summary function for disag_data_mmap objects

Prints counts of time points, polygons, pixels, per-time
largest/smallest polygon sizes, number of covariates and their summaries
and a mesh summary

## Usage

``` r
# S3 method for class 'disag_data_mmap'
summary(object, ...)
```

## Arguments

- object:

  A 'disag_data_mmap' object (from 'prepare_data_mmap()').

- ...:

  Additional arguments (unused).

## Value

Invisibly returns a list with components: - 'n_times', 'n_polygons',
'n_pixels' - 'per_time': data.frame with 'time', 'min_pixels',
'max_pixels' - 'n_covariates', 'covariate_summaries' (named list of
summaries) - 'mesh_nodes', 'mesh_triangles'

# Validate inputs to prepare_data_mmap()

Check that all list-arguments are the same length (where required), that
required arguments have the correct type, and that 'id_var',
'response_var', and 'sample_size_var' are valid strings.

## Usage

``` r
validate_prepare_data_inputs(
  polygon_shapefile_list,
  covariate_rasters_list,
  aggregation_rasters_list,
  id_var,
  response_var,
  sample_size_var,
  make_mesh,
  categorical_covariate_baselines = NULL
)
```

## Arguments

- polygon_shapefile_list:

  A list of 'sf' objects.

- covariate_rasters_list:

  NULL or a list of 'SpatRaster' objects.

- aggregation_rasters_list:

  NULL or a list of 'SpatRaster' objects.

- id_var:

  Character of length 1: name of polygon ID column.

- response_var:

  Character of length 1: name of response column.

- sample_size_var:

  NULL or character of length 1: sample-size column.

- make_mesh:

  Logical flag indicating whether to build a mesh.

- categorical_covariate_baselines:

  passed from prepare_data_mmap

## Value

Invisibly 'TRUE' if all checks pass; otherwise stops with an error.

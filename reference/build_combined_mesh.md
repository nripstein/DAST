# (Internal) Build combined mesh from a list of sf polygons

Just in case some maps have additional polygons outside the first extent

## Usage

``` r
build_combined_mesh(polygon_list, mesh_args, make_mesh)
```

## Arguments

- polygon_list:

  List of 'sf' objects (same CRS).

- mesh_args:

  Passed to 'build_mesh()'.

## Value

An 'inla.mesh' object or 'NULL' if 'make_mesh = FALSE'.

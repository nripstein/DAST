# Plot the SPDE mesh with custom outer/inner boundaries

Plot the SPDE mesh with custom outer/inner boundaries

## Usage

``` r
plot_mesh(
  disag_data,
  edge_col = "grey70",
  edge_size = 0.2,
  outer_col = "black",
  outer_size = 1,
  inner_col = "blue",
  inner_size = 1,
  node_col = "black",
  node_size = 0.5
)
```

## Arguments

- disag_data:

  A 'disag_data_mmap' object.

- edge_col:

  Colour for internal mesh edges (default = "grey70").

- edge_size:

  Line width for those edges (default = 0.2).

- outer_col:

  Colour for the outer perimeter (default = "black").

- outer_size:

  Line width for the outer perimeter (default = 1).

- inner_col:

  Colour for any inner perimeter (default = "blue").

- inner_size:

  Line width for inner perimeter (default = 1).

- node_col:

  Colour for mesh nodes (default = "black").

- node_size:

  Size for mesh nodes (default = 0.5).

## Value

A ggplot2 object.

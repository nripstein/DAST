# Plot polygon response data

Draws the prepared polygons colored by the response variable, with an
optional title.

## Usage

``` r
plot_polygons(disag_data, time = 1, show_title = TRUE)
```

## Arguments

- disag_data:

  A 'disag_data_mmap' object.

- time:

  Integer index of time-slice to plot (default = 1).

- show_title:

  Logical; if TRUE (default), add a title "Response at time X".

## Value

A ggplot2 object.

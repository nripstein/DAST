# Get Default Prior Values for Disaggregation Model

Calculates the default Penalized Complexity (PC) prior parameters and
Gaussian priors that will be used by
[`disag_model_mmap()`](http://noahripstein.com/DAST/reference/disag_model_mmap.md)
if the user does not provide overrides.

## Usage

``` r
get_priors(data)
```

## Arguments

- data:

  A `disag_data_mmap` object (output from `prepare_data_mmap`).

## Value

A named list of prior specifications.

## Details

The default priors are dynamic and depend on the input data:

- **Range (Rho):** The lower bound `prior_rho_min` is set to 1/3 of the
  diagonal length of the study area's bounding box.

- **Spatial SD (Sigma):** The upper bound `prior_sigma_max` is set to
  the coefficient of variation of the polygon response counts.

## Examples

``` r
# Create minimal polygon and covariate inputs for one time point.
polygons <- sf::st_sf(
  area_id = 1:2,
  response = c(10, 12),
  geometry = sf::st_sfc(
    sf::st_polygon(list(rbind(c(0, 0), c(1, 0), c(1, 2), c(0, 2), c(0, 0)))),
    sf::st_polygon(list(rbind(c(1, 0), c(2, 0), c(2, 2), c(1, 2), c(1, 0)))),
    crs = 3857
  )
)
covariate <- terra::rast(
  ncols = 2, nrows = 2, xmin = 0, xmax = 2, ymin = 0, ymax = 2,
  crs = "EPSG:3857"
)
terra::values(covariate) <- c(1, 2, 3, 4)

data <- suppressMessages(prepare_data_mmap(
  polygon_shapefile_list = list(polygons),
  covariate_rasters_list = list(covariate),
  make_mesh = FALSE
))

# Inspect defaults and modify a prior for a later model fit.
defaults <- get_priors(data)
defaults[c("prior_rho_min", "prior_sigma_max")]
#> $prior_rho_min
#>     xmax 
#> 0.942809 
#> 
#> $prior_sigma_max
#> [1] 0.1285649
#> 
my_priors <- defaults
my_priors$prior_rho_prob <- 0.05
```

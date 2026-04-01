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
if (FALSE) { # \dontrun{
# Check defaults before fitting
defaults <- get_priors(my_data)
print(defaults)

# Use defaults as a base to modify specific values
my_priors <- defaults
my_priors$prior_rho_prob <- 0.05 # Stricter probability
fit <- disag_model_mmap(my_data, priors = my_priors)
} # }
```

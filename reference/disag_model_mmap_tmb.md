# Fit a multi-map disaggregation model via TMB

Builds the TMB ADFun object for a multi-map disaggregation model, then
fits the model by maximizing the TMB objective and approximates
uncertainty via the optimized Hessian.

## Usage

``` r
disag_model_mmap_tmb(
  data,
  priors = NULL,
  family = "poisson",
  link = "log",
  time_varying_betas = FALSE,
  fixed_effect_betas = TRUE,
  iterations = 1000,
  field = TRUE,
  iid = TRUE,
  hess_control_parscale = NULL,
  hess_control_ndeps = 1e-04,
  silent = TRUE,
  starting_values = NULL,
  verbose = FALSE
)
```

## Arguments

- data:

  A 'disag_data_mmap' object (from 'prepare_data_mmap()').

- priors:

  Optional named list of prior specifications (see internal helper).

- family:

  One of 'gaussian', 'binomial', 'poisson', or 'negbinomial'.

- link:

  One of 'identity', 'logit', or 'log'.

- time_varying_betas:

  Logical; if TRUE, each time point has its own fixed-effect

- fixed_effect_betas:

  Logical; if TRUE (default), active beta coefficients are treated as
  fixed effects. If FALSE, active beta coefficients are treated as
  random effects in the inner Laplace step.

- iterations:

  Integer \>= 1: maximum number of optimizer iterations.

- field:

  Logical: include the spatial random field?

- iid:

  Logical: include polygon-specific IID effects?

- hess_control_parscale:

  Optional numeric vector for scaling the Hessian steps.

- hess_control_ndeps:

  Numeric; relative step size for Hessian finite-difference (default
  1e-4).

- silent:

  Logical: if TRUE, suppress TMB's console output.

- starting_values:

  Optional named list of starting parameter values.

- verbose:

  Logical: if TRUE, print total runtime.

## Value

An object of class 'disag_model_mmap_tmb' (a list with '\$obj', '\$opt',
'\$sd_out', '\$data', and '\$model_setup').

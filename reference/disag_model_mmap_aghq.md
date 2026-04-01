# Fit a multi-map disaggregation model via TMB + AGHQ

Builds the TMB ADFun object for a multi-map disaggregation model, then
fits the model via AGHQ with desired number of quadrature points.

## Usage

``` r
disag_model_mmap_aghq(
  data,
  priors = NULL,
  family = "poisson",
  link = "log",
  time_varying_betas = FALSE,
  fixed_effect_betas = TRUE,
  aghq_k = 1,
  field = TRUE,
  iid = TRUE,
  silent = TRUE,
  starting_values = NULL,
  optimizer = NULL,
  verbose = FALSE
)
```

## Arguments

- data:

  A 'disag_data_mmap' object (from 'prepare_data_mmap()').

- priors:

  Optional named list of prior specifications (see internal helper).

- family:

  One of "gaussian", "binomial", "poisson", or "negbinomial".

- link:

  One of "identity", "logit", or "log".

- time_varying_betas:

  Logical; if TRUE, each time point has its own fixed-effect

- fixed_effect_betas:

  Logical; if TRUE (default), beta coefficients are in AGHQ outer
  parameters. If FALSE, active betas are treated as TMB random effects.

- aghq_k:

  Integer \>= 1: number of quadrature nodes for AGHQ ('1' = Laplace).

- field:

  Logical: include the spatial random field?

- iid:

  Logical: include polygon-specific IID effects?

- silent:

  Logical: if TRUE, suppress TMB's console output.

- starting_values:

  Optional named list of starting parameter values.

- optimizer:

  Optional optimizer name passed to AGHQ control.

- verbose:

  Logical: if TRUE, print total runtime.

## Value

An object of class 'disag_model_mmap_aghq' (a list with '\$aghq_model',
'\$data', and '\$model_setup').

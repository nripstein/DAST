# Build the TMB ADFun object for multi-map disaggregation

Internal helper. Converts data, priors, and model settings into the list
of inputs required by 'TMB::MakeADFun()'.

## Usage

``` r
make_model_object_mmap(
  data,
  priors = NULL,
  family = "gaussian",
  link = "identity",
  time_varying_betas = FALSE,
  fixed_effect_betas = TRUE,
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

  A 'disag_data_mmap' object.

- priors:

  NULL or named list overriding default hyperpriors.

- family:

  One of "gaussian", "binomial", "poisson", "negbinomial".

- link:

  One of "identity", "logit", "log".

- time_varying_betas:

  Logical; if TRUE, each time point has its own fixed-effect

- fixed_effect_betas:

  Logical; if FALSE, active beta coefficients are included in TMB random
  effects (for AGHQ inner-Laplace treatment).

- field:

  Logical: include spatial field?

- iid:

  Logical: include IID polygon effects?

- silent:

  Logical: pass to 'MakeADFun()' to suppress output.

- starting_values:

  NULL or named list of starting values.

- optimizer:

  Optional; For changing the arguments used in AGHQ.

- verbose:

  Logical: if TRUE, print details throughout including runtime.

## Value

A 'TMB::ADFun' object ready for 'marginal_laplace_tmb()'.

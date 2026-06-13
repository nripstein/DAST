# Fit a multi-map disaggregation model (via AGHQ, TMB, or MCMC)

Top-level fitting wrapper with engine dispatch and engine-specific
argument handling. Engine-specific controls should be supplied via
`engine.args`.

## Usage

``` r
disag_model_mmap(
  data,
  priors = NULL,
  family = "poisson",
  link = "log",
  engine = c("AGHQ", "TMB", "MCMC"),
  time_varying_betas = FALSE,
  fixed_effect_betas = TRUE,
  engine.args = NULL,
  aghq_k = 2,
  field = TRUE,
  iid = TRUE,
  silent = TRUE,
  starting_values = NULL,
  optimizer = NULL,
  verbose = FALSE,
  ...
)
```

## Arguments

- data:

  A `disag_data_mmap` object.

- priors:

  Optional named list of prior overrides.

- family:

  One of `"gaussian"`, `"binomial"`, `"poisson"`, or `"negbinomial"`.

- link:

  One of `"identity"`, `"logit"`, or `"log"`.

- engine:

  Character; one of `"AGHQ"`, `"TMB"`, or `"MCMC"`. The MCMC engine uses
  tmbstan.

- time_varying_betas:

  Logical; if TRUE, each time point has its own fixed-effect.

- fixed_effect_betas:

  Logical; if TRUE (default), beta coefficients are treated as fixed
  effects in the AGHQ outer parameter block (current behavior). If FALSE
  and `engine = "AGHQ"`, beta coefficients are moved to TMB random
  effects so they are integrated in the inner Laplace step.

- engine.args:

  Optional named list of engine-specific options. Supported AGHQ keys
  are `aghq_k`, `optimizer`, and `outer_derivative_method`. Supported
  TMB keys are `iterations`, `hess_control_parscale`,
  `hess_control_ndeps`, and `outer_derivative_method`.
  `outer_derivative_method` may be `"tmb"` (default) or
  `"finite_difference"`. The finite-difference option affects only the
  outer fixed/hyperparameter optimization and Hessian; TMB still handles
  the inner Laplace approximation. Supported MCMC keys are `chains`,
  `iter`, `warmup`, `thin`, `cores`, `seed`, `refresh`, `laplace`,
  `lower`, `upper`, and `control`. Additional named MCMC keys are passed
  through to
  [`tmbstan::tmbstan()`](https://rdrr.io/pkg/tmbstan/man/tmbstan.html)
  and
  [`rstan::sampling()`](https://mc-stan.org/rstan/reference/stanmodel-method-sampling.html).
  `iter` is the total number of Stan iterations, including warmup.

- aghq_k:

  Deprecated at wrapper level; use `engine.args = list(aghq_k = ...)`.
  Retained for backward compatibility.

- field:

  Logical; include spatial field?

- iid:

  Logical; include IID polygon effects?

- silent:

  Logical; pass through to engine fit function.

- starting_values:

  Optional named list of starting values.

- optimizer:

  Deprecated at wrapper level; use
  `engine.args = list(optimizer = ...)`. Retained for backward
  compatibility.

- verbose:

  Logical; print runtime diagnostics.

- ...:

  Additional arguments. Engine-specific arguments passed via `...` are
  deprecated in this wrapper and should be moved to `engine.args`.

## Value

A fitted model object of class `disag_model_mmap_tmb`,
`disag_model_mmap_aghq`, or `disag_model_mmap_mcmc` (all also inherit
`disag_model_mmap`).

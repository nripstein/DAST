# Fit a multi-map disaggregation model (via AGHQ or TMB)

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
  engine = c("AGHQ", "TMB"),
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

  Character; either `"AGHQ"` or `"TMB"`.

- time_varying_betas:

  Logical; if TRUE, each time point has its own fixed-effect.

- fixed_effect_betas:

  Logical; if TRUE (default), beta coefficients are treated as fixed
  effects in the AGHQ outer parameter block (current behavior). If FALSE
  and `engine = "AGHQ"`, beta coefficients are moved to TMB random
  effects so they are integrated in the inner Laplace step.

- engine.args:

  Optional named list of engine-specific options. Supported keys:

  - AGHQ: `aghq_k`, `optimizer`

  - TMB: `iterations`, `hess_control_parscale`, `hess_control_ndeps`

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

A fitted model object of class `disag_model_mmap_tmb` or
`disag_model_mmap_aghq` (both also inherit `disag_model_mmap`).

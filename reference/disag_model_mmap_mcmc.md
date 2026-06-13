# Fit a multi-map disaggregation model via tmbstan MCMC

Builds the shared TMB ADFun object for a multi-map disaggregation model,
then samples from it with
[`tmbstan::tmbstan()`](https://rdrr.io/pkg/tmbstan/man/tmbstan.html).
This engine supports parameter estimation only; prediction is not
implemented for MCMC fits.

## Usage

``` r
disag_model_mmap_mcmc(
  data,
  priors = NULL,
  family = "poisson",
  link = "log",
  time_varying_betas = FALSE,
  fixed_effect_betas = TRUE,
  chains = 4L,
  iter = 2000L,
  warmup = NULL,
  thin = 1L,
  cores = NULL,
  seed = NULL,
  refresh = NULL,
  laplace = FALSE,
  lower = numeric(0),
  upper = numeric(0),
  control = NULL,
  field = TRUE,
  iid = TRUE,
  silent = TRUE,
  starting_values = NULL,
  verbose = FALSE,
  ...
)
```

## Arguments

- data:

  A 'disag_data_mmap' object (from 'prepare_data_mmap()').

- priors:

  Optional named list of prior specifications.

- family:

  One of 'gaussian', 'binomial', 'poisson', or 'negbinomial'.

- link:

  One of 'identity', 'logit', or 'log'.

- time_varying_betas:

  Logical; if TRUE, each time point has its own fixed-effect.

- fixed_effect_betas:

  Logical; if TRUE (default), active beta coefficients are sampled as
  fixed effects. If FALSE, active beta coefficients are included in the
  TMB random-effect block.

- chains:

  Integer \>= 1; number of MCMC chains.

- iter:

  Integer \>= 1; total Stan iterations per chain, including warmup.

- warmup:

  Integer \>= 0 and less than `iter`; warmup iterations per chain.
  Defaults to `floor(iter / 2)`.

- thin:

  Integer \>= 1; thinning interval.

- cores:

  Integer \>= 1; number of cores passed to Stan. Defaults to
  `getOption("mc.cores", chains)`.

- seed:

  Optional positive integer seed.

- refresh:

  Optional integer \>= 0; Stan progress refresh interval.

- laplace:

  Logical; passed to
  [`tmbstan::tmbstan()`](https://rdrr.io/pkg/tmbstan/man/tmbstan.html).
  Defaults to `FALSE` for full posterior sampling.

- lower:

  Numeric lower bounds passed to
  [`tmbstan::tmbstan()`](https://rdrr.io/pkg/tmbstan/man/tmbstan.html).

- upper:

  Numeric upper bounds passed to
  [`tmbstan::tmbstan()`](https://rdrr.io/pkg/tmbstan/man/tmbstan.html).

- control:

  Optional list passed to
  [`rstan::sampling()`](https://mc-stan.org/rstan/reference/stanmodel-method-sampling.html).

- field:

  Logical: include the spatial random field?

- iid:

  Logical: include polygon-specific IID effects?

- silent:

  Logical: if TRUE, suppress TMB/tmbstan console output.

- starting_values:

  Optional named list of starting parameter values.

- verbose:

  Logical: if TRUE, print total runtime.

- ...:

  Additional arguments passed through to
  [`tmbstan::tmbstan()`](https://rdrr.io/pkg/tmbstan/man/tmbstan.html)
  and
  [`rstan::sampling()`](https://mc-stan.org/rstan/reference/stanmodel-method-sampling.html).

## Value

An object of class 'disag_model_mmap_mcmc' with components `stanfit`,
`obj`, `data`, and `model_setup`.

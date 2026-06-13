# Summary method for 'disag_model_mmap_mcmc' objects

Summarizes parameter estimates and MCMC diagnostics from the underlying
`stanfit` returned by
[`tmbstan::tmbstan()`](https://rdrr.io/pkg/tmbstan/man/tmbstan.html).

## Usage

``` r
# S3 method for class 'disag_model_mmap_mcmc'
summary(object, pars = NULL, probs = c(0.025, 0.5, 0.975), ...)
```

## Arguments

- object:

  A 'disag_model_mmap_mcmc' object.

- pars:

  Optional parameter names passed to `summary.stanfit()`.

- probs:

  Numeric vector of quantile probabilities.

- ...:

  Additional arguments passed to `summary.stanfit()`.

## Value

An object of class 'summary.disag_model_mmap_mcmc'.

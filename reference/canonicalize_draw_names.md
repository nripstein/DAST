# Canonicalize posterior draw parameter names

Canonicalize parameter draw names for consistency across shared vs.
time-varying intercepts/slopes while leaving random effects and
hyperparameters unchanged.

## Usage

``` r
canonicalize_draw_names(old_names, coef_meta, time_varying_betas)
```

## Arguments

- old_names:

  Character vector of draw names.

- coef_meta:

  List with coefficient metadata from \`compute_coef_meta()\`.

- time_varying_betas:

  Logical indicating whether time-varying betas are used.

## Value

Character vector of canonicalized draw names.

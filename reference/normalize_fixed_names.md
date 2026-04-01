# Normalize fixed-effect parameter names

Normalize fixed-effect parameter names to consistent labels.

## Usage

``` r
normalize_fixed_names(nm, coef_meta, time_varying_betas)
```

## Arguments

- nm:

  Character vector of parameter names.

- coef_meta:

  List with coefficient metadata from \`compute_coef_meta()\`.

- time_varying_betas:

  Logical indicating whether time-varying betas are used.

## Value

Character vector of normalized parameter names.

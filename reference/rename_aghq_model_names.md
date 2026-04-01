# Rename AGHQ model parameter names

Rename parameter entries in an AGHQ model object (marginals, optimizer
outputs, modes, Hessians) using canonicalized names based on coefficient
metadata and time-varying structure.

## Usage

``` r
rename_aghq_model_names(aghq_model, coef_meta, time_varying_betas)
```

## Arguments

- aghq_model:

  Fitted AGHQ model object.

- coef_meta:

  List with coefficient metadata from \`compute_coef_meta()\`.

- time_varying_betas:

  Logical indicating whether time-varying betas are used.

## Value

AGHQ model object with normalized parameter names in key components.

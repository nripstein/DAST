# Estimate uncertainty via Monte Carlo for multi-map disaggregation (TMB)

Draw Monte Carlo samples of model parameters, propagate through the
prediction function, and compute credible intervals at each cell.

## Usage

``` r
predict_uncertainty_mmap(
  model_output,
  new_data = NULL,
  predict_iid = FALSE,
  N = 100,
  CI = 0.95,
  newdata = NULL
)
```

## Arguments

- model_output:

  A 'disag_model_mmap_tmb' model fit.

- new_data:

  Optional SpatRaster (or list) of new covariates.

- predict_iid:

  Logical; if TRUE, include the IID polygon effect.

- N:

  Integer; number of Monte Carlo draws (default 100).

- CI:

  Numeric in (0,1); credible‐interval level (default 0.95).

## Value

A list with components: - realisations: list of SpatRasters of each
draw. - predictions_ci: list with 'lower' and 'upper' SpatRaster stacks.

# DAST (DisAggregation in Space and Time)

DAST fits spatial disaggregation models for areal data observed on maps
where polygon boundaries change over time. It combines polygon
responses, optional fine-scale covariates, and population rasters to
infer fine-scale spatial risk surfaces.

## Installation

You can install the released version of DAST from CRAN:

``` r

install.packages("DAST")
```

You can install the development version from GitHub:

``` r

# install.packages("remotes")
remotes::install_github("nripstein/DAST")
```

## Data Requirements

- `polygon_shapefile_list`: one `sf` polygon object per time point, with
  `area_id` and `response` columns by default.

- `covariate_rasters_list`: optional matching list of
  [`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
  covariate stacks.

- `aggregation_rasters_list`: optional matching list of
  [`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
  aggregation or population rasters; if omitted, uniform aggregation
  weights are used.

- Polygon and raster inputs should use compatible coordinate reference
  systems and aligned raster grids within each time point.

## Workflow

``` r


# polygon_list: list of sf polygon objects, one per time point

# covariate_list: optional list of terra::SpatRaster covariate stacks

# aggregation_list: optional list of terra::SpatRaster aggregation/population rasters

dat <- prepare_data_mmap(
    polygon_shapefile_list = polygon_list,
    covariate_rasters_list = covariate_list,
    aggregation_rasters_list = aggregation_list
)

fit <- disag_model_mmap(dat, engine = "AGHQ")

pred <- predict(fit)
```

Predictions are returned as fine-scale rate or risk surfaces. When the
aggregation raster represents population or exposure, expected fine-cell
counts can be obtained by multiplying the predicted surface by the
matching aggregation raster.

## Fitting Algorithms

It is straightforward to use the model-fitting algorithm of your choice
by specifying an `engine` argument in
[`disag_model_mmap()`](http://noahripstein.com/DAST/reference/disag_model_mmap.md).

| Engine | Description | Recommended use |
|----|----|----|
| `AGHQ` | Approximate Bayesian inference using [Adaptive Gauss-Hermite Quadrature](https://arxiv.org/abs/2101.04468). | Default option for fast approximate fully Bayesian inference. |
| `TMB` | Laplace approximation through [Template Model Builder](https://doi.org/10.18637/jss.v070.i05). | Fastest option, using Empirical Bayes instead of full Bayes. |
| `MCMC` | [NUTS](https://jmlr.org/papers/v15/hoffman14a.html) algorithm implimented in [tmbstan](https://doi.org/10.1371/journal.pone.0197954). | Provides asymptotically exact posterior sampling, but is very slow; [`predict()`](https://rdrr.io/r/stats/predict.html) is not currently implemented. |

## Passing Engine-Specific Arguments

Use `engine.args` to pass arguments specific to the fitting algorithm
selected.

``` r

# AGHQ controls
fit_aghq <- disag_model_mmap(
    dat,
    engine = "AGHQ",
    engine.args = list(
        aghq_k = 2,
        optimizer = "BFGS"
    )
)

# TMB controls
fit_tmb <- disag_model_mmap(
    dat,
    engine = "TMB",
    engine.args = list(
        iterations = 1000,
        hess_control_ndeps = 1e-4
    )
)

# MCMC controls via tmbstan
fit_mcmc <- disag_model_mmap(
    dat,
    engine = "MCMC",
    engine.args = list(
        chains = 4,
        iter = 2000,
        warmup = 1000
    )
)

summary(fit_mcmc)
```

## Citation

If you use `DAST`, please cite:

``` bibtex
@misc{ripstein2026spatiotemporal,
  title         = {Spatio-Temporal Disaggregation with Changing Areal Boundaries},
  author        = {Ripstein, Noah and Brown, Patrick and Stafford, Jamie},
  year          = {2026},
  eprint        = {2606.25074},
  archivePrefix = {arXiv},
  url           = {https://arxiv.org/abs/2606.25074}
}
```

make_slice_raster <- function(vals = c(1, 2, 3, 4), name = "x") {
  r <- terra::rast(ncols = 2, nrows = 2, xmin = 0, xmax = 2, ymin = 0, ymax = 2, crs = "EPSG:3857")
  terra::values(r) <- vals
  names(r) <- name
  r
}

test_that("compute_coef_meta extracts covariate names and handles no-covariate case", {
  d1 <- list(
    covariate_data = data.frame(
      ID = 1,
      cell = 1,
      poly_local_id = 1,
      time = 1,
      temp = 10,
      precip = 20
    ),
    time_points = 1:3
  )

  m1 <- DAST:::compute_coef_meta(d1)
  expect_equal(m1$n_times, 3)
  expect_equal(m1$p, 2)
  expect_equal(m1$cov_names, c("temp", "precip"))

  d2 <- list(
    covariate_data = data.frame(ID = 1, cell = 1, poly_local_id = 1, time = 1),
    time_points = 1:2
  )
  m2 <- DAST:::compute_coef_meta(d2)
  expect_equal(m2$p, 0)
  expect_equal(m2$cov_names, character(0))
})

test_that("rename_aghq_model_names renames marginals, Hessian dimnames, and thetanames", {
  coef_meta <- list(p = 2L, n_times = 1L, cov_names = c("temp", "precip"))

  aghq_model <- list(
    marginals = stats::setNames(list(1, 2), c("slope", "slope1")),
    optresults = list(
      par = stats::setNames(c(0.1, 0.2), c("slope", "slope1")),
      mode = stats::setNames(c(0.3, 0.4), c("slope", "slope1")),
      theta = stats::setNames(c(0.5, 0.6), c("slope", "slope1"))
    ),
    modesandhessians = list(
      mode = stats::setNames(c(0.7, 0.8), c("slope", "slope1")),
      H = matrix(
        c(1, 0, 0, 1),
        nrow = 2,
        dimnames = list(c("slope", "slope1"), c("slope", "slope1"))
      )
    ),
    normalized_posterior = list(thetanames = c("slope", "slope1"))
  )

  out <- DAST:::rename_aghq_model_names(aghq_model, coef_meta, time_varying_betas = FALSE)

  expect_equal(names(out$marginals), c("temp", "precip"))
  expect_equal(names(out$optresults$par), c("temp", "precip"))
  expect_equal(names(out$modesandhessians$mode), c("temp", "precip"))
  expect_equal(rownames(out$modesandhessians$H), c("temp", "precip"))
  expect_equal(colnames(out$modesandhessians$H), c("temp", "precip"))
  expect_equal(out$normalized_posterior$thetanames, c("temp", "precip"))
})

test_that("canonicalize_draw_names handles NULL and defensive fallbacks", {
  expect_null(DAST:::canonicalize_draw_names(NULL, list(p = 1, n_times = 1, cov_names = "x"), FALSE))

  nm <- c("intercept_t", "intercept_t1", "nodemean[1]", "iideffect[2]")
  out <- DAST:::canonicalize_draw_names(
    old_names = nm,
    coef_meta = list(p = NA_integer_, n_times = NA_integer_, cov_names = NULL),
    time_varying_betas = TRUE
  )

  expect_equal(out, c("intercept_t1", "intercept_t2", "nodemean", "iideffect"))
})

test_that("build_tmb_beta_metadata validates required metadata and mapping", {
  bad_no_meta <- list(
    model_setup = list(time_varying_betas = FALSE, fixed_effect_betas = TRUE),
    sd_out = list(par.fixed = stats::setNames(c(1, 2), c("intercept", "slope"))),
    obj = list(env = list(par = stats::setNames(c(1, 2), c("intercept", "slope"))))
  )
  expect_error(
    DAST:::build_tmb_beta_metadata(bad_no_meta),
    "coef_meta is required"
  )

  bad_source <- list(
    model_setup = list(
      time_varying_betas = FALSE,
      fixed_effect_betas = TRUE,
      coef_meta = list(p = 1L, n_times = 1L, cov_names = "temp")
    ),
    sd_out = list(
      par.fixed = stats::setNames(c(1), c("intercept")),
      par.random = numeric(0)
    ),
    obj = list(env = list(par = stats::setNames(c(1, 2), c("intercept", "slope"))))
  )
  expect_error(
    DAST:::build_tmb_beta_metadata(bad_source),
    "could not map beta names in fixed order"
  )

  bad_full <- list(
    model_setup = list(
      time_varying_betas = FALSE,
      fixed_effect_betas = TRUE,
      coef_meta = list(p = 1L, n_times = 1L, cov_names = "temp")
    ),
    sd_out = list(
      par.fixed = stats::setNames(c(1, 2), c("intercept", "slope")),
      par.random = numeric(0)
    ),
    obj = list(env = list(par = stats::setNames(c(1), c("intercept"))))
  )
  expect_error(
    DAST:::build_tmb_beta_metadata(bad_full),
    "could not map beta names in full parameter order"
  )
})

test_that("build_tmb_beta_metadata supports time-varying mapping and empty fixed-order names", {
  tv_ok <- list(
    model_setup = list(
      time_varying_betas = TRUE,
      fixed_effect_betas = TRUE,
      coef_meta = list(p = 1L, n_times = 2L, cov_names = "temp")
    ),
    sd_out = list(
      par.fixed = stats::setNames(c(1, 2, 3, 4), c("intercept_t", "intercept_t1", "slope_t", "slope_t1")),
      par.random = numeric(0)
    ),
    obj = list(env = list(par = stats::setNames(c(1, 2, 3, 4, 5), c("intercept_t", "intercept_t1", "slope_t", "slope_t1", "nodemean"))))
  )

  out_tv <- DAST:::build_tmb_beta_metadata(tv_ok)
  expect_equal(length(out_tv$beta_index_map$intercept_idx), 2)
  expect_equal(dim(out_tv$beta_index_map$slope_idx), c(1, 2))
  expect_equal(dim(out_tv$beta_index_map$full_slope_idx), c(1, 2))

  unnamed_fixed <- list(
    model_setup = list(
      time_varying_betas = FALSE,
      fixed_effect_betas = FALSE,
      coef_meta = list(p = 1L, n_times = 1L, cov_names = "temp")
    ),
    sd_out = list(
      par.fixed = c(999),
      par.random = stats::setNames(c(1, 2), c("intercept", "slope"))
    ),
    obj = list(env = list(par = stats::setNames(c(1, 2), c("intercept", "slope"))))
  )

  out_unnamed_fixed <- DAST:::build_tmb_beta_metadata(unnamed_fixed)
  expect_equal(out_unnamed_fixed$fixed_order, character(0))

  unnamed_full <- list(
    model_setup = list(
      time_varying_betas = FALSE,
      fixed_effect_betas = FALSE,
      coef_meta = list(p = 1L, n_times = 1L, cov_names = "temp")
    ),
    sd_out = list(
      par.fixed = c(999),
      par.random = stats::setNames(c(1, 2), c("intercept", "slope"))
    ),
    obj = list(env = list(par = c(1, 2)))
  )
  expect_error(DAST:::build_tmb_beta_metadata(unnamed_full), "full parameter order")
})

test_that("slice_params_tmb sequential fallback infers p/Tn and slices tv gaussian iid field", {
  model <- list(
    model_setup = list(
      family = "gaussian",
      field = TRUE,
      iid = TRUE,
      time_varying_betas = TRUE
    ),
    data = list(
      polygon_data = data.frame(response = c(1, 2)),
      time_points = 1:2,
      covariate_rasters_list = list(make_slice_raster(name = "temp")),
      mesh = list(loc = matrix(0, nrow = 3, ncol = 2))
    ),
    obj = list(env = list(par = NULL))
  )

  out <- DAST:::slice_params_tmb(unname(seq_len(13)), model)

  expect_equal(out$intercept_t, c(1, 2))
  expect_equal(out$slope_t, c(3, 4))
  expect_equal(out$log_tau_gaussian, 5)
  expect_equal(out$iideffect_log_tau, 6)
  expect_equal(out$iideffect, c(7, 8))
  expect_equal(out$log_sigma, 9)
  expect_equal(out$log_rho, 10)
  expect_equal(out$nodemean, c(11, 12, 13))
  expect_equal(out$p, 1)
  expect_equal(out$Tn, 2)
  expect_true(out$tv)
})

test_that("slice_params_tmb sequential fallback covers p=0 and negbin branch", {
  no_cov_model <- list(
    model_setup = list(
      family = "poisson",
      field = FALSE,
      iid = FALSE,
      time_varying_betas = FALSE
    ),
    data = list(
      polygon_data = data.frame(response = 1),
      time_points = 1:3,
      covariate_rasters_list = NULL
    ),
    obj = list(env = list(par = NULL))
  )

  out_no_cov <- DAST:::slice_params_tmb(unname(10), no_cov_model)
  expect_equal(out_no_cov$p, 0)
  expect_equal(out_no_cov$Tn, 3)
  expect_equal(out_no_cov$intercept, 10)
  expect_equal(out_no_cov$slope, numeric(0))

  negbin_model <- list(
    model_setup = list(
      family = "negbinomial",
      field = FALSE,
      iid = FALSE,
      time_varying_betas = FALSE
    ),
    data = list(
      polygon_data = data.frame(response = 1),
      time_points = 1,
      covariate_rasters_list = NULL
    ),
    obj = list(env = list(par = NULL))
  )

  out_nb <- DAST:::slice_params_tmb(unname(c(1, 2)), negbin_model)
  expect_equal(out_nb$intercept, 1)
  expect_equal(out_nb$iideffect_log_tau, 2)
})

test_that("slice_params_tmb named path uses reference names, validates blocks, and slices iid/field", {
  model_ref_names <- list(
    model_setup = list(
      family = "poisson",
      field = FALSE,
      iid = FALSE,
      time_varying_betas = FALSE,
      coef_meta = list(p = 1L, n_times = 1L),
      beta_index_map = NULL
    ),
    data = list(
      polygon_data = data.frame(response = 1),
      time_points = 1,
      covariate_rasters_list = list(make_slice_raster(name = "temp"))
    ),
    obj = list(env = list(par = stats::setNames(c(0, 0), c("intercept", "slope"))))
  )

  out_ref <- DAST:::slice_params_tmb(unname(c(5, 6)), model_ref_names)
  expect_equal(out_ref$intercept, 5)
  expect_equal(out_ref$slope, 6)

  model_tv <- list(
    model_setup = list(
      family = "poisson",
      field = FALSE,
      iid = FALSE,
      time_varying_betas = TRUE,
      coef_meta = list(p = 1L, n_times = 2L),
      beta_index_map = NULL
    ),
    data = list(
      polygon_data = data.frame(response = 1),
      time_points = 1:2,
      covariate_rasters_list = list(make_slice_raster(name = "temp"))
    ),
    obj = list(env = list(par = stats::setNames(c(0, 0, 0, 0), c("intercept_t", "intercept_t", "slope_t", "slope_t"))))
  )

  out_tv <- DAST:::slice_params_tmb(unname(c(1, 2, 3, 4)), model_tv)
  expect_equal(out_tv$intercept_t, c(1, 2))
  expect_equal(out_tv$slope_t, c(3, 4))

  model_tv_missing <- model_tv
  model_tv_missing$obj$env$par <- stats::setNames(c(0, 0), c("slope_t", "slope_t"))
  expect_error(
    DAST:::slice_params_tmb(unname(c(3, 4)), model_tv_missing),
    "required parameter block `intercept_t`"
  )

  model_tv_mismatch <- model_tv
  model_tv_mismatch$obj$env$par <- stats::setNames(c(0, 0, 0), c("intercept_t", "slope_t", "slope_t"))
  expect_error(
    DAST:::slice_params_tmb(unname(c(1, 3, 4)), model_tv_mismatch),
    "has length 1, expected 2"
  )

  model_iid <- list(
    model_setup = list(
      family = "poisson",
      field = FALSE,
      iid = TRUE,
      time_varying_betas = FALSE,
      coef_meta = list(p = 0L, n_times = 1L),
      beta_index_map = NULL
    ),
    data = list(
      polygon_data = data.frame(response = c(1, 2)),
      time_points = 1,
      covariate_rasters_list = NULL
    ),
    obj = list(env = list(par = NULL))
  )

  par_iid <- stats::setNames(c(1, 2, 10, 11), c("intercept", "iideffect_log_tau", "iideffect", "iideffect"))
  out_iid <- DAST:::slice_params_tmb(par_iid, model_iid)
  expect_equal(out_iid$iideffect_log_tau, 2)
  expect_equal(out_iid$iideffect, c(10, 11))

  model_field_unknown_nodes <- list(
    model_setup = list(
      family = "poisson",
      field = TRUE,
      iid = FALSE,
      time_varying_betas = FALSE,
      coef_meta = list(p = 0L, n_times = 1L),
      beta_index_map = NULL
    ),
    data = list(
      polygon_data = data.frame(response = 1),
      time_points = 1,
      covariate_rasters_list = NULL,
      mesh = list()
    ),
    obj = list(env = list(par = NULL))
  )

  par_field <- stats::setNames(c(1, 2, 3, 4, 5), c("intercept", "log_sigma", "log_rho", "nodemean", "nodemean"))
  out_field <- DAST:::slice_params_tmb(par_field, model_field_unknown_nodes)
  expect_equal(out_field$log_sigma, 2)
  expect_equal(out_field$log_rho, 3)
  expect_equal(out_field$nodemean, c(4, 5))
})

test_that("parvec_to_param_list delegates to slice_params_tmb", {
  model <- list(
    model_setup = list(
      family = "poisson",
      field = FALSE,
      iid = FALSE,
      time_varying_betas = FALSE,
      coef_meta = list(p = 1L, n_times = 1L),
      beta_index_map = NULL
    ),
    data = list(
      polygon_data = data.frame(response = 1),
      time_points = 1,
      covariate_rasters_list = list(make_slice_raster(name = "temp"))
    ),
    obj = list(env = list(par = NULL))
  )

  par_vec <- stats::setNames(c(3, 4), c("intercept", "slope"))
  expect_equal(DAST:::parvec_to_param_list(model, par_vec), DAST:::slice_params_tmb(par_vec, model))
})

test_that("disag_model_mmap wrapper dispatches to TMB with a tiny smoke fit", {
  fixture <- make_fixture_fit_tmb(
    seed = 101L,
    n_times = 1,
    n_polygon_per_side = 3,
    n_pixels_per_side = 6
  )
  data_obj <- prepare_data_mmap(
    polygon_shapefile_list = fixture$polygon_shapefile_list,
    covariate_rasters_list = fixture$covariate_rasters_list,
    aggregation_rasters_list = fixture$aggregation_rasters_list,
    make_mesh = TRUE
  )

  fit <- suppressWarnings(suppressMessages(
    disag_model_mmap(
      data = data_obj,
      engine = "TMB",
      family = "poisson",
      link = "log",
      engine.args = list(iterations = 3),
      field = FALSE,
      iid = FALSE,
      silent = TRUE
    )
  ))

  expect_s3_class(fit, "disag_model_mmap_tmb")
  expect_s3_class(fit, "disag_model_mmap")
  expect_true(all(c("obj", "opt", "sd_out", "data", "model_setup") %in% names(fit)))
  expect_equal(fit$model_setup$family, "poisson")
  expect_false(isTRUE(fit$model_setup$field))
  expect_false(isTRUE(fit$model_setup$iid))
})

test_that("disag_model_mmap_tmb returns expected object contract", {
  skip_tmb_integration()
  bundle <- get_core_field_fit()
  fit <- bundle$fit
  family <- get_test_family_mmap()

  expect_s3_class(fit, "disag_model_mmap_tmb")
  expect_true(all(c("obj", "opt", "sd_out", "data", "model_setup") %in% names(fit)))
  expect_true(is.list(fit$model_setup))
  expect_equal(fit$model_setup$family, family)
  expect_equal(fit$model_setup$link, "log")
  expect_true(isTRUE(fit$model_setup$field))
  expect_false(isTRUE(fit$model_setup$iid))
  expect_false(isTRUE(fit$model_setup$time_varying_betas))
  expect_true(isTRUE(fit$model_setup$fixed_effect_betas))
  expect_true(is.list(fit$model_setup$beta_index_map))
  expect_equal(fit$model_setup$beta_index_map$source, "fixed")
  expect_true(is.numeric(fit$opt$par))
})

test_that("disag_model_mmap_tmb supports shared random-betas mode", {
  skip_tmb_integration()
  bundle <- suppressWarnings(get_cached_tmb_fit(
    name = "fit_shared_random_betas",
    seed = 12L,
    iterations = 20,
    family = "poisson",
    link = "log",
    field = FALSE,
    iid = FALSE,
    time_varying_betas = FALSE,
    fixed_effect_betas = FALSE
  ))
  fit <- bundle$fit

  expect_false(isTRUE(fit$model_setup$fixed_effect_betas))
  expect_true(is.list(fit$model_setup$beta_index_map))
  expect_equal(fit$model_setup$beta_index_map$source, "random")
  expect_equal(length(fit$opt$par), 0L)
  expect_true(length(fit$sd_out$par.random) > 0L)
})

test_that("disag_model_mmap_tmb supports time-varying random-betas mode", {
  skip_tmb_integration()
  bundle <- suppressWarnings(get_cached_tmb_fit(
    name = "fit_tv_random_betas",
    seed = 13L,
    iterations = 20,
    family = "poisson",
    link = "log",
    field = FALSE,
    iid = FALSE,
    time_varying_betas = TRUE,
    fixed_effect_betas = FALSE
  ))
  fit <- bundle$fit
  beta_map <- fit$model_setup$beta_index_map
  p <- fit$model_setup$coef_meta$p
  Tn <- fit$model_setup$coef_meta$n_times

  expect_false(isTRUE(fit$model_setup$fixed_effect_betas))
  expect_equal(beta_map$source, "random")
  expect_true(isTRUE(beta_map$tv))
  expect_length(beta_map$intercept_idx, Tn)
  expect_true(is.matrix(beta_map$slope_idx))
  expect_equal(dim(beta_map$slope_idx), c(p, Tn))
})

test_that("disag_model_mmap_tmb keeps model flags for no-field/no-iid setup", {
  skip_tmb_integration()
  bundle <- suppressWarnings(get_core_nofield_fit())
  fit <- bundle$fit
  family <- get_test_family_mmap()

  expect_false(isTRUE(fit$model_setup$field))
  expect_false(isTRUE(fit$model_setup$iid))
  expect_equal(fit$model_setup$family, family)
  expect_equal(fit$model_setup$link, "log")
})

test_that("disag_model_mmap_tmb validates family and link inputs", {
  data_obj <- get_cached_prepared_data("prep_default_mesh")
  family <- get_test_family_mmap()

  expect_error(
    disag_model_mmap_tmb(
      data = data_obj,
      family = "banana",
      link = "log",
      iterations = 20,
      field = FALSE,
      iid = FALSE,
      silent = TRUE
    ),
    "family"
  )

  expect_error(
    disag_model_mmap_tmb(
      data = data_obj,
      family = family,
      link = "apple",
      iterations = 20,
      field = FALSE,
      iid = FALSE,
      silent = TRUE
    ),
    "link"
  )
})

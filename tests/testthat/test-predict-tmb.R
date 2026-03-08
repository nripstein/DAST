test_that("predict.disag_model_mmap_tmb returns expected structure", {
  bundle <- get_core_field_fit()
  fit <- bundle$fit
  n_times <- length(fit$data$time_points)

  pred <- suppressMessages(predict(fit, N = 2, predict_iid = FALSE))

  expect_s3_class(pred, "disag_prediction_mmap")
  expect_equal(names(pred), c("mean_prediction", "uncertainty_prediction"))

  expect_equal(names(pred$mean_prediction), c("prediction", "field", "iid", "covariates"))
  expect_true(inherits(pred$mean_prediction$prediction, "SpatRaster"))
  expect_true(inherits(pred$mean_prediction$field, "SpatRaster"))
  expect_true(is.null(pred$mean_prediction$iid))
  expect_true(inherits(pred$mean_prediction$covariates, "SpatRaster"))
  expect_equal(terra::nlyr(pred$mean_prediction$prediction), n_times)
  expect_equal(terra::nlyr(pred$mean_prediction$field), n_times)
  expect_equal(terra::nlyr(pred$mean_prediction$covariates), n_times)

  expect_equal(names(pred$uncertainty_prediction), c("realisations", "predictions_ci"))
  expect_true(is.list(pred$uncertainty_prediction$realisations))
  expect_equal(length(pred$uncertainty_prediction$realisations), n_times)
  for (ii in seq_len(n_times)) {
    expect_true(inherits(pred$uncertainty_prediction$realisations[[ii]], "SpatRaster"))
    expect_equal(terra::nlyr(pred$uncertainty_prediction$realisations[[ii]]), 2)
  }

  expect_equal(names(pred$uncertainty_prediction$predictions_ci), c("lower", "upper"))
  expect_true(inherits(pred$uncertainty_prediction$predictions_ci$lower, "SpatRaster"))
  expect_true(inherits(pred$uncertainty_prediction$predictions_ci$upper, "SpatRaster"))
  expect_equal(terra::nlyr(pred$uncertainty_prediction$predictions_ci$lower), n_times)
  expect_equal(terra::nlyr(pred$uncertainty_prediction$predictions_ci$upper), n_times)
})

test_that("predict.disag_model_mmap_tmb handles no-field/no-iid model", {
  bundle <- suppressWarnings(get_core_nofield_fit())
  fit <- bundle$fit
  n_times <- length(fit$data$time_points)

  pred <- suppressMessages(predict(fit, N = 2, predict_iid = FALSE))

  expect_true(inherits(pred$mean_prediction$prediction, "SpatRaster"))
  expect_true(is.null(pred$mean_prediction$field))
  expect_true(is.null(pred$mean_prediction$iid))
  expect_true(inherits(pred$mean_prediction$covariates, "SpatRaster"))
  expect_equal(terra::nlyr(pred$mean_prediction$prediction), n_times)

  expect_true(is.list(pred$uncertainty_prediction$realisations))
  for (ii in seq_len(n_times)) {
    expect_equal(terra::nlyr(pred$uncertainty_prediction$realisations[[ii]]), 2)
  }
  expect_equal(terra::nlyr(pred$uncertainty_prediction$predictions_ci$lower), n_times)
  expect_equal(terra::nlyr(pred$uncertainty_prediction$predictions_ci$upper), n_times)
})

test_that("predict.disag_model_mmap_tmb works with shared random-betas mode", {
  bundle <- suppressWarnings(get_cached_tmb_fit(
    name = "pred_shared_random_betas",
    seed = 14L,
    iterations = 20,
    family = "poisson",
    link = "log",
    field = FALSE,
    iid = FALSE,
    time_varying_betas = FALSE,
    fixed_effect_betas = FALSE
  ))
  fit <- bundle$fit
  n_times <- length(fit$data$time_points)

  pred <- suppressMessages(predict(fit, N = 2, predict_iid = FALSE))

  expect_s3_class(pred, "disag_prediction_mmap")
  expect_equal(terra::nlyr(pred$mean_prediction$prediction), n_times)
  expect_equal(length(pred$uncertainty_prediction$realisations), n_times)
  expect_equal(terra::nlyr(pred$uncertainty_prediction$predictions_ci$lower), n_times)
  expect_equal(terra::nlyr(pred$uncertainty_prediction$predictions_ci$upper), n_times)
})

test_that("predict.disag_model_mmap_tmb works with field + shared random-betas mode", {
  bundle <- suppressWarnings(get_cached_tmb_fit(
    name = "pred_shared_random_betas_field",
    seed = 17L,
    iterations = 60,
    family = "poisson",
    link = "log",
    field = TRUE,
    iid = FALSE,
    time_varying_betas = FALSE,
    fixed_effect_betas = FALSE
  ))
  fit <- bundle$fit
  n_times <- length(fit$data$time_points)

  pred <- suppressMessages(predict(fit, N = 2, predict_iid = FALSE))

  expect_s3_class(pred, "disag_prediction_mmap")
  expect_equal(terra::nlyr(pred$mean_prediction$prediction), n_times)
  expect_true(inherits(pred$mean_prediction$field, "SpatRaster"))
  expect_equal(terra::nlyr(pred$mean_prediction$field), n_times)
  expect_equal(length(pred$uncertainty_prediction$realisations), n_times)
  expect_equal(terra::nlyr(pred$uncertainty_prediction$predictions_ci$lower), n_times)
  expect_equal(terra::nlyr(pred$uncertainty_prediction$predictions_ci$upper), n_times)
})

test_that("predict.disag_model_mmap_tmb works with time-varying random-betas mode", {
  bundle <- suppressWarnings(get_cached_tmb_fit(
    name = "pred_tv_random_betas",
    seed = 15L,
    iterations = 20,
    family = "poisson",
    link = "log",
    field = FALSE,
    iid = FALSE,
    time_varying_betas = TRUE,
    fixed_effect_betas = FALSE
  ))
  fit <- bundle$fit
  n_times <- length(fit$data$time_points)

  pred <- suppressMessages(predict(fit, N = 2, predict_iid = FALSE))

  expect_s3_class(pred, "disag_prediction_mmap")
  expect_equal(terra::nlyr(pred$mean_prediction$prediction), n_times)
  expect_equal(length(pred$uncertainty_prediction$realisations), n_times)
  expect_equal(terra::nlyr(pred$uncertainty_prediction$predictions_ci$lower), n_times)
  expect_equal(terra::nlyr(pred$uncertainty_prediction$predictions_ci$upper), n_times)
})

test_that("predict.disag_model_mmap_tmb uses single-raster new_data in mean and uncertainty paths", {
  bundle <- suppressWarnings(get_cached_tmb_fit(
    name = "pred_new_data_single",
    seed = 31L,
    iterations = 20,
    family = "poisson",
    link = "log",
    field = FALSE,
    iid = FALSE,
    time_varying_betas = FALSE,
    fixed_effect_betas = TRUE
  ))
  fit <- bundle$fit

  base_pred <- suppressMessages(predict(fit, N = 3, predict_iid = FALSE))
  new_data <- fit$data$covariate_rasters_list[[length(fit$data$covariate_rasters_list)]]
  for (k in seq_len(terra::nlyr(new_data))) {
    new_data[[k]] <- new_data[[k]] + 1000
  }
  shifted_pred <- suppressMessages(predict(fit, new_data = new_data, N = 3, predict_iid = FALSE))

  mean_delta <- terra::values(
    shifted_pred$mean_prediction$prediction - base_pred$mean_prediction$prediction,
    mat = FALSE
  )
  ci_delta <- terra::values(
    shifted_pred$uncertainty_prediction$predictions_ci$lower -
      base_pred$uncertainty_prediction$predictions_ci$lower,
    mat = FALSE
  )

  expect_gt(max(abs(mean_delta), na.rm = TRUE), 1e-6)
  expect_gt(max(abs(ci_delta), na.rm = TRUE), 1e-6)
})

test_that("predict.disag_model_mmap_tmb supports per-time new_data lists", {
  bundle <- suppressWarnings(get_cached_tmb_fit(
    name = "pred_new_data_list",
    seed = 33L,
    iterations = 20,
    family = "poisson",
    link = "log",
    field = FALSE,
    iid = FALSE,
    time_varying_betas = FALSE,
    fixed_effect_betas = TRUE
  ))
  fit <- bundle$fit
  n_times <- length(fit$data$time_points)

  base_pred <- suppressMessages(predict(fit, N = 2, predict_iid = FALSE))
  new_data_list <- lapply(seq_len(n_times), function(i) {
    r <- fit$data$covariate_rasters_list[[i]]
    for (k in seq_len(terra::nlyr(r))) {
      r[[k]] <- r[[k]] + (200 * i)
    }
    r
  })
  list_pred <- suppressMessages(predict(fit, new_data = new_data_list, N = 2, predict_iid = FALSE))

  layer_delta <- vapply(seq_len(n_times), function(i) {
    vals <- terra::values(
      list_pred$mean_prediction$prediction[[i]] - base_pred$mean_prediction$prediction[[i]],
      mat = FALSE
    )
    max(abs(vals), na.rm = TRUE)
  }, numeric(1))

  expect_true(all(layer_delta > 1e-6))
  expect_gt(stats::sd(layer_delta), 1e-6)
})

test_that("predict.disag_model_mmap_tmb validates new_data covariate names and counts", {
  bundle <- suppressWarnings(get_cached_tmb_fit(
    name = "pred_new_data_validation",
    seed = 34L,
    iterations = 20,
    family = "poisson",
    link = "log",
    field = FALSE,
    iid = FALSE,
    time_varying_betas = FALSE,
    fixed_effect_betas = TRUE
  ))
  fit <- bundle$fit
  new_data <- fit$data$covariate_rasters_list[[1]]

  bad_names <- new_data
  names(bad_names) <- paste0("bad_", names(bad_names))
  expect_error(
    suppressMessages(predict(fit, new_data = bad_names, N = 2, predict_iid = FALSE)),
    "Covariate layer names do not match training"
  )

  bad_count <- new_data[[1]]
  expect_error(
    suppressMessages(predict(fit, new_data = bad_count, N = 2, predict_iid = FALSE)),
    "Mismatch in covariate layer count for prediction"
  )
})

test_that("predict.disag_model_mmap_tmb reorders new_data layers when names match", {
  bundle <- suppressWarnings(get_cached_tmb_fit(
    name = "pred_new_data_reorder",
    seed = 35L,
    iterations = 20,
    family = "poisson",
    link = "log",
    field = FALSE,
    iid = FALSE,
    time_varying_betas = FALSE,
    fixed_effect_betas = TRUE
  ))
  fit <- bundle$fit
  new_data <- fit$data$covariate_rasters_list[[1]]
  rev_names <- rev(names(new_data))
  new_data_reordered <- new_data[[rev_names]]

  pred_expected <- suppressMessages(predict(fit, new_data = new_data, N = 2, predict_iid = FALSE))
  pred_reordered <- suppressMessages(predict(fit, new_data = new_data_reordered, N = 2, predict_iid = FALSE))

  expect_equal(
    terra::values(pred_reordered$mean_prediction$prediction, mat = FALSE),
    terra::values(pred_expected$mean_prediction$prediction, mat = FALSE),
    tolerance = 1e-8
  )
})

test_that("predict.disag_model_mmap_tmb includes iid predictions when enabled for supported families", {
  fixture <- make_fixture_fit_tmb(
    seed = 36L,
    n_times = 1,
    n_polygon_per_side = 3,
    n_pixels_per_side = 6
  )
  prepared <- prepare_data_mmap(
    polygon_shapefile_list = fixture$polygon_shapefile_list,
    covariate_rasters_list = fixture$covariate_rasters_list,
    aggregation_rasters_list = fixture$aggregation_rasters_list,
    make_mesh = TRUE
  )
  poisson_fit <- suppressWarnings(disag_model_mmap_tmb(
    data = prepared,
    family = "poisson",
    link = "log",
    iterations = 20,
    field = FALSE,
    iid = TRUE,
    time_varying_betas = FALSE,
    fixed_effect_betas = TRUE,
    silent = TRUE
  ))
  n_times <- length(poisson_fit$data$time_points)

  pred_iid <- suppressMessages(predict(poisson_fit, N = 2, predict_iid = TRUE))
  expect_true(inherits(pred_iid$mean_prediction$iid, "SpatRaster"))
  expect_equal(terra::nlyr(pred_iid$mean_prediction$iid), n_times)
  expect_false(all(is.na(terra::values(pred_iid$mean_prediction$iid, mat = FALSE))))

  nb_fit <- suppressWarnings(disag_model_mmap_tmb(
    data = prepared,
    family = "negbinomial",
    link = "log",
    iterations = 20,
    field = FALSE,
    iid = TRUE,
    time_varying_betas = FALSE,
    fixed_effect_betas = TRUE,
    silent = TRUE
  ))
  pred_nb <- suppressMessages(predict(nb_fit, N = 2, predict_iid = TRUE))
  expect_null(pred_nb$mean_prediction$iid)
})

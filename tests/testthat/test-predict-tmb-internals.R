make_onecell_raster <- function(value = 1, name = "x") {
  r <- terra::rast(ncols = 1, nrows = 1, xmin = 0, xmax = 1, ymin = 0, ymax = 1, crs = "EPSG:3857")
  terra::values(r) <- value
  names(r) <- name
  r
}

test_that("predict_single_raster_mmap applies supported links and rejects unsupported links", {
  covariates <- make_onecell_raster(value = 2, name = "temp")
  objects <- list(
    covariates = covariates,
    field_objects = NULL,
    iid_objects = NULL,
    time_index = 1L,
    time_varying_betas = FALSE
  )
  model_parameters <- list(intercept = 1, slope = 0.5)

  pred_identity <- DAST:::predict_single_raster_mmap(model_parameters, objects, link_function = "identity")
  pred_log <- DAST:::predict_single_raster_mmap(model_parameters, objects, link_function = "log")
  pred_logit <- DAST:::predict_single_raster_mmap(model_parameters, objects, link_function = "logit")

  lin <- 1 + 0.5 * 2
  expect_equal(as.numeric(terra::values(pred_identity$prediction, mat = FALSE)), lin, tolerance = 1e-8)
  expect_equal(as.numeric(terra::values(pred_log$prediction, mat = FALSE)), exp(lin), tolerance = 1e-8)
  expect_equal(
    as.numeric(terra::values(pred_logit$prediction, mat = FALSE)),
    1 / (1 + exp(-lin)),
    tolerance = 1e-8
  )

  expect_error(
    DAST:::predict_single_raster_mmap(model_parameters, objects, link_function = "unsupported"),
    "Link function not implemented"
  )
})

test_that("predict_single_raster_mmap validates time-varying parameter blocks", {
  cov_one <- make_onecell_raster(value = 3, name = "temp")
  cov_two <- c(cov_one, make_onecell_raster(value = 4, name = "precip"))

  objects_bad_index <- list(
    covariates = cov_one,
    field_objects = NULL,
    iid_objects = NULL,
    time_index = 0L,
    time_varying_betas = TRUE
  )
  expect_error(
    DAST:::predict_single_raster_mmap(list(intercept_t = c(1, 2), slope_t = c(0.1, 0.2)), objects_bad_index, "identity"),
    "time_index must be a positive integer"
  )

  objects_tv <- list(
    covariates = cov_one,
    field_objects = NULL,
    iid_objects = NULL,
    time_index = 2L,
    time_varying_betas = TRUE
  )

  expect_error(
    DAST:::predict_single_raster_mmap(list(intercept_t = 1, slope_t = c(0.1, 0.2)), objects_tv, "identity"),
    "intercept_t does not contain entry"
  )

  expect_error(
    DAST:::predict_single_raster_mmap(list(intercept_t = c(1, 2)), objects_tv, "identity"),
    "slope_t is missing"
  )

  objects_tv_two_cov <- list(
    covariates = cov_two,
    field_objects = NULL,
    iid_objects = NULL,
    time_index = 1L,
    time_varying_betas = TRUE
  )
  expect_error(
    DAST:::predict_single_raster_mmap(list(intercept_t = c(1, 2), slope_t = c(0.1, 0.2, 0.3)), objects_tv_two_cov, "identity"),
    "not a multiple"
  )

  objects_tv_oob <- list(
    covariates = cov_two,
    field_objects = NULL,
    iid_objects = NULL,
    time_index = 2L,
    time_varying_betas = TRUE
  )
  expect_error(
    DAST:::predict_single_raster_mmap(list(intercept_t = c(1, 2), slope_t = c(0.1, 0.2)), objects_tv_oob, "identity"),
    "exceed length of slope_t"
  )
})

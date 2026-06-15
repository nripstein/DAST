capture_warnings_mmap <- function(expr) {
  warnings <- character(0)
  value <- withCallingHandlers(
    expr,
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
  list(value = value, warnings = warnings)
}

resolve_engine_args_for_test <- function(engine,
                                         engine_args = list(),
                                         legacy_named_args = list(),
                                         dot_engine_args = list()) {
  spec <- DAST:::get_engine_specs_mmap()[[engine]]
  DAST:::resolve_engine_args_mmap(
    engine = engine,
    engine_spec = spec,
    engine_args = engine_args,
    legacy_named_args = legacy_named_args,
    dot_engine_args = dot_engine_args
  )
}

test_that("engine.args routes TMB-specific controls", {
  resolved <- resolve_engine_args_for_test(
    "TMB",
    engine_args = list(
      iterations = 20,
      hess_control_ndeps = 1e-4
    )
  )
  resolved <- DAST:::validate_engine_specific_values("TMB", resolved)

  expect_identical(resolved$iterations, 20L)
  expect_equal(resolved$hess_control_ndeps, 1e-4)
  expect_equal(resolved$outer_derivative_method, "tmb")
})

test_that("engine.args routes TMB finite-difference outer derivatives", {
  resolved <- resolve_engine_args_for_test(
    "TMB",
    engine_args = list(
      iterations = 20,
      outer_derivative_method = "finite_difference"
    )
  )
  resolved <- DAST:::validate_engine_specific_values("TMB", resolved)

  expect_identical(resolved$iterations, 20L)
  expect_equal(resolved$outer_derivative_method, "finite_difference")
})

test_that("engine.args unknown keys warn and are ignored", {
  out <- capture_warnings_mmap(
    resolve_engine_args_for_test(
      "TMB",
      engine_args = list(iterations = 20, banana = 123)
    )
  )

  expect_true(any(grepl("Ignoring unknown `engine.args` key", out$warnings)))
  expect_identical(out$value$iterations, 20)
  expect_false("banana" %in% names(out$value))
})

test_that("legacy engine-specific args in dots are deprecated but still supported", {
  resolved <- resolve_engine_args_for_test(
    "TMB",
    dot_engine_args = list(iterations = 20)
  )

  expect_identical(resolved$iterations, 20)
  expect_warning(
    expect_error(
      disag_model_mmap(data = NULL, engine = "TMB", iterations = 20),
      "data must be an object of class 'disag_data_mmap'"
    ),
    "Engine-specific arguments in `\\.\\.\\.` are deprecated"
  )
})

test_that("AGHQ-specific top-level args are warned and ignored under TMB", {
  skip_tmb_integration()
  data_obj <- get_cached_prepared_data("prep_default_mesh")
  out <- capture_warnings_mmap(
    suppressMessages(
      disag_model_mmap(
        data = data_obj,
        engine = "TMB",
        family = "poisson",
        link = "log",
        engine.args = list(iterations = 20),
        aghq_k = 3,
        optimizer = "BFGS",
        field = FALSE,
        iid = FALSE,
        silent = TRUE
      )
    )
  )

  expect_true(any(grepl("`aghq_k` is AGHQ-specific and was ignored", out$warnings)))
  expect_true(any(grepl("`optimizer` is AGHQ-specific and was ignored", out$warnings)))
  expect_s3_class(out$value, "disag_model_mmap_tmb")
})

test_that("fixed_effect_betas FALSE is honored under TMB", {
  skip_tmb_integration()
  data_obj <- get_cached_prepared_data("prep_default_mesh")
  out <- capture_warnings_mmap(
    suppressMessages(
      disag_model_mmap(
        data = data_obj,
        engine = "TMB",
        family = "poisson",
        link = "log",
        engine.args = list(iterations = 20),
        fixed_effect_betas = FALSE,
        field = FALSE,
        iid = FALSE,
        silent = TRUE
      )
    )
  )

  expect_false(any(grepl("currently implemented for `engine = \"AGHQ\"` only", out$warnings)))
  expect_s3_class(out$value, "disag_model_mmap_tmb")
  expect_false(isTRUE(out$value$model_setup$fixed_effect_betas))
  expect_equal(out$value$model_setup$beta_index_map$source, "random")
})

test_that("invalid engine.args container and names are rejected", {
  data_obj <- get_cached_prepared_data("prep_default_mesh")

  expect_error(
    disag_model_mmap(
      data = data_obj,
      engine = "TMB",
      engine.args = 1
    ),
    "`engine.args` must be NULL or a named list"
  )

  expect_error(
    disag_model_mmap(
      data = data_obj,
      engine = "TMB",
      engine.args = list(1)
    ),
    "`engine.args` must be a named list"
  )

  expect_error(
    disag_model_mmap(
      data = data_obj,
      engine = "TMB",
      engine.args = structure(list(10, 20), names = c("iterations", "iterations"))
    ),
    "duplicated names"
  )
})

test_that("invalid engine-specific values are rejected before fit", {
  data_obj <- get_cached_prepared_data("prep_default_mesh")

  expect_error(
    disag_model_mmap(
      data = data_obj,
      engine = "TMB",
      engine.args = list(iterations = 0)
    ),
    "`iterations` must be an integer-like scalar >= 1"
  )

  expect_error(
    disag_model_mmap(
      data = data_obj,
      engine = "TMB",
      engine.args = list(hess_control_ndeps = 0)
    ),
    "`hess_control_ndeps` must be a numeric scalar > 0"
  )

  expect_error(
    disag_model_mmap(
      data = data_obj,
      engine = "AGHQ",
      engine.args = list(aghq_k = 0)
    ),
    "`aghq_k` must be an integer-like scalar >= 1"
  )

  expect_error(
    disag_model_mmap(
      data = data_obj,
      engine = "AGHQ",
      engine.args = list(optimizer = 1)
    ),
    "`optimizer` must be a non-empty character scalar"
  )

  expect_error(
    disag_model_mmap(
      data = data_obj,
      engine = "TMB",
      engine.args = list(outer_derivative_method = "fd")
    ),
    "`outer_derivative_method` must be one of"
  )

  expect_error(
    disag_model_mmap(
      data = data_obj,
      engine = "AGHQ",
      engine.args = list(
        optimizer = "BFGS",
        outer_derivative_method = "finite_difference"
      )
    ),
    "requires `engine.args = list\\(optimizer = \"nlminb\"\\)`"
  )
})

test_that("AGHQ engine.args are routed and default k in wrapper remains 2 (gated)", {
  skip_aghq_integration()
  data_obj <- get_cached_aghq_prepared_data("aghq_small_onecov_mesh")

  fit <- suppressWarnings(
    disag_model_mmap(
      data = data_obj,
      engine = "AGHQ",
      family = "poisson",
      link = "log",
      engine.args = list(aghq_k = 1, optimizer = "BFGS"),
      field = TRUE,
      iid = TRUE,
      silent = TRUE
    )
  )
  expect_s3_class(fit, "disag_model_mmap_aghq")
  expect_equal(as.integer(fit$aghq_model$normalized_posterior$grid$level[[1]]), 1L)

  fit_default <- suppressWarnings(
    disag_model_mmap(
      data = data_obj,
      engine = "AGHQ",
      family = "poisson",
      link = "log",
      field = TRUE,
      iid = TRUE,
      silent = TRUE
    )
  )
  expect_s3_class(fit_default, "disag_model_mmap_aghq")
  expect_equal(as.integer(fit_default$aghq_model$normalized_posterior$grid$level[[1]]), 2L)
})

test_that("AGHQ engine.args route finite-difference outer derivatives with nlminb (gated)", {
  skip_aghq_integration()
  data_obj <- get_cached_aghq_prepared_data("aghq_small_onecov_mesh")

  fit <- suppressWarnings(
    disag_model_mmap(
      data = data_obj,
      engine = "AGHQ",
      family = "poisson",
      link = "log",
      engine.args = list(
        aghq_k = 1,
        optimizer = "nlminb",
        outer_derivative_method = "finite_difference"
      ),
      field = TRUE,
      iid = TRUE,
      silent = TRUE
    )
  )

  expect_s3_class(fit, "disag_model_mmap_aghq")
  expect_equal(fit$model_setup$outer_derivative_method, "finite_difference")
  expect_equal(as.integer(fit$aghq_model$normalized_posterior$grid$level[[1]]), 1L)
})

test_that("legacy AGHQ top-level args are deprecated but still supported (gated)", {
  skip_aghq_integration()
  data_obj <- get_cached_aghq_prepared_data("aghq_small_onecov_mesh")
  out <- capture_warnings_mmap(
    suppressMessages(
      disag_model_mmap(
        data = data_obj,
        engine = "AGHQ",
        family = "poisson",
        link = "log",
        aghq_k = 1,
        optimizer = "BFGS",
        field = TRUE,
        iid = TRUE,
        silent = TRUE
      )
    )
  )

  expect_true(any(grepl("`aghq_k` in `disag_model_mmap\\(\\)` is deprecated", out$warnings)))
  expect_true(any(grepl("`optimizer` in `disag_model_mmap\\(\\)` is deprecated", out$warnings)))
  expect_s3_class(out$value, "disag_model_mmap_aghq")
})

test_that("AGHQ helper keeps a legacy fixture path for compatibility checks (gated)", {
  skip_aghq_integration()
  out <- capture_warnings_mmap(
    get_cached_aghq_fit("aghq_small_onecov_shared", use_legacy_args = TRUE)
  )

  expect_true(any(grepl("deprecated", out$warnings)))
  expect_s3_class(out$value$fit, "disag_model_mmap_aghq")
})

test_that("engine.args wins in AGHQ conflicts with legacy top-level args (gated)", {
  skip_aghq_integration()
  data_obj <- get_cached_aghq_prepared_data("aghq_small_onecov_mesh")
  out <- capture_warnings_mmap(
    suppressMessages(
      disag_model_mmap(
        data = data_obj,
        engine = "AGHQ",
        family = "poisson",
        link = "log",
        engine.args = list(aghq_k = 1),
        aghq_k = 2,
        field = TRUE,
        iid = TRUE,
        silent = TRUE
      )
    )
  )

  expect_true(any(grepl("Argument conflict for `aghq_k`", out$warnings)))
  expect_s3_class(out$value, "disag_model_mmap_aghq")
  expect_equal(as.integer(out$value$aghq_model$normalized_posterior$grid$level[[1]]), 1L)
})

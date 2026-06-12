skip_if_mcmc_opted_out <- function() {
  skip_on_cran()
  run_mcmc <- tolower(Sys.getenv("RUN_MCMC_TESTS", "false")) %in% c("1", "true", "yes")
  skip_if_not(
    run_mcmc,
    message = "MCMC integration test is opt-in locally; set RUN_MCMC_TESTS=true to run it."
  )
}

test_that("MCMC engine is registered and validates engine.args before fitting", {
  expect_true("MCMC" %in% names(DAST:::get_engine_specs_mmap()))

  expect_error(
    disag_model_mmap(
      data = NULL,
      engine = "MCMC",
      engine.args = list(iter = 0)
    ),
    "`iter` must be an integer-like scalar >= 1"
  )
})

test_that("MCMC engine.args validates common tmbstan controls", {
  expect_error(
    disag_model_mmap(data = NULL, engine = "MCMC", engine.args = list(chains = 0)),
    "`chains` must be an integer-like scalar >= 1"
  )
  expect_error(
    disag_model_mmap(data = NULL, engine = "MCMC", engine.args = list(warmup = -1)),
    "`warmup` must be an integer-like scalar >= 0"
  )
  expect_error(
    disag_model_mmap(data = NULL, engine = "MCMC", engine.args = list(iter = 10, warmup = 10)),
    "`warmup` must be less than `iter`"
  )
  expect_error(
    disag_model_mmap(data = NULL, engine = "MCMC", engine.args = list(thin = 0)),
    "`thin` must be an integer-like scalar >= 1"
  )
  expect_error(
    disag_model_mmap(data = NULL, engine = "MCMC", engine.args = list(cores = 0)),
    "`cores` must be an integer-like scalar >= 1"
  )
  expect_error(
    disag_model_mmap(data = NULL, engine = "MCMC", engine.args = list(laplace = NA)),
    "`laplace` must be a TRUE/FALSE scalar"
  )
  expect_error(
    disag_model_mmap(data = NULL, engine = "MCMC", engine.args = list(control = 1)),
    "`control` must be NULL or a list"
  )
})

test_that("MCMC engine.args preserves arbitrary pass-through keys", {
  spec <- DAST:::get_engine_specs_mmap()$MCMC
  resolved <- DAST:::resolve_engine_args_mmap(
    engine = "MCMC",
    engine_spec = spec,
    engine_args = list(iter = 20, adapt_delta = 0.95, max_treedepth = 12),
    legacy_named_args = list(),
    dot_engine_args = list()
  )
  resolved <- DAST:::validate_engine_specific_values("MCMC", resolved)

  expect_equal(resolved$iter, 20L)
  expect_equal(resolved$adapt_delta, 0.95)
  expect_equal(resolved$max_treedepth, 12)
})

test_that("MCMC engine.args rejects top-level argument duplicates", {
  expect_error(
    disag_model_mmap(data = NULL, engine = "MCMC", engine.args = list(silent = FALSE)),
    "must be supplied as top-level arguments"
  )
})

test_that("predict.disag_model_mmap_mcmc errors clearly", {
  fake <- structure(list(), class = c("disag_model_mmap_mcmc", "disag_model_mmap", "list"))

  expect_error(
    predict(fake),
    "Prediction is not implemented for the MCMC engine"
  )
})

test_that("MCMC engine returns expected fit contract (gated)", {
  skip_if_not_installed("tmbstan")
  skip_if_mcmc_opted_out()

  data_obj <- get_cached_aghq_prepared_data("aghq_small_onecov_mesh")

  fit <- suppressWarnings(
    suppressMessages(
      disag_model_mmap(
        data = data_obj,
        engine = "MCMC",
        family = "poisson",
        link = "log",
        engine.args = list(
          chains = 1,
          iter = 4,
          warmup = 2,
          refresh = 0
        ),
        field = FALSE,
        iid = FALSE,
        silent = TRUE
      )
    )
  )

  expect_s3_class(fit, "disag_model_mmap_mcmc")
  expect_s3_class(fit, "disag_model_mmap")
  expect_true(all(c("stanfit", "obj", "data", "model_setup") %in% names(fit)))
  expect_equal(fit$model_setup$family, "poisson")
  expect_equal(fit$model_setup$link, "log")
  expect_false(isTRUE(fit$model_setup$field))
  expect_false(isTRUE(fit$model_setup$iid))
  expect_false(isTRUE(fit$model_setup$mcmc_args$laplace))

  s <- summary(fit)
  expect_s3_class(s, "summary.disag_model_mmap_mcmc")
  expect_true(is.data.frame(s$parameter_summary))
  expect_true(nrow(s$parameter_summary) > 0L)

  expect_error(
    predict(fit),
    "Prediction is not implemented for the MCMC engine"
  )
})

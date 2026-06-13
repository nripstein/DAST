skip_if_mcmc_opted_out <- function() {
  skip_on_cran()
  run_mcmc <- tolower(Sys.getenv("RUN_MCMC_TESTS", "false")) %in% c("1", "true", "yes")
  skip_if_not(
    run_mcmc,
    message = "MCMC integration test is opt-in locally; set RUN_MCMC_TESTS=true to run it."
  )
}

make_mcmc_summary_matrix <- function(rows = c("intercept", "slope", "lp__")) {
  mat <- matrix(
    c(
      1, 0.1, 0.2, 0.5, 1.0, 1.5, 20, 1.01,
      2, 0.2, 0.3, 1.5, 2.0, 2.5, 30, 1.02,
      -3, 0.3, 0.4, -4, -3, -2, 40, 1.00
    ),
    nrow = 3,
    byrow = TRUE,
    dimnames = list(rows, c("mean", "se_mean", "sd", "2.5%", "50%", "97.5%", "n_eff", "Rhat"))
  )
  mat[seq_along(rows), , drop = FALSE]
}

make_fake_stan_summary <- function(summary = make_mcmc_summary_matrix()) {
  structure(list(summary = summary), class = "fake_mcmc_summary_matrix")
}

make_fake_stan_summary_list <- function(summary = make_mcmc_summary_matrix()) {
  structure(list(summary = summary), class = "fake_mcmc_summary_list")
}

make_fake_stan_bad_summary <- function() {
  structure(list(), class = "fake_mcmc_bad_summary")
}

if (!isClass("fake_mcmc_stanfit")) {
  setClass("fake_mcmc_stanfit", slots = list(sim = "list"))
}

make_fake_stan_slot <- function(names = c("intercept", "slope", "lp__")) {
  new("fake_mcmc_stanfit", sim = list(fnames_oi = names))
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

test_that("validate_mcmc_engine_args_values coerces valid controls and keeps nullable defaults", {
  out <- DAST:::validate_mcmc_engine_args_values(list(
    chains = 2,
    iter = 20,
    warmup = 5,
    thin = 2,
    cores = 1,
    seed = 123,
    refresh = 0,
    laplace = FALSE,
    lower = c(-Inf, 0),
    upper = c(Inf, 10),
    control = list(adapt_delta = 0.9)
  ))

  expect_identical(out$chains, 2L)
  expect_identical(out$iter, 20L)
  expect_identical(out$warmup, 5L)
  expect_identical(out$thin, 2L)
  expect_identical(out$cores, 1L)
  expect_identical(out$seed, 123L)
  expect_identical(out$refresh, 0L)
  expect_false(out$laplace)
  expect_equal(out$lower, c(-Inf, 0))
  expect_equal(out$upper, c(Inf, 10))
  expect_equal(out$control, list(adapt_delta = 0.9))

  nullable <- DAST:::validate_mcmc_engine_args_values(list(
    warmup = NULL,
    cores = NULL,
    seed = NULL,
    refresh = NULL,
    control = NULL
  ))
  expect_null(nullable$warmup)
  expect_null(nullable$cores)
  expect_null(nullable$seed)
  expect_null(nullable$refresh)
  expect_null(nullable$control)
})

test_that("validate_mcmc_engine_args_values rejects malformed common controls", {
  expect_error(DAST:::validate_mcmc_engine_args_values(1), "must be a list")
  expect_error(DAST:::validate_mcmc_engine_args_values(list(chains = NA_real_)), "`chains`")
  expect_error(DAST:::validate_mcmc_engine_args_values(list(iter = c(10, 20))), "`iter`")
  expect_error(DAST:::validate_mcmc_engine_args_values(list(seed = 0)), "`seed`")
  expect_error(DAST:::validate_mcmc_engine_args_values(list(refresh = -1)), "`refresh`")
  expect_error(DAST:::validate_mcmc_engine_args_values(list(lower = c(0, NA))), "`lower`")
  expect_error(DAST:::validate_mcmc_engine_args_values(list(upper = "bad")), "`upper`")
  expect_error(DAST:::validate_mcmc_engine_args_values(list(control = 1)), "`control`")
})

test_that("validate_mcmc_bounds accepts supported lengths and rejects mismatches", {
  obj <- list(
    par = stats::setNames(c(1, 2), c("intercept", "slope")),
    env = list(par = stats::setNames(c(1, 2, 3), c("intercept", "slope", "nodemean")))
  )

  expect_true(DAST:::validate_mcmc_bounds(numeric(0), numeric(0), obj))
  expect_true(DAST:::validate_mcmc_bounds(c(-Inf, -Inf), c(Inf, Inf), obj))
  expect_true(DAST:::validate_mcmc_bounds(c(-Inf, -Inf, -Inf), c(Inf, Inf, Inf), obj))

  expect_error(
    DAST:::validate_mcmc_bounds(c(-Inf), numeric(0), obj),
    "length 0, length\\(obj\\$par\\)"
  )
  expect_error(
    DAST:::validate_mcmc_bounds(c(2, 1), c(1, 2), obj),
    "`lower` cannot exceed `upper`"
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

test_that("build_mcmc_parameter_metadata handles shared and random-effect parameter names", {
  obj <- list(
    par = stats::setNames(c(1, 2), c("intercept", "slope")),
    env = list(
      par = stats::setNames(c(1, 2, 3, 4), c("intercept", "slope", "nodemean[1]", "iideffect[1]")),
      random = c(3L, 4L)
    )
  )
  coef_meta <- list(p = 1L, n_times = 1L, cov_names = "temp")
  stanfit <- make_fake_stan_slot(c("intercept", "slope", "nodemean[1]", "lp__"))

  out <- DAST:::build_mcmc_parameter_metadata(
    obj = obj,
    stanfit = stanfit,
    coef_meta = coef_meta,
    time_varying_betas = FALSE
  )

  expect_equal(out$fixed_order, c("intercept", "temp"))
  expect_equal(out$random_order, c("nodemean", "iideffect"))
  expect_equal(out$full_order, c("intercept", "temp", "nodemean", "iideffect"))
  expect_equal(out$sampled_parameter_names_raw, c("intercept", "slope", "nodemean[1]"))
  expect_equal(out$sampled_parameter_names, c("intercept", "temp", "nodemean"))
})

test_that("build_mcmc_parameter_metadata handles time-varying and no-random-effect models", {
  obj <- list(
    par = stats::setNames(c(1, 2, 3, 4), c("intercept_t", "intercept_t1", "slope_t", "slope_t1")),
    env = list(
      par = stats::setNames(c(1, 2, 3, 4), c("intercept_t", "intercept_t1", "slope_t", "slope_t1")),
      random = integer(0)
    )
  )
  coef_meta <- list(p = 1L, n_times = 2L, cov_names = "temp")
  stanfit <- make_fake_stan_slot(c("intercept_t", "intercept_t1", "slope_t", "slope_t1", "lp__"))

  out <- DAST:::build_mcmc_parameter_metadata(
    obj = obj,
    stanfit = stanfit,
    coef_meta = coef_meta,
    time_varying_betas = TRUE
  )

  expect_equal(out$fixed_order, c("intercept_t1", "intercept_t2", "temp_t1", "temp_t2"))
  expect_equal(out$random_order, character(0))
  expect_equal(out$full_order, c("intercept_t1", "intercept_t2", "temp_t1", "temp_t2"))
  expect_equal(out$sampled_parameter_names, c("intercept_t1", "intercept_t2", "temp_t1", "temp_t2"))
})

test_that("extract_mcmc_stan_parameter_names supports slot, summary, and empty fallbacks", {
  slot_fit <- make_fake_stan_slot(c("intercept", "slope", "lp__"))
  expect_equal(
    DAST:::extract_mcmc_stan_parameter_names(slot_fit),
    c("intercept", "slope")
  )

  summary_fit <- make_fake_stan_summary(make_mcmc_summary_matrix(c("alpha", "beta", "lp__")))
  expect_equal(
    DAST:::extract_mcmc_stan_parameter_names(summary_fit),
    c("alpha", "beta")
  )

  expect_equal(
    DAST:::extract_mcmc_stan_parameter_names(make_fake_stan_bad_summary()),
    character(0)
  )
})

test_that("mcmc summary helpers handle matrix, list, canonicalization, filtering, and bad summaries", {
  mat_fit <- make_mcmc_summary_matrix(c("slope", "nodemean[1]", "lp__"))
  mat <- DAST:::mcmc_stan_summary_matrix(mat_fit)
  expect_true(is.matrix(mat))
  expect_equal(rownames(mat), c("slope", "nodemean[1]", "lp__"))

  list_fit <- make_fake_stan_summary_list(make_mcmc_summary_matrix(c("slope", "nodemean[1]", "lp__")))
  list_mat <- DAST:::mcmc_stan_summary_matrix(list_fit)
  expect_true(is.matrix(list_mat))

  tbl <- DAST:::mcmc_parameter_summary_table(
    stanfit = list_fit,
    coef_meta = list(p = 1L, n_times = 1L, cov_names = "temp"),
    time_varying_betas = FALSE
  )
  expect_equal(tbl$parameter, c("temp", "nodemean"))
  expect_equal(tbl$original_parameter, c("slope", "nodemean[1]"))
  expect_true(all(c("mean", "n_eff", "Rhat") %in% names(tbl)))

  expect_error(
    DAST:::mcmc_stan_summary_matrix(make_fake_stan_bad_summary()),
    "Could not extract a parameter summary table"
  )
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

test_that("MCMC print and summary methods work with fake fits", {
  fake_fit <- structure(
    list(
      stanfit = make_fake_stan_summary(make_mcmc_summary_matrix(c("slope", "nodemean[1]", "lp__"))),
      model_setup = list(
        family = "poisson",
        link = "log",
        field = TRUE,
        iid = FALSE,
        time_varying_betas = FALSE,
        fixed_effect_betas = TRUE,
        coef_meta = list(p = 1L, n_times = 1L, cov_names = "temp"),
        mcmc_args = list(chains = 2L, iter = 100L, warmup = 50L, thin = 1L, laplace = FALSE),
        sampled_parameter_names_raw = c("slope", "nodemean[1]")
      )
    ),
    class = c("disag_model_mmap_mcmc", "disag_model_mmap", "list")
  )

  printed <- capture.output(print(fake_fit))
  expect_true(any(grepl("fit with MCMC", printed)))
  expect_true(any(grepl("Family: poisson", printed)))
  expect_true(any(grepl("Chains: 2", printed)))
  return_printed <- capture.output(return_value <- print(fake_fit))
  expect_true(length(return_printed) > 0L)
  expect_identical(return_value, fake_fit)

  s <- summary(fake_fit)
  expect_s3_class(s, "summary.disag_model_mmap_mcmc")
  expect_true(is.data.frame(s$parameter_summary))
  expect_true(is.data.frame(s$diagnostics))
  expect_identical(s$stanfit, fake_fit$stanfit)

  summary_printed <- capture.output(print(s, max_print = 1))
  expect_true(any(grepl("Summary of disaggregation model", summary_printed)))
  expect_true(any(grepl("Showing 1 of", summary_printed)))

  empty_summary <- s
  empty_summary$parameter_summary <- s$parameter_summary[0, , drop = FALSE]
  expect_output(print(empty_summary), "No MCMC summary information available")
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

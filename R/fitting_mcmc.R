#' Fit a multi-map disaggregation model via tmbstan MCMC
#'
#' @description
#' Builds the shared TMB ADFun object for a multi-map disaggregation model, then
#' samples from it with \code{tmbstan::tmbstan()}. This engine supports
#' parameter estimation only; prediction is not implemented for MCMC fits.
#'
#' @param data A 'disag_data_mmap' object (from 'prepare_data_mmap()').
#' @param priors Optional named list of prior specifications.
#' @param family One of 'gaussian', 'binomial', 'poisson', or 'negbinomial'.
#' @param link One of 'identity', 'logit', or 'log'.
#' @param time_varying_betas Logical; if TRUE, each time point has its own fixed-effect.
#' @param fixed_effect_betas Logical; if TRUE (default), active beta coefficients
#'   are sampled as fixed effects. If FALSE, active beta coefficients are included
#'   in the TMB random-effect block.
#' @param chains Integer >= 1; number of MCMC chains.
#' @param iter Integer >= 1; total Stan iterations per chain, including warmup.
#' @param warmup Integer >= 0 and less than \code{iter}; warmup iterations per
#'   chain. Defaults to \code{floor(iter / 2)}.
#' @param thin Integer >= 1; thinning interval.
#' @param cores Integer >= 1; number of cores passed to Stan. Defaults to
#'   \code{getOption("mc.cores", chains)}.
#' @param seed Optional positive integer seed.
#' @param refresh Optional integer >= 0; Stan progress refresh interval.
#' @param laplace Logical; passed to \code{tmbstan::tmbstan()}. Defaults to
#'   \code{FALSE} for full posterior sampling.
#' @param lower Numeric lower bounds passed to \code{tmbstan::tmbstan()}.
#' @param upper Numeric upper bounds passed to \code{tmbstan::tmbstan()}.
#' @param control Optional list passed to \code{rstan::sampling()}.
#' @param field Logical: include the spatial random field?
#' @param iid Logical: include polygon-specific IID effects?
#' @param silent Logical: if TRUE, suppress TMB/tmbstan console output.
#' @param starting_values Optional named list of starting parameter values.
#' @param verbose Logical: if TRUE, print total runtime.
#' @param ... Additional arguments passed through to \code{tmbstan::tmbstan()}
#'   and \code{rstan::sampling()}.
#'
#' @return An object of class 'disag_model_mmap_mcmc' with components
#'   \code{stanfit}, \code{obj}, \code{data}, and \code{model_setup}.
#' @export
disag_model_mmap_mcmc <- function(data,
                                  priors = NULL,
                                  family = "poisson",
                                  link = "log",
                                  time_varying_betas = FALSE,
                                  fixed_effect_betas = TRUE,
                                  chains = 4L,
                                  iter = 2000L,
                                  warmup = NULL,
                                  thin = 1L,
                                  cores = NULL,
                                  seed = NULL,
                                  refresh = NULL,
                                  laplace = FALSE,
                                  lower = numeric(0),
                                  upper = numeric(0),
                                  control = NULL,
                                  field = TRUE,
                                  iid = TRUE,
                                  silent = TRUE,
                                  starting_values = NULL,
                                  verbose = FALSE,
                                  ...) {
  start_time <- Sys.time()

  if (!requireNamespace("tmbstan", quietly = TRUE)) {
    stop(
      "The MCMC engine requires the suggested package `tmbstan`. ",
      "Install it with install.packages(\"tmbstan\") and try again.",
      call. = FALSE
    )
  }

  if (!inherits(data, "disag_data_mmap")) {
    stop("`data` must be a 'disag_data_mmap' object; run prepare_data_mmap() first.",
         call. = FALSE)
  }
  if (!is.null(priors) && !is.list(priors)) {
    stop("`priors` must be NULL or a named list of prior values.", call. = FALSE)
  }

  sampling_args <- validate_mcmc_engine_args_values(list(
    chains = chains,
    iter = iter,
    warmup = warmup,
    thin = thin,
    cores = cores,
    seed = seed,
    refresh = refresh,
    laplace = laplace,
    lower = lower,
    upper = upper,
    control = control
  ))

  chains <- sampling_args$chains
  iter <- sampling_args$iter
  warmup <- sampling_args$warmup
  thin <- sampling_args$thin
  cores <- sampling_args$cores
  seed <- sampling_args$seed
  refresh <- sampling_args$refresh
  laplace <- sampling_args$laplace
  lower <- sampling_args$lower
  upper <- sampling_args$upper
  control <- sampling_args$control

  if (is.null(warmup)) {
    warmup <- as.integer(floor(iter / 2))
  }
  if (is.null(cores)) {
    cores <- getOption("mc.cores", chains)
  }

  sampling_args <- validate_mcmc_engine_args_values(list(
    chains = chains,
    iter = iter,
    warmup = warmup,
    thin = thin,
    cores = cores,
    seed = seed,
    refresh = refresh,
    laplace = laplace,
    lower = lower,
    upper = upper,
    control = control
  ))

  chains <- sampling_args$chains
  iter <- sampling_args$iter
  warmup <- sampling_args$warmup
  thin <- sampling_args$thin
  cores <- sampling_args$cores
  seed <- sampling_args$seed
  refresh <- sampling_args$refresh
  laplace <- sampling_args$laplace
  lower <- sampling_args$lower
  upper <- sampling_args$upper
  control <- sampling_args$control

  obj <- make_model_object_mmap(
    data = data,
    priors = priors,
    family = family,
    link = link,
    time_varying_betas = time_varying_betas,
    fixed_effect_betas = fixed_effect_betas,
    field = field,
    iid = iid,
    silent = silent,
    starting_values = starting_values,
    verbose = verbose
  )

  validate_mcmc_bounds(lower = lower, upper = upper, obj = obj)

  if (isTRUE(laplace) && isFALSE(fixed_effect_betas)) {
    warning(
      paste0(
        "`laplace = TRUE` with `fixed_effect_betas = FALSE` integrates beta ",
        "coefficients in the TMB random-effect block rather than sampling them."
      ),
      call. = FALSE
    )
  }

  message("Fitting ", family, " disaggregation model via MCMC with tmbstan.")

  tmbstan_args <- list(
    obj = obj,
    chains = chains,
    iter = iter,
    warmup = warmup,
    thin = thin,
    cores = cores,
    lower = lower,
    upper = upper,
    laplace = laplace,
    silent = silent
  )
  if (!is.null(seed)) {
    tmbstan_args$seed <- seed
  }
  if (!is.null(refresh)) {
    tmbstan_args$refresh <- refresh
  }
  if (!is.null(control)) {
    tmbstan_args$control <- control
  }
  tmbstan_args <- c(tmbstan_args, list(...))

  stanfit <- do.call(tmbstan::tmbstan, tmbstan_args)

  coef_meta <- compute_coef_meta(data)
  parameter_metadata <- build_mcmc_parameter_metadata(
    obj = obj,
    stanfit = stanfit,
    coef_meta = coef_meta,
    time_varying_betas = time_varying_betas
  )

  model_output <- list(
    stanfit = stanfit,
    obj = obj,
    data = data,
    model_setup = list(
      family = family,
      link = link,
      field = field,
      iid = iid,
      time_varying_betas = time_varying_betas,
      fixed_effect_betas = fixed_effect_betas,
      coef_meta = coef_meta,
      mcmc_args = list(
        chains = chains,
        iter = iter,
        warmup = warmup,
        thin = thin,
        cores = cores,
        seed = seed,
        refresh = refresh,
        laplace = laplace,
        control = control
      ),
      theta_order = parameter_metadata$theta_order,
      fixed_order = parameter_metadata$fixed_order,
      random_order = parameter_metadata$random_order,
      full_order = parameter_metadata$full_order,
      sampled_parameter_names = parameter_metadata$sampled_parameter_names,
      sampled_parameter_names_raw = parameter_metadata$sampled_parameter_names_raw
    )
  )

  class(model_output) <- c("disag_model_mmap_mcmc", "disag_model_mmap", "list")

  if (verbose) {
    elapsed <- difftime(Sys.time(), start_time, units = "mins")
    message(sprintf("disag_model_mmap_mcmc() runtime: %.2f minutes", as.numeric(elapsed)))
  }

  model_output
}

validate_mcmc_engine_args_values <- function(resolved_engine_args) {
  if (!is.list(resolved_engine_args)) {
    stop("Internal: MCMC engine arguments must be a list.", call. = FALSE)
  }

  is_scalar_integerish <- function(x) {
    is.numeric(x) && length(x) == 1L && is.finite(x) && abs(x - round(x)) < 1e-8
  }

  validate_int <- function(key, min_value) {
    if (!(key %in% names(resolved_engine_args))) return(invisible(NULL))
    val <- resolved_engine_args[[key]]
    if (is.null(val)) return(invisible(NULL))
    if (!is_scalar_integerish(val) || val < min_value) {
      stop(
        "`", key, "` must be an integer-like scalar >= ", min_value, ".",
        call. = FALSE
      )
    }
    resolved_engine_args[[key]] <<- as.integer(round(val))
    invisible(NULL)
  }

  validate_int("chains", 1L)
  validate_int("iter", 1L)
  validate_int("warmup", 0L)
  validate_int("thin", 1L)
  validate_int("cores", 1L)
  validate_int("seed", 1L)
  validate_int("refresh", 0L)

  if (all(c("iter", "warmup") %in% names(resolved_engine_args)) &&
      !is.null(resolved_engine_args$iter) &&
      !is.null(resolved_engine_args$warmup) &&
      resolved_engine_args$warmup >= resolved_engine_args$iter) {
    stop("`warmup` must be less than `iter`.", call. = FALSE)
  }

  if ("laplace" %in% names(resolved_engine_args)) {
    laplace <- resolved_engine_args$laplace
    if (!is.logical(laplace) || length(laplace) != 1L || is.na(laplace)) {
      stop("`laplace` must be a TRUE/FALSE scalar.", call. = FALSE)
    }
  }

  for (key in c("lower", "upper")) {
    if (key %in% names(resolved_engine_args)) {
      bound <- resolved_engine_args[[key]]
      if (!is.numeric(bound) || anyNA(bound)) {
        stop("`", key, "` must be a numeric vector without missing values.", call. = FALSE)
      }
    }
  }

  if ("control" %in% names(resolved_engine_args)) {
    control <- resolved_engine_args$control
    if (!(is.null(control) || is.list(control))) {
      stop("`control` must be NULL or a list.", call. = FALSE)
    }
  }

  resolved_engine_args
}

validate_mcmc_bounds <- function(lower, upper, obj) {
  full_par <- tryCatch(obj$env$par, error = function(e) NULL)
  allowed_lengths <- unique(c(0L, length(obj$par), length(full_par)))

  check_one <- function(x, key) {
    len <- length(x)
    if (!(len %in% allowed_lengths)) {
      stop(
        "`", key, "` must have length 0, length(obj$par) (", length(obj$par),
        "), or length(obj$env$par) (", length(full_par), ").",
        call. = FALSE
      )
    }
  }

  check_one(lower, "lower")
  check_one(upper, "upper")

  if (length(lower) > 0L && length(lower) == length(upper) && any(lower > upper)) {
    stop("`lower` cannot exceed `upper`.", call. = FALSE)
  }

  invisible(TRUE)
}

build_mcmc_parameter_metadata <- function(obj,
                                          stanfit,
                                          coef_meta,
                                          time_varying_betas) {
  fixed_order_raw <- tryCatch(names(obj$par), error = function(e) NULL)
  full_order_raw <- tryCatch(names(obj$env$par), error = function(e) NULL)
  random_index <- tryCatch(obj$env$random, error = function(e) integer(0))
  random_order_raw <- if (!is.null(full_order_raw) && length(random_index)) {
    full_order_raw[random_index]
  } else {
    character(0)
  }

  fixed_order <- if (is.null(fixed_order_raw)) {
    character(0)
  } else {
    normalize_fixed_names(fixed_order_raw, coef_meta, time_varying_betas)
  }
  full_order <- if (is.null(full_order_raw)) {
    character(0)
  } else {
    canonicalize_draw_names(full_order_raw, coef_meta, time_varying_betas)
  }
  random_order <- canonicalize_draw_names(random_order_raw, coef_meta, time_varying_betas)

  sampled_raw <- extract_mcmc_stan_parameter_names(stanfit)
  sampled <- canonicalize_draw_names(sampled_raw, coef_meta, time_varying_betas)

  list(
    theta_order = fixed_order,
    fixed_order = fixed_order,
    random_order = random_order,
    full_order = full_order,
    sampled_parameter_names = sampled,
    sampled_parameter_names_raw = sampled_raw
  )
}

extract_mcmc_stan_parameter_names <- function(stanfit) {
  out <- tryCatch(stanfit@sim$fnames_oi, error = function(e) NULL)
  if (is.null(out)) {
    out <- tryCatch(rownames(mcmc_stan_summary_matrix(stanfit)), error = function(e) NULL)
  }
  if (is.null(out)) {
    return(character(0))
  }
  out[out != "lp__"]
}

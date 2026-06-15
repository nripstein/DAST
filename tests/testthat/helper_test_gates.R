run_truthy_env <- function(var, default = FALSE) {
  value <- Sys.getenv(var, unset = NA_character_)
  if (is.na(value) || !nzchar(value)) {
    return(isTRUE(default))
  }

  tolower(value) %in% c("1", "true", "yes")
}

skip_tmb_integration <- function() {
  skip_on_cran()
  skip_if_not(
    run_truthy_env("RUN_TMB_INTEGRATION_TESTS"),
    message = "Set RUN_TMB_INTEGRATION_TESTS=true to run TMB integration tests."
  )
}

skip_aghq_integration <- function() {
  skip_on_cran()
  skip_if_not(
    run_truthy_env("RUN_AGHQ_TESTS"),
    message = "Set RUN_AGHQ_TESTS=true to run AGHQ integration tests."
  )
}

skip_mcmc_integration <- function() {
  skip_on_cran()
  skip_if_not(
    run_truthy_env("RUN_MCMC_TESTS"),
    message = "Set RUN_MCMC_TESTS=true to run MCMC integration tests."
  )
}

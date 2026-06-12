#' Prediction guard for MCMC-fitted multi-map disaggregation models
#'
#' @description
#' Prediction is intentionally not implemented for MCMC fits. This method
#' provides a clear error directing users to the parameter-estimation outputs.
#'
#' @param object A fitted 'disag_model_mmap_mcmc' object.
#' @param ... Unused.
#'
#' @return This function always errors.
#' @method predict disag_model_mmap_mcmc
#' @export
predict.disag_model_mmap_mcmc <- function(object, ...) {
  stop(
    "Prediction is not implemented for the MCMC engine. ",
    "Use `fit$stanfit` or `summary(fit)` for parameter inference.",
    call. = FALSE
  )
}

## Resubmission

This is a resubmission. In this version I have made the following changes to reflect the comments:

* Added a complete `\value{}` section for `predict.disag_model_mmap_tmb()`.
* Replaced the `\dontrun{}` example in `get_priors()` with a runnable example.
* Added a method citation to the `Description` field in `DESCRIPTION`.
* Added `inst/CITATION` so `citation("DAST")` cites the associated methods
  paper.

## R CMD check results

0 errors | 0 warnings | 4 notes

## Notes

* Installed package size is 12.8 MB, with 12.3 MB in `libs`. The package uses
  compiled C++ code via `TMB`/`RcppEigen`; the source tarball is 192 KB.

* The local check reported "unable to verify current time" for future file
  timestamps. This appears to be specific to the local checking environment.

* The local check reported HTML validation notes for the generated HTML manual
  (for example, `<main>` not being recognized by the validator). These messages
  appear to come from R's generated help-page HTML rather than package-authored
  HTML in the Rd sources or vignette. The Rd checks, PDF manual check, and
  non-ASCII source checks pass.

* The words "spatio" and "disaggregation" are domain-specific terms used in
  spatial statistics and small area estimation.

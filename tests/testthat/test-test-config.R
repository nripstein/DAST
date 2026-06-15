with_use_poisson_tests <- function(value, expr) {
  old <- Sys.getenv("USE_POISSON_TESTS", unset = NA_character_)
  on.exit({
    if (is.na(old)) {
      Sys.unsetenv("USE_POISSON_TESTS")
    } else {
      Sys.setenv(USE_POISSON_TESTS = old)
    }
  }, add = TRUE)

  if (is.null(value)) {
    Sys.unsetenv("USE_POISSON_TESTS")
  } else {
    Sys.setenv(USE_POISSON_TESTS = value)
  }

  force(expr)
}

with_test_env_var <- function(var, value, expr) {
  old <- Sys.getenv(var, unset = NA_character_)
  on.exit({
    if (is.na(old)) {
      Sys.unsetenv(var)
    } else {
      do.call(Sys.setenv, stats::setNames(list(old), var))
    }
  }, add = TRUE)

  if (is.null(value)) {
    Sys.unsetenv(var)
  } else {
    do.call(Sys.setenv, stats::setNames(list(value), var))
  }

  force(expr)
}

test_that("get_test_family_mmap defaults to negative binomial", {
  with_use_poisson_tests(NULL, {
    expect_equal(get_test_family_mmap(), "negbinomial")
  })
})

test_that("get_test_family_mmap switches to poisson for true-like values", {
  with_use_poisson_tests("true", {
    expect_equal(get_test_family_mmap(), "poisson")
  })
  with_use_poisson_tests("1", {
    expect_equal(get_test_family_mmap(), "poisson")
  })
  with_use_poisson_tests("yes", {
    expect_equal(get_test_family_mmap(), "poisson")
  })
})

test_that("get_test_family_mmap stays negative binomial for false-like values", {
  with_use_poisson_tests("false", {
    expect_equal(get_test_family_mmap(), "negbinomial")
  })
  with_use_poisson_tests("0", {
    expect_equal(get_test_family_mmap(), "negbinomial")
  })
  with_use_poisson_tests("no", {
    expect_equal(get_test_family_mmap(), "negbinomial")
  })
})

test_that("get_test_aghq_optimizer_mmap maps family to expected optimizer", {
  expect_equal(get_test_aghq_optimizer_mmap("negbinomial"), "nlminb")
  expect_equal(get_test_aghq_optimizer_mmap("poisson"), "BFGS")
  expect_error(
    get_test_aghq_optimizer_mmap("gaussian"),
    "Unsupported family"
  )
})

test_that("run_truthy_env defaults integration gates off", {
  for (var in c("RUN_TMB_INTEGRATION_TESTS", "RUN_AGHQ_TESTS", "RUN_MCMC_TESTS")) {
    with_test_env_var(var, NULL, {
      expect_false(run_truthy_env(var))
    })
  }
})

test_that("run_truthy_env recognizes opt-in values", {
  for (value in c("true", "TRUE", "1", "yes", "YES")) {
    with_test_env_var("RUN_AGHQ_TESTS", value, {
      expect_true(run_truthy_env("RUN_AGHQ_TESTS"))
    })
  }

  for (value in c("false", "0", "no", "maybe")) {
    with_test_env_var("RUN_AGHQ_TESTS", value, {
      expect_false(run_truthy_env("RUN_AGHQ_TESTS"))
    })
  }
})

test_that("heavy integration test gates do not default on in test sources", {
  test_dir <- testthat::test_path()
  files <- list.files(test_dir, pattern = "\\.[rR]$", full.names = TRUE)
  source <- unlist(lapply(files, readLines, warn = FALSE), use.names = FALSE)

  expect_false(any(grepl('Sys\\.getenv\\("RUN_(TMB_INTEGRATION|AGHQ|MCMC)_TESTS",\\s*"true"\\)', source)))
  expect_false(any(grepl("default\\s*=\\s*TRUE", source[grepl("RUN_(TMB_INTEGRATION|AGHQ|MCMC)_TESTS", source)])))
})

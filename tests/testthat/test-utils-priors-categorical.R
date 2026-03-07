make_test_raster <- function(vals, ncols = 2, nrows = 2, name = "x") {
  r <- terra::rast(ncols = ncols, nrows = nrows, xmin = 0, xmax = ncols, ymin = 0, ymax = nrows, crs = "EPSG:3857")
  terra::values(r) <- vals
  names(r) <- name
  r
}

make_categorical_raster <- function(vals, codes, labels, name = "landuse") {
  r <- make_test_raster(vals = vals, name = name)
  r <- terra::as.factor(r)
  levels(r) <- data.frame(ID = codes, label = labels, stringsAsFactors = FALSE)
  names(r) <- name
  r
}

make_disag_data_stub <- function(response) {
  poly <- sf::st_sf(
    response = 0,
    geometry = sf::st_sfc(
      sf::st_polygon(list(rbind(c(0, 0), c(3, 0), c(3, 4), c(0, 4), c(0, 0)))),
      crs = 3857
    )
  )

  out <- list(
    polygon_shapefile_list = list(poly),
    polygon_data = data.frame(response = response)
  )
  class(out) <- c("disag_data_mmap", "list")
  out
}

test_that("get_priors validates class and computes dynamic defaults", {
  expect_error(
    DAST::get_priors(list()),
    "must be a 'disag_data_mmap'"
  )

  d <- make_disag_data_stub(c(0, 2, 4))
  pri <- DAST::get_priors(d)

  expect_equal(unname(pri$prior_rho_min), 5 / 3, tolerance = 1e-12)
  expect_equal(pri$prior_sigma_max, stats::sd(c(0, 1, 2)), tolerance = 1e-12)
  expect_equal(pri$priormean_intercept, 0)
  expect_equal(pri$prior_rho_prob, 0.1)
})

test_that("get_priors uses sigma fallback when response mean is zero", {
  d <- make_disag_data_stub(c(0, 0, 0))
  pri <- DAST::get_priors(d)
  expect_equal(pri$prior_sigma_max, 1.0)
})

test_that("extract_categorical_level_table handles levels, fallback values, and errors", {
  r_levels <- make_categorical_raster(
    vals = c(1, 2, 1, 2),
    codes = c(1, 2),
    labels = c("urban", "rural"),
    name = "landuse"
  )
  tbl_levels <- DAST:::extract_categorical_level_table(r_levels, "landuse", context = "test")
  expect_equal(tbl_levels$code, c(1, 2))
  expect_equal(tbl_levels$label, c("urban", "rural"))

  r_values <- make_test_raster(vals = c(3, NA, 1, 3), name = "soil")
  tbl_values <- DAST:::extract_categorical_level_table(r_values, "soil", context = "test")
  expect_equal(tbl_values$code, c(1, 3))
  expect_equal(tbl_values$label, c("1", "3"))

  r_all_na <- make_test_raster(vals = c(NA, NA, NA, NA), name = "empty")
  expect_error(
    DAST:::extract_categorical_level_table(r_all_na, "empty", context = "test"),
    "has no non-missing values"
  )

})

test_that("normalize_categorical_baseline_value resolves label, code, numeric code and errors", {
  level_table <- data.frame(
    code = c("1", "2.0", "3"),
    label = c("urban", "rural", "forest"),
    stringsAsFactors = FALSE
  )

  expect_equal(
    DAST:::normalize_categorical_baseline_value(level_table, "urban", "landuse", context = "test"),
    "urban"
  )
  expect_equal(
    DAST:::normalize_categorical_baseline_value(level_table, "1", "landuse", context = "test"),
    "urban"
  )
  expect_equal(
    DAST:::normalize_categorical_baseline_value(level_table, "2", "landuse", context = "test"),
    "rural"
  )

  expect_error(
    DAST:::normalize_categorical_baseline_value(level_table, "desert", "landuse", context = "test"),
    "baseline 'desert' not found"
  )
})

make_schema_raster <- function(codes, labels, values, name = "landuse") {
  make_categorical_raster(vals = values, codes = codes, labels = labels, name = name)
}

test_that("build_categorical_schema handles empty input and builds ordered schema", {
  expect_equal(
    DAST:::build_categorical_schema(list(make_test_raster(1:4, name = "x")), NULL),
    list(schema = list(), baselines = list())
  )

  t1 <- make_schema_raster(c(1, 2, 3), c("urban", "rural", "forest"), c(1, 2, 3, 1))
  t2 <- make_schema_raster(c(1, 2, 3), c("urban", "rural", "forest"), c(3, 2, 1, 3))

  out <- DAST:::build_categorical_schema(
    covariate_rasters_list = list(t1, t2),
    categorical_covariate_baselines = list(landuse = "urban")
  )

  sch <- out$schema$landuse
  expect_equal(out$baselines$landuse, "urban")
  expect_equal(sch$level_labels, c("urban", "rural", "forest"))
  expect_equal(sch$dummy_levels, c("rural", "forest"))
  expect_equal(sch$dummy_names, c("landuse_rural", "landuse_forest"))
})

test_that("build_categorical_schema detects missing rasters and mapping inconsistencies", {
  expect_error(
    DAST:::build_categorical_schema(
      covariate_rasters_list = list(NULL),
      categorical_covariate_baselines = list(landuse = "urban")
    ),
    "requested but covariate raster"
  )

  r_label_conflict_a <- make_schema_raster(c(1, 2), c("urban", "rural"), c(1, 2, 1, 2))
  r_label_conflict_b <- make_schema_raster(c(9, 2), c("urban", "rural"), c(9, 2, 9, 2))
  expect_error(
    DAST:::build_categorical_schema(
      covariate_rasters_list = list(r_label_conflict_a, r_label_conflict_b),
      categorical_covariate_baselines = list(landuse = "urban")
    ),
    "labels mapped to multiple codes"
  )

  r_code_conflict_a <- make_schema_raster(c(1, 2), c("urban", "rural"), c(1, 2, 1, 2))
  r_code_conflict_b <- make_schema_raster(c(1, 2), c("city", "rural"), c(1, 2, 1, 2))
  expect_error(
    DAST:::build_categorical_schema(
      covariate_rasters_list = list(r_code_conflict_a, r_code_conflict_b),
      categorical_covariate_baselines = list(landuse = "urban")
    ),
    "codes mapped to multiple labels"
  )

  r_single <- make_schema_raster(c(1), c("urban"), c(1, 1, 1, 1))
  out_single <- DAST:::build_categorical_schema(
    covariate_rasters_list = list(r_single),
    categorical_covariate_baselines = list(landuse = "urban")
  )
  expect_equal(out_single$schema$landuse$dummy_levels, character(0))
  expect_equal(out_single$schema$landuse$dummy_names, character(0))
})

test_that("map_values_to_categorical_labels maps values robustly and errors on unknowns", {
  layer_schema <- list(level_codes = c("1.0", "2.0"), level_labels = c("urban", "rural"))

  expect_equal(DAST:::map_values_to_categorical_labels(character(0), layer_schema, "landuse"), character(0))
  expect_equal(DAST:::map_values_to_categorical_labels(c(NA, NA), layer_schema, "landuse"), c(NA_character_, NA_character_))

  vals <- c("1", "rural", "2.0", NA)
  out <- DAST:::map_values_to_categorical_labels(vals, layer_schema, "landuse", context = "test")
  expect_equal(out, c("urban", "rural", "rural", NA_character_))

  expect_error(
    DAST:::map_values_to_categorical_labels(c("bogus"), layer_schema, "landuse", context = "test"),
    "contains values not present in training categorical schema"
  )
})

test_that("encode_categorical_values handles NA policy and dummy dimensionality", {
  schema_two <- list(
    level_codes = c(1, 2, 3),
    level_labels = c("urban", "rural", "forest"),
    baseline_label = "urban",
    dummy_levels = c("rural", "forest"),
    dummy_names = c("landuse_rural", "landuse_forest")
  )

  dm <- DAST:::encode_categorical_values(c(1, 2, NA, 3), schema_two, "landuse", na_to_baseline = FALSE)
  expect_equal(colnames(dm), c("landuse_rural", "landuse_forest"))
  expect_equal(unname(dm[1, ]), c(0, 0))
  expect_equal(unname(dm[2, ]), c(1, 0))
  expect_true(all(is.na(dm[3, ])))
  expect_equal(unname(dm[4, ]), c(0, 1))

  dm_na_base <- DAST:::encode_categorical_values(c(NA, 2), schema_two, "landuse", na_to_baseline = TRUE)
  expect_equal(unname(dm_na_base[1, ]), c(0, 0))
  expect_equal(unname(dm_na_base[2, ]), c(1, 0))

  schema_one <- list(
    level_codes = c(1, 2),
    level_labels = c("urban", "rural"),
    baseline_label = "urban",
    dummy_levels = "rural",
    dummy_names = "landuse_rural"
  )
  dm_one <- DAST:::encode_categorical_values(c(1, 2), schema_one, "landuse")
  expect_equal(dim(dm_one), c(2, 1))
  expect_equal(colnames(dm_one), "landuse_rural")

  schema_zero <- list(
    level_codes = 1,
    level_labels = "urban",
    baseline_label = "urban",
    dummy_levels = character(0),
    dummy_names = character(0)
  )
  dm_zero <- DAST:::encode_categorical_values(c(1, 1, 1), schema_zero, "landuse")
  expect_equal(dim(dm_zero), c(3, 0))
})

test_that("encode_categorical_raster_stack validates conflicts and encodes raw layers", {
  expect_null(DAST:::encode_categorical_raster_stack(NULL, list(landuse = list())))

  cov_num <- make_test_raster(c(1, 2, 3, 4), name = "temp")
  expect_equal(names(DAST:::encode_categorical_raster_stack(cov_num, NULL)), names(cov_num))
  expect_equal(names(DAST:::encode_categorical_raster_stack(cov_num, list())), names(cov_num))

  schema <- list(
    landuse = list(
      layer_name = "landuse",
      level_labels = c("urban", "rural"),
      level_codes = c(1, 2),
      baseline_label = "urban",
      baseline_code = 1,
      dummy_levels = "rural",
      dummy_names = "landuse_rural"
    )
  )

  landuse_raw <- make_categorical_raster(c(1, 2, 1, 2), c(1, 2), c("urban", "rural"), name = "landuse")
  cov_ok <- c(cov_num, landuse_raw)
  encoded <- DAST:::encode_categorical_raster_stack(cov_ok, schema, context = "test")
  expect_equal(names(encoded), c("temp", "landuse_rural"))
  expect_equal(as.numeric(terra::values(encoded[[2]], mat = FALSE)), c(0, 1, 0, 1))

  cov_conflict <- c(cov_ok, make_test_raster(c(0, 1, 0, 1), name = "landuse_rural"))
  expect_error(
    DAST:::encode_categorical_raster_stack(cov_conflict, schema, context = "test"),
    "appears as both raw categorical and encoded dummy names"
  )

  schema_two_dummies <- list(
    landuse = list(
      layer_name = "landuse",
      level_labels = c("urban", "rural", "forest"),
      level_codes = c(1, 2, 3),
      baseline_label = "urban",
      baseline_code = 1,
      dummy_levels = c("rural", "forest"),
      dummy_names = c("landuse_rural", "landuse_forest")
    )
  )
  cov_partial <- make_test_raster(c(0, 1, 0, 1), name = "landuse_rural")
  expect_error(
    DAST:::encode_categorical_raster_stack(cov_partial, schema_two_dummies, context = "test"),
    "partial dummy set"
  )

  schema_zero <- list(
    landuse = list(
      layer_name = "landuse",
      level_labels = "urban",
      level_codes = 1,
      baseline_label = "urban",
      baseline_code = 1,
      dummy_levels = character(0),
      dummy_names = character(0)
    )
  )
  only_raw <- make_categorical_raster(c(1, 1, 1, 1), c(1), c("urban"), name = "landuse")
  intercept_only <- DAST:::encode_categorical_raster_stack(only_raw, schema_zero, context = "test")
  expect_equal(names(intercept_only), "intercept_only")
  expect_true(all(as.numeric(terra::values(intercept_only, mat = FALSE)) == 0))
})

# Trim data/*.csv down to what the interactive OJS explorers display, so the
# self-contained deck stays small (gzipped; the deck decompresses them in the
# browser). The R chunks still read the full files.
# Run from this directory: Rscript prep_ojs_data.R
suppressPackageStartupMessages(library(data.table))

out <- "data/ojs"
dir.create(out, showWarnings = FALSE)

# keep in sync with `seasons` in the OJS setup chunk
seasons <- data.table(
  season = c("2023-24", "2024-25", "2025-26"),
  start  = as.IDate(c("2023-10-01", "2024-10-15", "2025-10-15")),
  end    = as.IDate(c("2024-06-01", "2025-06-01", "2026-06-15"))
)

# forecasts: drop target_end_date (rebuilt in JS from reference_date + horizon)
# and round quantiles to 1 decimal
q_cols <- c("q05", "q25", "q50", "q75", "q95")
refs <- list()
for (i in seq_len(nrow(seasons))) {
  s <- seasons$season[i]
  fc <- fread(sprintf("data/forecasts_%s.csv", s), colClasses = list(character = "location"))
  fc[, (q_cols) := lapply(.SD, round, 1), .SDcols = q_cols]
  fwrite(fc[, c("model", "location", "reference_date", "horizon", q_cols), with = FALSE],
         sprintf("%s/forecasts_%s.csv.gz", out, s))
  refs[[s]] <- data.table(reference_date = as.IDate(unique(fc$reference_date)),
                          start = seasons$start[i])
}
refs <- rbindlist(refs)

# truth: only dates inside a season window
truth <- fread("data/truth.csv", colClasses = list(character = "location"))
truth[, date := as.IDate(date)]
truth <- truth[seasons, on = .(date >= start, date <= end), nomatch = NULL,
               .(location, date = x.date, value)]
fwrite(unique(truth)[order(location, date)], file.path(out, "truth.csv.gz"))

# as-of data: only reference dates with forecasts, and dates the panel shows
asof <- fread("data/asof.csv", colClasses = list(character = "location"))
asof[, `:=`(reference_date = as.IDate(reference_date), date = as.IDate(date))]
asof <- asof[refs, on = "reference_date", nomatch = NULL][date >= start]
asof[, value := round(value, 1)]
fwrite(asof[, .(reference_date, location, date, value)], file.path(out, "asof.csv.gz"))

locs <- fread("data/locations.csv", colClasses = list(character = "location"))
fwrite(locs[, .(location, location_name)], file.path(out, "locations.csv"))

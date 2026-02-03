#!/usr/bin/env Rscript
# Usage:
# annif index \
#   --projects projects.cfg \
#   --limit 100 \
#   --output suggestions-from-annif.jsonl \
#   [PROJECT_ID] \
#   [Path to text-corpus for testing]
#
# Rscript src/annif-to-casimir.r \
#   --jsonl_input suggestions-from-annif.jsonl \
#   --index test_index.csv \
#   --output suggestions-for-casimir.csv

library("optparse")
option_list <- list(
  make_option(
    c("--jsonl_input"), type = "character",
    default = NA_character_,
    help = "input file name for the predictions in json format as produced by 
      annif index",
    metavar = "character"
  ),
  make_option(
    c("--index"), type = "character",
    default = NA_character_,
    help = "index file in csv format that contains the document ids matching
      the documents in the jsonl file in the same order as in the jsonl file",
    metavar = "character"
  ),
  make_option(
    c("--output"), type = "character",
    default = "test.csv",
    help = "output file name for the predictions in csv format with columns
      doc_id, label_id and score as required for casimir",
    metavar = "character"
  )
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

suppressPackageStartupMessages({
  library(tidyverse)
  library(jsonlite)
})


# Read the JSON lines
index <- read_csv(opt$index, col_select = c("doc_id"))

json_data <- stream_in(file(opt$jsonl_input))

message("Binding index to json-data...")
warning("Binding assumes consistent row order between index and json input")
long_table <- bind_cols(
  index,
  json_data
)  |>
  select(doc_id, results) |>
  unnest(results)  |>
  transmute(
    doc_id = doc_id,
    label_id = uri,
    score
  )

message("Writing output to ", opt$output, "...")
readr::write_csv(long_table, opt$output)

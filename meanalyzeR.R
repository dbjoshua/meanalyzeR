# meanalyseR: An R package for analyzing interlinear WRIML-annotated data

# === Load required libraries ===
library(stringr)
library(purrr)
library(dplyr)
library(tools)

# === Helper Functions ===

# Remove extra spaces and split gloss into morphemes
normalize_gloss <- function(gl_line) {
  str_split(str_squish(gl_line), "[\u0020\p{Punct}]+", simplify = TRUE) %>% as.character()
}

# Extract data blocks marked with ^data ... _data
extract_data_blocks <- function(text_lines) {
  block_starts <- which(str_detect(text_lines, "^ \^data "))
  block_ends <- which(str_detect(text_lines, "^ _data "))
  map2(block_starts, block_ends, ~ text_lines[.x:.y])
}

# Parse a data block into a named list
parse_block <- function(block_lines) {
  get_content <- function(tag) {
    pattern <- paste0("^ \\^", tag, " (.*) _", tag, "$")
    match <- str_match(block_lines, pattern)
    na.omit(match[, 2])[1] %||% ""
  }
  list(
    ct = get_content("ct"),
    tx = get_content("tx"),
    mb = get_content("mb"),
    gl = get_content("gl"),
    tr = get_content("tr"),
    raw = block_lines
  )
}

# === Function 1: sort by minimal pairs ===
sort_by_minimal_pairs <- function(input_file) {
  lines <- readLines(input_file, warn = FALSE)
  blocks <- extract_data_blocks(lines)
  data_parsed <- map(blocks, parse_block)

  compare_pair <- function(gl1, gl2) {
    morphemes1 <- normalize_gloss(gl1)
    morphemes2 <- normalize_gloss(gl2)
    diff <- length(setdiff(morphemes1, morphemes2)) + length(setdiff(morphemes2, morphemes1))
    return(diff == 1)
  }

  groups <- list()
  assigned <- rep(FALSE, length(data_parsed))

  for (i in seq_along(data_parsed)) {
    if (assigned[i]) next
    pair_group <- list(data_parsed[[i]])
    assigned[i] <- TRUE
    for (j in seq_along(data_parsed)) {
      if (i == j || assigned[j]) next
      if (compare_pair(data_parsed[[i]]$gl, data_parsed[[j]]$gl)) {
        pair_group <- append(pair_group, list(data_parsed[[j]]))
        assigned[j] <- TRUE
      }
    }
    groups <- append(groups, list(pair_group))
  }

  out_file <- paste0(file_path_sans_ext(input_file), "-sorted.", file_ext(input_file))
  writeLines(
    unlist(map(groups, ~ flatten_chr(map(.x, "raw")))),
    con = out_file
  )
  return(out_file)
}

# === Function 2: sort by context variants ===
sort_by_context_variants <- function(input_file) {
  lines <- readLines(input_file, warn = FALSE)
  blocks <- extract_data_blocks(lines)
  data_parsed <- map(blocks, parse_block)

  # Use gl tag as a key
  grouped <- split(data_parsed, sapply(data_parsed, function(x) str_squish(x$gl)))

  out_file <- paste0(file_path_sans_ext(input_file), "-ctvariants.", file_ext(input_file))
  writeLines(
    unlist(map(grouped, ~ flatten_chr(map(.x, "raw")))),
    con = out_file
  )
  return(out_file)
}

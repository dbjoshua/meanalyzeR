#' @title Searching the occurrence contexts of a morpheme in a dataset
#'
#' @description
#' `get_morpheme_contexts` is a `meanalyzeR` UI function that returns the set of
#' data or contexts in which a given morpheme appears within a dataset that is
#' marked up using the WRIML language.
#'
#' @section About WRIML:
#' WRIML (WRIting Markup Language) is a lightweight markup language designed to
#' annotate documents -- such as linguistic data -- in plain text. It uses a
#' system of inline tags prefixed by ` ^` to open and ` _` to close each tag.
#' Tags can include optional attributes using a key="value" syntax.
#'
#' Only the WRIML format is currently supported by this function. Full documentation
#' on WRIML is available at: \url{https://github.com/dbjoshua/WRIML-presentation}
#'
#' @section Data markup template:
#' A minimal WRIML-annotated data block should follow this structure:
#' ```
#' ^data
#' ^id ex01 _id
#' ^ct_type="out-of-the-blue" This sentence was said spontaneously. _ct
#' ^aj _aj
#' ^tx John eats an apple. _tx
#' ^mb John eat-s an apple _mb
#' ^gl JOHN EAT-3SG ART APPLE _gl
#' ^tr John eats an apple. _tr
#' ^lt John eats one apple _lt
#' _data
#' ```
#'
#' The tags used here are **reserved** and must not be redefined or reused for other
#' purposes. These include:
#'
#' - `data`: Encloses a full data block.
#' - `ct`: Provides contextual information about the utterance. Use the `type` attribute
#'   to specify the nature of the context (e.g., `out-of-the-blue`, `bridging`, `donkey`).
#' - `aj`: Consultant's acceptability judgment (empty = fully acceptable).
#' - `tx`: The unsegmented utterance (optional).
#' - `mb`: The segmented morpheme line (mandatory).
#' - `gl`: The gloss line corresponding to `mb` (mandatory).
#' - `tr`: The free translation (optional).
#' - `lt`: The literal translation (optional).
#' - `id` or `rf`: Unique identifier of the data block (mandatory).
#'
#' The attribute name `type` is also reserved for describing the nature of the context
#' in the `ct` tag. Users must **avoid defining their own tags** using:
#' - Any of the reserved tag names above
#' - Tags beginning with any of these names (e.g., `glossnote` is invalid)
#' - Any tag using the reserved attribute `type` outside of `ct`
#'
#' Outside of these restrictions, users are free to define their own tags for additional metadata.
#'
#' A full template and example projects are available at:
#' \url{https://github.com/dbjoshua/meanalyzeR}
#'
#' @section About export formats:
#' - The `"contexts"` mode is intended purely for analysis; `.tex` is **not** available
#'   as an export format for this mode.
#' - Export to `.tex` is designed for researchers who wish to directly incorporate data
#'   into their manuscripts.
#' - The exported LaTeX syntax is based on the `interlinear` package, but users may
#'   define a compatible `interlinear` environment in their LaTeX preamble.
#' - If the `type` attribute is missing in a context, it will be displayed as `[unspecified]`
#'
#' @section Toolbox Support:
#' Support for the Linguist's Toolbox (by SIL) may be added in future versions for:
#' - Importing annotated data
#' - Exporting results using Toolbox-compatible macros
#'
#' If there is enough interest from researchers, Toolbox support will be prioritized.
#'
#' @param morpheme A character string representing the morpheme to search for (case-sensitive).
#' @param file A character string giving the path to the WRIML-annotated data file.
#' @param mode `full` (returns the whole data block) | `contexts` (only returns the context and the ID of the data (block))
#'
#' @returns
#' The list of data (if `mode = "full"` is ) or the list of contexts
#' (if `mode = "contexts"` is chosen) in "file" in which the gloss appears.
#' Optionally exports the results to .tex, .wriml, .txt or .rmd.
#' Note that: ".tex"-export is not available in the `contexts` mode.
#'
#' @export
get_morpheme_contexts <- function(morpheme, file, mode = "full") {
  # Lecture du fichier
  if (!file.exists(file)) {
    stop("File not found.")
  }

  lines <- readLines(file, warn = FALSE)
  lines <- trimws(lines)

  # Détection des blocs ^data ... _data
  data_blocks <- list()
  in_block <- FALSE
  current_block <- c()
  for (line in lines) {
    if (grepl("^\\^data\\s*$", line)) {
      in_block <- TRUE
      current_block <- c(line)
    } else if (grepl("^_data\\s*$", line) && in_block) {
      current_block <- c(current_block, line)
      data_blocks <- append(data_blocks, list(current_block))
      in_block <- FALSE
      current_block <- c()
    } else if (in_block) {
      current_block <- c(current_block, line)
    }
  }

  # Fonction de détection du morphème
  contains_morpheme <- function(block, morpheme) {
    # Extraire la ligne de morpheme
    mb_line <- block[grepl("^\\^mb\\s", block)]
    if (length(mb_line) == 0) return(FALSE)

    # Nettoyer la ligne sans altérer la casse
    mb_text <- gsub("^\\^mb\\s*|\\s*_mb$", "", mb_line)
    mb_text <- trimws(mb_text)

    # Découper en jetons
    tokens <- unlist(strsplit(mb_text, "[[:space:][:punct:]]+"))

    # Vérifier la présence exacte (respecte la casse)
    morpheme %in% tokens
  }


  # Extraction selon le mode
  matched_blocks <- Filter(function(block) contains_morpheme(block, morpheme), data_blocks)

  if (length(matched_blocks) == 0) {
    cat("No data found for the morpheme:", morpheme, "\n")
    return(invisible(NULL))
  }

  if (mode == "full") {
    # Affichage à la console
    for (block in matched_blocks) {
      cat(paste0(rep("=", 40), "\n"))
      cat(paste(block, collapse = "\n"), "\n")
    }
  } else if (mode == "contexts") {
    for (block in matched_blocks) {
      ct_line <- block[grepl("^\\^ct\\s*", block)]
      ct_type <- block[grepl("_type=\"", block)]
      id_line <- block[grepl("^\\^(rf|id)\\s", block)]
      ct <- ifelse(length(ct_line) > 0, gsub("^\\^ct\\s*|\\s*_ct$", "", ct_line), "[no context]")
      ty <- ifelse(length(ct_line) > 0, gsub("_type=\"\\s*|\"\\s*$", "", ct_type), NULL)
      id <- ifelse(length(id_line) > 0, gsub("^\\^(rf|id)\\s*|\\s*_(rf|id)$", "", id_line), "[no id]")
      cat(paste0("ID: ", id, "\nContext (type: ", ty, "): ", ct, "\n\n"))
    }
  } else {
    stop("Invalid mode. Use 'full' or 'contexts'.")
  }

  # Export interactif
  repeat {
    export_choice <- tolower(readline("Do you want to export the results? [y/n]: "))
    if (export_choice %in% c("y", "n")) break
  }

  if (export_choice == "y") {
    if (mode == "full") {
      repeat {
        format <- tolower(readline("Choose export format: .tex, .rmd, .txt, .wriml: "))
        if (format %in% c(".tex", ".rmd", ".txt", ".wriml")) break
      }
    } else {
      repeat {
        format <- tolower(readline("Choose export format: .rmd, .txt, .wriml: "))
        if (format %in% c(".rmd", ".txt", ".wriml")) break
      }
    }

    base_name <- tools::file_path_sans_ext(basename(file))
    file_ext <- switch(format,
      ".tex" = ".tex",
      ".rmd" = ".Rmd",
      ".txt" = ".txt",
      ".wriml" = ".wriml"
    )

    if (!dir.exists("export")) dir.create("export")

    output_file <- paste0("export/", base_name, "_morpheme-", morpheme, "_contexts_report", file_ext)

    if (mode == "full") {
      # content <- sapply(matched_blocks, paste, collapse = "\n") # old code
      content <- sapply(matched_blocks, function(block) {
        ct_line <- block[grepl("^\\^ct(_|\\s|$)", block)]
        aj_line <- block[grepl("^\\^aj\\s", block)]
        tx_line <- block[grepl("^\\^tx\\s", block)]
        mb_line <- block[grepl("^\\^mb\\s", block)]
        gl_line <- block[grepl("^\\^gl\\s", block)]
        tr_line <- block[grepl("^\\^tr\\s", block)]
        lt_line <- block[grepl("^\\^lt\\s", block)]
        id_line <- block[grepl("^\\^(rf|id)\\s", block)]

        ct <- if (length(ct_line) > 0) {
          gsub("^\\^ct(_type=\"[^\"]*\")?\\s*|\\s*_ct$", "", ct_line)
        } else {
          "[Warning: Empty or missing context]"
        }

        ty <- if (length(ct_line) > 0 && grepl("_type=", ct_line)) {
          sub('.*_type="([^"]*)".*', "\\1", ct_line)
        } else {
          "[unspecified]"
        }

        aj <- ifelse(length(aj_line) > 0, gsub("^\\^aj\\s*|\\s*_aj$", "", aj_line), " ")
        tx <- ifelse(length(tx_line) > 0, gsub("^\\^tx\\s*|\\s*_tx$", "", tx_line), " ")
        mb <- ifelse(length(mb_line) > 0, gsub("^\\^mb\\s*|\\s*_mb$", "", mb_line), "[Error: Empty or missing morpheme break line]")
        gl <- ifelse(length(gl_line) > 0, gsub("^\\^gl\\s*|\\s*_gl$", "", gl_line), "[Error: Empty or missing gloss line]")
        tr <- ifelse(length(tr_line) > 0, gsub("^\\^tr\\s*|\\s*_tr$", "", tr_line), " ")
        lt <- ifelse(length(lt_line) > 0, gsub("^\\^lt\\s*|\\s*_lt$", "", lt_line), " ")
        id <- ifelse(length(id_line) > 0, gsub("^\\^(rf|id)\\s*|\\s*_(rf|id)$", "", id_line), "[Error: Empty or missing ID]")

        switch(format,
               ".tex" = paste0(
                 "\\begin{interlinear}\n",
                 "\\ct ", ct, "\\\\\n",
                 "\\aj ", aj, "\\\\\n",
                 "\\tx ", tx, "\\\\\n",
                 "\\mb ", mb, "\\\\\n",
                 "\\gl ", gl, "\\\\\n",
                 "\\tr ", tr, "\\\\\n",
                 "\\lt ", lt, "\\\\\n",
                 "\\id ", id, "\\\\\n",
                 "\\end{interlinear}", "\n"
               ),
               ".wriml" = paste0(
                 " ^data ", "\n",
                 " ^ct", "_type=\"", ty, "\" ", ct, " _ct ", "\n",
                 " ^aj ", aj, " _aj ", "\n",
                 " ^tx ", tx, " _tx ", "\n",
                 " ^mb ", mb, " _mb ", "\n",
                 " ^gl ", gl, " _gl ", "\n",
                 " ^tr ", tr, " _tr ", "\n",
                 " ^lt ", lt, " _lt ", "\n",
                 " ^id ", id, " _id ", "\n",
                 " _data ", "\n"
               ),
               ".txt" = paste0(
                 "ID: ", id, "\n",
                 "Context (", ty, "): ", ct, "\n",
                 "tx: ", tx, "\n",
                 "mb: ", mb, "\n",
                 "gl: ", gl, "\n",
                 "tr: ", tr, "\n",
                 "lt: ", lt, "\n"
               ),
               ".rmd" = paste0(
                 "- id: \"", id, "\"\n",
                 "  ct-type: \"", ty, "\"\n",
                 "  ct: \"", ct, "\"\n",
                 "  tx: \"", tx, "\"\n",
                 "  mb: \"", mb, "\"\n",
                 "  gl: \"", gl, "\"\n",
                 "  tr: \"", tr, "\"\n",
                 "  lt: \"", lt, "\"\n"
               ),
               stop("Format inconnu : ", format)  # valeur par défaut si format non reconnu
        )
      })
    } else {
      content <- sapply(matched_blocks, function(block) {
        ct_line <- block[grepl("^\\^ct(_|\\s|$)", block)]
        id_line <- block[grepl("^\\^(rf|id)\\s", block)]
        ct <- if (length(ct_line) > 0) {
          gsub("^\\^ct(_type=\"[^\"]*\")?\\s*|\\s*_ct$", "", ct_line)
        } else {
          "[Warning: Empty or missing context]"
        }

        ty <- if (length(ct_line) > 0 && grepl("_type=", ct_line)) {
          sub('.*_type="([^"]*)".*', "\\1", ct_line)
        } else {
          "[unspecified]"
        }

        id <- ifelse(length(id_line) > 0, gsub("^\\^(rf|id)\\s*|\\s*_(rf|id)$", "", id_line), "[Empty or missing ID]")
        switch(format,
               ".wriml" = paste0(
                 " ^context_id=\"", id, "\"_type=\"", ty, "\" \n",
                 "   ", ct, "\n",
                 " _context ", "\n"
               ),
               ".txt" = paste0(
                 "ID: ", id, "\n",
                 "Context (", ty, "): ", ct, "\n"
               ),
               ".rmd" = paste0(
                 "- id: \"", id, "\"\n",
                 "  type: \"", ty, "\"\n",
                 "  ct: \"", ct, "\"\n"
               ),
               stop("Format inconnu : ", format)  # valeur par défaut si format non reconnu
        )
      })
    }


    ofilestart <- switch(format,
                          ".tex" = c(
                            "%!TeX program=xelatex",
                            "\\documentclass{article}",
                            "\\usepackage{junicode} % to handle both latin scripts and unicode API transcriptions",
                            "\\usepackage{interlinear}",
                            "\\begin{document}",
                            "\\title{Rapport d'occurrence de ", gl, "}",  # <- concatène dans une seule ligne
                            "\\date{\\today}",
                            "\\maketitle"
                          ),
                          ".wriml" = c(
                            " ^Rexport_target=\"distribution\"_specification=\"contexts\" ",
                            "  ^title Rapport d'ocurrences _title ",
                            "  ^date ", Sys.Date(), " _date ",
                            "  ^morpheme ", gl, " _morpheme ",
                            "  ^corpus ", file, " _corpus "
                          ),
                          ".txt" = c(
                            "Titre: ", "Rapport d'ocurrences",
                            "Date: ", Sys.Date(),
                            "Morpheme: ", gl
                          ),
                          ".rmd" = c(
                            "---",
                            "title: \"Rapport d'ocurrences\"",
                            sprintf("date: \"", Sys.Date(), "\""),
                            "output: html_document",
                            "params:",
                            "  morpheme:", gl,
                            "  contexts:"
                          ),
                          stop("Format inconnu : ", format)  # valeur par défaut si format non reconnu
    )

    ofileend <-  switch(format,
                         ".tex" = c("", "\\end{document}"),
                         ".wriml" = c(
                           "  ^_* ",
                           " _Rexport "
                         ),
                         ".txt" = character,
                         ".rmd" = c(
                           "---",
                           "```{r setup, include=FALSE}",
                           "knitr::opts_chunk$set(echo = FALSE, message = FALSE, warning = FALSE)",
                           "library(dplyr)",
                           "library(purrr)"
                         ),
                         stop("Format inconnu : ", format)  # valeur par défaut si format non reconnu
    )
    #writeLines(unlist(ofilestart), output_file)
    writeLines(unlist(content), output_file)#, append = TRUE)
    #writeLines(unlist(ofileend), output_file, append = TRUE)
    cat("Results exported to:", output_file, "\n")
    file.show(output_file)
  }
}

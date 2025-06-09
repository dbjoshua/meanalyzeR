# meanalyzeR
An R toolkit for semanticists to extract meaning-related contrasts from interlinear corpora using WRIML.

---

## Quick overview of meanalyseR

**meanalyseR** is an R package designed for field linguists and semanticists working with large corpora of interlinear data. Its main purpose is to help researchers **automatically extract key semantic properties** of morphemes or expressions across a corpus, enabling **faster diagnostics** and **semantic generalizations**.

This tool is especially useful when dealing with understudied languages, where annotated data often come from manually constructed questionnaires and follow-up field interviews.

---

## What Does meanalyseR Do?

meanalyseR takes as input a **corpus of interlinear examples** marked using a simplified custom markup language called **WRIML** (WRIting Markup Language). It currently provides tools for:

- Grouping data by **minimal pairs** based on their gloss lines (function: `sort_by_minimal_pairs()`)
- Grouping data by **contextual variants** based on their context prompts (function: `sort_by_context_variants()`)
- Extracting all data in which a particular **gloss** or **morpheme** appears (functions: `get_gloss_contexts()` and `get_morpheme_contexts()`)

These automatic groupings are useful to identify subtle meaning contrasts across examples and track morpheme distribution across contexts.

---

## Input Format: WRIML

Your corpus must be written in plain text (`.txt` or `.wriml`) using WRIML, a markup system where each example is wrapped in `^data ... _data` blocks and annotated with a small set of reserved tags.

Here is a minimal template to follow (a complete template is available at [github.com/dbjoshua/meanalyzeR](https://github.com/dbjoshua/meanalyzeR)):

```wriml
 ^data 
 ^ct_type="out-of-the-blue" This is the context. _ct 
 ^aj _aj 
 ^tx Nko _tx 
 ^mb N ko _mb 
 ^gl 1SG say _gl 
 ^tr "I say" _tr 
 ^lt "I declare" _lt 
 ^id ex001 _id 
 _data 
````

### Tags used in WRIML

| Tag          | Description                                                               |
| ------------ | ------------------------------------------------------------------------- |
| `data`       | Wraps the entire data block                                               |
| `ct`         | Provides the context. You may specify the context type using `ct_type=""` |
| `aj`         | Acceptability judgment (leave empty if acceptable in context)             |
| `tx`         | Unsegmented expression (optional)                                         |
| `mb`         | Morpheme-by-morpheme segmentation (**required**)                          |
| `gl`         | Glosses corresponding to `mb` (**required**)                              |
| `tr`         | Free translation (can be empty)                                           |
| `lt`         | Literal translation (optional)                                            |
| `id` or `rf` | Reference or unique ID for the data (**required**)                        |

**⚠ Reserved Tags and Namespaces:**

* Do **not** define your own tags using names identical to or starting with: `data`, `ct`, `aj`, `tx`, `mb`, `gl`, `tr`, `lt`, `rf`, or `id`.
* Also avoid defining a property called `type`, as it is reserved for specifying context type (e.g., `ct_type="bridging"`).
* Other custom tags may be defined freely by the user for their own use.

📚 The full WRIML documentation is available here: [github.com/dbjoshua/WRIML-presentation](https://github.com/dbjoshua/WRIML-presentation)

---

## How to Use meanalyseR in a Project

### 1. Install the package locally

Clone or download the package folder, then install it from the command line or R console:

```r
# Replace with the actual path to your folder
devtools::install_local("path/to/meanalyseR")
```

You may need to install `devtools` first:

```r
install.packages("devtools")
```

You may also install `meanalyzeR` from this repository's `.tar.gz` archive. To do so, you have three options: 

The first one is to use `devtools`:

```r
devtools::install("meanalyzeR_0.1.0.tar.gz")
```

The second one is to use `install.packages`: 

```r
install.packages("meanalyzeR_0.1.0.tar.gz", repos = NULL, type = "source")
```

The third one is to use the command line 

```bash
R CMD INSTALL meanalyzeR_0.1.0.tar.gz
```

All these codes have to be run from the directory containing the archive.

### 2. Prepare your corpus

* Create a `.txt` or `.wri` file containing your WRIML-annotated data.
* Make sure your tags follow the WRIML format strictly (see above).

A complete template and personal project examples are available at [github.com/dbjoshua/meanalyzeR](https://github.com/dbjoshua/meanalyzeR).

---

## 3. Use the analysis functions

```r
library(meanalyseR)

# Sort by gloss-based minimal pairs
sort_by_minimal_pairs("path/to/your/corpus.txt")

# Sort by contextual variants
sort_by_context_variants("path/to/your/corpus.txt")

# Get all data blocks in which a specific gloss appears
get_gloss_contexts("your-corpus.txt", gloss = "3SG")

# Get all data blocks in which a specific morpheme appears
get_morpheme_contexts("your-corpus.txt", morpheme = "ko")
```

Each function will generate an output file named after the input file, with suffix `-sorted`, `-contexts`, etc., and the same file extension.

---

## Export Formats and Guidelines

* Results from gloss/morpheme search (`get_gloss_contexts()`, `get_morpheme_contexts()`) can be exported to `.txt`, `.tex`, or `.csv`.
* **The `.tex` export is designed to help researchers insert interlinear examples into manuscripts with minimal effort.**

  * It uses the `interlinear` package (or your custom environment named `interlinear`).
  * If no `type` is specified for a context, `[unspecified]` will appear in the LaTeX output.
* **The `context` mode is intended purely for semantic analysis**, not formatting. Therefore, `.tex` export is not available for this mode.
* In the future, support may be added for **Toolbox** (SIL) for both data input and export. If enough users request it, I will consider adding Toolbox-compatible macros or export profiles.

---

## Why Use meanalyseR?

Semantic fieldwork is time-consuming and complex. **meanalyseR** helps researchers:

* Automate repetitive sorting and searching tasks
* Systematize semantic diagnostics
* Quickly identify patterns in large interlinear datasets
* Focus more on interpretation and less on formatting

It’s especially helpful for fieldwork on **under-documented languages**, where structured, replicable analysis is key.

---

## Features Available Now

* Search for the distribution of a gloss or morpheme
* Export of search results in `.txt`, `.csv`, and `.tex` (where applicable)

---

## Upcoming Features

* Sorting data by **minimal pairs** based on linguistic variants
* Sorting data by **contextual variants** (for detecting felicity/infelicity)
* Export options for all sorting functions
* Property-based queries (similar to the **TerraLing** database)
* **Toolbox support** (input/export, depending on user demand)

---

## Contributions & Feedback

You are welcome to open issues, suggest features, or contribute to the code. Let’s make semantic diagnostics faster and more reliable for everyone in the linguistic community.

```

Souhaites-tu également une version courte pour CRAN ou une présentation plus axée utilisateur novice ?
```
